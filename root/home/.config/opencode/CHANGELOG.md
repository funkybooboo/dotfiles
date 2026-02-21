# OpenCode Configuration Changelog

## Version 2.0 - TDD & Roadmap Integration (Feb 21, 2026)

### 🎯 Major Improvements

#### New TDD Agent
- **Strict TDD mode** enforcing Red-Green-Refactor workflow
- **Automatic roadmap integration** - reads and updates `plans/roadmap.md`
- **Token-efficient communication** - concise progress updates only
- **Lower temperature (0.25)** for more focused, deterministic behavior
- **Auto-runs quality gates** before finishing work

#### Enhanced AGENTS.md
Added comprehensive new sections:
- **TDD Workflow** - Step-by-step Red-Green-Refactor process
- **Roadmap Integration** - Automatic tracking and checkbox updates
- **Pre-Completion Checklist** - Mandatory quality gates before finishing
- **Performance & Token Efficiency** - Parallel reads, smart tool selection
- **Debugging Protocol** - Systematic 6-step debugging approach

#### Enhanced Permissions (opencode.json)
Auto-allowed commands (no permission needed):
- **Testing:** `npm test`, `cargo test`, `pytest`, `bun test`, `go test`
- **Building:** `npm run build`, `cargo build`, `tsc --noEmit`, `go build`
- **Linting:** `biome check`, `cargo clippy`, `ruff check`, `eslint`

#### New Skills
- **Roadmap Tracker** (`skills/roadmap/`) - Enhanced milestone tracking
- **Omarchy** (`skills/omarchy/`) - Symlinked for system config management

#### Documentation
- **USAGE.md** - Quick reference guide for all agents and features
- **CHANGELOG.md** - This file

---

### 📊 Comparison: Before vs After

| Feature | Before | After |
|---------|--------|-------|
| **Agents** | 3 (build, explanatory, learning) | 4 (+ tdd) |
| **TDD Enforcement** | Manual | Automatic (tdd agent) |
| **Roadmap Sync** | Manual | Automatic |
| **Test Commands** | Ask permission | Auto-allowed |
| **Build Commands** | Ask permission | Auto-allowed |
| **Linter Commands** | Ask permission | Auto-allowed |
| **Quality Checklist** | Informal | Mandatory pre-finish |
| **Token Efficiency** | Baseline | Optimized (parallel calls) |
| **Debugging** | Ad-hoc | Systematic protocol |
| **Skills** | 0 | 2 (roadmap, omarchy) |

---

### 🚀 Usage Examples

#### Before (Manual TDD)
```bash
opencode
# User: "Write a test for the login function"
# Agent: Writes test
# User: "Now implement it"
# Agent: Implements
# User: "Run the tests"
# Agent: Asks permission to run npm test
# User: Approves
# Agent: Runs tests
# User: "Update the roadmap"
# Agent: Asks which file
# User: "plans/roadmap.md"
# Agent: Updates manually
```

#### After (Automatic TDD)
```bash
opencode --agent tdd
# Agent: Reads plans/roadmap.md automatically
# Agent: "RED: Writing failing test for login function"
# Agent: "GREEN: Test passing, implementation complete"
# Agent: "Updated roadmap: ✅ Login function"
# Agent: Runs npm test && npm run build automatically
# Agent: "All checks passed. Work complete."
```

---

### 📁 File Changes

#### Modified Files
- `AGENTS.md` - Added 4 new sections (TDD, Performance, Checklist, Debugging)
- `opencode.json` - Added tdd agent + 15 auto-allowed bash commands

#### New Files
- `prompts/tdd.txt` - TDD agent system prompt
- `skills/roadmap/SKILL.md` - Roadmap tracking skill
- `skills/omarchy/` - Symlink to omarchy skill
- `USAGE.md` - Quick reference guide
- `CHANGELOG.md` - This file

---

### 🎓 Migration Guide

#### For Existing Users

**No breaking changes!** All existing workflows continue to work.

**To try TDD mode:**
```bash
cd your-project-with-roadmap
opencode --agent tdd
```

**To use default mode:**
```bash
opencode  # Same as before
```

**Roadmap format:**
```markdown
## v1.0.0 - Feature Name
- [ ] Unchecked task
- [x] Completed task ✅
```

---

### 🔧 Technical Details

#### Agent Temperature Settings
- **build:** 0.3 (balanced)
- **tdd:** 0.25 (focused, deterministic)
- **explanatory:** 0.45 (creative explanations)
- **learning:** 0.55 (interactive, exploratory)

#### Roadmap Detection
Agents check these locations in order:
1. `./plans/roadmap.md`
2. `./roadmap.md`
3. `./ROADMAP.md`
4. `./docs/roadmap.md`

#### Pre-Completion Checklist
All agents now verify:
1. Tests written and passing
2. Build succeeds
3. Linter clean
4. Roadmap updated (if exists)
5. No debug code
6. Error handling present

---

### 🐛 Known Issues

None currently. Report issues to the configuration maintainer.

---

### 🔮 Future Enhancements

Potential improvements for v3.0:
- Per-project `.opencode/config.json` support
- Custom skill templates
- Automated skill discovery
- Integration with git hooks
- Pre-commit quality gates
- Automated changelog generation

---

### 📚 Resources

- **USAGE.md** - Quick reference for all features
- **AGENTS.md** - Complete rules and guidelines
- **opencode.json** - Agent and permission configuration
- **skills/** - Available skills and their documentation

---

**Contributors:** AI Assistant  
**Date:** February 21, 2026  
**Version:** 2.0.0
