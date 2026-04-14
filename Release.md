# cnfrp v0.68.1-cnfrp.1 发布说明

## 版本信息

- 项目：`cnfrp`
- 当前正式版本：`v0.68.1-cnfrp.1`
- 发布类型：`Stable`
- 发布分支：`main`
- 说明：本文档对应已正式发布的 `v0.68.1-cnfrp.1` 版本，用于说明本轮上游同步、构建测试与正式发布结果。

## 一句话说明

`v0.68.1-cnfrp.1` 是 `cnfrp` 在首版正式发布后的首个上游同步稳定版本，重点承接官方 `frp v0.68.1` 修复点，并完成同步候选分支的构建、测试与预览验证。

## 本次重点

- 承接官方 `frp v0.68.1` 的关键修复点
- 完成 `sync/upstream-v0.68.1` 候选分支的构建、测试与预览验证
- 保持 `cnfrp` 既有中文入口、发布链路和兼容边界不变

## 适用范围

本版本适用于：

- 需要继续使用 `frpc` / `frps` 原有程序名与兼容配置的用户
- 希望继续使用中文化 Web 管理界面的用户
- 需要吸收 `v0.68.1` 上游修复点并保持既有部署链路的协作者

## 主要变更

### 1. 上游同步

- 同步官方稳定基线到 `v0.68.1`
- 吸收 `routeByHTTPUser` 相关 HTTP 认证绕过修复
- 吸收 `web/frpc` 路由静态导入优化

### 2. 构建与验证

- `make build` 通过
- `make test` 通过
- `frps` / `frpc` 本地预览通过
- 公网预览域名验证通过

### 3. CLI / 配置 / 兼容边界

- 当前阶段不修改 `frpc` / `frps` 二进制名
- 当前阶段不修改 `go.mod`、import path、配置键名和协议字段
- 继续保持对官方 `frp v0.68.1` 基线的映射关系

### 4. 发布结果

- 当前正式版本为 `v0.68.1-cnfrp.1`
- 压缩包命名统一为 `cnfrp_v0.68.1-cnfrp.1_<平台>_<架构>`
- 校验文件名继续使用 `cnfrp_sha256_checksums.txt`
- 正式 Git、构建、打包、Tag 与发布继续统一在 Ubuntu 主工作树执行

## 兼容性说明

当前版本默认继续保持以下兼容边界：

- 不改程序名 `frpc` / `frps`
- 不改 `go.mod` 和 import path
- 不改配置字段 key
- 不改 API 字段名
- 不改协议值和类型值

如后续版本引入超出以上边界的变化，需在对应 Release 中单独声明。

## 已知限制

- 当前发布矩阵暂时仍不包含 `android-arm64`
- Android 目标不是取消，而是顺延到后续独立修复支线
- 若后续继续调整 Release 口径、下载入口或官网互链，应与本版本发布说明同步更新

## 下载与仓库入口

- 统一下载入口：[download/README.md](download/README.md)
- 当前 GitHub 稳定版下载页：<https://github.com/wuse999/cnfrp/releases/tag/v0.68.1-cnfrp.1>
- 当前 Gitee 稳定版下载页：<https://gitee.com/frpnat/cnfrp/releases/tag/v0.68.1-cnfrp.1>
- Gitee Releases：<https://gitee.com/frpnat/cnfrp/releases>
- GitHub 仓库：<https://github.com/wuse999/cnfrp>
- Gitee 镜像仓：<https://gitee.com/frpnat/cnfrp>
- 官方站点：<https://www.frpnat.com>

## 上游关系说明

`cnfrp` 基于官方 `frp` 项目进行汉化整理与后续功能迭代。

官方上游仓库：

- <https://github.com/fatedier/frp>

## 许可证

本项目继续沿用 Apache-2.0 许可证。
