# cnfrp

`cnfrp` is a Chinese-localized distribution and follow-up evolution branch based on the official [`frp`](https://github.com/fatedier/frp) project.

It keeps the core architecture and compatibility boundaries of `frp` while gradually improving:

- repository entry and release wording
- Chinese-facing documentation and UI copy
- dashboard experience for `frpc` and `frps`
- follow-up automation, packaging, and deployment conventions

[English](README.md) | [简体中文](README_zh.md)

## Project Positioning

`cnfrp` is not a full rewrite of `frp`.

At the current stage, it is a compatibility-first branch focused on:

- Chinese localization
- repository and release cleanup
- dashboard copy refinement
- later feature iteration on top of the upstream baseline

The following stay unchanged in the first phase:

- program names: `frpc`, `frps`
- Go module path and import path
- config keys and API fields
- protocol names and type values

## Repository Roles

- GitHub main repository: <https://github.com/wuse999/cnfrp>
- Gitee mirror repository: <https://gitee.com/frpnat/cnfrp>
- Upstream repository: <https://github.com/fatedier/frp>

Current branch convention:

- `dev`: active working branch for `cnfrp`
- release branch/tag strategy: to be stabilized during the first public release cycle

## Current Status

The project is currently in the first localization and release-preparation cycle.

Current priorities:

1. clean up repository entry wording
2. localize the `frpc` and `frps` dashboards
3. align release/package/deployment conventions
4. prepare the first usable `cnfrp` release

## What You Can Use Today

If you are already familiar with `frp`, you can continue using `cnfrp` with the same core concepts:

- `frps` remains the server program
- `frpc` remains the client program
- existing config structure stays compatible in the current phase

Reference locations in this repository:

- examples: [`conf/`](conf)
- supporting docs/assets: [`doc/`](doc)
- web dashboards: [`web/`](web)

## Documentation Strategy

The repository entry is being rewritten for `cnfrp`.

During the transition period:

- `cnfrp`-specific repository and release guidance is maintained here
- detailed feature behavior and upstream architecture references still rely on official `frp` materials when not yet localized

Useful upstream references:

- upstream README: <https://github.com/fatedier/frp>
- upstream docs site: <https://gofrp.org>

## Feedback

For `cnfrp` repository wording, localization, release flow, and downstream adaptation issues, please use:

- GitHub Issues: <https://github.com/wuse999/cnfrp/issues>
- Gitee Issues: <https://gitee.com/frpnat/cnfrp/issues>

If your issue is clearly an upstream `frp` core behavior issue, it may still need to be checked against the upstream project.

## Upstream Attribution

`cnfrp` is based on the official `frp` project by `fatedier` and contributors.

This repository does not remove upstream attribution. It keeps the upstream relationship explicit and preserves the original license obligations.

## License

`cnfrp` continues to use the Apache-2.0 license inherited from the upstream project.

See [LICENSE](LICENSE) for details.
