import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zoneer_mobile/features/property/viewmodels/property_sections_viewmodel.dart';
import 'package:zoneer_mobile/features/property/widgets/home_header.dart';
import 'package:zoneer_mobile/features/property/widgets/home_properties_category.dart';
import 'package:zoneer_mobile/features/property/widgets/home_property_section.dart';
import 'package:zoneer_mobile/shared/widgets/search_bar.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: const HomeHeader(),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SearchBarApp(),
              const SizedBox(height: 20),
              const HomePropertiesCategory(),

              HomePropertySection(title: 'Nearby', propertiesAsync: ref.watch(propertySectionProvider(PropertySection.nearby))),
              HomePropertySection(title: 'Property in Siem Reap', propertiesAsync: ref.watch(propertySectionProvider(PropertySection.siemreap))),
              HomePropertySection(title: 'Property in Phnom Penh', propertiesAsync: ref.watch(propertySectionProvider(PropertySection.phnompenh)))
            ],
          ),
        ),
      ),
    );
  }
}
