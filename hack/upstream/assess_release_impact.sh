#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/../.." && pwd)"

if [[ -f "${HOME}/.profile" ]]; then
    # shellcheck disable=SC1090
    . "${HOME}/.profile"
fi

export PATH="/usr/local/go/bin:${HOME}/.local/bin:${HOME}/bin:/usr/local/bin:/usr/bin:/bin:${PATH:-}"

run_date="${CNFRP_UPSTREAM_DATE:-$(date +%F)}"
output_dir="${CNFRP_UPSTREAM_OUTPUT_DIR:-${repo_root}/tmp/upstream-watch}"
state_file="${output_dir}/${run_date}-state.env"
verify_log="${output_dir}/${run_date}-verify.log"
release_impact_file="${output_dir}/${run_date}-release-impact.md"

mkdir -p "${output_dir}"

refresh_mode="${CNFRP_UPSTREAM_REFRESH:-1}"
if [[ "${refresh_mode}" == "1" || ! -f "${state_file}" ]]; then
    "${script_dir}/check_upstream.sh" >/dev/null
fi

# shellcheck disable=SC1090
source "${state_file}"

cd "${repo_root}"

target_branch="${CNFRP_RELEASE_BRANCH:-}"
if [[ -z "${target_branch}" ]]; then
    if [[ -n "${LATEST_UPSTREAM_TAG:-}" ]]; then
        target_branch="sync/upstream-${LATEST_UPSTREAM_TAG}"
    else
        target_branch="main"
    fi
fi

main_ref="refs/heads/main"
target_ref="refs/heads/${target_branch}"

if ! git show-ref --verify --quiet "${main_ref}"; then
    echo "[cnfrp] missing local main branch" >&2
    exit 1
fi

if ! git show-ref --verify --quiet "${target_ref}"; then
    echo "[cnfrp] target branch not found: ${target_branch}" >&2
    exit 1
fi

current_version="$(sed -n 's/^var version = "\(.*\)"$/\1/p' "${repo_root}/pkg/util/version/version.go" | head -n1)"
read -r main_only_commits target_only_commits < <(git rev-list --left-right --count "${main_ref}...${target_ref}")
diff_files="$(git diff --name-only "${main_ref}...${target_ref}" || true)"
diff_count="$(printf '%s\n' "${diff_files}" | sed '/^$/d' | wc -l | tr -d ' ')"
target_state="none"

doc_changed="no"
web_changed="no"
go_changed="no"
build_changed="no"
conf_changed="no"

while IFS= read -r file; do
    [[ -z "${file}" ]] && continue
    case "${file}" in
        README.md|README_zh.md|README_en.md|Release.md|*.md)
            doc_changed="yes"
            ;;
    esac
    case "${file}" in
        web/*)
            web_changed="yes"
            ;;
    esac
    case "${file}" in
        *.go|cmd/*|pkg/*|server/*|client/*)
            go_changed="yes"
            ;;
    esac
    case "${file}" in
        .goreleaser.yml|Makefile|package.sh|.github/workflows/*|doc/agents/release.md)
            build_changed="yes"
            ;;
    esac
    case "${file}" in
        conf/*)
            conf_changed="yes"
            ;;
    esac
done <<< "${diff_files}"

verify_ready="unknown"
if [[ -f "${verify_log}" ]]; then
    build_status="$(grep '^build_status=' "${verify_log}" | tail -n1 | cut -d= -f2 || true)"
    test_status="$(grep '^test_status=' "${verify_log}" | tail -n1 | cut -d= -f2 || true)"
    web_status="$(grep '^web_status=' "${verify_log}" | tail -n1 | cut -d= -f2 || true)"
    preview_status="$(grep '^preview_status=' "${verify_log}" | tail -n1 | cut -d= -f2 || true)"
    if [[ "${build_status}" == "0" && "${test_status}" == "0" && "${web_status}" == "0" && "${preview_status}" == "0" ]]; then
        verify_ready="yes"
    else
        verify_ready="no"
    fi
else
    build_status="unknown"
    test_status="unknown"
    web_status="unknown"
    preview_status="unknown"
fi

origin_local_only="$(git rev-list --left-only --count "${main_ref}...refs/remotes/origin/main" 2>/dev/null || echo 0)"
origin_remote_only="$(git rev-list --right-only --count "${main_ref}...refs/remotes/origin/main" 2>/dev/null || echo 0)"
gitee_local_only="$(git rev-list --left-only --count "${main_ref}...refs/remotes/gitee/main" 2>/dev/null || echo 0)"
gitee_remote_only="$(git rev-list --right-only --count "${main_ref}...refs/remotes/gitee/main" 2>/dev/null || echo 0)"

if [[ "${main_only_commits}" != "0" && "${target_only_commits}" == "0" ]]; then
    target_state="behind-main"
elif [[ "${diff_count}" == "0" ]]; then
    target_state="no-diff"
else
    target_state="has-diff"
fi

release_now="no"
deploy_now="no"
release_md_now="no"
release_blockers=()

if [[ "${target_state}" == "behind-main" ]]; then
    release_blockers+=("同步候选分支基线已落后当前 main，需先基于最新主线重建候选分支。")
elif [[ "${diff_count}" == "0" ]]; then
    release_blockers+=("同步候选分支相对 main 没有实际差异，本轮还没有形成可发布内容。")
else
    if [[ "${verify_ready}" == "yes" ]]; then
        release_now="yes"
    else
        release_blockers+=("统一验证尚未完整通过。")
    fi
fi

if [[ "${doc_changed}" == "yes" || "${LATEST_UPSTREAM_TAG:-}" != "" ]]; then
    release_md_now="yes"
fi

if [[ "${release_now}" == "yes" && ( "${go_changed}" == "yes" || "${build_changed}" == "yes" || "${conf_changed}" == "yes" ) ]]; then
    deploy_now="yes"
fi

if [[ "${origin_remote_only}" != "0" ]]; then
    release_now="no"
    deploy_now="no"
    release_blockers+=("本地 main 落后 GitHub main，需要先同步远端主线。")
fi

if [[ "${gitee_remote_only}" != "0" && "${gitee_local_only}" == "0" ]]; then
    release_now="no"
    deploy_now="no"
    release_blockers+=("本地 main 落后 Gitee main，需要先同步远端主线。")
elif [[ "${gitee_remote_only}" != "0" && "${gitee_local_only}" != "0" ]]; then
    release_now="no"
    deploy_now="no"
    release_blockers+=("本地 main 与 Gitee main 已发生分叉，需要先人工审阅并处理差异。")
fi

{
    echo "# cnfrp P5 release 影响判断"
    echo
    echo "- 日期：\`${RUN_DATE}\`"
    echo "- 当前 cnfrp 版本：\`${current_version:-unknown}\`"
    echo "- 最新官方稳定 tag：\`${LATEST_UPSTREAM_TAG:-none}\`"
    echo "- 评估分支：\`${target_branch}\`"
    echo "- 当前是否建议直接发 release：\`${release_now}\`"
    echo "- 当前是否建议部署香港服务器：\`${deploy_now}\`"
    echo "- 当前候选分支状态：\`${target_state}\`"
    echo
    echo "## 1. 候选分支变化概况"
    echo
    echo "- main 独有提交数：\`${main_only_commits}\`"
    echo "- ${target_branch} 独有提交数：\`${target_only_commits}\`"
    echo "- 差异文件数：\`${diff_count}\`"
    echo "- 文档面变化：\`${doc_changed}\`"
    echo "- Web 面变化：\`${web_changed}\`"
    echo "- Go / 内核面变化：\`${go_changed}\`"
    echo "- 构建发布面变化：\`${build_changed}\`"
    echo "- 配置面变化：\`${conf_changed}\`"
    echo
    echo "## 2. 验证状态"
    echo
    echo "- build_status：\`${build_status}\`"
    echo "- test_status：\`${test_status}\`"
    echo "- web_status：\`${web_status}\`"
    echo "- preview_status：\`${preview_status}\`"
    echo "- 统一验证是否通过：\`${verify_ready}\`"
    echo
    echo "## 3. release 口径判断"
    echo
    echo "- 是否需要更新 \`Release.md\`：\`${release_md_now}\`"
    if [[ -n "${LATEST_UPSTREAM_TAG:-}" ]]; then
        echo "- 说明：官方稳定基线已出现 \`${LATEST_UPSTREAM_TAG}\`，后续一旦真正并入同步内容，应同步收口发布说明。"
    fi
    if [[ "${target_state}" == "behind-main" ]]; then
        echo "- 当前结论：虽然上游已有新 tag，但同步候选分支仍停留在旧主线基线，需先重建候选分支。"
    elif [[ "${diff_count}" == "0" ]]; then
        echo "- 当前结论：虽然上游已有新 tag，但同步候选分支尚未承接实际代码/文档差异，因此本轮还不具备正式 release 条件。"
    fi
    echo
    echo "## 4. 远端阻塞"
    echo
    echo "- GitHub main 本地独有提交数：\`${origin_local_only}\`"
    echo "- GitHub main 远端独有提交数：\`${origin_remote_only}\`"
    echo "- Gitee main 本地独有提交数：\`${gitee_local_only}\`"
    echo "- Gitee main 远端独有提交数：\`${gitee_remote_only}\`"
    echo
    echo "## 5. 当前阻塞项"
    echo
    if [[ "${#release_blockers[@]}" -eq 0 ]]; then
        echo "- 无。"
    else
        for blocker in "${release_blockers[@]}"; do
            echo "- ${blocker}"
        done
    fi
    echo
    echo "## 6. 下一步建议"
    echo
    if [[ "${release_now}" == "yes" ]]; then
        echo "1. 在 Ubuntu 主工作树确认同步候选改动、版本口径与 Release 内容。"
        echo "2. 将 \`${target_branch}\` 并回 \`main\`。"
        echo "3. 推送 GitHub / Gitee，并按正式版本流程决定是否部署香港服务器。"
    elif [[ "${origin_remote_only}" != "0" ]]; then
        echo "1. 先同步并审阅 GitHub main 上领先于本地 main 的变更。"
        echo "2. 再处理 Gitee 分歧与同步候选重建。"
        echo "3. 差异形成后，重新执行 P4 验证与 P5 评估。"
    elif [[ "${gitee_remote_only}" != "0" && "${gitee_local_only}" != "0" ]]; then
        echo "1. 先处理 Gitee 上的分歧提交，明确是否吸收或覆盖。"
        echo "2. 再基于最新 main 重建 \`${target_branch}\`。"
        echo "3. 差异形成后，重新执行 P4 验证与 P5 评估。"
    else
        echo "1. 先让 \`${target_branch}\` 真正承接 \`${LATEST_UPSTREAM_TAG:-upstream}\` 的实际同步内容。"
        echo "2. 差异形成后，重新执行 P4 验证与 P5 评估。"
        echo "3. release 条件满足后，再决定是否推进正式发布与部署。"
    fi
    echo
    echo "## 7. 一句话结论"
    echo
    if [[ "${release_now}" == "yes" ]]; then
        echo "当前这轮同步候选已经达到进入正式 release 决策的条件，如人工确认无误，可并回 main 并推进发布与部署。"
    elif [[ "${#release_blockers[@]}" -eq 1 && "${target_state}" == "behind-main" ]]; then
        echo "当前这轮还不应直接发 cnfrp release，也不应触发香港服务器部署；唯一剩余前置问题是同步候选分支基线过旧。"
    else
        echo "当前这轮还不应直接发 cnfrp release，也不应触发香港服务器部署；先解决当前阻塞项后再进入正式发布判断。"
    fi
} > "${release_impact_file}"

echo "[cnfrp] release impact: ${release_impact_file}"
