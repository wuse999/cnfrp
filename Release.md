# cnfrp 首版正式发布说明（预备稿）

## 版本信息

- 项目：`cnfrp`
- 目标正式版本：`v0.68.0-cnfrp.1`
- 发布类型：`Stable`
- 发布分支：`main`
- 说明：本文档已按首版正式发布口径收口，真实 Tag 与发布时间以 Ubuntu 主工作树最终执行结果为准。

## 一句话说明

`v0.68.0-cnfrp.1` 是 `cnfrp` 首个正式发布版本，重点完成仓库入口中文化、`frpc` / `frps` Web 管理台汉化、发布链路收口和首版部署落地。

## 本次重点

- 完成仓库首页、README、Release 入口与品牌口径收口
- 完成 `frpc` / `frps` 管理台主路径汉化与第三轮边角复扫
- 完成发布配置、产物命名、Ubuntu 主工作树打包链路与香港服务器首版部署闭环

## 适用范围

本版本适用于：

- 需要继续使用 `frpc` / `frps` 原有程序名与兼容配置的用户
- 希望直接使用中文化 Web 管理界面的用户
- 准备基于 `cnfrp` 继续部署、验证和后续迭代的协作者

## 主要变更

### 1. 仓库入口与文档

- 重写 `README.md`、`README_en.md` 和 `Release.md` 的对外描述
- 明确 GitHub 为主发布仓、Gitee 为镜像仓
- 保留与官方 `frp` 的关系说明和许可证信息

### 2. frpc 管理台

- 完成主导航、列表页、详情页、编辑页与客户端配置页中文化
- 完成 `visitor-form/*` 与 `proxy-form/*` 深层表单分区和字段文案收口
- 统一状态词、只读详情态与配置分区术语

### 3. frps 管理台

- 完成主壳层、概览页、客户端页、代理页和详情页中文化
- 完成流量图表、确认弹窗、筛选组件和相对时间展示的术语统一
- 收口异常提示、空状态、折叠区和少量共享组件残留英文

### 4. CLI / 配置 / 构建

- 当前阶段不修改 `frpc` / `frps` 二进制名
- 当前阶段不修改 `go.mod`、import path、配置键名和协议字段
- 继续保持对官方 `frp v0.68.0` 基线的映射关系

### 5. 发布与部署

- GoReleaser 发布目标切换为 `wuse999/cnfrp`
- GitHub Actions 的 Go 版本对齐到 `1.26.1`
- 压缩包命名统一为 `cnfrp_v0.68.0-cnfrp.1_<平台>_<架构>`
- 校验文件名统一为 `cnfrp_sha256_checksums.txt`
- 正式 Git、构建、打包、Tag 与发布统一在 Ubuntu 主工作树执行
- 首版 `frps` 已按既定方案部署到香港服务器并完成面板可用性验证

### 6. 上游 `v0.68.1` 已承接修复点

- 修复 `type = "http"` 代理在 `routeByHTTPUser` 与 `httpUser` / `httpPassword` 组合使用时的认证绕过问题
- 该问题主要影响代理模式请求
- 修复后，代理模式下认证失败会返回 `407 Proxy Authentication Required`

## 兼容性说明

当前版本默认继续保持以下兼容边界：

- 不改程序名 `frpc` / `frps`
- 不改 `go.mod` 和 import path
- 不改配置字段 key
- 不改 API 字段名
- 不改协议值和类型值

如后续版本引入超出以上边界的变化，需在对应 Release 中单独声明。

## 已知限制

- 当前首版发布矩阵暂时不包含 `android-arm64`
- Android 目标不是取消，而是顺延到首版正式发布走通后的独立修复支线
- 少量 CLI / 配置层用户可见文案仍可在后续迭代中继续收口

## 下载与仓库入口

- GitHub：<https://github.com/wuse999/cnfrp>
- Gitee：<https://gitee.com/frpnat/cnfrp>

## 上游关系说明

`cnfrp` 基于官方 `frp` 项目进行汉化整理与后续功能迭代。

官方上游仓库：

- <https://github.com/fatedier/frp>

## 许可证

本项目继续沿用 Apache-2.0 许可证。
