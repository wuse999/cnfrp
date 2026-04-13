# cnfrp — FRP 中文版

> **工具分享 · 数据分析 · 应用程序开发 · 服务器部署**  
> 官方服务：[FRPNAT.COM](https://frpnat.com)

cnfrp 是基于 [fatedier/frp](https://github.com/fatedier/frp) 的中文文档与配置示例集合，帮助开发者快速上手内网穿透，实现工具共享、数据分析平台搭建、应用程序开发调试以及服务器部署等场景。

---

## 目录

1. [什么是 FRP？](#什么是-frp)
2. [FRPNAT.COM 服务介绍](#frpnatcom-服务介绍)
3. [快速开始](#快速开始)
   - [服务端配置 (frps)](#服务端配置-frps)
   - [客户端配置 (frpc)](#客户端配置-frpc)
4. [典型应用场景](#典型应用场景)
   - [工具分享](#工具分享)
   - [数据分析平台](#数据分析平台)
   - [应用程序开发与调试](#应用程序开发与调试)
   - [服务器部署](#服务器部署)
5. [常见端口说明](#常见端口说明)
6. [注意事项与安全建议](#注意事项与安全建议)
7. [参考资源](#参考资源)

---

## 什么是 FRP？

FRP（Fast Reverse Proxy）是一款高性能的反向代理工具，支持 TCP、UDP、HTTP、HTTPS 等协议，可将内网服务安全地暴露到公网，无需公网 IP。

**主要特性：**

- 支持 TCP / UDP / HTTP / HTTPS / STCP / XTCP 多种代理协议
- 客户端服务端双向身份验证（Token / TLS）
- 基于域名的虚拟主机支持，一个端口托管多个网站
- 连接池复用，降低延迟
- 提供 Web 管理面板，直观监控隧道状态
- 支持插件扩展（静态文件服务、HTTPS 证书等）

---

## FRPNAT.COM 服务介绍

[FRPNAT.COM](https://frpnat.com) 是面向国内用户的 FRP 公共服务节点，提供：

| 功能 | 说明 |
|------|------|
| 免费节点 | 提供基础免费带宽，满足个人学习与测试需求 |
| 高速专线节点 | 付费专线，适合生产环境和数据分析大流量场景 |
| 多地区节点 | 华东、华北、华南多节点，就近接入降低延迟 |
| 自定义域名 | 支持绑定自有域名，打造专属开发调试环境 |
| Web 控制台 | 在线管理隧道、查看流量统计 |

> 注册地址：[https://frpnat.com](https://frpnat.com)

---

## 快速开始

### 下载 FRP

从 [GitHub Releases](https://github.com/fatedier/frp/releases) 下载对应平台的二进制文件，或使用以下脚本一键安装（Linux x86_64）：

```bash
FRP_VERSION="0.61.0"
wget -q "https://github.com/fatedier/frp/releases/download/v${FRP_VERSION}/frp_${FRP_VERSION}_linux_amd64.tar.gz"
tar -xzf "frp_${FRP_VERSION}_linux_amd64.tar.gz"
cd "frp_${FRP_VERSION}_linux_amd64"
```

---

### 服务端配置 (frps)

> 如果使用 FRPNAT.COM 提供的公共服务端，可跳过此步骤，直接配置客户端。

创建 `frps.toml`：

```toml
# frps.toml — FRP 服务端配置示例

# 监听端口，客户端通过此端口连接服务端（控制连接端口）
bindPort = 7000

# Dashboard 管理面板（可选）
webServer.port     = 7500
webServer.user     = "admin"
webServer.password = "your_strong_password"

# 身份验证令牌（与客户端保持一致）
auth.method = "token"
auth.token  = "your_secret_token"

# 最大连接数（按需调整）
maxPoolCount = 10

# 日志配置
log.to    = "/var/log/frps.log"
log.level = "info"
```

启动服务端：

```bash
./frps -c frps.toml
```

---

### 客户端配置 (frpc)

创建 `frpc.toml`，将本地服务映射到公网：

```toml
# frpc.toml — FRP 客户端配置示例

# 服务端地址（使用 FRPNAT.COM 节点时填写对应域名/IP）
serverAddr = "node1.frpnat.com"
serverPort = 7000

# 与服务端相同的身份验证令牌
auth.method = "token"
auth.token  = "your_secret_token"

# 日志配置
log.to    = "/var/log/frpc.log"
log.level = "info"

# ── 示例1：Web 应用 HTTP 穿透 ──────────────────────────────────────────
[[proxies]]
name          = "web-app"
type          = "http"
localIP       = "127.0.0.1"
localPort     = 8080
customDomains = ["myapp.frpnat.com"]

# ── 示例2：数据分析平台 (Jupyter Notebook) ────────────────────────────
[[proxies]]
name          = "jupyter"
type          = "http"
localIP       = "127.0.0.1"
localPort     = 8888
customDomains = ["jupyter.frpnat.com"]

# ── 示例3：SSH 远程登录 ──────────────────────────────────────────────
[[proxies]]
name        = "ssh"
type        = "tcp"
localIP     = "127.0.0.1"
localPort   = 22
remotePort  = 6022

# ── 示例4：数据库远程访问 (MySQL) ────────────────────────────────────
[[proxies]]
name        = "mysql"
type        = "tcp"
localIP     = "127.0.0.1"
localPort   = 3306
remotePort  = 13306

# ── 示例5：UDP 游戏/音视频服务 ──────────────────────────────────────
[[proxies]]
name        = "game-udp"
type        = "udp"
localIP     = "127.0.0.1"
localPort   = 7000
remotePort  = 17000
```

启动客户端：

```bash
./frpc -c frpc.toml
```

---

## 典型应用场景

### 工具分享

将本地运行的工具（代码生成器、文件转换服务、在线编辑器等）通过 FRP 暴露到公网，与团队或客户共享，无需部署到云服务器。

```toml
# 分享本地工具服务（端口 3000）
[[proxies]]
name          = "my-tool"
type          = "http"
localPort     = 3000
customDomains = ["tool.frpnat.com"]
```

**典型工具：**

| 工具 | 本地端口 | 说明 |
|------|----------|------|
| VS Code Server | 8080 | 浏览器中的远程开发环境 |
| Gitea | 3000 | 自托管 Git 服务 |
| FileBrowser | 8080 | Web 文件管理器 |
| Draw.io | 8080 | 在线流程图工具 |

---

### 数据分析平台

在本地或内网服务器运行数据分析环境（Jupyter、Metabase、Superset 等），通过 FRP 对外提供访问，避免数据上传至第三方云服务。

```toml
# Jupyter Notebook
[[proxies]]
name          = "jupyter"
type          = "https"
localIP       = "127.0.0.1"
localPort     = 8888
customDomains = ["jupyter.frpnat.com"]
plugin        = "https2http"
plugin.localAddr = "127.0.0.1:8888"
plugin.crtPath   = "./server.crt"
plugin.keyPath   = "./server.key"

# Apache Superset
[[proxies]]
name          = "superset"
type          = "http"
localIP       = "127.0.0.1"
localPort     = 8088
customDomains = ["bi.frpnat.com"]
```

**推荐数据分析工具栈：**

| 工具 | 用途 |
|------|------|
| Jupyter Notebook / Lab | 交互式数据分析、机器学习建模 |
| Apache Superset | BI 看板、SQL 分析 |
| Metabase | 轻量级数据可视化 |
| Grafana | 时序数据与指标监控 |
| MinIO | 本地对象存储（数据集管理） |

---

### 应用程序开发与调试

开发者可将本地开发环境快速暴露到公网，便于：

- **Webhook 调试**：接收第三方平台（微信、支付宝、GitHub 等）的回调请求
- **移动端联调**：手机直接访问开发机上的 API 服务
- **演示给客户**：无需发布版本，直接展示开发进度

```toml
# 微信/支付宝 Webhook 调试
[[proxies]]
name          = "webhook"
type          = "http"
localIP       = "127.0.0.1"
localPort     = 5000
customDomains = ["dev.frpnat.com"]

# 前后端分离项目联调（后端 API）
[[proxies]]
name          = "api-dev"
type          = "http"
localIP       = "127.0.0.1"
localPort     = 8000
customDomains = ["api-dev.frpnat.com"]
locations     = ["/api"]
```

**开发场景速查表：**

| 场景 | 代理类型 | 说明 |
|------|----------|------|
| HTTP API 调试 | http | 支持自定义域名 |
| HTTPS API 调试 | https | 需配置 TLS 证书 |
| WebSocket 应用 | http/tcp | 自动支持 WS 升级 |
| gRPC 服务 | tcp | 映射 gRPC 端口 |
| 小程序开发 | https | 要求 HTTPS 域名 |

---

### 服务器部署

将内网服务器通过 FRP 变成可对外提供服务的生产节点，适合：

- 家庭/办公室 NAS 对外服务
- 边缘计算节点接入
- 企业内网服务对合作伙伴开放

#### 使用 systemd 管理 frpc（推荐用于生产环境）

创建 `/etc/systemd/system/frpc.service`：

```ini
[Unit]
Description=FRP Client Service
After=network.target

[Service]
Type=simple
User=nobody
Restart=on-failure
RestartSec=5s
ExecStart=/usr/local/bin/frpc -c /etc/frp/frpc.toml

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl daemon-reload
sudo systemctl enable frpc
sudo systemctl start frpc
sudo systemctl status frpc
```

#### 使用 Docker 部署

```yaml
# docker-compose.yml
version: "3.8"
services:
  frpc:
    image: snowdreamtech/frpc:latest
    restart: unless-stopped
    volumes:
      - ./frpc.toml:/etc/frp/frpc.toml:ro
    network_mode: host
```

```bash
docker compose up -d
docker compose logs -f frpc
```

---

## 常见端口说明

| 端口 | 用途 |
|------|------|
| 7000 | FRP 客户端与服务端控制连接默认端口（TCP） |
| 7500 | FRP Dashboard 默认端口（HTTP） |
| 6022 | SSH 穿透常用远程端口 |
| 13306 | MySQL 穿透常用远程端口 |
| 16379 | Redis 穿透常用远程端口 |
| 15432 | PostgreSQL 穿透常用远程端口 |

> ⚠️ 生产环境中请修改默认端口，并配置防火墙规则，避免未授权访问。

---

## 注意事项与安全建议

1. **使用强 Token**：`auth.token` 请使用随机生成的高强度字符串（建议 32 位以上）。
2. **启用 TLS**：在 frps.toml 中开启 `transport.tls.force = true`，所有通信使用 TLS 加密。
3. **限制访问 IP**：通过 `allowPorts` 或防火墙规则限制可接入的端口范围。
4. **数据库不直接暴露**：数据库类服务建议通过 STCP（点对点加密隧道）而非公开 TCP 端口访问。
5. **定期更新 FRP**：关注 [官方发布](https://github.com/fatedier/frp/releases) 及时更新修复安全漏洞。

---

## 参考资源

- [FRP 官方文档](https://gofrp.org/zh-cn/docs/)
- [fatedier/frp GitHub](https://github.com/fatedier/frp)
- [FRPNAT.COM 官网](https://frpnat.com)
- [FRP 配置参考（完整版）](https://github.com/fatedier/frp/blob/dev/conf/frpc_full_example.toml)

---

> 本项目仅整理中文文档与配置模板，不包含 frp 二进制文件。请从 [官方渠道](https://github.com/fatedier/frp/releases) 下载可信赖的二进制包。

