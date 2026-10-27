---
name: lark
description: "通过本机 lark-cli 操作飞书 / Lark / Feishu：消息群聊、云文档、知识库、多维表格、电子表格、日历会议、审批、任务、邮件、通讯录等。用户提到飞书、Lark、Feishu，或要发飞书消息、读写飞书文档、查日历、处理审批时使用。"
---

# Lark / Feishu via lark-cli

官方各业务 skill 的文档都内嵌在 `lark-cli` 里，按需用 `lark-cli skills` 读取。

`lark-cli` 不在 PATH 时，让用户安装：

```sh
curl -fsSL https://github.com/Hariketsu/pure-lark-cli/raw/main/install.sh | sh
# 访问不了 GitHub：
curl -fsSL https://cdn.jsdelivr.net/gh/Hariketsu/pure-lark-cli@main/install.sh | sh -s -- --mirror
```

## 工作流

1. 先读共享规则：`lark-cli skills read lark-shared`。身份（`--as user` / `--as bot`）、认证、`exit 10` 确认、输出格式都在里面。
2. 按下方索引选 skill，读它的 SKILL.md：`lark-cli skills read <skill>`。
3. 拿不准用哪个 skill 时，`lark-cli skills list` 会列出全部 skill 及其触发描述，以它为准。

官方文档默认自己就在本地磁盘上。凡是要读文档里引用的文件（包括"用 Read 工具读取 …"），一律改用 `lark-cli skills read <skill>/<路径>`；`../lark-xxx/…` 去掉 `../` 即可。

## skill 索引

| 领域 | skill |
|---|---|
| 消息、群聊、卡片 | `lark-im` |
| 云文档、知识库、Markdown | `lark-doc` `lark-wiki` `lark-markdown` |
| 多维表格、电子表格、画板、幻灯片 | `lark-base` `lark-sheets` `lark-whiteboard` `lark-slides` |
| 云盘文件 | `lark-drive` |
| 日历、会议室、视频会议、妙记 | `lark-calendar` `lark-meeting` |
| 任务、审批、OKR | `lark-task` `lark-approval` `lark-okr` |
| 通讯录、考勤 | `lark-contact` `lark-attendance` |
| 邮件 | `lark-mail` |
| 妙搭应用 | `lark-apps` |
| 事件订阅 | `lark-event` |
| CLI 未封装的 OpenAPI | `lark-openapi-explorer` |
| 编写新的飞书 skill | `lark-skill-maker` |
| 组合流程示例 | `lark-workflow-meeting-summary` `lark-workflow-standup-report` |

`lark-minutes`、`lark-note`、`lark-vc`、`lark-vc-agent` 是旧名，会跳转到 `lark-meeting`。

## 红线

- 不跑裸 `lark-cli update`，也不安装官方 skill：它们会往 `~/.agents/skills/` 写入官方那一整套。查更新用 `lark-cli update --check`。
- 不替用户执行 `lark-cli config init` / `lark-cli auth login`，缺认证时把命令交给用户。
- 写入、删除和 `exit 10` 按 `lark-shared` 的要求先征得用户确认，不要加 flag 绕过确认。
