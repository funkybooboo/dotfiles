# OpenCode Configuration - Quick Reference

## Available Agents

### build (default)
**Description:** Fast and efficient coding assistant
**Use when:** General development work, quick fixes, feature implementation
**Temperature:** 0.3
**Switch to:** `opencode --agent build` (or just `opencode`)

### tdd
**Description:** Strict TDD mode - tests first, roadmap-driven
**Use when:** Working on milestone-based projects with roadmap.md
**Temperature:** 0.25
**Switch to:** `opencode --agent tdd`

**TDD Agent Workflow:**
1. Reads `plans/roadmap.md` or `roadmap.md` automatically
2. Enforces Red-Green-Refactor cycle
3. Auto-updates roadmap with [X] checkmarks
4. Runs tests before finishing
5. Concise, token-efficient communication

### explanatory
**Description:** Educational mode with detailed reasoning
**Use when:** Learning new concepts, understanding complex code
**Temperature:** 0.45
**Switch to:** `opencode --agent explanatory`

### learning
**Description:** Interactive teaching mode - learn by doing
**Use when:** Hands-on learning, guided practice
**Temperature:** 0.55
**Switch to:** `opencode --agent learning`

---

## Key Features

### Auto-Allowed Commands
Agents can now run these without asking permission:

**Testing:**
- `npm test`, `cargo test`, `pytest`, `bun test`, `go test`

**Building:**
- `npm run build`, `cargo build`, `tsc --noEmit`, `go build`

**Linting:**
- `biome check`, `cargo clippy`, `ruff check`, `eslint`

### Pre-Completion Checklist
All agents now verify before finishing:
- [X] Tests written and passing
- [X] Build succeeds
- [X] Linter clean
- [X] Roadmap updated (if exists)
- [X] No debug code left behind
- [X] Error handling present

### Roadmap Integration
When `plans/roadmap.md` or `roadmap.md` exists:
- Agents read it on project start
- Update with [X] as tasks complete
- Stay in scope (current milestone only)
- Use surgical edits (preserve formatting)

---

## Performance Optimizations

### Parallel Tool Calls
Agents now batch independent operations:
```
[OK] Read(file1.ts), Read(file2.ts), Read(file3.ts)
[X] Sequential reads (wasteful)
```

### Smart Exploration
Use Task(explore) for broad searches:
```
[OK] Task(explore, "find all API endpoints")
[X] Manual grep/glob chains
```

---

## Debugging Protocol

All agents follow systematic debugging:
1. **Reproduce** - Confirm error exists
2. **Isolate** - Find exact failure point
3. **Hypothesize** - Form theory about cause
4. **Fix** - Smallest possible change
5. **Verify** - Run tests to confirm
6. **Prevent** - Add regression test

---

## Skills

### Roadmap Tracker (Optional)
**Location:** `~/.config/opencode/skills/roadmap/SKILL.md`
**Auto-loads when:** Project has `plans/roadmap.md`
**Features:**
- Automatic progress tracking
- Milestone-aware development
- Checkbox updates with [X]
- Scope management

---

## File Structure

```
~/.config/opencode/
├── AGENTS.md              # Global rules (enhanced with TDD, checklist, debugging)
├── opencode.json          # Agent definitions + permissions
├── USAGE.md               # This file
├── prompts/
│   ├── default.txt        # Build agent prompt
│   ├── tdd.txt            # TDD agent prompt (NEW)
│   ├── explanatory.txt    # Explanatory agent prompt
│   └── learning.txt       # Learning agent prompt
└── skills/
    └── roadmap/           # Roadmap tracking skill (NEW)
        └── SKILL.md
```

---

## Examples

### Using TDD Agent
```bash
cd ~/projects/lazycsv
opencode --agent tdd

# Agent automatically:
# 1. Reads plans/roadmap.md
# 2. Enforces test-first development
# 3. Updates roadmap with [X]
# 4. Runs cargo test && cargo clippy before finishing
```

### Using Build Agent (Default)
```bash
cd ~/projects/myapp
opencode

# Agent:
# 1. Fast, efficient development
# 2. Runs tests before finishing
# 3. Follows quality checklist
# 4. Updates roadmap if exists
```

---

## Tips

1. **Use TDD agent for milestone work** - Enforces discipline and roadmap sync
2. **Use build agent for quick fixes** - Faster, less strict workflow
3. **Roadmap format matters** - Use `- [ ]` for unchecked, `- [x]` for checked
4. **Let agents run tests** - They're auto-allowed now, no permission needed
5. **Trust the checklist** - Agents verify quality before finishing

---

## Troubleshooting

**Agent not updating roadmap?**
- Check file exists: `plans/roadmap.md` or `roadmap.md`
- Verify format: `- [ ] Task description`
- Use TDD agent for stricter enforcement

**Tests not running automatically?**
- Check permissions in `opencode.json`
- Verify test command is auto-allowed
- Agent should run before finishing

**Want to skip checklist?**
- Use build agent (less strict)
- Or explicitly tell agent to skip

---

**Last Updated:** Feb 21, 2026
**Version:** 2.0 (TDD + Roadmap Integration)