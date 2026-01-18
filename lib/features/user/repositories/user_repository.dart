import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zoneer_mobile/core/services/supabase_service.dart';
import 'package:zoneer_mobile/features/user/models/user_model.dart';

class UserRepository {
  final SupabaseService _supabase;

  UserRepository(this._supabase);

  Future<List<UserModel>> getUsers() async {
    final response = await _supabase.from('users').select();
    return (response as List).map((e) => UserModel.fromJson(e)).toList();
  }
}

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final supabase = ref.watch(supabaseServiceProvider);
  return UserRepository(supabase);
});