---
name: ascii-convert
description: >
  Tools for normalizing text files to ASCII characters. Use when cleaning up code files
  with smart quotes, em dashes, accented characters, or emojis. Triggers: ASCII conversion,
  normalize quotes, remove emojis, fix encoding, transliterate characters, clean text files,
  smart quotes, curly quotes, non-ASCII characters, tree characters, box drawing.
---

# ASCII Convert Skill

Normalize non-ASCII characters in text files to ASCII equivalents using the
`opencode-ascii-convert` script at `~/.pi/agent/skills/ascii-convert/opencode-ascii-convert`
(tracked in ~/dotfiles, symlinked live).

## Usage

```bash
~/.pi/agent/skills/ascii-convert/opencode-ascii-convert              # dry run (default, safe preview)
~/.pi/agent/skills/ascii-convert/opencode-ascii-convert --apply      # apply, with .bak backups
~/.pi/agent/skills/ascii-convert/opencode-ascii-convert --apply ~/some/dir
```

Always dry-run first to preview; `--apply` writes `.bak` backups next to each
modified file (drop them with `--no-backup` only when the tree is disposable).
Scope it by running from (or passing) the specific subdirectory you want cleaned.

## Conversions

- Smart/curly quotes -> straight quotes (" ' " ')
- Em/en dashes -> `--` / `-`; ellipsis -> `...`
- Tree/box-drawing -> ASCII (`|--`, `\-`, `|`)
- Accented letters -> base letter (cafe-accent -> e, n-tilde -> n, etc.)
- Bullets -> `-`; NBSP/thin space -> space
- Emoji and any other remaining non-ASCII: removed entirely

## Scope

Processes .md .txt .py .js .ts .tsx .jsx .rs .go .java .c .cpp .h .rb .php .lua
.vim .sh .bash .zsh .yaml .yml .json .toml .conf .config .ini .html .css .scss
.xml .sql .csv. Skips node_modules, .git, dist, build, target, vendor, .cache,
__pycache__, existing .bak files, and binary/image files.

## When to use

- Cleaning copy-pasted text that carries smart quotes or em dashes into code/docs
- Preparing a repo for an ASCII-only policy (pair with the pi ascii-guard hook)
- Converting Unicode tree diagrams in comments/READMEs to ASCII