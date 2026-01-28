import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zoneer_mobile/features/inquiry/models/inquiry_model.dart';
import 'package:zoneer_mobile/features/inquiry/repositories/inquiry_repository.dart';

class InquiryViewmodel extends AsyncNotifier<List<InquiryModel>> {
  @override
  Future<List<InquiryModel>> build() async => [];

  Future<void> loadUserInquiries(String userId) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      return ref.read(inquiryRepositoryProvider).getInquiriesByUserId(userId);
    });
  }

  Future<void> loadPropertyInquiries(String propertyId) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      return ref
          .read(inquiryRepositoryProvider)
          .getInquiriesByPropertyId(propertyId);
    });
  }

  Future<void> submitInquiry(InquiryModel inquiry) async {
    await AsyncValue.guard(() async {
      await ref.read(inquiryRepositoryProvider).createInquiry(inquiry);
    });
  }
}

final inquiriesViewModelProvider =
    AsyncNotifierProvider<InquiryViewmodel, List<InquiryModel>>(
      InquiryViewmodel.new,
    );
