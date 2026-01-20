import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zoneer_mobile/core/services/supabase_service.dart';
import 'package:zoneer_mobile/features/property/models/property_model.dart';

class PropertyRepository {
  final SupabaseService _supabase;

  PropertyRepository(this._supabase);

  Future<List<PropertyModel>> getProperties() async {
    final response = await _supabase.from('properties').select();
    return (response as List).map((e) => PropertyModel.fromJson(e)).toList();
  }
}

final propertyRepositoryProvider = Provider<PropertyRepository>((ref) {
  final supabase = ref.watch(supabaseServiceProvider);
  return PropertyRepository(supabase);
});