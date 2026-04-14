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
push_plan_file="${output_dir}/${run_date}-push-plan.md"

mkdir -p "${output_dir}"

refresh_mode="${CNFRP_UPSTREAM_REFRESH:-1}"
if [[ "${refresh_mode}" == "1" || ! -f "${state_file}" ]]; then
    "${script_dir}/check_upstream.sh" >/dev/null
fi

# shellcheck disable=SC1090
source "${state_file}"

cd "${repo_root}"

target_branch="${CNFRP_PUSH_BRANCH:-}"
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

read -r main_only_commits target_only_commits < <(git rev-list --left-right --count "${main_ref}...${target_ref}")
target_diff_files="$(git diff --name-only "${main_ref}...${target_ref}" || true)"
target_diff_count="$(printf '%s\n' "${target_diff_files}" | sed '/^$/d' | wc -l | tr -d ' ')"

remote_status_line() {
    local remote_name="$1"
    local remote_ref="refs/remotes/${remote_name}/main"
    local reachable="yes"
    local remote_head=""
    local local_only="-"
    local remote_only="-"
    local relation="unknown"

    if git ls-remote --heads "${remote_name}" main >/dev/null 2>&1; then
        remote_head="$(git ls-remote --heads "${remote_name}" main | awk 'NR==1 {print $1}')"
    else
        reachable="no"
        relation="unreachable"
    fi

    if [[ "${reachable}" == "yes" ]] && git show-ref --verify --quiet "${remote_ref}"; then
        read -r local_only remote_only < <(git rev-list --left-right --count "${main_ref}...${remote_ref}")
        if [[ "${local_only}" == "0" && "${remote_only}" == "0" ]]; then
            relation="in-sync"
        elif [[ "${local_only}" != "0" && "${remote_only}" == "0" ]]; then
            relation="local-ahead"
        elif [[ "${local_only}" == "0" && "${remote_only}" != "0" ]]; then
            relation="local-behind"
        else
            relation="diverged"
        fi
    fi

    printf '%s|%s|%s|%s|%s|%s\n' "${remote_name}" "${reachable}" "${remote_head}" "${local_only}" "${remote_only}" "${relation}"
}

origin_info="$(remote_status_line origin)"
gitee_info="$(remote_status_line gitee)"

verify_ready="unknown"
build_status="unknown"
test_status="unknown"
web_status="unknown"
preview_status="unknown"
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
fi

origin_relation="$(printf '%s' "${origin_info}" | cut -d'|' -f6)"
gitee_relation="$(printf '%s' "${gitee_info}" | cut -d'|' -f6)"

push_ready="yes"
push_blockers=()
target_state="none"

if [[ "${main_only_commits}" != "0" && "${target_only_commits}" == "0" ]]; then
    target_state="behind-main"
    push_ready="no"
    push_blockers+=("同步候选分支基线已落后当前 main，需先基于最新主线重建候选分支。")
elif [[ "${target_diff_count}" == "0" ]]; then
    target_state="no-diff"
    push_ready="no"
    push_blockers+=("同步候选分支相对 main 还没有实际差异，当前没有可推送的同步内容。")
else
    target_state="has-diff"
fi

if [[ "${verify_ready}" != "yes" ]]; then
    push_ready="no"
    push_blockers+=("同步候选分支缺少完整通过的统一验证结果。")
fi

if [[ "${origin_relation}" == "local-behind" || "${origin_relation}" == "diverged" ]]; then
    push_ready="no"
    push_blockers+=("本地 main 相对 GitHub main 不是可直接推送状态，需先同步远端。")
fi

if [[ "${gitee_relation}" == "local-behind" ]]; then
    push_ready="no"
    push_blockers+=("本地 main 相对 Gitee main 不是可直接推送状态，需先同步远端。")
elif [[ "${gitee_relation}" == "diverged" ]]; then
    push_ready="no"
    push_blockers+=("本地 main 与 Gitee main 已发生分叉，需先审阅并处理差异后再决定是否推送。")
fi

{
    echo "# cnfrp P5 推送准备摘要"
    echo
    echo "- 日期：\`${RUN_DATE}\`"
    echo "- 主工作树：\`${REPO_ROOT}\`"
    echo "- 当前本地主线：\`main\` -> \`$(git rev-parse "${main_ref}")\`"
    echo "- 同步候选分支：\`${target_branch}\` -> \`$(git rev-parse "${target_ref}")\`"
    echo "- 最新官方稳定 tag：\`${LATEST_UPSTREAM_TAG:-none}\`"
    echo "- 当前统一验证：\`${verify_ready}\`"
    echo "- 当前是否建议直接进入推送：\`${push_ready}\`"
    echo "- 当前候选分支状态：\`${target_state}\`"
    echo
    echo "## 1. 同步候选相对 main"
    echo
    echo "- main 独有提交数：\`${main_only_commits}\`"
    echo "- ${target_branch} 独有提交数：\`${target_only_commits}\`"
    echo "- 差异文件数：\`${target_diff_count}\`"
    if [[ "${target_state}" == "behind-main" ]]; then
        echo "- 结论：当前同步候选分支没有承接新内容，且已经落后于最新 main。"
    elif [[ "${target_diff_count}" == "0" ]]; then
        echo "- 结论：当前同步候选分支尚未承接任何实际上游改动。"
    else
        echo "- 主要差异文件："
        printf '%s\n' "${target_diff_files}" | sed '/^$/d' | head -n 20 | while IFS= read -r line; do
            echo "  - \`${line}\`"
        done
    fi
    echo
    echo "## 2. 远端状态"
    echo
    while IFS='|' read -r remote_name reachable remote_head local_only remote_only relation; do
        echo "- ${remote_name}"
        echo "  - 可达：\`${reachable}\`"
        echo "  - 远端 main：\`${remote_head:-unknown}\`"
        echo "  - 本地独有提交数：\`${local_only}\`"
        echo "  - 远端独有提交数：\`${remote_only}\`"
        echo "  - 关系：\`${relation}\`"
    done <<EOF
${origin_info}
${gitee_info}
EOF
    echo
    echo "## 3. 统一验证结果"
    echo
    echo "- build_status：\`${build_status}\`"
    echo "- test_status：\`${test_status}\`"
    echo "- web_status：\`${web_status}\`"
    echo "- preview_status：\`${preview_status}\`"
    echo "- 验证日志：\`${verify_log}\`"
    echo
    echo "## 4. 建议推送顺序"
    echo
    if [[ "${push_ready}" == "yes" ]]; then
        echo "1. 在 Ubuntu 主工作树确认同步候选内容无误。"
        echo "2. 先将同步候选并回 \`main\`。"
        echo "3. 执行 \`git push origin main\`。"
        echo "4. 确认 GitHub 正常后，再执行 \`git push gitee main\`。"
    else
        echo "1. 先处理下方阻塞项，不要直接推送。"
        echo "2. 阻塞项清理后，再重新生成本摘要。"
    fi
    echo
    echo "## 5. 当前阻塞项"
    echo
    if [[ "${#push_blockers[@]}" -eq 0 ]]; then
        echo "- 无。"
    else
        for blocker in "${push_blockers[@]}"; do
            echo "- ${blocker}"
        done
    fi
    echo
    echo "## 6. 一句话结论"
    echo
    if [[ "${push_ready}" == "yes" ]]; then
        echo "当前这轮同步候选已具备进入人工推送确认的条件，但仍需先人工并回 \`main\` 后再按 GitHub -> Gitee 顺序推送。"
    elif [[ "${#push_blockers[@]}" -eq 1 && "${target_state}" == "behind-main" ]]; then
        echo "当前远端主线已经一致，唯一剩余阻塞项是同步候选分支基线过旧；先基于最新 main 重建候选分支。"
    else
        echo "当前还不适合直接推送；先处理本地与远端分叉/落后问题，并确认同步候选已经真正承接上游改动。"
    fi
} > "${push_plan_file}"

echo "[cnfrp] push plan: ${push_plan_file}"
