import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

class SupabaseService {
  final SupabaseClient client;

  const SupabaseService({required this.client});

  SupabaseQueryBuilder from(String table) => client.from(table);

  SupabaseStorageClient get storage => client.storage;
}

final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseService(client: client);
});