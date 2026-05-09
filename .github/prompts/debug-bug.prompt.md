---
mode: ask
description: Debug a bug in Dukaan AI — forces read-before-write workflow
---

# Bug Debug Workflow

## Step 1 — Understand Before Fixing (Mandatory — Do Not Skip)

Answer these questions before suggesting any fix:

1. **Which file(s) are involved?** List the exact file paths.
2. **What is the current behavior?** Describe precisely what is happening.
3. **What is the expected behavior?** Describe what should happen.
4. **What is the full error message?** (paste it — never paraphrase)
5. **Which layer is the bug in?**
   - Presentation (widget/screen rendering)
   - Application (Riverpod state/provider)
   - Domain (model/business logic)
   - Infrastructure (Supabase query/repository)
   - Worker (Cloudflare Worker handler)

Do NOT suggest a fix until all 5 answers are stated.

## Step 2 — Root Cause Analysis

After reading the relevant files, state:
- The exact line or block causing the issue
- Why it is wrong (not just that it is wrong)
- Whether this is a symptom of a deeper architectural issue

## Step 3 — Fix Constraints
- Fix ONLY the identified issue
- Do NOT refactor unrelated code in the same edit
- Do NOT change method signatures unless the signature IS the bug
- Do NOT add new dependencies unless essential
- If the fix requires touching > 2 files, state this upfront and get confirmation

## Step 4 — Verify the Fix
After fixing:
1. Show what the corrected code looks like
2. Explain why this fix addresses the root cause
3. State whether an existing test covers this case — if not, write one
