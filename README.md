# pure-lark-cli

把飞书官方 CLI（`lark-cli`）的二进制装进 `~/.local/bin`，只装这一个文件。
另外提供一个 agent skill，把官方平铺的 28 个 skill 收成 1 个入口。

## 安装 CLI

需要 macOS 或 Linux，以及 curl。

```sh
curl -fsSL https://raw.githubusercontent.com/Hariketsu/pure-lark-cli/main/install.sh | sh
```

脚本从 [larksuite/cli](https://github.com/larksuite/cli) 的 Release 下载对应平台的 tar.gz，用同一个 Release 的 `checksums.txt` 校验 sha256，macOS 上再验一次 Apple 签名和公证，最后原子替换到目标路径。整个过程不碰 npm。

装完手动做两步：

```sh
lark-cli config init   # 应用凭据：App ID / App Secret
lark-cli auth login    # 用户身份 OAuth；只用 bot 身份可以跳过
```

其他选项：

```sh
sh install.sh --version 1.0.98      # 钉版本
sh install.sh --prefix ~/bin        # 换目录
sh install.sh --dry-run             # 只看计划
sh install.sh --skip-notarization   # 离线时不查公证
```

## 安装 agent skill（可选）

```sh
npx skills add Hariketsu/pure-lark-cli -g -y
```

装出来的是**一个** `lark` skill，不是官方那 28 个。它本身不含业务文档，运行时用 `lark-cli skills list` 和 `lark-cli skills read` 读二进制里内嵌的官方文档，所以永远和 CLI 版本一致。需要 Node 22.20+。

如果之前用官方方式装过 28 个 skill，先清掉再装：

```sh
npx skills remove -g
```

## 它不做什么

不装 npm 包，不跑 postinstall，不用 npx 装 CLI，不装官方 skill，不执行 `config init` / `auth login`，不改 shell 配置，不动 PATH。

## 为什么不用官方安装

官方入口 `npx @larksuite/cli@latest install` 会依次做四件事：全局 npm 装包、用 npx 装 28 个 skill、`config init`、`auth login`。只想要一个二进制的人不需要这些。

另外两个坑：

- `npm install -g @larksuite/cli` 会把 47 MB 二进制放进 `node_modules`；npm 拦截 postinstall 时，首次运行还会懒下载。
- 裸 `lark-cli update` 即使版本已是最新，也会用 npx 把 28 个 skill 装进 `~/.agents/skills/` 并写 lock 文件。

## 升级

重跑安装脚本即可，替换用临时文件加 rename，是原子的。

```sh
curl -fsSL https://raw.githubusercontent.com/Hariketsu/pure-lark-cli/main/install.sh | sh
```

## 卸载

```sh
sh uninstall.sh            # 只删二进制
sh uninstall.sh --purge    # 连同 ~/.lark-cli 一起删
npx skills remove -g lark  # 删 agent skill
```

## 开发

```
install.sh            安装 / 升级二进制
uninstall.sh          卸载
skills/lark/SKILL.md  agent skill（唯一的 skill 文件）
```

MIT License.
