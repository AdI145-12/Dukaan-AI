# Dukaan AI — GitHub Copilot Global Instructions

## Project Identity
Mobile-first Flutter app for Indian small business owners.
Generates AI-powered product ads, manages customer credit (Khata), and shares to WhatsApp.

## Tech Stack (Non-Negotiable)
- **Flutter 3.x / Dart** — Android-only, min SDK 21
- **State Management** — Riverpod ONLY (no Provider, Bloc, GetX, setState)
- **Navigation** — GoRouter ONLY (no Navigator.push directly)
- **Backend/Auth/DB** — Firebase (Auth + Firestore + Storage)
- **Serverless AI** — Cloudflare Workers (JavaScript/TypeScript)
- **Payments** — Razorpay Flutter SDK
- **Push Notifications** — Firebase Cloud Messaging (FCM)

## Folder Conventions
```
lib/
  core/           # App-wide: router, theme, constants, firebase service
  features/       # One folder per feature (studio, khata, account, pricing)
    <feature>/
      presentation/   # Screens + Widgets only
      application/    # Riverpod providers + notifiers
      domain/         # Models, enums, interfaces
      infrastructure/ # Repositories (Firestore calls)
  shared/         # Reusable widgets, utils, extensions
workers/          # Cloudflare Workers (one file per endpoint)
firebase.json
  migrations/     # SQL migration files
  functions/      # Edge Functions (Deno)
test/             # Unit + widget tests
```

## Absolute Rules
1. **Server does AI work** — Never run image processing, ML inference, or API calls to AI services from Flutter. Always proxy via Cloudflare Worker.
2. **UI thread stays free** — All async operations in Flutter use Isolates via `compute()` or async providers. Never block the main thread.
3. **Reuse before create** — Before writing any new file, function, widget, provider, or utility, search for an existing equivalent. Create new abstraction only if duplication spans 3+ locations.
4. **Const everywhere** — Mark every widget `const` where possible. Never skip `const` on static widgets.
5. **No hardcoded strings** — All user-facing strings in `lib/core/constants/strings.dart`.
6. **Compress before upload** — Always run images through `ImagePipeline.prepareForUpload()` before any network call.

## Anti-Hallucination Contract
Do NOT invent:
- Package APIs or SDK methods not verified in pubspec.yaml
- Firestore collection names, document field names, or security rules
- Environment variable names
- GoRouter route names (use `AppRoutes` constants)
- Riverpod provider names
- Cloudflare Worker endpoint paths
- Business logic not specified in the task

If any of the above are unclear: **ask first or mark as `// ASSUMPTION:` in a comment.**

## Code Quality Standards
- All public methods must have Dart doc comments (`///`)
- Error states must always be handled (never silent catch blocks)
- Never use `dynamic` type — always be explicit
- Max function length: 40 lines. Split if longer.
- No print() in production code — use logger package only

## Model Guidance
- **Copilot autocomplete / Codex** — implementation, widget code, service methods
- **Claude Sonnet (Copilot Chat)** — architecture review, "what's wrong here?", refactors
- **GPT-4o (Copilot Chat)** — debugging, explaining error messages, cross-module planning
