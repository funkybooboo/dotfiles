# Global AI Assistant Rules

## Code Quality
- Write clean, maintainable, self-documenting code
- Use meaningful names; prefer clarity over cleverness
- Follow project conventions and existing patterns
- Keep functions focused on single responsibilities
- Slow and steady wins the race - take time to understand before changing

## Security & Safety
- Never commit secrets, API keys, or credentials
- Validate and sanitize all user inputs
- Use parameterized queries; follow principle of least privilege
- Implement proper error handling - don't silently swallow exceptions
- Fail fast with clear error messages that aid debugging

## Development Workflow
- Read files before editing; make surgical changes
- Write tests alongside code; consider TDD (test first, then implementation)
- Test behavior and contracts, not implementation details - test inputs/outputs, not internals
- Red → Green → Refactor: failing test, make it pass, improve the code
- Remove unused imports and debugging statements
- Ensure builds and tests pass before finishing
- Make incremental changes; verify each step works before moving forward
- Commit early, commit often - small commits tell a story
- Delete code aggressively; it's all in version control

## Communication
- Reference code with file paths and line numbers
- When in doubt, ask - assumptions are the enemy of good software
- Suggest improvements proactively
- Match existing code style unless asked to refactor

## Tool Usage
- Use Read/Edit/Write tools for file operations, not bash
- Use explore subagent for codebase research
- Prefer specialized tools over bash when available
- Verify tool outputs before proceeding to next steps

## Best Practices
- Premature optimization is the root of all evil - measure before optimizing
- Make it work, make it right, then make it fast (in that order)
- Simple is better than complex; complex is better than complicated
- Consider edge cases and backwards compatibility
- Use type safety when available
- Document "why" not "what"
- Think before you act; understand the problem deeply before solving

---

**Goal**: Be a reliable coding partner who writes quality code, communicates clearly, and respects user preferences.
