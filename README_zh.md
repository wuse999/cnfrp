# cnfrp

`cnfrp` 是基于官方 [`frp`](https://github.com/fatedier/frp) 项目进行汉化整理、发布收口与后续迭代维护的兼容性分支。

它不是一个“推倒重写”的新内核项目，而是在尽量保持官方兼容边界的前提下，持续改善中文用户的使用体验、仓库入口、发布链路和部署落地体验。

[简体中文](README.md) | [English](README_en.md)

## 项目定位

`cnfrp` 当前聚焦三件事：

- 让 `frpc` / `frps` 的 Web 管理台与仓库入口更适合中文用户
- 保持和官方 `frp` 的核心兼容边界，降低迁移成本
- 把构建、打包、发布、部署流程逐步规范化

这意味着当前阶段的重点是：

- 中文文档与界面文案整理
- Release 与产物命名收口
- 仓库协作与部署流程完善

而不是大规模改动协议层、配置结构或程序命名。

## 合规说明

本项目是一个通用网络工具的兼容性分支，仅应在合法、合规、获得授权的前提下使用。

- 使用者应自行确保用途、目标网络、服务器资源和数据处理方式符合所在地法律法规
- 本仓库不提供公共穿透节点，不提供绕过监管的服务能力
- 如将本项目用于生产、商业或公网环境，请自行完成安全、备案、访问控制与运维责任评估

## 当前特性

相较于直接使用官方仓库，`cnfrp` 当前已经完成或正在推进的内容主要包括：

- 仓库首页与 Release 入口的中文化收口
- `frpc` / `frps` Web 管理台主路径汉化
- GitHub 主仓与 Gitee 镜像仓的双仓发布口径
- Ubuntu 主工作树下的构建、打包、预发布与部署约定

当前保持不变的兼容边界：

- 不改程序名 `frpc` / `frps`
- 不改 `go.mod` 和 import path
- 不改配置字段 key
- 不改 API 字段名
- 不改协议值和类型值

如果你已经在使用官方 `frp`，通常可以沿用原有配置习惯迁移到 `cnfrp`。

## 快速开始

### 1. 获取程序

- GitHub Releases：<https://github.com/wuse999/cnfrp/releases>
- Gitee 仓库：<https://gitee.com/frpnat/cnfrp>

如需自行构建，请直接使用仓库源码。

### 2. 服务端启动

```bash
./frps -c ./frps.toml
```

### 3. 客户端连接

```bash
./frpc -c ./frpc.toml
```

### 4. 配置参考

- 服务端示例：[conf/frps.toml](conf/frps.toml)
- 完整服务端示例：[conf/frps_full_example.toml](conf/frps_full_example.toml)
- 客户端示例：[conf/frpc.toml](conf/frpc.toml)
- 完整客户端示例：[conf/frpc_full_example.toml](conf/frpc_full_example.toml)

如需完整功能说明，仍建议结合官方文档站阅读：<https://gofrp.org>

## 仓库关系

- GitHub 主仓：<https://github.com/wuse999/cnfrp>
- Gitee 镜像仓：<https://gitee.com/frpnat/cnfrp>
- 官方上游：<https://github.com/fatedier/frp>

当前建议理解方式：

- GitHub 负责主开发、主版本历史和主发布
- Gitee 负责国内访问和镜像分发
- 官方 `frp` 继续作为能力基线与后续同步来源

## 当前状态

项目当前处于“首轮汉化完成后，继续做发布收口与稳定化”的阶段。

当前主线分支：

- `main`

当前已明确的执行口径：

- 正式 Git、构建、打包、发布以 Ubuntu 主工作树为准
- Windows 主要承担 IDE 入口、远程开发和审阅职责
- 香港服务器承担部署、验证和回滚职责

## 问题反馈

如果问题属于以下范围，建议优先在 `cnfrp` 仓库反馈：

- 汉化问题或翻译不一致
- README / Release / 仓库入口文案问题
- 打包产物命名与发布链路问题
- `cnfrp` 的部署、同步与协作约定问题

反馈入口：

- GitHub Issues：<https://github.com/wuse999/cnfrp/issues>
- Gitee Issues：<https://gitee.com/frpnat/cnfrp/issues>

如果确认属于上游 `frp` 内核行为问题，再结合官方仓库进一步判断：

- <https://github.com/fatedier/frp>

## 技术支持

如果你需要中文部署咨询、定制接入支持或商用环境协助，可以访问：

- FRPNAT：<https://www.frpnat.com>
- 技术支持邮箱：<mailto:admin@frpnat.com>

这里更适合处理：

- 中文部署咨询
- 私有化部署协助
- 商用环境接入与运维支持

仓库 README 仍以开源项目说明为主，商业服务信息仅作为补充入口。

## 上游归属与许可证

`cnfrp` 基于官方 `frp` 项目进行整理和延伸，保留上游归属信息，并继续遵守 Apache-2.0 许可证。

当前遵循的基本原则：

- 明确保留与上游 `frp` 的关系
- 不删除原作者版权声明和许可证义务
- 不做“去来源化”改造

许可证见：[LICENSE](LICENSE)