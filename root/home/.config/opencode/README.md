# OpenCode Configuration

Enhanced AI coding assistant configuration with TDD workflow, roadmap integration, and performance optimizations.

## 🚀 Quick Start

```bash
# Default mode (fast, efficient)
opencode

# TDD mode (strict, roadmap-driven)
opencode --agent tdd

# Educational mode (detailed explanations)
opencode --agent explanatory

# Learning mode (interactive teaching)
opencode --agent learning
```

## 📁 Directory Structure

```
~/.config/opencode/
├── AGENTS.md              # Global rules and guidelines
├── opencode.json          # Agent definitions and permissions
├── README.md              # This file
├── USAGE.md               # Detailed usage guide
├── CHANGELOG.md           # Version history
├── prompts/
│   ├── default.txt        # Build agent (default)
│   ├── tdd.txt            # TDD agent (NEW)
│   ├── explanatory.txt    # Educational agent
│   └── learning.txt       # Interactive learning agent
└── skills/
    ├── omarchy/           # System config management (symlink)
    │   └── SKILL.md
    └── roadmap/           # Roadmap tracking (NEW)
        └── SKILL.md
```

## ✨ New Features (v2.0)

### TDD Agent
- Enforces Red-Green-Refactor workflow
- Auto-reads and updates `plans/roadmap.md`
- Runs tests/build/linter before finishing
- Token-efficient communication

### Enhanced Permissions
Auto-allowed commands (no permission needed):
- **Tests:** `npm test`, `cargo test`, `pytest`, `bun test`, `go test`
- **Build:** `npm run build`, `cargo build`, `tsc --noEmit`
- **Lint:** `biome check`, `cargo clippy`, `ruff check`, `eslint`

### Pre-Completion Checklist
All agents verify before finishing:
- ✅ Tests passing
- ✅ Build succeeds
- ✅ Linter clean
- ✅ Roadmap updated
- ✅ No debug code
- ✅ Error handling present

### Performance Optimizations
- Parallel file reads
- Smart tool selection
- Avoid redundant operations
- Concise communication

## 🎯 Agent Comparison

| Agent | Temperature | Best For | Communication |
|-------|-------------|----------|---------------|
| **build** | 0.3 | General development, quick fixes | Concise, efficient |
| **tdd** | 0.25 | Milestone work, strict TDD | Minimal, progress-only |
| **explanatory** | 0.45 | Learning, understanding code | Detailed, educational |
| **learning** | 0.55 | Hands-on practice, tutorials | Interactive, guided |

## 📚 Documentation

- **[USAGE.md](USAGE.md)** - Complete usage guide with examples
- **[CHANGELOG.md](CHANGELOG.md)** - Version history and changes
- **[AGENTS.md](AGENTS.md)** - Full rules and guidelines

## 🔧 Skills

### Roadmap Tracker
**Location:** `skills/roadmap/SKILL.md`  
**Triggers:** When `plans/roadmap.md` exists  
**Features:**
- Automatic progress tracking
- Checkbox updates with ✅
- Milestone-aware development
- Scope management

### Omarchy
**Location:** `skills/omarchy/SKILL.md` (symlink)  
**Triggers:** System config changes (Hyprland, waybar, etc.)  
**Features:**
- Safe system configuration
- Window manager rules
- Theme management
- Display configuration

## 🎓 Examples

### Using TDD Agent
```bash
cd ~/projects/lazycsv
opencode --agent tdd

# Agent automatically:
# 1. Reads plans/roadmap.md
# 2. Enforces test-first development
# 3. Updates roadmap with ✅
# 4. Runs cargo test && cargo clippy
```

### Roadmap Format
```markdown
## v1.0.0 - Feature Name
- [ ] Unchecked task (not started)
- [x] Completed task ✅
- [x] Another completed task
```

## 🔍 Verification

Check your configuration:
```bash
# List available agents
grep -A 2 '"description"' ~/.config/opencode/opencode.json

# List skills
ls -1 ~/.config/opencode/skills/

# List prompts
ls -1 ~/.config/opencode/prompts/

# Verify omarchy skill
cat ~/.config/opencode/skills/omarchy/SKILL.md | head -5

# Verify roadmap skill
cat ~/.config/opencode/skills/roadmap/SKILL.md | head -5
```

## 🐛 Troubleshooting

**Agent not found?**
- Check `opencode.json` has agent definition
- Verify prompt file exists in `prompts/`

**Roadmap not updating?**
- Ensure file is named `plans/roadmap.md` or `roadmap.md`
- Use TDD agent for stricter enforcement
- Check format: `- [ ]` for unchecked, `- [x]` for checked

**Tests not running?**
- Verify command is in auto-allowed list in `opencode.json`
- Check project has test command configured

**Skill not loading?**
- Verify `SKILL.md` exists in skill directory
- Check skill frontmatter has `name` and `description`

## 📊 Status

**Version:** 2.0.0  
**Last Updated:** Feb 21, 2026  
**Agents:** 4 (build, tdd, explanatory, learning)  
**Skills:** 2 (omarchy, roadmap)  
**Auto-Allowed Commands:** 15+

## 🎉 Success!

Your OpenCode configuration is now optimized for:
- ✅ TDD-driven development
- ✅ Roadmap-based milestone tracking
- ✅ Token-efficient operations
- ✅ Automated quality gates
- ✅ Systematic debugging
- ✅ Performance optimization

**Ready to code!** 🚀
