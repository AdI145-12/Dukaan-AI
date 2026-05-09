import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/features/khata/application/khata_provider.dart';
import 'package:dukaan_ai/features/khata/domain/khata_entry.dart';
import 'package:dukaan_ai/features/khata/presentation/screens/khata_screen.dart';
import 'package:dukaan_ai/features/khata/presentation/widgets/khata_entry_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
	Future<void> pumpKhataScreen(
		WidgetTester tester, {
		required List<KhataEntry> entries,
	}) async {
		await tester.pumpWidget(
			ProviderScope(
				overrides: [
					khataEntriesProvider.overrideWith(
						(Ref ref) => Stream<List<KhataEntry>>.value(entries),
					),
				],
				child: const MaterialApp(home: KhataScreen()),
			),
		);
		await tester.pump();
	}

	group('KhataScreen', () {
		testWidgets('shows empty state when entries list is empty', (
			WidgetTester tester,
		) async {
			await pumpKhataScreen(tester, entries: const <KhataEntry>[]);

			expect(find.text(AppStrings.khataEmptyTitle), findsOneWidget);
			expect(find.text(AppStrings.addFirstCustomerButton), findsOneWidget);
		});

		testWidgets('shows total baaki header when entries are present', (
			WidgetTester tester,
		) async {
			await pumpKhataScreen(
				tester,
				entries: <KhataEntry>[
					_entry(id: 'e1', amount: 500, customerName: 'Amit'),
					_entry(id: 'e2', amount: 1200, customerName: 'Neha'),
				],
			);

			expect(find.text('₹1700 ${AppStrings.baakiHai}'), findsOneWidget);
			expect(find.text('2 ${AppStrings.customersLabel}'), findsOneWidget);
		});

		testWidgets('shows one KhataEntryCard per unsettled entry', (
			WidgetTester tester,
		) async {
			await pumpKhataScreen(
				tester,
				entries: <KhataEntry>[
					_entry(id: 'e1', amount: 500, customerName: 'Amit'),
					_entry(id: 'e2', amount: 800, customerName: 'Neha'),
					_entry(id: 'e3', amount: 350, customerName: 'Ravi'),
				],
			);

			expect(find.byType(KhataEntryCard), findsNWidgets(3));
		});

		testWidgets('shows FAB add button', (WidgetTester tester) async {
			await pumpKhataScreen(
				tester,
				entries: <KhataEntry>[_entry(id: 'e1', amount: 100, customerName: 'A')],
			);

			expect(find.byType(FloatingActionButton), findsOneWidget);
			expect(find.byIcon(Icons.add), findsOneWidget);
		});
	});
}

KhataEntry _entry({
	required String id,
	required double amount,
	required String customerName,
}) {
	return KhataEntry(
		id: id,
		userId: 'u1',
		customerName: customerName,
		amount: amount,
		createdAt: DateTime(2026, 4, 1),
	);
}