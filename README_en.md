# cnfrp

`cnfrp` is a compatibility-focused branch based on the official [`frp`](https://github.com/fatedier/frp) project, with ongoing work around Chinese localization, release cleanup, and downstream maintenance.

It is not a full rewrite of the upstream core. Instead, it keeps the main compatibility boundaries of `frp` while improving the user-facing repository entry, dashboard wording, release flow, and deployment experience for Chinese-speaking users.

[English](README_en.md) | [简体中文](README.md)

## Project Scope

At the current stage, `cnfrp` focuses on three things:

- making the `frpc` and `frps` web dashboards more usable for Chinese users
- keeping the core compatibility boundaries of upstream `frp`
- gradually standardizing build, packaging, release, and deployment workflows

This means the current focus is on:

- documentation and UI wording cleanup
- release/package naming cleanup
- repository collaboration and deployment conventions

It is not currently focused on large protocol-layer refactors or renaming core binaries and config structures.

## Compliance Notice

This repository is a compatibility branch for a general-purpose networking tool and should only be used in lawful, authorized, and compliant scenarios.

- users are responsible for ensuring their usage complies with local laws, regulations, and network policies
- this repository does not provide public relay nodes or bypass services
- if you use it in production, commercial, or public network environments, you should handle your own security, access control, compliance, and operations review

## Current Features

Compared with using the upstream repository directly, `cnfrp` currently includes or is actively improving:

- Chinese cleanup of repository entry pages and release wording
- Chinese localization of the main `frpc` / `frps` dashboard paths
- dual-repository release wording for GitHub and Gitee
- Ubuntu-based build, packaging, prerelease, and deployment conventions

Compatibility boundaries intentionally kept unchanged:

- binary names stay `frpc` / `frps`
- `go.mod` and import paths stay unchanged
- config keys stay unchanged
- API field names stay unchanged
- protocol names and type values stay unchanged

If you already use upstream `frp`, you can usually migrate to `cnfrp` without changing your main configuration habits.

## Quick Start

### 1. Get the binaries

- Unified download entry: [download/README.md](download/README.md)
- GitHub Releases: <https://github.com/wuse999/cnfrp/releases>
- Gitee mirror: <https://gitee.com/frpnat/cnfrp>

If you prefer to build from source, use this repository directly.

### 2. Start the server

```bash
./frps -c ./frps.toml
```

### 3. Start the client

```bash
./frpc -c ./frpc.toml
```

### 4. Config references

- server example: [conf/frps.toml](conf/frps.toml)
- full server example: [conf/frps_full_example.toml](conf/frps_full_example.toml)
- client example: [conf/frpc.toml](conf/frpc.toml)
- full client example: [conf/frpc_full_example.toml](conf/frpc_full_example.toml)

For complete feature behavior, the upstream docs site is still the best reference: <https://gofrp.org>

## Repository Roles

- GitHub primary repository: <https://github.com/wuse999/cnfrp>
- Gitee mirror repository: <https://gitee.com/frpnat/cnfrp>
- upstream repository: <https://github.com/fatedier/frp>

Recommended interpretation:

- GitHub is the primary development and release repository
- Gitee is the mirror and distribution repository for domestic access
- upstream `frp` remains the baseline for capabilities and future sync work

## Current Status

The project is currently in the stage of post-localization stabilization, release cleanup, and first public release preparation.

Current main branch:

- `main`

Current execution baseline:

- formal Git, build, packaging, and release actions are based on the Ubuntu main worktree
- Windows is mainly used as the IDE, remote development, and review entry
- the Hong Kong server is used for deployment, verification, and rollback

## Feedback

If your issue belongs to one of the following categories, please report it in `cnfrp` first:

- incomplete or inconsistent localization
- README / Release / repository-entry wording problems
- package naming or release-flow issues
- deployment, sync, or collaboration conventions specific to `cnfrp`

Feedback channels:

- GitHub Issues: <https://github.com/wuse999/cnfrp/issues>
- Gitee Issues: <https://gitee.com/frpnat/cnfrp/issues>

If the issue is clearly about upstream `frp` core behavior, it should then be checked against the upstream project:

- <https://github.com/fatedier/frp>

## Support

If you need Chinese deployment guidance, integration assistance, or commercial environment support, you can visit:

- FRPNAT: <https://www.frpnat.com>

Typical support scenarios include:

- Chinese deployment guidance
- private deployment assistance
- commercial environment integration and operations support

This repository README remains focused on the open-source project itself, with commercial support kept as a secondary entry point.

## Upstream Attribution and License

`cnfrp` is based on the official `frp` project and keeps upstream attribution explicit while continuing to comply with the Apache-2.0 license.

Current principles:

- keep the upstream relationship explicit
- preserve original copyright and license obligations
- avoid any “de-attribution” style repackaging

License: [LICENSE](LICENSE)

Download and checksum guidance: [download/README.md](download/README.md)
