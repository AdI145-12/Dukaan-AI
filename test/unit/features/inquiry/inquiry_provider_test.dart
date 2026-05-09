import 'package:dukaan_ai/core/providers/firebase_providers.dart';
import 'package:dukaan_ai/features/inquiry/application/inquiry_provider.dart';
import 'package:dukaan_ai/features/inquiry/domain/inquiry.dart';
import 'package:dukaan_ai/features/inquiry/domain/inquiry_repository.dart';
import 'package:dukaan_ai/features/inquiry/domain/inquiry_status.dart';
import 'package:dukaan_ai/features/inquiry/infrastructure/inquiry_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/test_data.dart';

class MockInquiryRepository extends Mock implements InquiryRepository {}

void main() {
  late MockInquiryRepository mockRepo;

  setUpAll(() {
    registerFallbackValue(testInquiry());
  });

  setUp(() {
    mockRepo = MockInquiryRepository();
  });

  ProviderContainer createContainer() {
    final ProviderContainer container = ProviderContainer(
      overrides: [
        inquiryRepositoryProvider.overrideWithValue(mockRepo),
        currentUserIdProvider.overrideWithValue('test-uid'),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('InquiryNotifier.addInquiry', () {
    test('addInquiry should optimistically prepend new inquiry to list',
        () async {
      final Inquiry existing = testInquiry(id: 'existing');
      final Inquiry newInquiry = testInquiry(id: 'new');

      when(() => mockRepo.watchInquiries(any()))
          .thenAnswer((_) => Stream<List<Inquiry>>.value(<Inquiry>[existing]));
      when(() => mockRepo.createInquiry(any()))
          .thenAnswer((_) async => newInquiry);

      final ProviderContainer container = createContainer();
      await container.read(inquiryProvider.future);

      await container.read(inquiryProvider.notifier).addInquiry(newInquiry);

      final List<Inquiry> inquiries =
          container.read(inquiryProvider).requireValue.inquiries;
      expect(inquiries.first.id, equals('new'));
      expect(inquiries.length, equals(2));
    });
  });

  group('InquiryNotifier.advanceStatus', () {
    test('advanceStatus should move newInquiry to interested', () async {
      final Inquiry inquiry = testInquiry(status: InquiryStatus.newInquiry);

      when(() => mockRepo.watchInquiries(any()))
          .thenAnswer((_) => Stream<List<Inquiry>>.value(<Inquiry>[inquiry]));
      when(() => mockRepo.updateInquiry(any())).thenAnswer((_) async {});

      final ProviderContainer container = createContainer();
      await container.read(inquiryProvider.future);

      await container.read(inquiryProvider.notifier).advanceStatus(inquiry);

      final Inquiry updated =
          container.read(inquiryProvider).requireValue.inquiries.first;
      expect(updated.status, equals(InquiryStatus.interested));
    });

    test('advanceStatus should not update delivered terminal state', () async {
      final Inquiry inquiry = testInquiry(status: InquiryStatus.delivered);

      when(() => mockRepo.watchInquiries(any()))
          .thenAnswer((_) => Stream<List<Inquiry>>.value(<Inquiry>[inquiry]));

      final ProviderContainer container = createContainer();
      await container.read(inquiryProvider.future);

      await container.read(inquiryProvider.notifier).advanceStatus(inquiry);

      verifyNever(() => mockRepo.updateInquiry(any()));
    });
  });

  group('InquiryNotifier.deleteInquiry', () {
    test('deleteInquiry should remove inquiry optimistically', () async {
      final Inquiry inquiry = testInquiry();

      when(() => mockRepo.watchInquiries(any()))
          .thenAnswer((_) => Stream<List<Inquiry>>.value(<Inquiry>[inquiry]));
      when(() => mockRepo.deleteInquiry(any())).thenAnswer((_) async {});

      final ProviderContainer container = createContainer();
      await container.read(inquiryProvider.future);

      await container.read(inquiryProvider.notifier).deleteInquiry(inquiry.id);

      expect(container.read(inquiryProvider).requireValue.inquiries, isEmpty);
    });
  });

  group('InquiryNotifier.setFilter', () {
    test('setFilter should update active filter when status is selected',
        () async {
      final Inquiry inquiry = testInquiry();
      when(() => mockRepo.watchInquiries(any()))
          .thenAnswer((_) => Stream<List<Inquiry>>.value(<Inquiry>[inquiry]));

      final ProviderContainer container = createContainer();
      await container.read(inquiryProvider.future);

      container
          .read(inquiryProvider.notifier)
          .setFilter(InquiryStatus.followUpNeeded);

      expect(
        container.read(inquiryProvider).requireValue.activeFilter,
        equals(InquiryStatus.followUpNeeded),
      );
    });
  });

  group('InquiryStatus.isFollowUpDue', () {
    test('isFollowUpDue should return true when status is followUpNeeded', () {
      final Inquiry inquiry = testInquiry(status: InquiryStatus.followUpNeeded);
      expect(inquiry.isFollowUpDue, isTrue);
    });

    test(
        'isFollowUpDue should return true for interested inquiry older than 2 days',
        () {
      final Inquiry inquiry = testInquiry(
        status: InquiryStatus.interested,
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      );
      expect(inquiry.isFollowUpDue, isTrue);
    });

    test(
        'isFollowUpDue should return false for interested inquiry within 1 day',
        () {
      final Inquiry inquiry = testInquiry(
        status: InquiryStatus.interested,
        updatedAt: DateTime.now().subtract(const Duration(hours: 23)),
      );
      expect(inquiry.isFollowUpDue, isFalse);
    });

    test('isFollowUpDue should return false for ordered status', () {
      final Inquiry inquiry = testInquiry(
        status: InquiryStatus.ordered,
        updatedAt: DateTime.now().subtract(const Duration(days: 30)),
      );
      expect(inquiry.isFollowUpDue, isFalse);
    });
  });
}
