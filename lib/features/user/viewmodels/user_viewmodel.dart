import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zoneer_mobile/features/user/models/user_model.dart';
import 'package:zoneer_mobile/features/user/repositories/user_repository.dart';

class UserViewmodel extends Notifier<AsyncValue<UserModel>> {
  @override
  AsyncValue<UserModel> build() {
    return const AsyncValue.loading();
  }

  Future<void> loadUserById(String id) async {
    state = const AsyncValue.loading();
    try {
      final user = await ref.read(userRepositoryProvider).getUserById(id);
      state = AsyncValue.data(user);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final userViewModelProvider =
    NotifierProvider<UserViewmodel, AsyncValue<UserModel>>(() {
      return UserViewmodel();
    });
