#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/../.." && pwd)"

export PATH="/usr/local/bin:/usr/bin:/bin"

run_date="${CNFRP_UPSTREAM_DATE:-$(date +%F)}"
timestamp="${CNFRP_UPSTREAM_TIMESTAMP:-$(date +%F-%H%M%S)}"
output_dir="${CNFRP_UPSTREAM_OUTPUT_DIR:-${repo_root}/tmp/upstream-watch}"
run_log="${output_dir}/${run_date}-run.log"
lock_file="${output_dir}/.daily-watch.lock"

mkdir -p "${output_dir}"

exec 9>"${lock_file}"
if ! flock -n 9; then
    {
        echo "[cnfrp] ${timestamp} daily watch skipped"
        echo "[cnfrp] reason: another upstream watch run is still in progress"
    } >> "${run_log}"
    exit 0
fi

{
    echo "[cnfrp] ${timestamp} daily watch started"
    echo "[cnfrp] repo root: ${repo_root}"
    echo "[cnfrp] output dir: ${output_dir}"
    echo "[cnfrp] current branch: $(cd "${repo_root}" && git branch --show-current || true)"
    echo

    CNFRP_UPSTREAM_DATE="${run_date}" \
    CNFRP_UPSTREAM_TIMESTAMP="${timestamp}" \
    CNFRP_UPSTREAM_OUTPUT_DIR="${output_dir}" \
        "${script_dir}/check_upstream.sh"

    echo

    CNFRP_UPSTREAM_DATE="${run_date}" \
    CNFRP_UPSTREAM_TIMESTAMP="${timestamp}" \
    CNFRP_UPSTREAM_OUTPUT_DIR="${output_dir}" \
        "${script_dir}/report_upstream_diff.sh"

    echo
    echo "[cnfrp] ${timestamp} daily watch completed"
} >> "${run_log}" 2>&1
