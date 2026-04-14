#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/../.." && pwd)"

run_date="${CNFRP_UPSTREAM_DATE:-$(date +%F)}"
output_dir="${CNFRP_UPSTREAM_OUTPUT_DIR:-${repo_root}/tmp/upstream-watch}"
state_file="${output_dir}/${run_date}-state.env"
impact_file="${output_dir}/${run_date}-impact.txt"
translation_file="${output_dir}/${run_date}-translation.txt"

if [[ ! -f "${state_file}" ]]; then
    "${script_dir}/check_upstream.sh"
fi

# shellcheck disable=SC1090
source "${state_file}"

cd "${repo_root}"

compare_base="${MERGE_BASE_WITH_DEV}"
if [[ -z "${compare_base:-}" ]]; then
    compare_base="$(git merge-base HEAD upstream/dev)"
fi

mapfile -t changed_files < <(git diff --name-only "${compare_base}" upstream/dev)

user_visible=()
frontend=()
docs_release=()
configs=()
high_risk=()

for file in "${changed_files[@]}"; do
    [[ -z "${file}" ]] && continue

    case "${file}" in
        web/package-lock.json|web/*/package-lock.json|web/*/node_modules/*|web/node_modules/*)
            continue
            ;;
    esac

    case "${file}" in
        web/*)
            frontend+=("${file}")
            user_visible+=("${file}")
            ;;
        README.md|README_zh.md|README_en.md|Release.md|doc/*|doc/**/*)
            docs_release+=("${file}")
            user_visible+=("${file}")
            ;;
        conf/*.toml|conf/*.ini|conf/**/*)
            configs+=("${file}")
            user_visible+=("${file}")
            ;;
    esac

    case "${file}" in
        web/*|pkg/*|server/*|client/*|cmd/*|test/*|go.mod|go.sum|package.sh|Makefile|Makefile.cross-compiles|.goreleaser.yml)
            high_risk+=("${file}")
            ;;
    esac
done

sort_unique() {
    if (($# == 0)); then
        return 0
    fi
    printf '%s\n' "$@" | awk '!seen[$0]++'
}

{
    echo "[cnfrp] translation impact summary"
    echo "run_date=${RUN_DATE}"
    echo "compare_base=${compare_base}"
    echo "upstream_dev_head=${UPSTREAM_DEV_HEAD}"
    echo
    echo "[all_changed_files]"
    sort_unique "${changed_files[@]}"
    echo
    echo "[high_risk_files]"
    sort_unique "${high_risk[@]}"
} >> "${impact_file}"

{
    echo "# cnfrp 汉化影响清单"
    echo
    echo "- 日期：${RUN_DATE}"
    echo "- 对比基线：${compare_base}"
    echo "- upstream/dev：${UPSTREAM_DEV_HEAD}"
    echo
    echo "## 1. 需要重点关注的用户可见文件"
    if ((${#user_visible[@]} == 0)); then
        echo "- 本轮未识别到明显用户可见文件"
    else
        sort_unique "${user_visible[@]}" | sed 's/^/- /'
    fi
    echo
    echo "## 2. 前端汉化影响"
    if ((${#frontend[@]} == 0)); then
        echo "- 本轮未命中 web 前端文件"
    else
        sort_unique "${frontend[@]}" | sed 's/^/- /'
    fi
    echo
    echo "## 3. 文档 / Release 影响"
    if ((${#docs_release[@]} == 0)); then
        echo "- 本轮未命中文档或 Release 口径文件"
    else
        sort_unique "${docs_release[@]}" | sed 's/^/- /'
    fi
    echo
    echo "## 4. 配置说明影响"
    if ((${#configs[@]} == 0)); then
        echo "- 本轮未命中配置示例文件"
    else
        sort_unique "${configs[@]}" | sed 's/^/- /'
    fi
    echo
    echo "## 5. 建议动作"
    if ((${#user_visible[@]} == 0)); then
        echo "- 本轮可以先以内核兼容与验证为主，暂不需要额外汉化补齐。"
    else
        echo "- 先在 sync 候选分支验证上游改动。"
        echo "- 再对上述用户可见文件逐项补齐中文口径。"
        echo "- 若命中 web 页面，后续进入 P3 时应继续做字符串精扫。"
    fi
} > "${translation_file}"

echo "[cnfrp] impact file: ${impact_file}"
echo "[cnfrp] translation file: ${translation_file}"
