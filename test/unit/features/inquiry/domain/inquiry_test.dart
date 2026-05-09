import 'package:dukaan_ai/features/inquiry/domain/inquiry.dart';
import 'package:dukaan_ai/features/inquiry/domain/inquiry_source.dart';
import 'package:dukaan_ai/features/inquiry/domain/inquiry_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Inquiry buildInquiry({
    required InquiryStatus status,
    required DateTime updatedAt,
  }) {
    return Inquiry(
      id: 'inq-1',
      userId: 'user-1',
      customerName: 'Ravi',
      productAsked: 'Kurta M size',
      source: InquirySource.whatsapp,
      status: status,
      createdAt: DateTime(2026, 4, 11),
      updatedAt: updatedAt,
    );
  }

  test('isFollowUpDue returns false for newInquiry', () {
    final Inquiry inquiry = buildInquiry(
      status: InquiryStatus.newInquiry,
      updatedAt: DateTime.now().subtract(const Duration(days: 4)),
    );

    expect(inquiry.isFollowUpDue, isFalse);
  });

  test('isFollowUpDue returns true for followUpNeeded', () {
    final Inquiry inquiry = buildInquiry(
      status: InquiryStatus.followUpNeeded,
      updatedAt: DateTime.now(),
    );

    expect(inquiry.isFollowUpDue, isTrue);
  });

  test('isFollowUpDue returns true for interested with old updatedAt', () {
    final Inquiry inquiry = buildInquiry(
      status: InquiryStatus.interested,
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
    );

    expect(inquiry.isFollowUpDue, isTrue);
  });
}
