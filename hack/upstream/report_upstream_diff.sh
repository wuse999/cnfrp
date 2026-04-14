#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/../.." && pwd)"

run_date="${CNFRP_UPSTREAM_DATE:-$(date +%F)}"
output_dir="${CNFRP_UPSTREAM_OUTPUT_DIR:-${repo_root}/tmp/upstream-watch}"
summary_file="${output_dir}/${run_date}-summary.md"
diff_file="${output_dir}/${run_date}-diff.txt"
state_file="${output_dir}/${run_date}-state.env"

mkdir -p "${output_dir}"

if [[ ! -f "${state_file}" ]]; then
    "${script_dir}/check_upstream.sh"
fi

# shellcheck disable=SC1090
source "${state_file}"

cd "${repo_root}"

recent_commit_count="${CNFRP_UPSTREAM_RECENT_COMMITS:-10}"
recent_window="${CNFRP_UPSTREAM_RECENT_WINDOW:-20}"

tmp_dirs_file="$(mktemp)"
trap 'rm -f "${tmp_dirs_file}"' EXIT

window_base_commit="$(
    git rev-list --max-count="${recent_window}" upstream/dev | tail -n 1 || true
)"
if [[ -z "${window_base_commit}" ]]; then
    window_base_commit="${UPSTREAM_DEV_HEAD}"
fi

git diff --name-only "${window_base_commit}" upstream/dev \
    | awk -F/ 'NF {print $1}' \
    | sort -u > "${tmp_dirs_file}"

high_risk_hits="$(
    grep -E '^(web|cmd|server|client|pkg|conf|test|go.mod|go.sum|Makefile|Makefile.cross-compiles|package.sh|\.goreleaser\.yml|\.github)$' "${tmp_dirs_file}" \
        || true
)"

risk_level="low"
if [[ -n "${high_risk_hits}" ]]; then
    risk_level="high"
elif [[ -s "${tmp_dirs_file}" ]]; then
    risk_level="medium"
fi

next_action="仅记录即可，继续观察上游。"
if [[ -n "${LATEST_UPSTREAM_TAG}" && "${HEAD_BEHIND_TAG:-}" != "" && "${HEAD_BEHIND_TAG}" != "0" ]]; then
    next_action="上游稳定 tag 已领先当前主线，建议准备 sync/upstream-${LATEST_UPSTREAM_TAG} 候选分支。"
elif [[ "${HEAD_BEHIND_DEV}" != "0" ]]; then
    next_action="upstream/dev 已领先当前主线，建议先看高风险目录和最近提交，再决定是否创建同步候选分支。"
fi

{
    echo "# cnfrp 上游日更摘要"
    echo
    echo "- 日期：\`${RUN_DATE}\`"
    echo "- 当前分支：\`${CURRENT_BRANCH}\`"
    echo "- 当前主线提交：\`${CURRENT_HEAD}\`"
    echo "- GitHub main：\`${ORIGIN_MAIN_HEAD}\`"
    echo "- Gitee main：\`${GITEE_MAIN_HEAD}\`"
    echo "- upstream/dev：\`${UPSTREAM_DEV_HEAD}\`"
    echo "- 最新官方稳定 tag：\`${LATEST_UPSTREAM_TAG:-none}\`"
    echo "- 当前风险级别：\`${risk_level}\`"
    echo
    echo "## 1. 当前相对 upstream/dev"
    echo
    echo "- 当前主线领先 upstream/dev：\`${HEAD_AHEAD_DEV}\` 提交"
    echo "- 当前主线落后 upstream/dev：\`${HEAD_BEHIND_DEV}\` 提交"
    echo "- 当前 merge-base：\`${MERGE_BASE_WITH_DEV}\`"
    echo
    echo "## 2. 当前相对最新官方 tag"
    echo
    if [[ -n "${LATEST_UPSTREAM_TAG}" ]]; then
        echo "- 最新官方 tag：\`${LATEST_UPSTREAM_TAG}\`"
        echo "- 当前主线领先该 tag：\`${HEAD_AHEAD_TAG:-0}\` 提交"
        echo "- 当前主线落后该 tag：\`${HEAD_BEHIND_TAG:-0}\` 提交"
        echo "- 当前 merge-base：\`${MERGE_BASE_WITH_TAG:-none}\`"
    else
        echo "- 未识别到官方稳定 tag"
    fi
    echo
    echo "## 3. 最近 ${recent_window} 个 upstream/dev 提交命中的顶层目录"
    echo
    if [[ -s "${tmp_dirs_file}" ]]; then
        while IFS= read -r line; do
            echo "- \`${line}\`"
        done < "${tmp_dirs_file}"
    else
        echo "- 无目录变更记录"
    fi
    echo
    echo "## 4. 高风险目录命中"
    echo
    if [[ -n "${high_risk_hits}" ]]; then
        while IFS= read -r line; do
            [[ -n "${line}" ]] && echo "- \`${line}\`"
        done <<< "${high_risk_hits}"
    else
        echo "- 本轮未命中高风险目录"
    fi
    echo
    echo "## 5. 建议动作"
    echo
    echo "- ${next_action}"
    echo
    echo "## 6. upstream/dev 最近 ${recent_commit_count} 条提交"
    echo
    git log --oneline --no-decorate -n "${recent_commit_count}" upstream/dev | sed 's/^/- `/; s/$/`/'
} > "${summary_file}"

{
    echo "[cnfrp] run date: ${RUN_DATE}"
    echo "[cnfrp] current branch: ${CURRENT_BRANCH}"
    echo "[cnfrp] current head: ${CURRENT_HEAD}"
    echo "[cnfrp] upstream/dev: ${UPSTREAM_DEV_HEAD}"
    echo "[cnfrp] latest upstream tag: ${LATEST_UPSTREAM_TAG:-none}"
    echo "[cnfrp] recent window base: ${window_base_commit}"
    echo
    echo "=== upstream/dev recent ${recent_commit_count} commits ==="
    git log --oneline --decorate -n "${recent_commit_count}" upstream/dev
    echo
    echo "=== changed files in ${window_base_commit}..upstream/dev ==="
    git diff --name-only "${window_base_commit}" upstream/dev
    echo
    if [[ -n "${LATEST_UPSTREAM_TAG}" ]]; then
        echo "=== commits in ${LATEST_UPSTREAM_TAG}..upstream/dev (latest ${recent_commit_count}) ==="
        git log --oneline --decorate -n "${recent_commit_count}" "${LATEST_UPSTREAM_TAG}"..upstream/dev
        echo
    fi
    echo "=== head...upstream/dev summary ==="
    git log --oneline --left-right HEAD...upstream/dev | sed -n "1,${recent_commit_count}p"
} > "${diff_file}"

echo "[cnfrp] summary file: ${summary_file}"
echo "[cnfrp] diff file: ${diff_file}"
