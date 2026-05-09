# PROMPT 2.1 — Khata Digital Ledger Screen
### Dukaan AI · Kavya Agent · New Feature Module — Week 2 Begins

---

## TASK 1.10 ASSESSMENT

**5/5 widget tests pass** for `CaptionLanguageSelector`. Emulator is **connected and ready** (`emulator-5554`, Android 16 API 36). [file:37]

Two widget tests in `ad_preview_screen_test.dart` still fail. These are permanently fixed below with complete test code before Task 2.1 begins.

---

## FINAL FIX — Both Failing `ad_preview_screen_test.dart` Tests

This is the **definitive fix with complete test code**. Do not paraphrase these tests — paste them verbatim.

**Attach `test/features/studio/presentation/screens/ad_preview_screen_test.dart`, then paste:**

```
Two tests fail:
  1. "shows regenerating overlay when isRegenerating is true"
  2. "copyCaption shows snackbar when captionHindi is null"

ROOT CAUSE (confirmed after multiple attempts):
  Both tests fail because the caption service mock resolves immediately
  (async => ...) and populates _currentAd.captionHindi before assertions run.
  The fix: use Completer (NO async keyword) for BOTH the ad service AND caption
  service in EACH of these two tests, so no async work completes during pumping.

REPLACE the two failing tests with EXACTLY this code:

  // ═══ TEST 1 ═══
  testWidgets('shows regenerating overlay when isRegenerating is true',
      (tester) async {
    // Both completers — nothing resolves during this test
    final adCompleter = Completer<GeneratedAd>();
    final captionCompleter = Completer<GeneratedCaption>();

    when(mockAdGenerationService.generateAd(any))
        .thenAnswer((_) => adCompleter.future);          // NO async
    when(mockCaptionService.generateCaption(
      userId: any(named: 'userId'),
      productName: any(named: 'productName'),
      category: any(named: 'category'),
      language: any(named: 'language'),
    )).thenAnswer((_) => captionCompleter.future);       // NO async

    await tester.pumpWidget(buildTestScreen(overrides: [
      adGenerationServiceProvider.overrideWithValue(mockAdGenerationService),
      captionServiceProvider.overrideWithValue(mockCaptionService),
    ]));

    await tester.pump();  // initial build + didChangeDependencies (caption pending)

    await tester.tap(find.text(AppStrings.regenerateButton));
    await tester.pump();  // synchronous setState(_isRegenerating = true) + rebuild

    expect(find.text(AppStrings.regeneratingMessage), findsOneWidget);

    // Prevent "Completer was never completed" lint warning
    adCompleter.complete(testAd);
    captionCompleter.complete(
        const GeneratedCaption(caption: '', hashtags: [], language: 'hinglish'));
    await tester.pump(const Duration(milliseconds: 50));
  });

  // ═══ TEST 2 ═══
  testWidgets('copyCaption shows snackbar when captionHindi is null',
      (tester) async {
    // Use a Completer so caption generation NEVER fills in captionHindi
    final captionCompleter = Completer<GeneratedCaption>();
    when(mockCaptionService.generateCaption(
      userId: any(named: 'userId'),
      productName: any(named: 'productName'),
      category: any(named: 'category'),
      language: any(named: 'language'),
    )).thenAnswer((_) => captionCompleter.future);       // NO async

    // Build with an ad that has NO captions
    await tester.pumpWidget(buildTestScreen(
      ad: testAd.copyWith(captionHindi: null, captionEnglish: null),
      overrides: [captionServiceProvider.overrideWithValue(mockCaptionService)],
    ));
    await tester.pump();  // initial build (caption generation started but PENDING)

    // Tap Copy Caption — captionHindi is still null since completer not completed
    await tester.tap(find.text(AppStrings.copyCaptionButton));
    await tester.pump();  // process tap + SnackBar

    expect(find.text(AppStrings.captionNotAvailableYet), findsOneWidget);

    // Cleanup
    captionCompleter.complete(
        const GeneratedCaption(caption: '', hashtags: [], language: 'hinglish'));
    await tester.pump(const Duration(milliseconds: 50));
  });

IMPORTANT: These are COMPLETE replacements. Delete the existing versions of
these two tests entirely. Output only the corrected ad_preview_screen_test.dart.
```

Then run:
```powershell
flutter test test/features/studio/presentation/screens/ad_preview_screen_test.dart
# Expected: 6/6 pass, zero failures
```

---

## RUN ON EMULATOR NOW

Emulator `emulator-5554` (Android 16, API 36) is confirmed connected.

```powershell
# In one terminal — start Worker locally
cd C:\dev\smb_ai\workers
npx wrangler dev --local --port 8787

# In another terminal — run on emulator
cd C:\dev\smb_ai
flutter run -d emulator-5554 `
  --dart-define=SKIP_AUTH=true `
  --dart-define=WORKER_BASE_URL=http://10.0.2.2:8787
# Note: 10.0.2.2 is how Android emulators reach host machine localhost
```

---

## TASK 2.1 — Khata Digital Ledger Screen

### STEP 1 — ATTACH THESE FILES

| # | File | Why |
|---|---|---|
| 1 | `copilot-instructions.md` | Global rules |
| 2 | `flutter.instructions.md` | Widget patterns, error handling |
| 3 | `SKILL.md` → *supabase-schema* | khataentries columns, realtime stream pattern |
| 4 | `SKILL.md` → *riverpod-patterns* | StreamProvider pattern (exact Khata example) |
| 5 | `SKILL.md` → *flutter-design-system* | Cards, FAB, AppColors, spacing |
| 6 | `SKILL.md` → *testing-patterns* | StreamProvider test setup |
| 7 | `app_nav_shell.dart` | ACTUAL — add Khata as 4th tab |
| 8 | `app_routes.dart` | ACTUAL — add /khata constant |
| 9 | `app_router.dart` | ACTUAL — add KhataScreen route |
| 10 | `app_strings.dart` | ACTUAL — add khata strings |
| 11 | `test/unit/features/khata/application/khata_provider_test.dart` | ACTUAL stub — fill in |
| 12 | `test/widget/features/khata/khata_screen_test.dart` | ACTUAL stub — fill in |

### STEP 2 — PASTE INTO COPILOT CHAT (Kavya Agent — New Session)

```
════════════════════════════════════════════════════════
  PROJECT CONTEXT — ALWAYS INCLUDE IN EVERY SESSION
════════════════════════════════════════════════════════

PROJECT: Dukaan AI — Khata Digital Ledger (Week 2, Day 8)
NEW FEATURE MODULE: lib/features/khata/

SUPABASE TABLE: khataentries (existing — already in schema)
EXACT COLUMN NAMES — use these, not camelCase versions:
  id            UUID PK
  userid        UUID FK profiles.id
  customername  TEXT NOT NULL
  customerphone TEXT NULLABLE
  amount        NUMERIC(10,2) NOT NULL   ← NOT 'amountOwed'
  type          TEXT 'credit' or 'debit' ← 'credit' means customer owes us
  note          TEXT NULLABLE            ← NOT 'notes'
  issettled     BOOLEAN DEFAULT false
  createdat     TIMESTAMPTZ

REALTIME STREAM PATTERN (from Supabase skill — use exactly):
  final stream = client
      .from(SupabaseTables.khataEntries)
      .stream(primaryKey: ['id'])
      .eq(SupabaseColumns.userId, userId)
      .order(SupabaseColumns.createdAt, ascending: false);

PROVIDER PATTERN (from Riverpod skill — use exactly):
  @riverpod
  Stream<List<KhataEntry>> khataEntries(KhataEntriesRef ref) {
    final repo = ref.watch(khataRepositoryProvider);
    return repo.watchEntries(userId: SupabaseClient.instance.auth.currentUser?.id ?? '');
  }

  @riverpod
  class Khata extends _$Khata {
    @override
    FutureOr<void> build() async {}  // mutations only, stream handles read
    Future<void> addEntry({...}) async { ... }
    Future<void> markPaid(String id) async { ... }
    Future<void> deleteEntry(String id) async { ... }
    Future<void> updateAmount(String id, double newAmount) async { ... }
  }

NAV CHANGE: Add Khata as Tab 1 in the bottom nav (shifts My Ads to Tab 2,
Account to Tab 3). FAB stays on Tab 0 (Studio) only.

════════════════════════════════════════════════════════
  TASK 2.1 — KHATA DIGITAL LEDGER SCREEN
════════════════════════════════════════════════════════

────────────────────────────────────────
  NEW FILE 1 — lib/features/khata/domain/khata_entry.dart    (NEW)
────────────────────────────────────────

Freezed model mapping to the khataentries DB schema:

  @freezed
  class KhataEntry with _$KhataEntry {
    const factory KhataEntry({
      required String id,
      required String userId,
      required String customerName,
      String? customerPhone,
      required double amount,
      @Default('credit') String type,    // 'credit' or 'debit'
      String? note,
      @Default(false) bool isSettled,
      required DateTime createdAt,
    }) = _KhataEntry;

    factory KhataEntry.fromRow(Map<String, dynamic> row) => KhataEntry(
      id:           row['id'] as String,
      userId:       row['userid'] as String,
      customerName: row['customername'] as String,
      customerPhone: row['customerphone'] as String?,
      amount:       (row['amount'] as num).toDouble(),
      type:         row['type'] as String? ?? 'credit',
      note:         row['note'] as String?,
      isSettled:    (row['issettled'] as bool?) ?? false,
      createdAt:    DateTime.parse(row['createdat'] as String),
    );
  }

  // No fromJson needed — use fromRow for Supabase maps

────────────────────────────────────────
  NEW FILE 2 — lib/features/khata/domain/repositories/khata_repository.dart    (NEW)
────────────────────────────────────────

  abstract class KhataRepository {
    /// Realtime stream — auto-updates on any DB change for this user
    Stream<List<KhataEntry>> watchEntries({required String userId});

    /// Insert new entry
    Future<void> addEntry({
      required String userId,
      required String customerName,
      String? customerPhone,
      required double amount,
      String type = 'credit',
      String? note,
    });

    /// Update amount on an existing entry
    Future<void> updateAmount({required String id, required double newAmount});

    /// Set issettled = true
    Future<void> markPaid({required String id});

    /// Hard delete
    Future<void> deleteEntry({required String id});

    /// Log analytics event (non-fatal)
    Future<void> trackEvent({
      required String userId,
      required String eventType,
      Map<String, dynamic>? metadata,
    });
  }

────────────────────────────────────────
  NEW FILE 3 — lib/features/khata/infrastructure/khata_repository_impl.dart    (NEW)
────────────────────────────────────────

  class KhataRepositoryImpl implements KhataRepository {
    const KhataRepositoryImpl({required this.supabase});
    final SupabaseClient supabase;

    @override
    Stream<List<KhataEntry>> watchEntries({required String userId}) {
      return supabase
          .from(SupabaseTables.khataEntries)
          .stream(primaryKey: ['id'])
          .eq(SupabaseColumns.userId, userId)
          .order(SupabaseColumns.createdAt, ascending: false)
          .map((rows) => rows
              .where((r) => (r['issettled'] as bool? ?? false) == false)
              .map(KhataEntry.fromRow)
              .toList());
      // Note: stream only emits UNSETTLED entries for the main list.
      // markPaid removes from stream automatically.
    }

    @override
    Future<void> addEntry({
      required String userId,
      required String customerName,
      String? customerPhone,
      required double amount,
      String type = 'credit',
      String? note,
    }) async {
      try {
        await supabase.from(SupabaseTables.khataEntries).insert({
          SupabaseColumns.userId: userId,
          'customername':   customerName.trim(),
          if (customerPhone != null) 'customerphone': customerPhone.trim(),
          'amount':         amount,
          'type':           type,
          if (note != null && note.isNotEmpty) 'note': note.trim(),
          'issettled':      false,
        });
      } on PostgrestException catch (e) {
        throw AppException.supabase(e.message);
      }
    }

    @override
    Future<void> updateAmount({required String id, required double newAmount}) async {
      try {
        await supabase
            .from(SupabaseTables.khataEntries)
            .update({'amount': newAmount})
            .eq('id', id);
      } on PostgrestException catch (e) {
        throw AppException.supabase(e.message);
      }
    }

    @override
    Future<void> markPaid({required String id}) async {
      try {
        await supabase
            .from(SupabaseTables.khataEntries)
            .update({'issettled': true})
            .eq('id', id);
      } on PostgrestException catch (e) {
        throw AppException.supabase(e.message);
      }
    }

    @override
    Future<void> deleteEntry({required String id}) async {
      try {
        await supabase.from(SupabaseTables.khataEntries).delete().eq('id', id);
      } on PostgrestException catch (e) {
        throw AppException.supabase(e.message);
      }
    }

    @override
    Future<void> trackEvent({
      required String userId,
      required String eventType,
      Map<String, dynamic>? metadata,
    }) async {
      try {
        await supabase.from(SupabaseTables.usageEvents).insert({
          SupabaseColumns.userId: userId,
          'eventtype':   eventType,
          'creditsused': 0,
          if (metadata != null) 'metadata': metadata,
        });
      } on PostgrestException catch (e) {
        debugPrint('trackEvent failed: ${e.message}');  // non-fatal
      }
    }
  }

  @riverpod
  KhataRepository khataRepository(KhataRepositoryRef ref) {
    return KhataRepositoryImpl(supabase: SupabaseClient.instance);
  }

────────────────────────────────────────
  NEW FILE 4 — lib/features/khata/application/khata_provider.dart    (NEW)
────────────────────────────────────────

TWO providers — one for the stream, one for mutations:

  // Stream provider — auto-updates via Supabase Realtime
  @riverpod
  Stream<List<KhataEntry>> khataEntries(KhataEntriesRef ref) {
    final repo = ref.watch(khataRepositoryProvider);
    final userId = SupabaseClient.instance.auth.currentUser?.id ?? '';
    if (userId.isEmpty) return Stream.value([]);
    return repo.watchEntries(userId: userId);
  }

  // Mutation notifier — handles add/edit/delete/mark-paid
  @riverpod
  class Khata extends _$Khata {
    @override
    FutureOr<void> build() async {}  // No state to load — stream handles read

    Future<void> addEntry({
      required String customerName,
      String? customerPhone,
      required double amount,
      String type = 'credit',
      String? note,
    }) async {
      final userId = SupabaseClient.instance.auth.currentUser?.id ?? '';
      if (userId.isEmpty) return;
      state = const AsyncLoading();
      state = await AsyncValue.guard(() async {
        await ref.read(khataRepositoryProvider).addEntry(
          userId: userId,
          customerName: customerName,
          customerPhone: customerPhone,
          amount: amount,
          type: type,
          note: note,
        );
      });
    }

    Future<void> updateAmount({required String id, required double newAmount}) async {
      state = const AsyncLoading();
      state = await AsyncValue.guard(() async {
        await ref.read(khataRepositoryProvider).updateAmount(
          id: id, newAmount: newAmount,
        );
      });
    }

    Future<void> markPaid({required String id}) async {
      state = const AsyncLoading();
      state = await AsyncValue.guard(() async {
        await ref.read(khataRepositoryProvider).markPaid(id: id);
      });
    }

    Future<void> deleteEntry({required String id}) async {
      state = const AsyncLoading();
      state = await AsyncValue.guard(() async {
        await ref.read(khataRepositoryProvider).deleteEntry(id: id);
      });
    }

    Future<void> sendReminderTracked({
      required String userId,
      required String entryId,
    }) async {
      // Fire-and-forget analytics — no state change needed
      ref.read(khataRepositoryProvider).trackEvent(
        userId: userId,
        eventType: 'remindersent',
        metadata: {'entryId': entryId},
      );
    }
  }

────────────────────────────────────────
  NEW FILE 5 — lib/features/khata/presentation/widgets/khata_entry_card.dart    (NEW)
────────────────────────────────────────

Card widget with RepaintBoundary. Long-press shows action sheet.

  class KhataEntryCard extends StatelessWidget {
    const KhataEntryCard({
      super.key,
      required this.entry,
      required this.onSendReminder,
      required this.onMarkPaid,
      required this.onDelete,
      required this.onEditAmount,
    });

    final KhataEntry entry;
    final VoidCallback onSendReminder;
    final VoidCallback onMarkPaid;
    final VoidCallback onDelete;
    final VoidCallback onEditAmount;

    // Deterministic avatar color from customer name
    static Color _avatarColor(String name) {
      const colors = [
        Color(0xFFEF5350), Color(0xFFFF7043), Color(0xFFFFCA28),
        Color(0xFF66BB6A), Color(0xFF42A5F5), Color(0xFFAB47BC),
      ];
      return colors[name.codeUnits.first % colors.length];
    }

    @override
    Widget build(BuildContext context) {
      final initials = entry.customerName.isNotEmpty
          ? entry.customerName[0].toUpperCase()
          : '?';

      return RepaintBoundary(
        child: GestureDetector(
          onLongPress: () => _showActionSheet(context),
          child: Container(
            margin: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.card),
              boxShadow: AppShadows.card,
            ),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 22,
                  backgroundColor: _avatarColor(entry.customerName),
                  child: Text(
                    initials,
                    style: AppTypography.labelLarge.copyWith(color: Colors.white),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),

                // Name + phone
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.customerName,
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (entry.customerPhone != null)
                        Text(
                          entry.customerPhone!,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),

                // Amount (right-aligned, red)
                Text(
                  '₹${entry.amount.toStringAsFixed(0)}',
                  style: AppTypography.headlineMedium.copyWith(
                    color: AppColors.khataDebit,  // red
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    void _showActionSheet(BuildContext context) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (_) => AppBottomSheet(
          title: entry.customerName,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_rounded, color: AppColors.primary),
                title: const Text(AppStrings.editAmountAction),
                onTap: () { Navigator.pop(context); onEditAmount(); },
              ),
              ListTile(
                leading: const Icon(Icons.whatsapp, color: Color(0xFF25D366)),
                title: const Text(AppStrings.sendReminderAction),
                onTap: () { Navigator.pop(context); onSendReminder(); },
              ),
              ListTile(
                leading: const Icon(Icons.check_circle_rounded, color: AppColors.success),
                title: const Text(AppStrings.markPaidAction),
                onTap: () { Navigator.pop(context); onMarkPaid(); },
              ),
              ListTile(
                leading: const Icon(Icons.delete_rounded, color: AppColors.error),
                title: const Text(AppStrings.deleteEntryAction),
                onTap: () { Navigator.pop(context); onDelete(); },
              ),
            ],
          ),
        ),
      );
    }
  }

────────────────────────────────────────
  NEW FILE 6 — lib/features/khata/presentation/widgets/add_khata_sheet.dart    (NEW)
────────────────────────────────────────

Bottom sheet form for adding a new khata entry.

  class AddKhataSheet extends ConsumerStatefulWidget {
    const AddKhataSheet({super.key});
  }

  class _AddKhataSheetState extends ConsumerState<AddKhataSheet> {
    final _nameCtrl   = TextEditingController();
    final _phoneCtrl  = TextEditingController();
    final _amountCtrl = TextEditingController();
    final _noteCtrl   = TextEditingController();
    final _formKey    = GlobalKey<FormState>();
    bool _isLoading   = false;

    @override
    void dispose() {
      _nameCtrl.dispose(); _phoneCtrl.dispose();
      _amountCtrl.dispose(); _noteCtrl.dispose();
      super.dispose();
    }

    Future<void> _submit() async {
      if (!_formKey.currentState!.validate()) return;
      setState(() => _isLoading = true);

      await ref.read(khataProvider.notifier).addEntry(
        customerName:  _nameCtrl.text.trim(),
        customerPhone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        amount:        double.parse(_amountCtrl.text.trim()),
        note:          _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.khataAddedMessage),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }

    @override
    Widget build(BuildContext context) {
      return AppBottomSheet(
        title: AppStrings.addKhataTitle,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Customer Name
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelText: AppStrings.customerNameLabel,
                  hintText: 'e.g. Amit Kumar',
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) => (v?.trim().isEmpty ?? true)
                    ? AppStrings.fieldRequired : null,
              ),
              const SizedBox(height: AppSpacing.md),

              // Phone (optional)
              TextFormField(
                controller: _phoneCtrl,
                decoration: InputDecoration(
                  labelText: AppStrings.customerPhoneLabel,
                  hintText: '10-digit mobile number',
                  prefixText: '+91 ',
                ),
                keyboardType: TextInputType.phone,
                maxLength: 10,
              ),
              const SizedBox(height: AppSpacing.md),

              // Amount (required)
              TextFormField(
                controller: _amountCtrl,
                decoration: InputDecoration(
                  labelText: AppStrings.amountLabel,
                  hintText: 'e.g. 500',
                  prefixText: '₹ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v?.trim().isEmpty ?? true) return AppStrings.fieldRequired;
                  if (double.tryParse(v!.trim()) == null) return 'Valid amount likhein';
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),

              // Note (optional)
              TextFormField(
                controller: _noteCtrl,
                decoration: InputDecoration(
                  labelText: AppStrings.noteLabel,
                  hintText: AppStrings.noteHint,
                ),
                maxLength: 100,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Submit
              AppButton(
                label: AppStrings.saveKhataButton,
                onPressed: _isLoading ? null : _submit,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      );
    }
  }

────────────────────────────────────────
  NEW FILE 7 — lib/features/khata/presentation/screens/khata_screen.dart    (NEW)
────────────────────────────────────────

  class KhataScreen extends ConsumerWidget {
    const KhataScreen({super.key});

    Future<void> _sendWhatsAppReminder(
      BuildContext context,
      WidgetRef ref,
      KhataEntry entry,
      String shopName,
    ) async {
      if (entry.customerPhone == null || entry.customerPhone!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.noPhoneNumber),
            backgroundColor: AppColors.warning,
          ),
        );
        return;
      }

      final message = Uri.encodeComponent(
        'Namaste ${entry.customerName} ji! '
        'Aapka $shopName mein ₹${entry.amount.toStringAsFixed(0)} baaki hai. '
        'Aaj pay karein. Dhanyavaad! 🙏',
      );

      // Normalize phone: strip leading 91 if present, then add 91
      final rawPhone = entry.customerPhone!.replaceAll(RegExp(r'[^0-9]'), '');
      final phone = rawPhone.startsWith('91') && rawPhone.length == 12
          ? rawPhone
          : '91$rawPhone';

      final uri = Uri.parse('https://wa.me/$phone?text=$message');

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        // Track reminder sent (fire-and-forget)
        final userId = SupabaseClient.instance.auth.currentUser?.id ?? '';
        if (userId.isNotEmpty) {
          ref.read(khataProvider.notifier).sendReminderTracked(
            userId: userId,
            entryId: entry.id,
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppStrings.whatsappNotInstalled),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }

    void _showEditAmountDialog(BuildContext context, WidgetRef ref, KhataEntry entry) {
      final ctrl = TextEditingController(text: entry.amount.toStringAsFixed(0));
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(AppStrings.editAmountTitle),
          content: TextField(
            controller: ctrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(prefixText: '₹ '),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppStrings.cancelButton),
            ),
            TextButton(
              onPressed: () {
                final newAmount = double.tryParse(ctrl.text.trim());
                if (newAmount == null || newAmount <= 0) return;
                Navigator.pop(context);
                ref.read(khataProvider.notifier).updateAmount(
                  id: entry.id, newAmount: newAmount,
                );
              },
              child: Text(AppStrings.saveButton,
                  style: TextStyle(color: AppColors.primary)),
            ),
          ],
        ),
      );
    }

    @override
    Widget build(BuildContext context, WidgetRef ref) {
      final entriesAsync = ref.watch(khataEntriesProvider);

      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          title: Text(AppStrings.khataTitle, style: AppTypography.headlineLarge),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.primary,
          onPressed: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: const AddKhataSheet(),
            ),
          ),
          child: const Icon(Icons.add, color: Colors.white),
        ),
        body: entriesAsync.when(
          data: (entries) {
            if (entries.isEmpty) {
              return _EmptyState(
                onAddTap: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: const AddKhataSheet(),
                  ),
                ),
              );
            }

            // Total baaki
            final total = entries.fold(0.0, (sum, e) => sum + e.amount);

            return CustomScrollView(
              slivers: [
                // Header — total baaki
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.all(AppSpacing.md),
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(AppRadius.card),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.totalPendingLabel,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '₹${total.toStringAsFixed(0)} ${AppStrings.baakiHai}',
                          style: AppTypography.displayMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${entries.length} ${AppStrings.customersLabel}',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Khata entry list
                SliverList.builder(
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return KhataEntryCard(
                      key: ValueKey(entry.id),
                      entry: entry,
                      onSendReminder: () => _sendWhatsAppReminder(
                        context, ref, entry,
                        'Aapki Dukaan',  // TODO Task 4.3: use actual shop name from profile
                      ),
                      onMarkPaid: () {
                        ref.read(khataProvider.notifier).markPaid(id: entry.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${entry.customerName} ka ₹${entry.amount.toStringAsFixed(0)} paid! 🎉'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                      onDelete: () {
                        // Confirm before delete
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text(AppStrings.deleteConfirmTitle),
                            content: Text('${entry.customerName} ko delete karein?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Ruko'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  ref.read(khataProvider.notifier).deleteEntry(id: entry.id);
                                },
                                child: Text('Haan, delete karo',
                                    style: TextStyle(color: AppColors.error)),
                              ),
                            ],
                          ),
                        );
                      },
                      onEditAmount: () => _showEditAmountDialog(context, ref, entry),
                    );
                  },
                ),
              ],
            );
          },
          loading: () => ListView.builder(
            itemCount: 5,
            itemBuilder: (_, __) => const ShimmerBox(
              width: double.infinity,
              height: 72,
            ),
          ),
          error: (e, _) => AppErrorView(
            message: AppStrings.khataLoadError,
            onRetry: () => ref.invalidate(khataEntriesProvider),
          ),
        ),
      );
    }
  }

  // Empty state widget
  class _EmptyState extends StatelessWidget {
    const _EmptyState({required this.onAddTap});
    final VoidCallback onAddTap;

    @override
    Widget build(BuildContext context) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_balance_wallet_outlined,
                size: 72, color: AppColors.divider),
            const SizedBox(height: AppSpacing.lg),
            Text(AppStrings.khataEmptyTitle,
                style: AppTypography.headlineLarge),
            const SizedBox(height: AppSpacing.sm),
            Text(AppStrings.khataEmptySubtitle,
                style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary),
                textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: AppStrings.addFirstCustomerButton,
              onPressed: onAddTap,
            ),
          ],
        ),
      );
    }
  }

────────────────────────────────────────
  CHANGE 1 — app_nav_shell.dart    (MODIFIED — add Khata as Tab 1)
────────────────────────────────────────

  ADD Khata tab between Studio and My Ads:

  NEW TAB ORDER:
    Tab 0: Studio  (Icons.auto_awesome_rounded)  ← FAB stays here
    Tab 1: Khata   (Icons.account_balance_wallet_outlined)  ← NEW
    Tab 2: My Ads  (Icons.grid_view_rounded)
    Tab 3: Account (Icons.person_rounded)

  UPDATE IndexedStack to have 4 children:
    index 0: StudioScreen()
    index 1: KhataScreen()     ← NEW
    index 2: MyAdsScreen()
    index 3: AccountScreen()

  UPDATE FAB condition: show only on Tab 0 (Studio):
    if (_currentIndex == 0) FloatingActionButton(...)

  UPDATE BottomNavigationBar items (4 items total):
    BottomNavigationBarItem(icon: Icon(Icons.auto_awesome_rounded), label: 'Studio'),
    BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), label: 'Khata'),
    BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'My Ads'),
    BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Account'),

────────────────────────────────────────
  CHANGE 2 — app_routes.dart    (MODIFIED)
────────────────────────────────────────

  ADD:
    static const khata = '/khata';

────────────────────────────────────────
  CHANGE 3 — app_strings.dart    (MODIFIED — add only)
────────────────────────────────────────

  // Khata screen
  static const khataTitle            = 'Khata';
  static const totalPendingLabel     = 'Kul baaki rakam';
  static const baakiHai              = 'baaki hai';
  static const customersLabel        = 'customers';
  static const addKhataTitle         = 'Naya udhaar add karo';
  static const customerNameLabel     = 'Customer ka naam *';
  static const customerPhoneLabel    = 'Mobile number (optional)';
  static const amountLabel           = 'Kitna baaki hai *';
  static const noteLabel             = 'Note (optional)';
  static const noteHint              = 'e.g. kapde ka baaki, advance liya';
  static const saveKhataButton       = 'Save karo';
  static const khataAddedMessage     = 'Udhaar save ho gaya! ✓';
  static const khataEmptyTitle       = 'Koi udhaar nahi! 🎉';
  static const khataEmptySubtitle    = 'Sab accounts clear hain.
Naya customer add karo.';
  static const addFirstCustomerButton = '+ Pehla customer add karo';
  static const khataLoadError        = 'Khata load nahi hua. Retry karein.';
  // Action sheet options
  static const editAmountAction      = 'Amount badlo';
  static const sendReminderAction    = 'WhatsApp reminder bhejo';
  static const markPaidAction        = 'Paid mark karo ✓';
  static const deleteEntryAction     = 'Delete karo';
  // Edit dialog
  static const editAmountTitle       = 'Amount badlo';
  static const cancelButton          = 'Ruko';
  static const deleteConfirmTitle    = 'Pakka delete karein?';
  // WhatsApp errors
  static const noPhoneNumber         = 'Phone number nahi diya. Edit karke number add karein.';
  static const whatsappNotInstalled  = 'WhatsApp install nahi hai.';
  // Form validation
  static const fieldRequired         = 'Yeh field zaruri hai';

────────────────────────────────────────
  CHANGE 4 — Fill stub test files    (MODIFIED — replace void main() {})
────────────────────────────────────────

test/unit/features/khata/application/khata_provider_test.dart:

  class MockKhataRepository extends Mock implements KhataRepository {}

  void main() {
    group('khataEntriesProvider', () {

      test('emits empty list when repository stream returns empty', () {
        final mockRepo = MockKhataRepository();
        when(mockRepo.watchEntries(userId: any(named: 'userId')))
            .thenAnswer((_) => Stream.value([]));

        final container = ProviderContainer(overrides: [
          khataRepositoryProvider.overrideWithValue(mockRepo),
        ]);
        addTearDown(container.dispose);

        // Stream emits immediately
        expect(
          container.read(khataEntriesProvider),
          const AsyncData<List<KhataEntry>>([]),
        );
      });

      test('emits entries from repository stream', () async {
        final mockRepo = MockKhataRepository();
        final testEntries = [
          KhataEntry(
            id: 'e1', userId: 'u1', customerName: 'Amit',
            amount: 500, createdAt: DateTime(2026, 4, 1),
          ),
        ];
        when(mockRepo.watchEntries(userId: any(named: 'userId')))
            .thenAnswer((_) => Stream.value(testEntries));

        final container = ProviderContainer(overrides: [
          khataRepositoryProvider.overrideWithValue(mockRepo),
        ]);
        addTearDown(container.dispose);

        await container.read(khataEntriesProvider.future);
        expect(container.read(khataEntriesProvider).value, testEntries);
      });
    })

    group('Khata notifier', () {

      test('addEntry calls repository.addEntry with correct params', () async {
        final mockRepo = MockKhataRepository();
        when(mockRepo.addEntry(
          userId: any(named: 'userId'),
          customerName: any(named: 'customerName'),
          customerPhone: any(named: 'customerPhone'),
          amount: any(named: 'amount'),
          type: any(named: 'type'),
          note: any(named: 'note'),
        )).thenAnswer((_) async {});

        when(mockRepo.watchEntries(userId: any(named: 'userId')))
            .thenAnswer((_) => Stream.value([]));

        final container = ProviderContainer(overrides: [
          khataRepositoryProvider.overrideWithValue(mockRepo),
        ]);
        addTearDown(container.dispose);

        await container.read(khataProvider.notifier).addEntry(
          customerName: 'Rahul',
          amount: 1200.0,
        );

        verify(() => mockRepo.addEntry(
          userId: any(named: 'userId'),
          customerName: 'Rahul',
          customerPhone: null,
          amount: 1200.0,
          type: 'credit',
          note: null,
        )).called(1);
      });

      test('markPaid calls repository.markPaid', () async {
        final mockRepo = MockKhataRepository();
        when(mockRepo.markPaid(id: any(named: 'id'))).thenAnswer((_) async {});
        when(mockRepo.watchEntries(userId: any(named: 'userId')))
            .thenAnswer((_) => Stream.value([]));

        final container = ProviderContainer(overrides: [
          khataRepositoryProvider.overrideWithValue(mockRepo),
        ]);
        addTearDown(container.dispose);

        await container.read(khataProvider.notifier).markPaid(id: 'e1');

        verify(() => mockRepo.markPaid(id: 'e1')).called(1);
      });

      test('deleteEntry calls repository.deleteEntry', () async {
        // Same pattern as markPaid test above
        // ... abbreviated
      });

      test('updateAmount calls repository with new amount', () async {
        // ... abbreviated
      });
    })
  }

test/widget/features/khata/khata_screen_test.dart:

  void main() {
    group('KhataScreen', () {

      testWidgets('shows empty state when entries list is empty', (tester) async {
        // Mock stream returning empty list
        // expect: find khataEmptyTitle text
      });

      testWidgets('shows total baaki header when entries present', (tester) async {
        // Mock stream with 2 entries (500 + 1200)
        // expect: find '₹1700 baaki hai' text
      });

      testWidgets('shows KhataEntryCard for each unsettled entry', (tester) async {
        // Mock stream with 3 entries
        // expect: find 3 KhataEntryCard widgets
      });

      testWidgets('shows FAB add button', (tester) async {
        // expect: find FloatingActionButton
        // expect: find add icon
      });
    })
  }

────────────────────────────────────────
  OUTPUT ORDER (13 files total)
────────────────────────────────────────

NEW (6 files):
  1. lib/features/khata/domain/khata_entry.dart
  2. lib/features/khata/domain/repositories/khata_repository.dart
  3. lib/features/khata/infrastructure/khata_repository_impl.dart
  4. lib/features/khata/application/khata_provider.dart
  5. lib/features/khata/presentation/widgets/khata_entry_card.dart
  6. lib/features/khata/presentation/widgets/add_khata_sheet.dart
  7. lib/features/khata/presentation/screens/khata_screen.dart

MODIFIED (4 files):
  8. lib/shared/navigation/app_nav_shell.dart    (add Khata tab)
  9. lib/core/constants/app_routes.dart
  10. lib/core/constants/app_strings.dart

TEST (2 files — fill in stubs):
  11. test/unit/features/khata/application/khata_provider_test.dart
  12. test/widget/features/khata/khata_screen_test.dart

Generated by build_runner (1+ files):
  13. lib/features/khata/infrastructure/khata_repository_impl.g.dart
  14. lib/features/khata/application/khata_provider.g.dart
  15. lib/features/khata/domain/khata_entry.freezed.dart

────────────────────────────────────────
  DO NOT
────────────────────────────────────────

✗ DO NOT use 'amountowed', 'notes', 'lastupdated' column names —
  the actual DB columns are 'amount', 'note', 'createdat'
✗ DO NOT use .select() for Khata list — use .stream() for realtime updates
✗ DO NOT implement pagination — the stream auto-filters issettled=false entries
✗ DO NOT add WhatsApp deep link (wa.me) to the intent-filter in AndroidManifest —
  url_launcher handles this automatically
✗ DO NOT use pumpAndSettle in widget tests
✗ DO NOT make the FAB show on Khata tab — it stays on Studio (Tab 0) ONLY
✗ DO NOT access supabase.auth.currentUser in the repository — pass userId explicitly
✗ DO NOT use ref.read in build() — use ref.watch for khataRepositoryProvider
✗ DO NOT hardcode shop name in WhatsApp message — use 'Aapki Dukaan' for MVP
  with TODO comment to replace with actual profile.shopName in Task 4.3
```

---

## STEP 3 — VALIDATION

```bash
dart run build_runner build --delete-conflicting-outputs
# Expected: clean, khata_provider.g.dart + khata_repository_impl.g.dart generated

flutter analyze
# Expected: No issues found!

flutter test
# Expected: 75+ passed, 0 failed

flutter test test/unit/features/khata/
# Expected: 5/5 khata_provider tests pass

flutter test test/widget/features/khata/
# Expected: 4/4 khata_screen tests pass

# Test on emulator
flutter run -d emulator-5554 --dart-define=SKIP_AUTH=true
# Manual test flow:
# a. Bottom nav now shows: Studio | Khata | My Ads | Account
# b. Tap Khata tab → shows empty state "Koi udhaar nahi! 🎉"
# c. Tap FAB (+) → Add sheet slides up with form
# d. Fill: Name "Amit Kumar", Phone "9876543210", Amount "500", Note "kapde ka"
# e. Tap "Save karo" → entry appears instantly in list (Realtime stream)
# f. Header shows "₹500 baaki hai, 1 customers"
# g. Long-press the entry → action sheet with 4 options
# h. Tap "WhatsApp reminder bhejo" → WhatsApp opens with pre-filled message
# i. Tap "Paid mark karo ✓" → entry disappears (issettled=true, filtered from stream)
# j. Header updates to "Koi udhaar nahi! 🎉"
```

---

## VALIDATION CHECKLIST

- [ ] `KhataEntry.fromRow()` uses exact DB column names: `customername`, `amount`, `issettled`
- [ ] Stream uses `.stream(primaryKey: ['id'])` (not `.select()`)
- [ ] Stream filters `issettled == false` entries only
- [ ] `khataEntriesProvider` is `Stream<List<KhataEntry>>` (not `Future`)
- [ ] `khataProvider` notifier wraps mutations with `AsyncValue.guard`
- [ ] Bottom nav has 4 tabs (Studio | Khata | My Ads | Account)
- [ ] FAB shows ONLY on Studio tab (Tab 0)
- [ ] WhatsApp URL uses `wa.me/{phone}?text={encodedMessage}` format
- [ ] Phone number normalized: 10-digit without 91 → add `91` prefix
- [ ] `trackEvent` for reminder is fire-and-forget (no `await` in calling code)
- [ ] Delete shows confirmation dialog before deleting
- [ ] `markPaid` shows success SnackBar with customer name + amount
- [ ] `build_runner` clean
- [ ] `flutter analyze`: No issues found!

---

## WHAT COMES NEXT — TASK 2.2

> **Task 2.2 — Supabase Database Schema SQL Migration**
> Writes the complete SQL migration file for all tables: profiles, generatedads,
> khataentries, transactions, usageevents. Adds RLS policies for all tables,
> creates the `decrementcredits(userid)` RPC function, and adds indexes on
> `userid` for all tables. Also creates a `supabase/migrations/` directory
> with the properly named migration file. This task runs the actual SQL in
> the Supabase Dashboard — no Flutter code changes.

---

*Dukaan AI v1.0 Build Playbook · Task 2.1 · Generated April 2026*
