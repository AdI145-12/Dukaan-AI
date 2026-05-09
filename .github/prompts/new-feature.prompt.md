---
mode: agent
description: Plan and scaffold a new feature end-to-end in Dukaan AI
---

# New Feature Scaffold

## Step 1 — Feature Scoping (Plan Before Build)

Answer before writing any code:
1. **Feature name:** (e.g., `catalogue`, `broadcast`, `upi_poster`)
2. **User story:** "As a [user], I want to [action] so that [benefit]"
3. **Screens needed:** list each screen name
4. **Supabase tables needed:** list existing or new tables
5. **Cloudflare Worker endpoints needed:** list each route
6. **Riverpod providers needed:** list each provider

Present this plan. Wait for confirmation before building.

## Step 2 — Scaffold Feature Folder
Create folder structure only (no implementation yet):
```
lib/features/${input:featureName}/
  presentation/
    screens/.gitkeep
    widgets/.gitkeep
  application/.gitkeep
  domain/.gitkeep
  infrastructure/.gitkeep
```

## Step 3 — Build Order (Follow This Sequence)
1. Domain models first (`domain/`)
2. Repository interface (`domain/${input:featureName}_repository.dart`)
3. Supabase repository implementation (`infrastructure/`)
4. Riverpod provider (`application/`)
5. Screens + widgets (`presentation/`)
6. Wire GoRouter route (`lib/core/router/app_router.dart`)
7. Unit tests for repository and provider
8. Widget test for main screen

## Step 4 — Integration Checklist
Before marking feature complete:
- [ ] Route added to `app_router.dart`
- [ ] Route name constant added to `app_routes.dart`
- [ ] All user-facing strings added to `app_strings.dart`
- [ ] Feature accessible from Account tab menu or Studio quick actions
- [ ] Credits deducted if feature uses AI generation
- [ ] Usage event logged to `usage_events` Supabase table
- [ ] Error state and empty state designed and implemented
- [ ] Unit tests written and passing
