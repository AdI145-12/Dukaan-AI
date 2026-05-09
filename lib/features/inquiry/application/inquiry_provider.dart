import 'package:dukaan_ai/core/providers/firebase_providers.dart';
import 'package:dukaan_ai/features/inquiry/application/inquiry_state.dart';
import 'package:dukaan_ai/features/inquiry/domain/inquiry.dart';
import 'package:dukaan_ai/features/inquiry/domain/inquiry_repository.dart';
import 'package:dukaan_ai/features/inquiry/domain/inquiry_status.dart';
import 'package:dukaan_ai/features/inquiry/infrastructure/inquiry_repository_impl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'inquiry_provider.g.dart';

@riverpod
class InquiryNotifier extends _$InquiryNotifier {
  @override
  Future<InquiryState> build() async {
    final String userId = ref.watch(currentUserIdProvider);
    if (userId.trim().isEmpty) {
      return const InquiryState();
    }

    final InquiryRepository repo = ref.watch(inquiryRepositoryProvider);
    final List<Inquiry> list = await repo.watchInquiries(userId).first;

    ref.listen<AsyncValue<List<Inquiry>>>(
      inquiryStreamProvider(userId),
      (_, AsyncValue<List<Inquiry>> next) {
        next.whenData((List<Inquiry> latest) {
          final InquiryState current =
              state.asData?.value ?? const InquiryState();
          state = AsyncData(current.copyWith(inquiries: latest));
        });
      },
    );

    return InquiryState(inquiries: list);
  }

  /// Creates a new inquiry and updates local state optimistically.
  Future<void> addInquiry(Inquiry inquiry) async {
    final AsyncValue<Inquiry> created = await AsyncValue.guard(
      () => ref.read(inquiryRepositoryProvider).createInquiry(inquiry),
    );

    created.whenData((Inquiry saved) {
      final InquiryState current = state.asData?.value ?? const InquiryState();
      state = AsyncData(
        current.copyWith(inquiries: <Inquiry>[saved, ...current.inquiries]),
      );
    });
  }

  /// Updates an existing inquiry and syncs the change to Firestore.
  Future<void> updateInquiry(Inquiry inquiry) async {
    final InquiryState current = state.asData?.value ?? const InquiryState();

    state = AsyncData(
      current.copyWith(
        inquiries: current.inquiries
            .map((Inquiry i) => i.id == inquiry.id ? inquiry : i)
            .toList(growable: false),
      ),
    );

    await AsyncValue.guard(
      () => ref.read(inquiryRepositoryProvider).updateInquiry(inquiry),
    );
  }

  /// Moves inquiry to the next status in the pipeline, if available.
  Future<void> advanceStatus(Inquiry inquiry) async {
    final InquiryStatus? next = inquiry.status.next;
    if (next == null) {
      return;
    }

    await updateInquiry(
      inquiry.copyWith(status: next),
    );
  }

  /// Marks this inquiry as requiring follow-up.
  Future<void> markFollowUpNeeded(Inquiry inquiry) async {
    await updateInquiry(
      inquiry.copyWith(status: InquiryStatus.followUpNeeded),
    );
  }

  /// Deletes an inquiry by id and removes it from local state.
  Future<void> deleteInquiry(String id) async {
    final InquiryState current = state.asData?.value ?? const InquiryState();

    state = AsyncData(
      current.copyWith(
        inquiries: current.inquiries
            .where((Inquiry inquiry) => inquiry.id != id)
            .toList(growable: false),
      ),
    );

    await AsyncValue.guard(
      () => ref.read(inquiryRepositoryProvider).deleteInquiry(id),
    );
  }

  /// Updates active status filter (null means all inquiries).
  void setFilter(InquiryStatus? filter) {
    final InquiryState current = state.asData?.value ?? const InquiryState();

    state = AsyncData(
      current.copyWith(
        activeFilter: filter,
      ),
    );
  }
}

/// Streams inquiries for a user in real time.
@riverpod
Stream<List<Inquiry>> inquiryStream(
  Ref ref,
  String userId,
) {
  if (userId.trim().isEmpty) {
    return Stream<List<Inquiry>>.value(const <Inquiry>[]);
  }

  final InquiryRepository repo = ref.watch(inquiryRepositoryProvider);
  return repo.watchInquiries(userId);
}

/// Streams count of inquiries currently due for follow-up.
@riverpod
Stream<int> followUpDueCount(Ref ref) {
  final String userId = ref.watch(currentUserIdProvider);
  if (userId.trim().isEmpty) {
    return Stream<int>.value(0);
  }

  final InquiryRepository repo = ref.watch(inquiryRepositoryProvider);
  return repo.watchFollowUpDueCount(userId);
}
