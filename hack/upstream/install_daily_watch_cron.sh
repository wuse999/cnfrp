#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/../.." && pwd)"

cron_minute="${CNFRP_UPSTREAM_CRON_MINUTE:-5}"
cron_hour="${CNFRP_UPSTREAM_CRON_HOUR:-9}"

begin_marker="# >>> cnfrp upstream daily watch >>>"
end_marker="# <<< cnfrp upstream daily watch <<<"

new_block="$(cat <<EOF
${begin_marker}
MAILTO=""
SHELL=/bin/bash
PATH=/usr/local/bin:/usr/bin:/bin
${cron_minute} ${cron_hour} * * * /bin/bash ${repo_root}/hack/upstream/run_daily_watch.sh
${end_marker}
EOF
)"

current_crontab="$(mktemp)"
next_crontab="$(mktemp)"
trap 'rm -f "${current_crontab}" "${next_crontab}"' EXIT

crontab -l 2>/dev/null > "${current_crontab}" || true

awk -v begin="${begin_marker}" -v end="${end_marker}" '
    $0 == begin {skip=1; next}
    $0 == end {skip=0; next}
    !skip {print}
' "${current_crontab}" > "${next_crontab}"

if [[ -s "${next_crontab}" && "$(tail -c 1 "${next_crontab}" || true)" != "" ]]; then
    printf '\n' >> "${next_crontab}"
fi

printf '%s\n' "${new_block}" >> "${next_crontab}"

crontab "${next_crontab}"

echo "[cnfrp] installed upstream daily watch cron"
echo "[cnfrp] schedule: ${cron_hour}:${cron_minute} daily"
crontab -l
