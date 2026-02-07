import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zoneer_mobile/features/property/models/property_model.dart';
import 'package:zoneer_mobile/features/property/viewmodels/properties_viewmodel.dart';

enum PropertySection {
  nearby,
  featured,
  phnompenh,
  siemreap
}

final propertySectionProvider = Provider.family<AsyncValue<List<PropertyModel>>, PropertySection>((ref, section) {
  final propertiesAsync = ref.watch(propertiesViewModelProvider);

  return propertiesAsync.whenData((properties) {
    switch (section) {
      case PropertySection.nearby:
        return properties.where((p) => p.bathroom >= 1).toList();
      case PropertySection.featured:
        return properties.where((p) => p.bedroom >= 1).toList();
      case PropertySection.phnompenh:
        return properties.where((p) => p.address.contains('Phnom Penh')).toList();
      case PropertySection.siemreap:
        return properties.where((p) => p.address.contains('Siem Reap')).toList();
    }
  });
});