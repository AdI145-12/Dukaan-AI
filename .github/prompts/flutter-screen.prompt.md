---
mode: agent
description: Create a new Flutter screen following Dukaan AI patterns
---

# New Flutter Screen

## Step 1 — Read Before Writing (Mandatory)
Before writing any code, read and confirm:
- The exact feature folder this screen belongs to (`lib/features/<feature>/`)
- Existing providers in `<feature>/application/` that this screen should consume
- Existing models in `<feature>/domain/` for the data this screen displays
- The GoRouter route name from `lib/core/router/app_routes.dart`

State the above findings before writing a single line of code.

## Step 2 — Build the Screen
Create the screen at: `lib/features/${input:featureName}/presentation/screens/${input:screenName}.dart`

Requirements:
- Extend `ConsumerWidget` (not StatefulWidget unless animation controller needed)
- Import only from the current feature or `shared/`
- Follow this exact structure:
```dart
class ${input:screenName} extends ConsumerWidget {
  const ${input:screenName}({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(${input:providerName});

    return Scaffold(
      backgroundColor: AppColors.surface,
      // No AppBar unless explicitly requested — use custom header widget
      body: state.when(
        data: (data) => _buildContent(context, ref, data),
        loading: () => const _LoadingSkeleton(),
        error: (e, _) => _ErrorView(message: e.toString()),
      ),
    );
  }
}

// Private skeleton widget (mirrors real layout with shimmer)
class _LoadingSkeleton extends StatelessWidget { ... }

// Private error widget
class _ErrorView extends StatelessWidget { ... }
```

## Step 3 — Performance Checklist
Confirm each point before finishing:
- [ ] All static widgets marked `const`
- [ ] Lists use `ListView.builder`, not `ListView` with children
- [ ] Network images use `CachedNetworkImage` with shimmer placeholder
- [ ] List items wrapped in `RepaintBoundary`
- [ ] No inline anonymous functions in `build()` that could break const

## Step 4 — Create Matching Test File
Create skeleton test at: `test/widget/features/${input:featureName}/${input:screenName}_test.dart`
With at least: loading state test, empty state test, error state test.
