---
name: flutter-design-system
description: >
  Use this skill whenever building Flutter widgets, screens, or modifying UI
  in the Dukaan AI app. Contains the exact color tokens, spacing values, text
  styles, widget patterns, and UX rules for this project. Ensures all UI
  follows the Dukaan AI design system and targets low-end Android devices.
---

# Dukaan AI — Flutter Design System

## Design Identity
- **Audience**: Indian SMB merchants, Tier 2/3 cities, low-end Android (4-8GB RAM)
- **Primary Language**: Hinglish UI (Hindi words, English script)
- **Brand Color**: Deep Saffron Orange `#FF6F00`
- **Font**: Noto Sans (supports Devanagari for Hindi captions)
- **Performance Rule**: All screens must render at 60fps on a ₹8,000 phone

## Color Tokens (AppColors)

```dart
// lib/core/theme/app_colors.dart
class AppColors {
  // Primary Brand
  static const primary = Color(0xFFFF6F00);        // Saffron Orange
  static const primaryDark = Color(0xFFE65100);    // Pressed state
  static const primaryLight = Color(0xFFFFF3E0);   // Background tint

  // Text
  static const textPrimary = Color(0xFF1A1A1A);    // Main text
  static const textSecondary = Color(0xFF757575);  // Muted text
  static const textHint = Color(0xFFBDBDBD);       // Placeholder

  // Surfaces
  static const surface = Color(0xFFFFFFFF);        // Card backgrounds
  static const background = Color(0xFFF5F5F5);     // Page background
  static const divider = Color(0xFFEEEEEE);        // Dividers

  // Semantic
  static const success = Color(0xFF2E7D32);
  static const error = Color(0xFFB71C1C);
  static const warning = Color(0xFFF57F17);

  // Khata specific
  static const khataCredit = Color(0xFF1B5E20);    // Green for "paisa aaya"
  static const khataDebit = Color(0xFFB71C1C);     // Red for "paisa gaya"
}
```

## Spacing Tokens (AppSpacing)

```dart
// lib/core/theme/app_spacing.dart
class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}
// Usage: padding: const EdgeInsets.all(AppSpacing.md)
// NEVER: padding: const EdgeInsets.all(16.0) — use tokens
```

## Text Style Tokens (AppTypography)

```dart
// lib/core/theme/app_typography.dart
class AppTypography {
  static const displayLarge  = TextStyle(fontSize: 28, fontWeight: FontWeight.w700);
  static const displayMedium = TextStyle(fontSize: 24, fontWeight: FontWeight.w700);
  static const headlineLarge = TextStyle(fontSize: 20, fontWeight: FontWeight.w600);
  static const headlineMedium= TextStyle(fontSize: 18, fontWeight: FontWeight.w600);
  static const bodyLarge     = TextStyle(fontSize: 16, fontWeight: FontWeight.w400);
  static const bodyMedium    = TextStyle(fontSize: 14, fontWeight: FontWeight.w400);
  static const labelLarge    = TextStyle(fontSize: 14, fontWeight: FontWeight.w600);
  static const labelSmall    = TextStyle(fontSize: 12, fontWeight: FontWeight.w500);
}
```

## Standard Widget Patterns

### Primary Button
```dart
// Use AppButton widget — never raw ElevatedButton
AppButton(
  label: 'Ad banao',
  onPressed: () {},
  isLoading: state.isLoading, // shows CircularProgressIndicator
)
```

### Card Pattern
```dart
// Cards: white background, 12px radius, shadow-sm, md padding
Container(
  decoration: BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(AppRadius.card), // 12
    boxShadow: AppShadows.card,
  ),
  padding: const EdgeInsets.all(AppSpacing.md),
  child: content,
)
```

### Shimmer Loading (always use ShimmerBox widget)
```dart
// NEVER show empty white space during loading
// Always use shimmer skeletons that match the final layout
ShimmerBox(width: double.infinity, height: 120)
```

### Bottom Sheet (always use AppBottomSheet)
```dart
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (_) => AppBottomSheet(
    title: 'Kya karna chahte ho?',
    child: content,
  ),
);
```

## Performance Rules for Low-End Devices

1. **All widgets must have `const` constructor where possible** — reduces rebuilds
2. **Use `RepaintBoundary`** around isolated animated widgets (Lottie, shimmer)
3. **Images**: Always use `CachedAdImage` widget — it handles caching + shimmer + error
4. **ListView/GridView**: Always use `ListView.builder` / `GridView.builder` — never `.children` with a list
5. **Heavy computation** (image compression, base64): Use `compute()` to run in Isolate
6. **Never use `Opacity` widget** for animations — use `FadeTransition` instead
7. **Avoid `setState()` in StatefulWidgets** — use Riverpod Consumer pattern

## Screen Structure Template

```dart
class FeatureScreen extends ConsumerWidget {
  const FeatureScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(featureProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Screen Title', style: AppTypography.headlineLarge),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: state.when(
        data: (data) => _buildContent(context, data),
        loading: () => const _LoadingSkeleton(),
        error: (e, _) => AppErrorView(
          message: ErrorHandler.toUserMessage(e),
          onRetry: () => ref.invalidate(featureProvider),
        ),
      ),
    );
  }
}
```

## Hinglish UX Conventions

- Greetings: "Namaste, [shop_name]!" (not "Hello")
- Success: "Ho gaya! ✓" (not "Success")
- Error: "Kuch gadbad ho gayi" (not "Error occurred")
- Loading: "Thoda ruko..." (not "Loading...")
- Empty state: "Abhi kuch nahi hai" with helpful CTA
- All strings must go in `AppStrings` — never hardcode in widgets

## Do Not

- Use `Colors.blue`, `Colors.red` etc. — use `AppColors.*` tokens
- Use raw `16.0` or `8.0` — use `AppSpacing.*` tokens
- Use `Text(style: TextStyle(fontSize: 18))` — use `AppTypography.*`
- Use `CircularProgressIndicator()` on full screens — use shimmer skeletons
- Build StatefulWidgets when Riverpod Consumer works
