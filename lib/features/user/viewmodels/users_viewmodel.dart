import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zoneer_mobile/features/user/repositories/user_repository.dart';
import 'package:zoneer_mobile/features/user/models/user_model.dart';

class UsersViewmodel extends AsyncNotifier<List<UserModel>> {
  @override
  Future<List<UserModel>> build() async => [];

  Future<void> loadUsers() async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(
      () => ref.read(userRepositoryProvider).getUsers(),
    );
  }
}

final usersViewModelProvider =
    AsyncNotifierProvider<UsersViewmodel, List<UserModel>>(UsersViewmodel.new);
