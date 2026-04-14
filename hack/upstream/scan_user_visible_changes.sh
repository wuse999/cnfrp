#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/../.." && pwd)"

run_date="${CNFRP_UPSTREAM_DATE:-$(date +%F)}"
output_dir="${CNFRP_UPSTREAM_OUTPUT_DIR:-${repo_root}/tmp/upstream-watch}"
state_file="${output_dir}/${run_date}-state.env"
ui_file="${output_dir}/${run_date}-ui-strings.txt"
doc_file="${output_dir}/${run_date}-doc-impact.txt"
todo_file="${output_dir}/${run_date}-translation-todo.md"

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

frontend_files=()
doc_files=()
config_files=()

for file in "${changed_files[@]}"; do
    [[ -z "${file}" ]] && continue

    case "${file}" in
        web/package-lock.json|web/*/package-lock.json|web/node_modules/*|web/*/node_modules/*)
            continue
            ;;
    esac

    case "${file}" in
        web/*)
            frontend_files+=("${file}")
            ;;
    esac

    case "${file}" in
        README.md|README_zh.md|README_en.md|Release.md|doc/*)
            doc_files+=("${file}")
            ;;
    esac

    case "${file}" in
        conf/*)
            config_files+=("${file}")
            ;;
    esac
done

sort_unique() {
    if (($# == 0)); then
        return 0
    fi
    printf '%s\n' "$@" | awk '!seen[$0]++'
}

extract_added_lines() {
    local file="$1"
    git diff --unified=0 "${compare_base}" upstream/dev -- "${file}" \
        | awk '
            /^\+\+\+/ {next}
            /^\+/ {
                line = substr($0, 2)
                if (line ~ /^[[:space:]]*$/) next
                print line
            }
        '
}

extract_probable_ui_literals() {
    local file="$1"
    extract_added_lines "${file}" \
        | grep -Ev '^[[:space:]]*(import |export |component:|path:|name:|redirect:|children:|meta:|from |const router|createRouter|\}|\{|\]|\[|return |<|>|router\.|await |async |type |interface )' \
        | grep -E '[[:alpha:]]|[一-龥]' \
        || true
}

{
    echo "# cnfrp 前端用户可见变化扫描"
    echo
    echo "- 日期：${RUN_DATE}"
    echo "- 对比基线：${compare_base}"
    echo "- upstream/dev：${UPSTREAM_DEV_HEAD}"
    echo
    echo "## 1. 命中的前端文件"
    if ((${#frontend_files[@]} == 0)); then
        echo "- 本轮未命中 `web/` 前端文件"
    else
        sort_unique "${frontend_files[@]}" | sed 's/^/- /'
    fi
    echo
    echo "## 2. 疑似用户可见字面量变更"
    if ((${#frontend_files[@]} == 0)); then
        echo "- 本轮无前端字面量变更"
    else
        found_literal=0
        while IFS= read -r file; do
            [[ -z "${file}" ]] && continue
            literals="$(extract_probable_ui_literals "${file}")"
            if [[ -n "${literals}" ]]; then
                found_literal=1
                echo
                echo "### ${file}"
                while IFS= read -r line; do
                    [[ -n "${line}" ]] && echo "- ${line}"
                done <<< "${literals}"
            fi
        done < <(sort_unique "${frontend_files[@]}")

        if [[ "${found_literal}" == "0" ]]; then
            echo "- 本轮前端文件有结构变化，但未识别到明显新增用户可见字面量"
        fi
    fi
} > "${ui_file}"

{
    echo "# cnfrp 文档与配置口径变化扫描"
    echo
    echo "- 日期：${RUN_DATE}"
    echo "- 对比基线：${compare_base}"
    echo
    echo "## 1. 文档 / Release 文件"
    if ((${#doc_files[@]} == 0)); then
        echo "- 本轮未命中文档或 Release 文件"
    else
        sort_unique "${doc_files[@]}" | sed 's/^/- /'
    fi
    echo
    echo "## 2. 配置说明文件"
    if ((${#config_files[@]} == 0)); then
        echo "- 本轮未命中配置示例文件"
    else
        sort_unique "${config_files[@]}" | sed 's/^/- /'
    fi
    echo
    echo "## 3. 关键新增行"
    if ((${#doc_files[@]} == 0 && ${#config_files[@]} == 0)); then
        echo "- 本轮无文档或配置新增行"
    else
        for file in $(sort_unique "${doc_files[@]}" "${config_files[@]}"); do
            echo
            echo "### ${file}"
            added="$(extract_added_lines "${file}")"
            if [[ -z "${added}" ]]; then
                echo "- 本轮无新增行"
            else
                while IFS= read -r line; do
                    [[ -n "${line}" ]] && echo "- ${line}"
                done <<< "${added}"
            fi
        done
    fi
} > "${doc_file}"

{
    echo "# cnfrp 本轮汉化补齐待办"
    echo
    echo "- 日期：${RUN_DATE}"
    echo "- 对比基线：${compare_base}"
    echo
    echo "## 1. 必做项"
    if ((${#doc_files[@]} == 0 && ${#frontend_files[@]} == 0 && ${#config_files[@]} == 0)); then
        echo "- 本轮暂无明显汉化补齐项"
    else
        if ((${#doc_files[@]} > 0)); then
            echo "- 复核并补齐以下文档 / Release 口径："
            sort_unique "${doc_files[@]}" | sed 's/^/  - /'
        fi
        if ((${#frontend_files[@]} > 0)); then
            echo "- 复核以下前端文件是否引入新的用户可见文案或页面行为变化："
            sort_unique "${frontend_files[@]}" | sed 's/^/  - /'
        fi
        if ((${#config_files[@]} > 0)); then
            echo "- 复核以下配置示例是否需要追加中文说明："
            sort_unique "${config_files[@]}" | sed 's/^/  - /'
        fi
    fi
    echo
    echo "## 2. 当前初步判断"
    if ((${#frontend_files[@]} > 0)); then
        echo "- 本轮已命中前端文件，进入同步候选分支后应继续做页面级走查。"
    else
        echo "- 本轮未命中明显前端页面文件，可先以内核验证为主。"
    fi
    if printf '%s\n' "${doc_files[@]}" | grep -qx 'Release.md'; then
        echo "- 本轮 Release.md 已变化，后续需要补齐 cnfrp 中文发布口径。"
    fi
    echo
    echo "## 3. 下一步建议"
    echo "- 先在 sync/upstream-* 候选分支验证上游改动。"
    echo "- 再根据本清单补齐中文文案、Release 说明和必要的术语表。"
} > "${todo_file}"

echo "[cnfrp] ui file: ${ui_file}"
echo "[cnfrp] doc file: ${doc_file}"
echo "[cnfrp] todo file: ${todo_file}"
