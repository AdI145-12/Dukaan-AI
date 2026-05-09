# TASK 1.3 — BUILD ERRORS: DIAGNOSIS & FIX PROMPT
### Dukaan AI · Copilot Debug Prompt

---

## Root Cause Diagnosis

Two separate root causes, not one. Fixing both in one pass.

### Cause 1 — `json_serializable 6.13.0` incompatible with Dart 3.3.0

`json_serializable 6.13.0` generates null-aware map entries using
`?instance.field` syntax — a Dart 3.8.0 feature. Your project runs
Dart 3.3.0. Result: `FormatterException` on every model, and **zero**
`.g.dart` files written.

```
W The language version (3.3.0) does not match the required range ^3.8.0
E This requires the 'null-aware-elements' language feature to be enabled.
  'thumbnailurl': ?instance.thumbnailUrl,   ← Dart 3.8 syntax, not 3.3
```

**Fix (no pubspec version change needed):** Stop using `json_serializable`
for Supabase models entirely. Supabase returns `Map<String, dynamic>` rows.
We parse them manually. `toJson()` from Supabase models is never used
in any direction. Replace `factory X.fromJson → _$XFromJson` with a
manual `static X fromRow(Map<String, dynamic> row)` method.

### Cause 2 — `studio_provider.g.dart` never generated

Because `json_serializable` failed, `build_runner` exited before
`riverpod_generator` could finish writing `studio_provider.g.dart`.
Without that file, `_$Studio` doesn't exist → `ref` and `future` are
undefined in `Studio extends _$Studio`. Once Cause 1 is fixed and
`build_runner` succeeds, `studio_provider.g.dart` generates correctly.

### Cause 3 — Copilot deviated from spec in `studio_provider.dart`

Copilot wrote `await ref.watch(authStateProvider.future)` — which is
wrong twice: (a) `ref.watch` is synchronous, you can't await it;
(b) the spec said to read `client.auth.currentUser?.id` directly.
Must be corrected to match the prompt spec.

---

## Fix: 3 Files to Change

### Paste-Ask for Copilot

Attach these files before pasting the prompt:
  1. `generated_ad.dart` (ACTUAL current file)
  2. `user_profile.dart` (ACTUAL current file)
  3. `studio_provider.dart` (ACTUAL current file)
  4. `studio_repository_impl.dart` (ACTUAL current file)

Then paste:

```
════════════════════════════════════════════════════════
  DEBUG FIX: Task 1.3 Build Errors
════════════════════════════════════════════════════════

PROBLEM:
json_serializable 6.13.0 generates `?instance.field` null-aware-elements
syntax that requires Dart 3.8.0. Our project uses Dart 3.3.0. This causes
FormatterException during build_runner, which prevents studio_provider.g.dart
from being generated, which causes all the 'ref' undefined errors.

FIX REQUIRED IN 4 FILES ONLY. Do not touch any other file.

────────────────────────────────────────
  FIX 1 — lib/features/studio/domain/generated_ad.dart
────────────────────────────────────────

REMOVE these two lines:
  part 'generated_ad.g.dart';
  factory GeneratedAd.fromJson(Map<String, dynamic> json) =>
      _$GeneratedAdFromJson(json);

REPLACE the factory with a static method:
  static GeneratedAd fromRow(Map<String, dynamic> row) => GeneratedAd(
    id: row[SupabaseColumns.id] as String,
    userId: row[SupabaseColumns.userId] as String,
    imageUrl: row[SupabaseColumns.imageUrl] as String,
    thumbnailUrl: row[SupabaseColumns.thumbnailUrl] as String?,
    backgroundStyle: row[SupabaseColumns.backgroundStyle] as String?,
    captionHindi: row[SupabaseColumns.captionHindi] as String?,
    captionEnglish: row[SupabaseColumns.captionEnglish] as String?,
    shareCount: row['sharecount'] as int? ?? 0,
    downloadCount: row['downloadcount'] as int? ?? 0,
    festivalTag: row['festivaltag'] as String?,
    createdAt: DateTime.parse(row[SupabaseColumns.createdAt] as String),
  );

The class should now have ONLY:
  part 'generated_ad.freezed.dart';   ← KEEP
  (no .g.dart part directive)

IMPORTANT: Since we removed json serialization from freezed,
also remove @JsonSerializable() annotation if present anywhere
on the class or factory, and remove the toJson() factory if present.
The class does NOT need toJson — Supabase data flows one way (in).

────────────────────────────────────────
  FIX 2 — lib/shared/domain/user_profile.dart
────────────────────────────────────────

Same pattern as Fix 1.

REMOVE:
  part 'user_profile.g.dart';
  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);

REPLACE with static method:
  static UserProfile fromRow(Map<String, dynamic> row) => UserProfile(
    id: row[SupabaseColumns.id] as String,
    shopName: row[SupabaseColumns.shopName] as String,
    ownerName: row['ownername'] as String?,
    phone: row[SupabaseColumns.phone] as String?,
    city: row[SupabaseColumns.city] as String?,
    category: row[SupabaseColumns.category] as String?,
    tier: row[SupabaseColumns.tier] as String? ?? 'free',
    creditsRemaining: row[SupabaseColumns.creditsRemaining] as int? ?? 3,
    language: row[SupabaseColumns.language] as String? ?? 'hinglish',
  );

Keep ONLY:
  part 'user_profile.freezed.dart';   ← KEEP
  (no .g.dart part directive)

Also remove @JsonSerializable() and toJson() if present.

────────────────────────────────────────
  FIX 3 — lib/features/studio/infrastructure/studio_repository_impl.dart
────────────────────────────────────────

Both .map() calls must use the new static method names:

In getRecentAds():
  CHANGE: rows.map(GeneratedAd.fromJson).toList()
  TO:     rows.map(GeneratedAd.fromRow).toList()

In getProfile():
  CHANGE: return UserProfile.fromJson(row);
  TO:     return UserProfile.fromRow(row);

No other changes to this file.

────────────────────────────────────────
  FIX 4 — lib/features/studio/application/studio_provider.dart
────────────────────────────────────────

Copilot deviated from the spec. Replace the entire build() method
body with this exact implementation:

  @override
  Future<StudioState> build() async {
    final client = ref.watch(supabaseClientProvider);
    final userId = client.auth.currentUser?.id;

    if (userId == null) {
      return const StudioState();
    }

    final repo = ref.watch(studioRepositoryProvider);

    final results = await Future.wait([
      repo.getRecentAds(userId: userId, limit: 3),
      repo.getProfile(userId: userId),
    ]);

    return StudioState(
      recentAds: results[0] as List<GeneratedAd>,
      profile: results[1] as UserProfile,
      todayFestival: FestivalCalendar.getTodayFestival(),
    );
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

KEY CHANGES from what Copilot wrote:
  - Remove `await ref.watch(authStateProvider.future)` — wrong API usage
  - Use `client.auth.currentUser?.id` directly (synchronous, correct)
  - `ref.watch(supabaseClientProvider)` not `ref.read`
  - `ref.watch(studioRepositoryProvider)` not `ref.read` in build()

────────────────────────────────────────
  OUTPUT THESE 4 FILES ONLY
────────────────────────────────────────

  1. lib/features/studio/domain/generated_ad.dart          (MODIFIED)
  2. lib/shared/domain/user_profile.dart                   (MODIFIED)
  3. lib/features/studio/infrastructure/studio_repository_impl.dart (MODIFIED)
  4. lib/features/studio/application/studio_provider.dart  (MODIFIED)

DO NOT output any other files.
DO NOT change studio_state.dart, studio_screen.dart, or any widget.
DO NOT add json_serializable or json_annotation anywhere.
```

---

## After Applying Fixes

```bash
# 1. Clean old broken generated files first
dart run build_runner clean

# 2. Regenerate — should complete with zero errors this time
dart run build_runner build --delete-conflicting-outputs

# Expected output:
#   ✅ freezed on X inputs: 3 output  (studio_state, generated_ad, user_profile)
#   ✅ riverpod_generator on X inputs: 2 output  (studio_provider, shared_providers)
#   NO json_serializable errors

# 3. Verify
flutter analyze
# Expected: No issues found!

# 4. Tests
flutter test test/features/studio/
# Expected: 8 tests pass
```

---

*Dukaan AI v1.0 · Task 1.3 Debug Fix · April 2026*
