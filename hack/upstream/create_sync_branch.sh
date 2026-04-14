#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/../.." && pwd)"

run_date="${CNFRP_UPSTREAM_DATE:-$(date +%F)}"
output_dir="${CNFRP_UPSTREAM_OUTPUT_DIR:-${repo_root}/tmp/upstream-watch}"
state_file="${output_dir}/${run_date}-state.env"
impact_file="${output_dir}/${run_date}-impact.txt"

if [[ ! -f "${state_file}" ]]; then
    "${script_dir}/check_upstream.sh"
fi

# shellcheck disable=SC1090
source "${state_file}"

cd "${repo_root}"

base_ref="${CNFRP_SYNC_BASE_REF:-main}"
checkout_mode="${CNFRP_SYNC_CHECKOUT:-0}"
rebuild_mode="${CNFRP_SYNC_REBUILD_EXISTING:-1}"

if git show-ref --verify --quiet "refs/heads/${base_ref}"; then
    base_commit="$(git rev-parse "${base_ref}")"
else
    echo "[cnfrp] base ref not found: ${base_ref}" >&2
    exit 1
fi

if [[ -n "${LATEST_UPSTREAM_TAG:-}" ]]; then
    branch_name="sync/upstream-${LATEST_UPSTREAM_TAG}"
else
    branch_name="sync/upstream-${RUN_DATE}"
fi

branch_status="created"
branch_local_only="0"
branch_base_only="0"
if git show-ref --verify --quiet "refs/heads/${branch_name}"; then
    existing_commit="$(git rev-parse "${branch_name}")"
    if [[ "${existing_commit}" == "${base_commit}" ]]; then
        branch_status="exists"
    else
        read -r branch_local_only branch_base_only < <(git rev-list --left-right --count "refs/heads/${branch_name}...refs/heads/${base_ref}")
        if [[ "${rebuild_mode}" == "1" && "${branch_local_only}" == "0" && "${branch_base_only}" != "0" ]]; then
            git branch -f "${branch_name}" "${base_ref}"
            existing_commit="$(git rev-parse "${branch_name}")"
            branch_status="rebuilt-from-base"
            branch_local_only="0"
            branch_base_only="0"
        else
            branch_status="exists-different-head"
        fi
    fi
else
    git branch "${branch_name}" "${base_ref}"
fi

if [[ "${checkout_mode}" == "1" ]]; then
    git switch "${branch_name}"
fi

{
    echo "[cnfrp] sync candidate branch"
    echo "run_date=${RUN_DATE}"
    echo "base_ref=${base_ref}"
    echo "base_commit=${base_commit}"
    echo "branch_name=${branch_name}"
    echo "branch_status=${branch_status}"
    echo "checkout_mode=${checkout_mode}"
    echo "rebuild_mode=${rebuild_mode}"
    echo "branch_local_only=${branch_local_only}"
    echo "branch_base_only=${branch_base_only}"
    echo "latest_upstream_tag=${LATEST_UPSTREAM_TAG:-none}"
    echo "upstream_dev_head=${UPSTREAM_DEV_HEAD}"
    echo "head_behind_dev=${HEAD_BEHIND_DEV}"
    echo "head_behind_tag=${HEAD_BEHIND_TAG:-}"
} > "${impact_file}"

echo "[cnfrp] sync branch file: ${impact_file}"
echo "[cnfrp] branch name: ${branch_name}"
echo "[cnfrp] branch status: ${branch_status}"
