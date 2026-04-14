#!/usr/bin/env bash

set -euo pipefail

OWNER="${GITEE_OWNER:-frpnat}"
REPO="${GITEE_REPO:-cnfrp}"
TAG="${1:-v0.68.0-cnfrp.1}"
TARGET_COMMITISH="${TARGET_COMMITISH:-main}"
PACKAGES_DIR="${PACKAGES_DIR:-release/packages}"
BODY_FILE="${BODY_FILE:-Release.md}"
TMP_DIR="${TMP_DIR:-tmp/gitee-release}"
CHECKSUM_FILE_NAME="${CHECKSUM_FILE_NAME:-cnfrp_sha256_checksums.txt}"
CHECKSUM_FILE_PATH="${TMP_DIR}/${CHECKSUM_FILE_NAME}"
API_BASE="https://gitee.com/api/v5/repos/${OWNER}/${REPO}"

if [[ -z "${GITEE_TOKEN:-}" ]]; then
  echo "GITEE_TOKEN is required" >&2
  exit 1
fi

if [[ ! -d "${PACKAGES_DIR}" ]]; then
  echo "packages directory not found: ${PACKAGES_DIR}" >&2
  exit 1
fi

if [[ ! -f "${BODY_FILE}" ]]; then
  echo "release body file not found: ${BODY_FILE}" >&2
  exit 1
fi

mkdir -p "${TMP_DIR}"

release_name="cnfrp ${TAG}"

generate_checksums() {
  (
    cd "${PACKAGES_DIR}"
    sha256sum ./* | sed 's# \*\./#  #; s# \./#  #'
  ) > "${CHECKSUM_FILE_PATH}"
}

api_get() {
  local url="$1"
  curl --silent --show-error --fail \
    --get \
    --data-urlencode "access_token=${GITEE_TOKEN}" \
    "${url}"
}

api_post_release() {
  curl --silent --show-error --fail \
    -X POST \
    --data-urlencode "access_token=${GITEE_TOKEN}" \
    --data-urlencode "tag_name=${TAG}" \
    --data-urlencode "target_commitish=${TARGET_COMMITISH}" \
    --data-urlencode "name=${release_name}" \
    --data-urlencode "body@${BODY_FILE}" \
    "${API_BASE}/releases"
}

api_post_asset() {
  local release_id="$1"
  local file_path="$2"
  curl --silent --show-error --fail \
    -X POST \
    -F "access_token=${GITEE_TOKEN}" \
    -F "file=@${file_path}" \
    "${API_BASE}/releases/${release_id}/attach_files"
}

get_existing_release_id() {
  python3 - "$OWNER" "$REPO" "$TAG" "$GITEE_TOKEN" <<'PY'
import json
import sys
import urllib.parse
import urllib.request

owner, repo, tag, token = sys.argv[1:]
params = urllib.parse.urlencode({"access_token": token})
url = f"https://gitee.com/api/v5/repos/{owner}/{repo}/releases?{params}"

with urllib.request.urlopen(url) as response:
    data = json.load(response)

for item in data:
    if item.get("tag_name") == tag:
        print(item["id"])
        raise SystemExit(0)

raise SystemExit(1)
PY
}

extract_release_id() {
  python3 - "$TAG" <<'PY'
import json
import sys

tag = sys.argv[1]
data = json.load(sys.stdin)

if isinstance(data, list):
    for item in data:
        if item.get("tag_name") == tag:
            print(item["id"])
            raise SystemExit(0)
    raise SystemExit(1)

if isinstance(data, dict) and "id" in data:
    print(data["id"])
    raise SystemExit(0)

raise SystemExit(1)
PY
}

list_existing_asset_names() {
  local release_id="$1"
  python3 - "$OWNER" "$REPO" "$release_id" "$GITEE_TOKEN" <<'PY'
import json
import sys
import urllib.parse
import urllib.request

owner, repo, release_id, token = sys.argv[1:]
params = urllib.parse.urlencode({"access_token": token, "per_page": "100"})
url = f"https://gitee.com/api/v5/repos/{owner}/{repo}/releases/{release_id}/attach_files?{params}"

with urllib.request.urlopen(url) as response:
    data = json.load(response)

for item in data:
    name = item.get("name")
    if name:
        print(name)
PY
}

ensure_release() {
  local release_id
  if release_id="$(get_existing_release_id 2>/dev/null)"; then
    echo "${release_id}"
    return 0
  fi

  if release_id="$(api_post_release | extract_release_id 2>/dev/null)"; then
    echo "${release_id}"
    return 0
  fi

  get_existing_release_id
}

upload_missing_assets() {
  local release_id="$1"
  mapfile -t existing_assets < <(list_existing_asset_names "${release_id}" || true)

  local files_to_upload=("${CHECKSUM_FILE_PATH}")
  while IFS= read -r file_path; do
    files_to_upload+=("${file_path}")
  done < <(find "${PACKAGES_DIR}" -maxdepth 1 -type f | sort)

  for file_path in "${files_to_upload[@]}"; do
    local file_name
    file_name="$(basename "${file_path}")"

    if printf '%s\n' "${existing_assets[@]:-}" | grep -Fxq "${file_name}"; then
      echo "skip existing asset: ${file_name}"
      continue
    fi

    echo "upload asset: ${file_name}"
    api_post_asset "${release_id}" "${file_path}" > /dev/null
  done
}

main() {
  echo "prepare checksum file..."
  generate_checksums

  echo "ensure release for ${TAG}..."
  local release_id
  release_id="$(ensure_release)"
  echo "release_id=${release_id}"

  echo "upload missing assets..."
  upload_missing_assets "${release_id}"

  echo "done"
}

main "$@"
