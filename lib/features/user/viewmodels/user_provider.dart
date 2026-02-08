import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zoneer_mobile/features/user/models/user_model.dart';
import 'package:zoneer_mobile/features/user/repositories/user_repository.dart';

final userByIdProvider =
    FutureProvider.family<UserModel, String>((ref, id) {
  return ref.read(userRepositoryProvider).getUserById(id);
});
