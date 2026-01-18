import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zoneer_mobile/features/users/repositories/user_repository.dart';
import 'package:zoneer_mobile/features/users/models/user_model.dart';

class UserViewmodel extends Notifier<AsyncValue<List<UserModel>>> {
  @override
  AsyncValue<List<UserModel>> build() {
    loadUsers();
    return const AsyncValue.loading();
  }

  Future<void> loadUsers() async {
    state = const AsyncValue.loading();
    try {
      final users = await ref.read(userRepositoryProvider).getUsers();
      state = AsyncValue.data(users);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final userViewModelProvider = NotifierProvider<UserViewmodel, AsyncValue<List<UserModel>>>(() {
  return UserViewmodel();
});