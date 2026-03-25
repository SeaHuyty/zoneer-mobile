import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zoneer_mobile/features/user/models/user_model.dart';
import 'package:zoneer_mobile/features/user/repositories/user_repository.dart';

final authUser = Supabase.instance.client.auth.currentUser;

final userByIdProvider =
    FutureProvider.family<UserModel, String>((ref, id) {
  return ref.read(userRepositoryProvider).getUserById(id);
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});
