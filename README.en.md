# pure-lark-cli

[![CI](https://github.com/Hariketsu/pure-lark-cli/actions/workflows/ci.yml/badge.svg)](https://github.com/Hariketsu/pure-lark-cli/actions/workflows/ci.yml)
[![License](https://img.shields.io/github/license/Hariketsu/pure-lark-cli)](LICENSE)
[![lark-cli](https://img.shields.io/github/v/release/larksuite/cli?label=lark-cli)](https://github.com/larksuite/cli/releases/latest)
![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux-lightgrey)

[中文](README.md) | English

The cleanest way to put the official Lark / Feishu CLI, [`lark-cli`](https://github.com/larksuite/cli), on your machine, plus a single Lark entry point for AI agents.

## Why not the official installer

|  | Official `npx @larksuite/cli@latest install` | pure-lark-cli |
|---|---|---|
| What gets installed | Global npm package + the full agent skill set | Just the `lark-cli` binary |
| Needs Node / npm | Yes | No |
| Agent skills | 28 flat skills | 1 `lark` entry point (optional) |
| Config and login | Run by the install wizard | Run by you |
| Upgrading | `lark-cli update` reinstalls the full skill set, even when already up to date | Rerun the install script |

The repo ships two things you can use independently:

- **An install script** that downloads `lark-cli` from the official GitHub Release, verifies it, and drops it into `~/.local/bin`. One file, no Node or npm required.
- **A `lark` skill**, an agent skill built to stay minimal. It can replace the official set of 28 flat skills, and reads the official docs from the `lark-cli` binary at runtime.

## Quick start

Requires macOS or Linux (amd64 / arm64 / riscv64), plus `curl` and `tar`.

```sh
# 1. Install lark-cli
curl -fsSL https://github.com/Hariketsu/pure-lark-cli/raw/main/install.sh | sh

# 2. Configure app credentials (App ID / App Secret)
lark-cli config init

# 3. Log in as a user (skip if you only use the bot identity)
lark-cli auth login

# 4. Optional: install the lark skill for your agent
npx skills add Hariketsu/pure-lark-cli -g
```

For details on step 4 and how to migrate from the official skills, see [`lark` skill](#lark-skill-optional).

If GitHub is slow or unreachable for you, step 1 can go through mirrors without touching GitHub at all:

```sh
curl -fsSL https://cdn.jsdelivr.net/gh/Hariketsu/pure-lark-cli@main/install.sh | sh -s -- --mirror
```

> To keep the install minimal, the script doesn't run steps 2 and 3 for you or edit your shell config.
If `~/.local/bin` isn't on your `PATH`, the installer prints a warning at the end, and you add it to your shell config yourself, for example:

```sh
export PATH="$HOME/.local/bin:$PATH"          # bash / zsh
fish_add_path ~/.local/bin                    # fish
```

## Install script

### What it does

1. Looks up the latest official release (or uses the version passed to `--version`).
2. Downloads the archive for your platform and checks its sha256 against the release's `checksums.txt`. It stops on a mismatch.
3. On macOS, also checks the Apple code signature and notarization, so you know the binary was signed by the vendor.
4. Writes to a temporary file, then renames it into place. If anything fails midway, your existing `lark-cli` is left intact.

### Options

```sh
curl -fsSL https://github.com/Hariketsu/pure-lark-cli/raw/main/install.sh | sh -s -- <options>
```

| Option | Effect |
|---|---|
| `--version 1.0.98` | Install a specific version (default: latest) |
| `--prefix ~/bin` | Install somewhere else (default: `~/.local/bin`) |
| `--dry-run` | Print the version, platform, and target path without downloading |
| `--skip-notarization` | Skip the macOS notarization check when offline (the signature is still verified) |
| `--mirror` | Download from npmmirror and jsDelivr instead of GitHub (see above) |

### Upgrading

Rerun the install command.

Don't use a plain `lark-cli update`, for the reason above. To check whether a new version is out, use `lark-cli update --check`.

## `lark` skill (optional)

This repo's `lark` skill folds the bloated official set into one entry point:

- It takes up a single slot in the skill list, and its trigger description covers every Lark scenario.
- It ships no product docs itself. It points the agent at the official docs embedded in the binary, so they always match the CLI version you installed, with nothing extra to update.
- It sets rules for the agent: never run `lark-cli update`, never log in on your behalf, and confirm before any write or delete.

### Install

The skill is distributed through the [skills](https://skills.sh/) tool.

```sh
npx skills add Hariketsu/pure-lark-cli -g
```

### Migrating from the official skills

Before migrating, remove the official skills first. Otherwise the agent sees two entry points at once:

```sh
npx skills remove -g $(cd ~/.agents/skills && ls -d lark-*)
```

> This removes only the official skills whose names start with `lark-`. It leaves this repo's `lark` skill and your other skills alone.

## Uninstall

```sh
# Remove the binary only; config and login state are kept, so a reinstall works right away
curl -fsSL https://github.com/Hariketsu/pure-lark-cli/raw/main/uninstall.sh | sh

# Full cleanup: sign out (clearing the Keychain credentials), then remove the binary and ~/.lark-cli
curl -fsSL https://github.com/Hariketsu/pure-lark-cli/raw/main/uninstall.sh | sh -s -- --purge

# Remove the agent skill
npx skills remove -g -y lark
```

If you installed with `--prefix`, pass the same `--prefix` to the uninstaller.

## Development

```
install.sh            install / upgrade the binary
uninstall.sh          uninstall
skills/lark/SKILL.md  the lark skill
```

CI (`.github/workflows/ci.yml`) does three things:

- Runs ShellCheck on both scripts.
- On Ubuntu and macOS, runs the installer against an empty scratch `HOME`, checks that it creates only one directory, and confirms that reinstalling works.
- Checks that exactly one skill is discoverable in the repo.

Locally, run `shellcheck install.sh uninstall.sh` and `sh install.sh --dry-run`.

## License

MIT
