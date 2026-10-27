---
name: lark
description: "飞书 / Lark（Feishu）操作入口：通过本机 lark-cli 内置的官方 skills 完成消息与群聊、云文档与知识库、多维表格与电子表格、画板与幻灯片、日历与会议、审批、任务、OKR、邮件、通讯录、考勤、妙搭应用、事件订阅等全部飞书操作。当用户提到飞书、Lark、Feishu，或要发消息、读写云文档、建多维表格、查日历、处理审批时使用。"
metadata:
  requires:
    bins: ["lark-cli"]
---

# Lark / Feishu via lark-cli

`lark-cli` 把官方全部 skill 文档内嵌在二进制里，可以用 `lark-cli skills list` / `lark-cli skills read` 按需读取。

本 skill 只是入口和路由，不复制那些文档，也不要求安装官方那 28 个 skill。

## 前置

`lark-cli` 不在 PATH 时，先让用户安装（只装二进制）：

```sh
curl -fsSL https://raw.githubusercontent.com/Hariketsu/pure-lark-cli/main/install.sh | sh
```

## 读取契约

官方文档是按「skill 已平铺在磁盘上」写的，里面的路径不能直接交给 Read 工具。一律按下表翻译：

| 文档里出现 | 你要执行 |
|---|---|
| 任何 `SKILL.md` / reference 文件 | `lark-cli skills read <skill> <路径>` |
| `../lark-xxx/SKILL.md` | `lark-cli skills read lark-xxx/SKILL.md`（去掉 `../`） |
| `references/foo.md` | `lark-cli skills read <当前 skill> references/foo.md` |
| 「用 Read 工具读取 …」 | 改走上面任一对应命令 |

例外：本文件、以及你自己创建的文件才用 Read。命令返回空或报错时不要凭记忆补内容，先 `lark-cli skills list` 核对名字。

## 工作流

1. 用下面的索引找 skill；拿不准就 `lark-cli skills list`（JSON，含每个 skill 的触发描述）。
2. `lark-cli skills read <skill>` 读它的 SKILL.md。
3. 需要细节时 `lark-cli skills list <skill>/references` 列出文件，再按契约读。
4. 动手前先读共享规则：`lark-cli skills read lark-shared`。身份选择（`--as user` / `--as bot`）、认证、`exit 10` 高风险确认、JSON 输出契约、文件路径限制都在里面，本文件不重复。

## skill 索引

| 领域 | skill |
|---|---|
| 即时消息、群聊、卡片、加急、Feed | `lark-im` |
| 云文档、知识库、Markdown | `lark-doc` `lark-wiki` `lark-markdown` |
| 多维表格、电子表格、画板、幻灯片 | `lark-base` `lark-sheets` `lark-whiteboard` `lark-slides` |
| 云盘文件、上传下载、搜索 | `lark-drive` |
| 日历、会议室、视频会议、妙记 | `lark-calendar` `lark-meeting` |
| 任务、审批、OKR | `lark-task` `lark-approval` `lark-okr` |
| 通讯录、考勤 | `lark-contact` `lark-attendance` |
| 邮件 | `lark-mail` |
| 妙搭（Spark/Miaoda）应用开发 | `lark-apps` |
| 事件订阅 | `lark-event` |
| 原生 OpenAPI 探索（CLI 未封装的能力） | `lark-openapi-explorer` |
| 认证、身份、授权、配置 | `lark-shared` |
| 组合流程示例 | `lark-workflow-meeting-summary` `lark-workflow-standup-report` |

`lark-minutes`、`lark-note`、`lark-vc`、`lark-vc-agent` 是兼容存根，内容会要求转到 `lark-meeting`，按读取契约翻译即可。

## 红线

- 不跑裸 `lark-cli update`。即使已是最新，它也会用 npx 把官方 28 个 skill 装进 `~/.agents/skills/` 并写 lock 文件。查更新用 `lark-cli update --check`。
- 不跑 `npx skills add larksuite/cli`，也不手动复制官方 skill 到 `~/.agents/skills/`。
- 不替用户执行 `lark-cli config init` / `lark-cli auth login`。缺认证时把命令告诉用户，由用户自己跑。
- 写操作、删除操作、`exit 10` 必须按 `lark-shared` 的要求先向用户确认；不要为了绕过确认而追加确认 flag。
