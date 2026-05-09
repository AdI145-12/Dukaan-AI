import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/core/providers/firebase_providers.dart';
import 'package:dukaan_ai/features/inquiry/domain/inquiry.dart';
import 'package:dukaan_ai/features/inquiry/domain/inquiry_repository.dart';
import 'package:dukaan_ai/features/inquiry/domain/inquiry_status.dart';
import 'package:dukaan_ai/features/inquiry/infrastructure/inquiry_repository_impl.dart';
import 'package:dukaan_ai/features/inquiry/presentation/screens/inquiry_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/test_data.dart';

class MockInquiryRepository extends Mock implements InquiryRepository {}

void main() {
  late MockInquiryRepository mockRepo;

  setUp(() {
    mockRepo = MockInquiryRepository();
  });

  Widget buildSubject() {
    return ProviderScope(
      overrides: [
        inquiryRepositoryProvider.overrideWithValue(mockRepo),
        currentUserIdProvider.overrideWithValue('test-uid'),
      ],
      child: const MaterialApp(home: InquiryListScreen()),
    );
  }

  testWidgets('shows empty state when there are no inquiries',
      (WidgetTester tester) async {
    when(() => mockRepo.watchInquiries(any()))
        .thenAnswer((_) => Stream<List<Inquiry>>.value(const <Inquiry>[]));

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.inquiryEmptyTitle), findsOneWidget);
  });

  testWidgets('renders inquiry cards when repository returns data',
      (WidgetTester tester) async {
    when(() => mockRepo.watchInquiries(any())).thenAnswer(
      (_) => Stream<List<Inquiry>>.value(
        <Inquiry>[
          testInquiry(customerName: 'Rina Sharma'),
          testInquiry(id: 'i2', customerName: 'Vikram Singh'),
        ],
      ),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text('Rina Sharma'), findsOneWidget);
    expect(find.text('Vikram Singh'), findsOneWidget);
  });

  testWidgets('shows follow-up due section when due inquiry exists',
      (WidgetTester tester) async {
    final Inquiry dueInquiry = testInquiry(
      status: InquiryStatus.followUpNeeded,
      customerName: 'Follow Due Person',
    );

    when(() => mockRepo.watchInquiries(any())).thenAnswer(
      (_) => Stream<List<Inquiry>>.value(<Inquiry>[dueInquiry]),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.followUpDueTitle), findsOneWidget);
    expect(find.text('Follow Due Person'), findsWidgets);
  });
}
