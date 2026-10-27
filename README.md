# pure-lark-cli

[![CI](https://github.com/Hariketsu/pure-lark-cli/actions/workflows/ci.yml/badge.svg)](https://github.com/Hariketsu/pure-lark-cli/actions/workflows/ci.yml)
[![License](https://img.shields.io/github/license/Hariketsu/pure-lark-cli)](LICENSE)
[![lark-cli](https://img.shields.io/github/v/release/larksuite/cli?label=lark-cli)](https://github.com/larksuite/cli/releases/latest)
![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux-lightgrey)

中文 | [English](README.en.md)

用最干净的方式在本机装上飞书官方 CLI [`lark-cli`](https://github.com/larksuite/cli)，并给 AI agent 一个统一的飞书入口。

## 为什么不用官方安装

|  | 官方 `npx @larksuite/cli@latest install` | pure-lark-cli |
|---|---|---|
| 安装内容 | 全局 npm 包 + 全套 agent skill | 只有 `lark-cli` 二进制 |
| 依赖 Node / npm | 需要 | 不需要 |
| agent skill | 28 个平铺 | 1 个 `lark` 入口（可选） |
| 配置和登录 | 安装向导里一并执行 | 你自己执行 |
| 升级 | `lark-cli update` 即使已是最新版，也会重装全套 skill | 重跑安装脚本 |

仓库里有两样东西，可以分开用：

- **安装脚本**：从官方 GitHub Release 下载 `lark-cli`，校验后放进 `~/.local/bin`。只装这一个文件，不需要 Node 或 npm。
- **`lark` skill**：面向简洁设计的 agent skill。可以取代官方那套臃肿达 28 个平铺的 skill，运行时从 `lark-cli` 二进制里读取官方文档。

## 快速开始

需要 macOS 或 Linux（amd64 / arm64 / riscv64），以及 `curl`、`tar`。

```sh
# 1. 安装 lark-cli
curl -fsSL https://github.com/Hariketsu/pure-lark-cli/raw/main/install.sh | sh

# 2. 配置应用凭据（App ID / App Secret）
lark-cli config init

# 3. 以用户身份登录（只用机器人身份可以跳过）
lark-cli auth login

# 4. 可选：给 agent 装 lark skill
npx skills add Hariketsu/pure-lark-cli -g
```

第 4 步的详细说明和从官方 skill 迁移的方法，见 [`lark` skill](#lark-skill可选)。

如果访问 GitHub 不稳定，第 1 步可以改用镜像，全程不访问 GitHub：

```sh
curl -fsSL https://cdn.jsdelivr.net/gh/Hariketsu/pure-lark-cli@main/install.sh | sh -s -- --mirror
```

> 为了最小化安装，脚本不会替你执行第 2、3 步 和 改 shell 配置。
如果 `~/.local/bin` 不在 `PATH` 里，安装结束时会提示，需要自己加到 shell 配置里，例如：

```sh
export PATH="$HOME/.local/bin:$PATH"          # bash / zsh
fish_add_path ~/.local/bin                    # fish
```

## 安装脚本

### 它会做什么

1. 查询官方最新版本（或使用 `--version` 指定的版本）。
2. 下载对应平台的压缩包，用同一个 Release 的 `checksums.txt` 校验 sha256，不匹配就停止。
3. macOS 上再检查 Apple 代码签名和公证，确认二进制确实由官方签发。
4. 先写到临时文件再改名替换。即使中途失败，原来的 `lark-cli` 也不会被损坏。

### 选项

```sh
curl -fsSL https://github.com/Hariketsu/pure-lark-cli/raw/main/install.sh | sh -s -- <选项>
```

| 选项 | 作用 |
|---|---|
| `--version 1.0.98` | 安装指定版本，默认装最新版 |
| `--prefix ~/bin` | 换安装目录，默认 `~/.local/bin` |
| `--dry-run` | 只打印版本、平台和目标路径，不下载 |
| `--skip-notarization` | 离线时跳过 macOS 公证检查（签名仍会校验） |
| `--mirror` | 不访问 GitHub，改从 npmmirror 和 jsDelivr 下载（见上文） |

### 升级

重新运行安装命令即可。

不要直接跑 `lark-cli update`，原因见上文。只想看有没有新版本，用 `lark-cli update --check`。

## `lark` skill（可选）

本仓库的 `lark` skill 把官方臃肿集合收成一个入口：

- 只占一个 skill 条目，触发描述覆盖全部飞书场景。
- 自身不带业务文档。指导 agent 读取二进制里内嵌的官方文档，所以文档版本始终和你装的 CLI 一致，不需要单独升级。
- 规定 agent 不能做的事：不跑 `lark-cli update`、不替你登录、写操作和删除操作要先确认。

### 安装

skill 通过 [skills](https://skills.sh/) 工具分发。

```sh
npx skills add Hariketsu/pure-lark-cli -g
```

### 从官方 skill 迁移

迁移之前建议先移除官方 skills，否则会同时看到两套入口：

```sh
npx skills remove -g $(cd ~/.agents/skills && ls -d lark-*)
```

> 这条命令只删 `lark-` 开头的官方 skill，不影响本仓库的 `lark` 和你的其他 skill。

## 卸载

```sh
# 只删二进制，保留配置和登录状态，重装后可以直接用
curl -fsSL https://github.com/Hariketsu/pure-lark-cli/raw/main/uninstall.sh | sh

# 彻底清理：先退出登录（清除 Keychain 中的凭据），再删除二进制和 ~/.lark-cli
curl -fsSL https://github.com/Hariketsu/pure-lark-cli/raw/main/uninstall.sh | sh -s -- --purge

# 删除 agent skill
npx skills remove -g -y lark
```

装的时候用了 `--prefix`，卸载时也要传同样的 `--prefix`。

## 开发

```
install.sh            安装 / 升级二进制
uninstall.sh          卸载
skills/lark/SKILL.md  lark skill
```

CI（`.github/workflows/ci.yml`）会做三件事：

- 用 ShellCheck 检查两个脚本。
- 在 Ubuntu 和 macOS 上，用一个临时的空 `HOME` 运行安装，确认只新建了一个目录，并验证重复安装没有问题。
- 确认仓库里只能发现一个 skill。

本地可以先跑 `shellcheck install.sh uninstall.sh` 和 `sh install.sh --dry-run`。

## License

MIT
