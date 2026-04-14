#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/../.." && pwd)"

run_date="${CNFRP_UPSTREAM_DATE:-$(date +%F)}"
timestamp="${CNFRP_UPSTREAM_TIMESTAMP:-$(date +%F-%H%M%S)}"
output_dir="${CNFRP_UPSTREAM_OUTPUT_DIR:-${repo_root}/tmp/upstream-watch}"

fetch_log="${output_dir}/${run_date}-fetch.log"
refs_file="${output_dir}/${run_date}-refs.txt"
state_file="${output_dir}/${run_date}-state.env"

mkdir -p "${output_dir}"

cd "${repo_root}"

{
    echo "[cnfrp] upstream check started at ${timestamp}"
    echo "[cnfrp] repo root: ${repo_root}"
    echo "[cnfrp] output dir: ${output_dir}"
    echo "[cnfrp] branch: $(git branch --show-current || true)"
    echo
    echo "[cnfrp] remotes"
    git remote -v
    echo
    echo "[cnfrp] fetch upstream --tags --prune"
    git fetch upstream --tags --prune
    echo
    echo "[cnfrp] fetch origin --prune"
    git fetch origin --prune
    echo
    echo "[cnfrp] fetch gitee --prune"
    git fetch gitee --prune
} | tee "${fetch_log}"

latest_upstream_tag="$(
    git tag --list 'v*' \
        | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' \
        | sort -V \
        | tail -n 1 \
        || true
)"

current_branch="$(git branch --show-current || true)"
current_head="$(git rev-parse HEAD)"
origin_main_head="$(git rev-parse origin/main)"
gitee_main_head="$(git rev-parse gitee/main)"
upstream_dev_head="$(git rev-parse upstream/dev)"
merge_base_with_dev="$(git merge-base HEAD upstream/dev)"

read -r head_ahead_dev head_behind_dev < <(git rev-list --left-right --count HEAD...upstream/dev)

tag_head=""
merge_base_with_tag=""
head_ahead_tag=""
head_behind_tag=""
if [[ -n "${latest_upstream_tag}" ]]; then
    tag_head="$(git rev-parse "${latest_upstream_tag}")"
    merge_base_with_tag="$(git merge-base HEAD "${latest_upstream_tag}")"
    read -r head_ahead_tag head_behind_tag < <(git rev-list --left-right --count HEAD..."${latest_upstream_tag}")
fi

cat > "${refs_file}" <<EOF
run_date=${run_date}
timestamp=${timestamp}
current_branch=${current_branch}
current_head=${current_head}
origin_main_head=${origin_main_head}
gitee_main_head=${gitee_main_head}
upstream_dev_head=${upstream_dev_head}
merge_base_with_dev=${merge_base_with_dev}
head_ahead_dev=${head_ahead_dev}
head_behind_dev=${head_behind_dev}
latest_upstream_tag=${latest_upstream_tag}
tag_head=${tag_head}
merge_base_with_tag=${merge_base_with_tag}
head_ahead_tag=${head_ahead_tag}
head_behind_tag=${head_behind_tag}
EOF

cat > "${state_file}" <<EOF
RUN_DATE='${run_date}'
TIMESTAMP='${timestamp}'
REPO_ROOT='${repo_root}'
OUTPUT_DIR='${output_dir}'
FETCH_LOG='${fetch_log}'
REFS_FILE='${refs_file}'
CURRENT_BRANCH='${current_branch}'
CURRENT_HEAD='${current_head}'
ORIGIN_MAIN_HEAD='${origin_main_head}'
GITEE_MAIN_HEAD='${gitee_main_head}'
UPSTREAM_DEV_HEAD='${upstream_dev_head}'
MERGE_BASE_WITH_DEV='${merge_base_with_dev}'
HEAD_AHEAD_DEV='${head_ahead_dev}'
HEAD_BEHIND_DEV='${head_behind_dev}'
LATEST_UPSTREAM_TAG='${latest_upstream_tag}'
TAG_HEAD='${tag_head}'
MERGE_BASE_WITH_TAG='${merge_base_with_tag}'
HEAD_AHEAD_TAG='${head_ahead_tag}'
HEAD_BEHIND_TAG='${head_behind_tag}'
EOF

echo "[cnfrp] fetch log: ${fetch_log}"
echo "[cnfrp] refs file: ${refs_file}"
echo "[cnfrp] state file: ${state_file}"
