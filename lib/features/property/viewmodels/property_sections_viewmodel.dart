import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zoneer_mobile/features/property/models/property_model.dart';
import 'package:zoneer_mobile/features/property/repositories/property_repository.dart';

enum PropertySection { nearby, featured, phnompenh, siemreap }

final propertySectionProvider =
    FutureProvider.family<List<PropertyModel>, PropertySection>((
      ref,
      section,
    ) async {
      final repo = ref.read(propertyRepositoryProvider);

      switch (section) {
        case PropertySection.nearby:
          return repo.getVerifiedPropertiesSection(limit: 20, minBathroom: 1);
        case PropertySection.featured:
          return repo.getVerifiedPropertiesSection(limit: 20, minBedroom: 1);
        case PropertySection.phnompenh:
          return repo.getVerifiedPropertiesSection(
            limit: 20,
            addressContains: 'Phnom Penh',
          );
        case PropertySection.siemreap:
          return repo.getVerifiedPropertiesSection(
            limit: 20,
            addressContains: 'Siem Reap',
          );
      }
    });
