import 'inquiry.dart';
import 'inquiry_status.dart';

abstract interface class InquiryRepository {
  /// Real-time stream of all inquiries for this user, ordered by updatedAt desc.
  Stream<List<Inquiry>> watchInquiries(String userId);

  /// Count of follow-up due inquiries — used for the tab badge.
  Stream<int> watchFollowUpDueCount(String userId);

  Future<Inquiry> createInquiry(Inquiry inquiry);

  Future<void> updateInquiry(Inquiry inquiry);

  Future<void> updateStatus(String inquiryId, InquiryStatus newStatus);

  Future<void> deleteInquiry(String inquiryId);
}
