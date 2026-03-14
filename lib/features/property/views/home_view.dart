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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            flexibleSpace: const HomeHeader(),
            floating: true,
            pinned: false,
            snap: true,
            toolbarHeight: 140,
            elevation: 0,
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SearchBarApp(),
                const SizedBox(height: 10),
                const Text(
                  'Category',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                const HomePropertiesCategory(),
                const SizedBox(height: 10),
                HomePropertySection(
                  title: 'Nearby',
                  propertiesAsync: ref.watch(
                    propertySectionProvider(PropertySection.nearby),
                  ),
                ),
                HomePropertySection(
                  title: 'Property in Siem Reap',
                  propertiesAsync: ref.watch(
                    propertySectionProvider(PropertySection.siemreap),
                  ),
                ),
                HomePropertySection(
                  title: 'Property in Phnom Penh',
                  propertiesAsync: ref.watch(
                    propertySectionProvider(PropertySection.phnompenh),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
