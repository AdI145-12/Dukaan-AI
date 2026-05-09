---
mode: agent
description: Refactor a file in Dukaan AI while preserving architecture
---

# Safe Refactor Workflow

## Step 1 — Read Before Refactoring (Mandatory)

Before changing any code:
1. Read the file to be refactored fully
2. Read every file that imports from it
3. Read the test file for this module (if exists)

State:
- What the file currently does
- What public interface it exposes (method signatures, exported classes)
- How many other files depend on it (import count)
- What is the specific problem being solved by this refactor

Do NOT begin refactoring until these are answered.

## Step 2 — Refactor Contract
The refactor MUST:
- [ ] Preserve all existing public method signatures (unless explicitly changing API)
- [ ] Not introduce new external dependencies
- [ ] Not change behavior — only structure/readability/performance
- [ ] Keep or improve test coverage
- [ ] Follow naming conventions from `.github/instructions/`

The refactor must NOT:
- [ ] Mix architectural concerns (e.g., Supabase logic in a widget)
- [ ] Create new abstractions unless duplication spans 3+ locations
- [ ] Change state management approach mid-refactor
- [ ] Rename files without updating all imports

## Step 3 — Diff Summary
After refactoring, provide:
1. Summary of what changed (bullet points)
2. Summary of what did NOT change (confirm interface preserved)
3. List of files that need to be updated as a result (import changes, etc.)
4. Whether tests need to be updated — and the specific changes needed

## Step 4 — Safety Check
Answer: "Could this refactor change any observable behavior for the end user?"
If YES → describe exactly how and get confirmation before finalizing.
If NO → state why it is behavior-neutral.
