---
name: roadmap
description: >
  Guidance on Semantic Versioning (SemVer) for version management and roadmap planning.
  Use when creating releases, bumping versions, planning features, or managing changelogs.
  Triggers: version bump, semantic versioning, semver, release planning, MAJOR.MINOR.PATCH,
  backward compatibility, breaking changes, version numbers, changelog, release.
---

# Roadmap Skill

Guide for managing project versions using Semantic Versioning (SemVer) principles.

## When This Skill MUST Be Used

**ALWAYS invoke this skill when the user's request involves ANY of these:**

- Bumping version numbers
- Creating releases or tags
- Planning roadmap features
- Managing changelogs
- Deciding version increment strategy
- Questions about backward compatibility
- Breaking change decisions
- Pre-release versioning (alpha, beta, RC)

## Semantic Versioning Summary

Given a version number **MAJOR.MINOR.PATCH**, increment the:

1. **MAJOR** version when you make incompatible API changes
2. **MINOR** version when you add functionality in a backward compatible manner
3. **PATCH** version when you make backward compatible bug fixes

Additional labels for pre-release and build metadata are available as extensions to the MAJOR.MINOR.PATCH format.

## Quick Decision Guide

| Change Type | Version Bump | Example |
|-------------|--------------|---------|
| Bug fix (no API change) | PATCH | 1.2.3 -> 1.2.4 |
| New feature (backward compatible) | MINOR | 1.2.3 -> 1.3.0 |
| Breaking change | MAJOR | 1.2.3 -> 2.0.0 |
| Initial development | 0.x.x | 0.1.0 -> 0.2.0 |
| First stable release | 1.0.0 | 0.9.5 -> 1.0.0 |
| Pre-release | Add suffix | 1.0.0-alpha.1 |
| Build metadata | Add + suffix | 1.0.0+20130313 |

## Key SemVer Rules

### 1. Declare a Public API
Software using Semantic Versioning MUST declare a public API. This API could be declared in the code itself or exist strictly in documentation.

### 2. Version Format
A normal version number MUST take the form X.Y.Z where X, Y, and Z are non-negative integers, and MUST NOT contain leading zeroes.
- X = major version
- Y = minor version
- Z = patch version

Example: 1.9.0 -> 1.10.0 -> 1.11.0

### 3. Immutability
Once a versioned package has been released, the contents of that version MUST NOT be modified. Any modifications MUST be released as a new version.

### 4. Initial Development (0.y.z)
Major version zero (0.y.z) is for initial development. Anything MAY change at any time. The public API SHOULD NOT be considered stable.

### 5. First Stable Release (1.0.0)
Version 1.0.0 defines the public API. The way in which the version number is incremented after this release is dependent on this public API and how it changes.

### 6. Patch Version (x.y.Z)
MUST be incremented if only backward compatible bug fixes are introduced. A bug fix is defined as an internal change that fixes incorrect behavior.

### 7. Minor Version (x.Y.z)
MUST be incremented if:
- New, backward compatible functionality is introduced to the public API
- Any public API functionality is marked as deprecated
- Substantial new functionality or improvements are introduced within private code

Patch version MUST be reset to 0 when minor version is incremented.

### 8. Major Version (X.y.z)
MUST be incremented if any backward incompatible changes are introduced to the public API. It MAY also include minor and patch level changes.

Patch and minor versions MUST be reset to 0 when major version is incremented.

### 9. Pre-release Versions
A pre-release version MAY be denoted by appending a hyphen and a series of dot separated identifiers immediately following the patch version.

Examples:
- 1.0.0-alpha
- 1.0.0-alpha.1
- 1.0.0-beta
- 1.0.0-rc.1

Pre-release versions have a lower precedence than the associated normal version.

### 10. Build Metadata
Build metadata MAY be denoted by appending a plus sign and a series of dot separated identifiers immediately following the patch or pre-release version.

Examples:
- 1.0.0+20130313144700
- 1.0.0-beta+exp.sha.5114f85

Build metadata MUST be ignored when determining version precedence.

### 11. Version Precedence
Precedence is determined by the first difference when comparing each identifier from left to right:

1. Major, minor, and patch versions are always compared numerically
   - Example: 1.0.0 < 2.0.0 < 2.1.0 < 2.1.1

2. When major, minor, and patch are equal, a pre-release version has lower precedence than a normal version
   - Example: 1.0.0-alpha < 1.0.0

3. Pre-release precedence example:
   - 1.0.0-alpha < 1.0.0-alpha.1 < 1.0.0-alpha.beta < 1.0.0-beta < 1.0.0-beta.2 < 1.0.0-beta.11 < 1.0.0-rc.1 < 1.0.0

## Common Scenarios

### Scenario 1: Bug Fix Only
**Situation:** Fixed a bug, no API changes, no new features
**Action:** Increment PATCH version
**Example:** 1.2.3 -> 1.2.4

### Scenario 2: New Feature (Backward Compatible)
**Situation:** Added new function/method, existing code still works
**Action:** Increment MINOR version, reset PATCH to 0
**Example:** 1.2.3 -> 1.3.0

### Scenario 3: Breaking Change
**Situation:** Changed function signature, removed feature, changed behavior
**Action:** Increment MAJOR version, reset MINOR and PATCH to 0
**Example:** 1.2.3 -> 2.0.0

### Scenario 4: Initial Development
**Situation:** Project not yet stable, rapid iteration
**Action:** Use 0.x.x versioning, increment MINOR for features, PATCH for fixes
**Example:** 0.1.0 -> 0.2.0 -> 0.2.1

### Scenario 5: First Stable Release
**Situation:** API is stable, ready for production use
**Action:** Release 1.0.0
**Example:** 0.9.5 -> 1.0.0

### Scenario 6: Deprecation
**Situation:** Marking feature as deprecated (but not removed)
**Action:** Increment MINOR version (backward compatible)
**Example:** 1.2.3 -> 1.3.0 (with deprecation notice)

### Scenario 7: Pre-release Testing
**Situation:** Testing before official release
**Action:** Use pre-release suffix
**Examples:**
- 2.0.0-alpha.1 (early testing)
- 2.0.0-beta.1 (feature complete, testing)
- 2.0.0-rc.1 (release candidate)
- 2.0.0 (final release)

### Scenario 8: Accidental Breaking Change
**Situation:** Released breaking change as minor/patch version
**Action:** 
1. Fix the problem immediately
2. Release new minor version that restores backward compatibility
3. Document the offending version
4. Inform users of the problem

## Version Format Rules

### Valid Versions
- 1.0.0
- 1.2.3
- 0.1.0
- 1.0.0-alpha
- 1.0.0-alpha.1
- 1.0.0-0.3.7
- 1.0.0+20130313144700
- 1.0.0-beta+exp.sha.5114f85

### Invalid Versions
- v1.0.0 (prefix not allowed in version string itself)
- 1.0 (must have all three numbers)
- 1.2.3.4 (only three numbers allowed)
- 01.0.0 (no leading zeroes)

**Note:** Prefixing with "v" is common in version control tags (e.g., `git tag v1.0.0`) but "v1.0.0" is not a semantic version - "1.0.0" is.

## FAQ

### When should I release 1.0.0?
If your software is being used in production, it should probably already be 1.0.0. If you have a stable API on which users have come to depend, you should be 1.0.0.

### Doesn't this discourage rapid development?
Major version zero (0.y.z) is all about rapid development. If you're changing the API every day, you should either still be in version 0.y.z or on a separate development branch.

### What if I accidentally release a breaking change as a minor version?
Fix the problem and release a new minor version that corrects the problem and restores backward compatibility. Document the offending version and inform your users.

### What if I update dependencies without changing the public API?
That would be considered compatible since it does not affect the public API. Determining whether the change is a patch level or minor level modification depends on whether you updated your dependencies to fix a bug (PATCH) or introduce new functionality (MINOR).

### How should I handle deprecating functionality?
When you deprecate part of your public API:
1. Update your documentation to let users know about the change
2. Issue a new MINOR release with the deprecation in place
3. Before you completely remove the functionality in a new MAJOR release, there should be at least one minor release that contains the deprecation

## Resources

- Official Specification: https://semver.org/
- SemVer 2.0.0 Full Spec: https://semver.org/spec/v2.0.0.html

## Decision Checklist

Before bumping a version, ask:

- [ ] Does this change the public API?
  - No -> PATCH (if bug fix) or MINOR (if internal improvement)
  - Yes -> Continue...

- [ ] Is the API change backward compatible?
  - Yes -> MINOR
  - No -> MAJOR

- [ ] Am I in initial development (0.x.x)?
  - Yes -> Use 0.MINOR.PATCH, anything can change
  - No -> Follow rules above

- [ ] Is this a pre-release?
  - Yes -> Add -alpha, -beta, or -rc suffix
  - No -> Use standard X.Y.Z format

- [ ] Do I need build metadata?
  - Yes -> Add +metadata suffix
  - No -> Standard version is complete
