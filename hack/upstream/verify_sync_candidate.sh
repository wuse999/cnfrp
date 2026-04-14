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
timestamp="${CNFRP_UPSTREAM_TIMESTAMP:-$(date +%F-%H%M%S)}"
output_dir="${CNFRP_UPSTREAM_OUTPUT_DIR:-${repo_root}/tmp/upstream-watch}"
state_file="${output_dir}/${run_date}-state.env"

mkdir -p "${output_dir}"

if [[ ! -f "${state_file}" ]]; then
    "${script_dir}/check_upstream.sh"
fi

# shellcheck disable=SC1090
source "${state_file}"

cd "${repo_root}"

target_branch="${CNFRP_VERIFY_BRANCH:-}"
if [[ -z "${target_branch}" ]]; then
    if [[ -n "${LATEST_UPSTREAM_TAG:-}" ]]; then
        target_branch="sync/upstream-${LATEST_UPSTREAM_TAG}"
    else
        target_branch="$(git branch --show-current)"
    fi
fi

build_log="${output_dir}/${run_date}-build.log"
test_log="${output_dir}/${run_date}-test.log"
web_build_log="${output_dir}/${run_date}-web-build.log"
verify_log="${output_dir}/${run_date}-verify.log"

current_branch="$(git branch --show-current)"
switched_branch="0"
if [[ "${current_branch}" != "${target_branch}" ]]; then
    git switch "${target_branch}"
    switched_branch="1"
fi

restore_branch() {
    if [[ "${switched_branch}" == "1" ]]; then
        git switch "${current_branch}" >/dev/null 2>&1 || true
    fi
}
trap restore_branch EXIT

run_step() {
    local name="$1"
    local logfile="$2"
    shift 2

    {
        echo "[cnfrp] step=${name}"
        echo "[cnfrp] started=$(date '+%F %T %Z')"
        echo "[cnfrp] branch=$(git branch --show-current)"
        echo "[cnfrp] repo=${repo_root}"
        echo
        "$@"
    } > "${logfile}" 2>&1
}

build_status=0
test_status=0
web_status=0
preview_status=0

if run_step "build" "${build_log}" make build; then
    build_status=0
else
    build_status=$?
fi

if run_step "test" "${test_log}" make test; then
    test_status=0
else
    test_status=$?
fi

if run_step "web-build" "${web_build_log}" bash -lc "cd '${repo_root}/web' && npm run build --workspace frps-dashboard && npm run build --workspace frpc-dashboard"; then
    web_status=0
else
    web_status=$?
fi

if run_step "preview-verify" "${verify_log}.preview.tmp" /bin/bash "${repo_root}/tmp/preview/verify-preview-chain.sh"; then
    preview_status=0
else
    preview_status=$?
fi

{
    echo "[cnfrp] verify sync candidate"
    echo "date=${run_date}"
    echo "timestamp=${timestamp}"
    echo "target_branch=${target_branch}"
    echo "current_branch_before=${current_branch}"
    echo "switched_branch=${switched_branch}"
    echo "build_status=${build_status}"
    echo "test_status=${test_status}"
    echo "web_status=${web_status}"
    echo "preview_status=${preview_status}"
    echo "build_log=${build_log}"
    echo "test_log=${test_log}"
    echo "web_build_log=${web_build_log}"
    echo "preview_log=${verify_log}.preview.tmp"
    echo
    echo "[summary]"
    [[ "${build_status}" == "0" ]] && echo "- make build: ok" || echo "- make build: fail"
    [[ "${test_status}" == "0" ]] && echo "- make test: ok" || echo "- make test: fail"
    [[ "${web_status}" == "0" ]] && echo "- web build: ok" || echo "- web build: fail"
    [[ "${preview_status}" == "0" ]] && echo "- preview verify: ok" || echo "- preview verify: fail"
} > "${verify_log}"

cat "${verify_log}.preview.tmp" >> "${verify_log}"
rm -f "${verify_log}.preview.tmp"

if [[ "${build_status}" != "0" || "${test_status}" != "0" || "${web_status}" != "0" || "${preview_status}" != "0" ]]; then
    echo "[cnfrp] verify log: ${verify_log}"
    exit 1
fi

echo "[cnfrp] build log: ${build_log}"
echo "[cnfrp] test log: ${test_log}"
echo "[cnfrp] web build log: ${web_build_log}"
echo "[cnfrp] verify log: ${verify_log}"
