# Release Process

## 1. Release Positioning

Current `cnfrp` release strategy:

- GitHub is the primary release source
- Gitee is the mirror repository
- Release archives use the `cnfrp` package prefix
- Binary names remain `frpc` and `frps` for compatibility

Current first stable target:

- version: `v0.68.1-cnfrp.1`
- branch: `main`
- purpose: first stable release based on the completed Chinese UI and release-chain closure

## 2. Update Release Notes

Edit `Release.md` in the project root before each release, and keep `download/README.md` aligned with the actual download entry.

Recommended minimum fields:

```markdown
## 版本信息
- 项目：cnfrp
- 版本：v0.68.1-cnfrp.1
- 发布类型：Stable

## 本次重点
- ...

## 主要变更
### 1. 仓库入口与文档
- ...
```

This file is used by GoReleaser as the GitHub Release body.

The download page should keep at least:

- the current stable tag
- the GitHub Release URL
- the checksum filename
- the package naming convention

## 3. Bump Version

Update `pkg/util/version/version.go`:

```go
var version = "0.68.1-cnfrp.1"
```

Commit and push to `main` after release preparation is complete:

```bash
git add pkg/util/version/version.go Release.md .goreleaser.yml package.sh
git commit -m "release: prepare v0.68.1-cnfrp.1"
git push origin main
```

## 4. Prepare Release Branch State

Recommended current flow:

1. Complete all code and document changes on `main`
2. Verify web builds and package generation
3. Rehearse the final release process locally on Ubuntu
4. Push to GitHub `origin`
5. Mirror to Gitee after GitHub state is confirmed

At the current stage, `main` is the working release branch.

## 5. Tag the Release

Recommended first stable tag:

```bash
git checkout main
git pull --ff-only origin main
git tag -a v0.68.1-cnfrp.1 -m "release v0.68.1-cnfrp.1"
git push origin v0.68.1-cnfrp.1
git push gitee v0.68.1-cnfrp.1
```

## 6. Trigger GoReleaser

Manually trigger the `goreleaser` workflow in GitHub Actions:

```bash
gh workflow run goreleaser --ref main
```

GoReleaser will:

1. Build `frps` web assets
2. Build `frpc` web assets
3. Run `package.sh`
4. Create a GitHub Release in `wuse999/cnfrp`
5. Upload `release/packages/*`
6. Upload `cnfrp_sha256_checksums.txt`

## 7. Mirror to Gitee

After GitHub release is confirmed:

```bash
git push gitee main
git push gitee --tags
```

Gitee is a mirror, not the primary release source.

## 8. Package Naming Rules

Archive naming examples:

- `cnfrp_v0.68.1-cnfrp.1_linux_amd64.tar.gz`
- `cnfrp_v0.68.1-cnfrp.1_windows_amd64.zip`

Checksum file:

- `cnfrp_sha256_checksums.txt`

Compatibility rules:

- keep `frpc` / `frps` binary names
- keep config filenames `frpc.toml` / `frps.toml`
- do not change Go module path in this stage

## 9. Key Files

| File | Purpose |
|------|---------|
| `pkg/util/version/version.go` | Version string |
| `Release.md` | Release notes |
| `.goreleaser.yml` | GoReleaser config |
| `package.sh` | Cross-compile and packaging script |
| `.github/workflows/goreleaser.yml` | GitHub Actions workflow |

## 10. Current Release Rule

- Primary release repository: `git@github.com:wuse999/cnfrp.git`
- Mirror repository: `git@gitee.com:frpnat/cnfrp.git`
- Current next stable target: `v0.68.1-cnfrp.1`
- Historical prerelease drill version: `v0.68.0-cnfrp.1-beta.1`
