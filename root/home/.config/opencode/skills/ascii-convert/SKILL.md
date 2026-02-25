---
name: ascii-convert
description: >
  Tools for normalizing text files to ASCII characters. Use when cleaning up code files
  with smart quotes, em dashes, accented characters, or emojis. Triggers: ASCII conversion,
  normalize quotes, remove emojis, fix encoding, transliterate characters, clean text files,
  smart quotes, curly quotes, non-ASCII characters, tree characters, box drawing.
---

# ASCII Convert Skill

Normalize non-ASCII characters in text files to ASCII equivalents.

## When This Skill MUST Be Used

**ALWAYS invoke this skill when the user's request involves ANY of these:**

- Converting smart quotes to regular quotes
- Fixing curly quotes in code or documentation
- Removing emojis from text files
- Transliterating accented characters
- Normalizing em dashes and en dashes
- Converting tree/box-drawing characters to ASCII
- Cleaning up text encoding issues
- Preparing files for ASCII-only environments
- Fixing copy-paste formatting issues

## What It Does

The `opencode-ascii-convert` script recursively processes text files in the current directory and converts non-ASCII characters to their ASCII equivalents.

**Key Features:**
- Dry-run mode by default (safe preview)
- Automatic backup creation (.bak files)
- Recursive directory processing
- Smart file type detection
- Comprehensive character mapping
- Color-coded output
- Summary statistics

## Character Conversion Table

### Smart Quotes
```
"  ->  "   (left double quote)
"  ->  "   (right double quote)
'  ->  '   (left single quote)
'  ->  '   (right single quote)
„  ->  "   (double low-9 quote)
‚  ->  '   (single low-9 quote)
```

### Dashes
```
—  ->  --  (em dash)
–  ->  -   (en dash)
‒  ->  -   (figure dash)
```

### Ellipsis
```
…  ->  ... (horizontal ellipsis)
```

### Tree/Box-Drawing Characters
```
├─  ->  |-   (tree branch)
└─  ->  \-   (tree last branch)
│   ->  |    (tree vertical line)
─   ->  -    (tree horizontal line)
┌─  ->  /-   (box top-left corner)
┐   ->  -\   (box top-right corner)
┘   ->  -/   (box bottom-right corner)
┼─  ->  +-   (box cross)
```

**Example tree conversion:**
```
Before:
~/project/
├── src/
│   └── main.rs
└── tests/

After:
~/project/
|-- src/
|   \-- main.rs
\-- tests/
```

### Accented Characters (Transliteration)
```
À Á Â Ã Ä Å  ->  A
à á â ã ä å  ->  a
È É Ê Ë      ->  E
è é ê ë      ->  e
Ì Í Î Ï      ->  I
ì í î ï      ->  i
Ò Ó Ô Õ Ö Ø  ->  O
ò ó ô õ ö ø  ->  o
Ù Ú Û Ü      ->  U
ù ú û ü      ->  u
Ý Ÿ          ->  Y
ý ÿ          ->  y
Ñ            ->  N
ñ            ->  n
Ç            ->  C
ç            ->  c
Æ            ->  AE
æ            ->  ae
Œ            ->  OE
œ            ->  oe
```

### Spaces
```
  ->     (non-breaking space to regular space)
  ->     (thin space to regular space)
```

### Bullets and Symbols
```
•  ->  -   (bullet)
·  ->  -   (middle dot)
×  ->  x   (multiplication sign)
÷  ->  /   (division sign)
```

### Emojis and Other Non-ASCII
All remaining non-ASCII characters (including emojis) are removed entirely.

## Target Files

### Included File Extensions
The script processes these file types:
- **Markdown/Text:** .md, .txt
- **Programming:** .py, .js, .ts, .tsx, .jsx, .rs, .go, .java, .c, .cpp, .h, .hpp, .rb, .php, .pl, .r, .lua, .vim, .el
- **Shell:** .sh, .bash, .zsh
- **Config:** .yaml, .yml, .json, .toml, .conf, .config, .ini
- **Web:** .html, .css, .scss, .xml
- **Data:** .sql, .csv

### Excluded Directories
The script skips these directories:
- node_modules
- .git
- dist
- build
- target
- vendor
- .next
- .cache
- __pycache__

### Excluded Files
- Binary files (detected automatically)
- Existing .bak files
- Image files
- Compressed archives

## Usage

### Basic Usage

**Dry run (preview changes):**
```bash
opencode-ascii-convert
```

This shows what would be changed without modifying any files.

**Apply changes:**
```bash
opencode-ascii-convert --apply
```

This creates .bak backups and modifies files.

**Apply without backups (not recommended):**
```bash
opencode-ascii-convert --apply --no-backup
```

**Show help:**
```bash
opencode-ascii-convert --help
```

### Example Output

```
Processing: src/utils.js
  - 12 smart quotes -> regular quotes
  - 3 em dashes -> hyphens
  - 8 tree characters -> ASCII equivalents
  - 1 accented character -> ASCII
  ✓ Backed up to src/utils.js.bak

Processing: README.md
  ✓ No non-ASCII characters found

Processing: docs/guide.md
  - 5 smart quotes -> regular quotes
  - 2 ellipsis -> three dots
  ✓ Backed up to docs/guide.md.bak

Summary:
  Files processed: 3
  Files modified: 2
  Total replacements: 31
```

## Safety Features

### 1. Dry-Run Default
The script runs in preview mode by default. You must explicitly use `--apply` to make changes.

### 2. Automatic Backups
Before modifying any file, the script creates a `.bak` backup with the original content.

### 3. File Type Detection
Binary files are automatically skipped to prevent corruption.

### 4. Excluded Patterns
Common build artifacts and dependency directories are excluded.

### 5. Backup Skip
Existing `.bak` files are not processed to avoid re-processing backups.

## Common Use Cases

### 1. Clean Up Copy-Pasted Code
When copying code from websites or documents, smart quotes and special characters often get pasted:

```bash
cd ~/project
opencode-ascii-convert --apply
```

### 2. Fix Documentation
README files often contain smart quotes from word processors:

```bash
cd ~/project/docs
opencode-ascii-convert --apply
```

### 3. Prepare for ASCII-Only Systems
Some systems or tools require pure ASCII:

```bash
cd ~/config-files
opencode-ascii-convert --apply
```

### 4. Clean Repository Before Commit
Ensure all files use ASCII characters:

```bash
cd ~/project
opencode-ascii-convert --apply
git add .
git commit -m "Normalize to ASCII characters"
```

### 5. Fix Tree Diagrams
Convert Unicode tree structures to ASCII:

```bash
# Your README.md has:
# ~/project/
# ├── src/
# │   └── main.rs
# └── tests/

opencode-ascii-convert --apply

# Now it has:
# ~/project/
# |-- src/
# |   \-- main.rs
# \-- tests/
```

## Troubleshooting

### Issue: Script not found
**Solution:** Ensure you're running from a directory where the skill is accessible:
```bash
~/.config/opencode/skills/ascii-convert/opencode-ascii-convert --help
```

### Issue: Permission denied
**Solution:** Make sure the script is executable:
```bash
chmod +x ~/.config/opencode/skills/ascii-convert/opencode-ascii-convert
```

### Issue: Too many files modified
**Solution:** Run without `--apply` first to preview changes:
```bash
opencode-ascii-convert
```

### Issue: Need to restore original
**Solution:** Restore from .bak files:
```bash
# Restore single file
cp file.txt.bak file.txt

# Restore all files in directory
find . -name "*.bak" -exec sh -c 'cp "$1" "${1%.bak}"' _ {} \;
```

### Issue: Want to process specific directory
**Solution:** Change to that directory first:
```bash
cd ~/project/src
opencode-ascii-convert --apply
```

## Best Practices

1. **Always preview first:** Run without `--apply` to see what will change
2. **Keep backups:** Don't use `--no-backup` unless you're certain
3. **Test on small directory first:** Try on a subdirectory before running on entire project
4. **Commit before running:** If using version control, commit first so you can easily revert
5. **Review changes:** After applying, review the changes before committing
6. **Use in CI/CD:** Add to pre-commit hooks to enforce ASCII-only files

## Integration Examples

### Pre-commit Hook
```bash
#!/bin/bash
# .git/hooks/pre-commit

# Check for non-ASCII characters
if ~/.config/opencode/skills/ascii-convert/opencode-ascii-convert | grep -q "would be modified"; then
  echo "Error: Non-ASCII characters detected. Run 'opencode-ascii-convert --apply' first."
  exit 1
fi
```

### Makefile Target
```makefile
.PHONY: ascii-clean
ascii-clean:
	~/.config/opencode/skills/ascii-convert/opencode-ascii-convert --apply
```

### NPM Script
```json
{
  "scripts": {
    "ascii-clean": "~/.config/opencode/skills/ascii-convert/opencode-ascii-convert --apply"
  }
}
```

## Technical Details

### Character Encoding
The script processes files as UTF-8 and outputs ASCII (7-bit).

### Processing Method
Uses `sed` with multiple expressions for efficient single-pass processing.

### File Detection
Uses the `file` command to detect binary files and skip them.

### Performance
Processes files sequentially. For large codebases, consider running on specific subdirectories.

## Resources

- ASCII Table: https://www.asciitable.com/
- Unicode Character Table: https://unicode-table.com/
- UTF-8 Encoding: https://en.wikipedia.org/wiki/UTF-8
