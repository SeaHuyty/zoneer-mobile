import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zoneer_mobile/features/inquiry/model/inquiry_model.dart';
import 'package:zoneer_mobile/features/inquiry/repositories/inquiry_repository.dart';

class InquiryViewmodel extends Notifier<AsyncValue<List<InquiryModel>>> {
  @override
  AsyncValue<List<InquiryModel>> build() {
    return const AsyncValue.loading();
  }

  Future<void> loadUserInquiries(String userId) async {
    state = const AsyncValue.loading();
    try {
      final inquiries = await ref
          .read(inquiryRepositoryProvider)
          .getInquiriesByUserId(userId);
      state = AsyncValue.data(inquiries);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> loadPropertyInquiries(String propertyId) async {
    state = const AsyncValue.loading();
    try {
      final inquiries = await ref
          .read(inquiryRepositoryProvider)
          .getInquiriesByPropertyId(propertyId);
      state = AsyncValue.data(inquiries);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> submitInquiry(InquiryModel inquiry) async {
    try {
      await ref.read(inquiryRepositoryProvider).createInquiry(inquiry);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final inquiriesViewModelProvider =
    NotifierProvider<InquiryViewmodel, AsyncValue<List<InquiryModel>>>(() {
      return InquiryViewmodel();
    });
