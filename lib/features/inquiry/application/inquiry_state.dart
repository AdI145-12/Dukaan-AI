import 'package:dukaan_ai/features/inquiry/domain/inquiry.dart';
import 'package:dukaan_ai/features/inquiry/domain/inquiry_status.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'inquiry_state.freezed.dart';

@freezed
abstract class InquiryState with _$InquiryState {
  const factory InquiryState({
    @Default(<Inquiry>[]) List<Inquiry> inquiries,
    InquiryStatus? activeFilter,
  }) = _InquiryState;

  const InquiryState._();

  List<Inquiry> get followUpDue {
    return inquiries.where((Inquiry inquiry) => inquiry.isFollowUpDue).toList();
  }

  List<Inquiry> get filtered {
    if (activeFilter == null) {
      return inquiries;
    }

    return inquiries
        .where((Inquiry inquiry) => inquiry.status == activeFilter!)
        .toList();
  }
}
