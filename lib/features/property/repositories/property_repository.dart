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

  Future<PropertyModel> getPropertyById(String id) async {
    final response = await _supabase
        .from('properties')
        .select()
        .eq('id', id)
        .single();
    return PropertyModel.fromJson(response);
  }

  Future<List<PropertyModel>> getPropertiesByLandlordId(
    String landlordId,
  ) async {
    final response = await _supabase
        .from('properties')
        .select()
        .eq('landlord_id', landlordId);
    return (response as List).map((e) => PropertyModel.fromJson(e)).toList();
  }

  Future<void> createProperty(PropertyModel property) async {
    await _supabase.from('properties').insert(property.toJson());
  }

  Future<void> updateProperty(PropertyModel property) async {
    await _supabase
        .from('properties')
        .update(property.toJson())
        .eq('id', property.id);
  }

  Future<void> deleteProperty(String id) async {
    await _supabase.from('properties').delete().eq('id', id);
  }
}

final propertyRepositoryProvider = Provider<PropertyRepository>((ref) {
  final supabase = ref.watch(supabaseServiceProvider);
  return PropertyRepository(supabase);
});
