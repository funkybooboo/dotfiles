---
name: roadmap
description: >
  Roadmap tracker for versioned development. Auto-loads when plans/roadmap.md exists.
  Updates checkboxes as work completes. Use for milestone-driven projects.
---

# Roadmap Tracking Skill

## Triggers
- File exists: `plans/roadmap.md`, `roadmap.md`, `ROADMAP.md`
- User mentions: "roadmap", "milestone", "version"
- Starting feature work in milestone-based project

## Core Rules
1. Read roadmap BEFORE coding
2. Check off items with ✅ when tests pass
3. Stay in scope (current milestone only)
4. Use Edit tool (surgical updates, preserve formatting)
5. Update format: `- [x] Item ✅` or `- [x] Item`

## Locations (Priority)
1. `./plans/roadmap.md`
2. `./roadmap.md`
3. `./ROADMAP.md`
4. `./docs/roadmap.md`
5. Ask user if not found

## Progress Format
After each completion:
"✅ Completed: [item]
📍 Next: [next unchecked item]
Progress: X/Y in [milestone name]"

## Update Protocol
- Use Edit tool to add ✅ to completed items
- Never remove context or reformat entire sections
- Surgical edits only
- Preserve existing formatting and structure

## Scope Management
- Only implement checked-off items in current milestone
- Ask permission before working on unchecked items
- Don't skip ahead to future milestones
- Respect milestone boundaries
