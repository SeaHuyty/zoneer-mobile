import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zoneer_mobile/features/property/models/property_model.dart';
import 'package:zoneer_mobile/features/property/repositories/property_repository.dart';

class PropertyViewmodel extends Notifier<AsyncValue<List<PropertyModel>>> {
  @override
  AsyncValue<List<PropertyModel>> build() {
    return const AsyncValue.loading();
  }

  Future<void> loadProperties() async {
    state = const AsyncValue.loading();
    try {
      final properties = await ref.read(propertyRepositoryProvider).getProperties();
      state = AsyncValue.data(properties);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> loadPropertyById(String id) async {
    
  }
}