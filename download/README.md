# cnfrp 下载入口

## 1. 当前下载原则

- GitHub Release 与 Gitee Releases 当前都已可提供正式压缩包下载。
- GitHub 仍是主发布源，Gitee 作为国内镜像发布源同步提供下载。
- 如需源码、文档或 Issue 反馈，可分别进入 GitHub / Gitee 仓库主页。

## 1.1 项目身份说明

- `cnfrp` 是基于官方 `fatedier/frp` 的中文汉化发行版。
- 当前主要聚焦中文文档、中文 Web 管理界面与本地化体验优化。
- 当前默认保持与官方 `frp` 的主要兼容边界，实际差异以仓库首页和版本说明为准。

## 2. 当前正式版本

- 当前稳定版：`v0.68.0-cnfrp.1`
- GitHub Release 页面：
  - <https://github.com/wuse999/cnfrp/releases/tag/v0.68.0-cnfrp.1>
- GitHub Releases 总入口：
  - <https://github.com/wuse999/cnfrp/releases>
- Gitee Releases 总入口：
  - <https://gitee.com/frpnat/cnfrp/releases>

## 3. 仓库入口

- GitHub 主仓：
  - <https://github.com/wuse999/cnfrp>
- Gitee 镜像仓：
  - <https://gitee.com/frpnat/cnfrp>
- Gitee Releases：
  - <https://gitee.com/frpnat/cnfrp/releases>
- 官方上游：
  - <https://github.com/fatedier/frp>
- 官方站点：
  - <https://www.frpnat.com>

## 4. 压缩包命名规则

发布产物统一使用以下命名风格：

- `cnfrp_v0.68.0-cnfrp.1_linux_amd64.tar.gz`
- `cnfrp_v0.68.0-cnfrp.1_windows_amd64.zip`
- `cnfrp_v0.68.0-cnfrp.1_darwin_arm64.tar.gz`

校验文件统一命名为：

- `cnfrp_sha256_checksums.txt`

## 5. 下载后校验

### 5.1 Linux / macOS

```bash
sha256sum -c cnfrp_sha256_checksums.txt
```

### 5.2 Windows PowerShell

```powershell
Get-FileHash .\cnfrp_v0.68.0-cnfrp.1_windows_amd64.zip -Algorithm SHA256
```

也可以使用：

```powershell
certutil -hashfile .\cnfrp_v0.68.0-cnfrp.1_windows_amd64.zip SHA256
```

请将输出结果与 `cnfrp_sha256_checksums.txt` 中对应条目逐项核对。

## 6. 使用提醒

- 当前阶段继续保持 `frpc` / `frps` 原始二进制名不变。
- 当前阶段继续保持 `frpc.toml` / `frps.toml` 配置文件名不变。
- 如需中文界面、发布口径与协作说明，请先阅读仓库根目录 [README.md](../README.md)。
- 如需查看当前版本变更说明，请阅读仓库根目录 [Release.md](../Release.md)。

## 7. 一句话结论

如果你只是想稳定下载和校验 `cnfrp`，现在可以从 GitHub Release 或 Gitee Releases 获取同版本压缩包，再按 `cnfrp_sha256_checksums.txt` 做完整性校验。
