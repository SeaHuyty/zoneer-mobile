import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zoneer_mobile/core/services/auth_service.dart';
import 'package:zoneer_mobile/features/property/viewmodels/property_sections_viewmodel.dart';
import 'package:zoneer_mobile/features/property/widgets/banner.dart';
import 'package:zoneer_mobile/features/property/widgets/home_header.dart';
import 'package:zoneer_mobile/features/property/widgets/home_properties_category.dart';
import 'package:zoneer_mobile/features/property/widgets/home_property_section.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset > 0 && !_isScrolled) {
        setState(() => _isScrolled = true);
      } else if (_scrollController.offset <= 0 && _isScrolled) {
        setState(() => _isScrolled = false);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
      final isAuthenticated = ref.watch(isAuthenticatedProvider);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
              flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                    final isCollapsed = constraints.maxHeight <= 200;

                return ClipRRect(
                  child: HomeHeader(isCollapsed: isCollapsed));
              },
            ),
            pinned: true,
            expandedHeight: isAuthenticated ? 270 : 140, 
            collapsedHeight: 140, 
            elevation: _isScrolled ? 4 : 0,
            shadowColor: Colors.black26,
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: false,
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                isAuthenticated? SizedBox.shrink() : const BannerZoneer() ,
                const SizedBox(height: 10),
                const Text(
                  'Category',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                const HomePropertiesCategory(),
                const SizedBox(height: 10),
                HomePropertySection(
                  title: 'House',
                  sectionType: 'house',
                  propertiesAsync: ref.watch(
                    propertySectionProvider(PropertySection.house),
                  ),
                ),
                HomePropertySection(
                  title: 'Condo',
                  sectionType: 'condo',
                  propertiesAsync: ref.watch(
                    propertySectionProvider(PropertySection.condo),
                  ),
                ),
                HomePropertySection(
                  title: 'Apartment',
                  sectionType: 'apartment',
                  propertiesAsync: ref.watch(
                    propertySectionProvider(PropertySection.apartment),
                  ),
                ),
                HomePropertySection(
                  title: 'Room',
                  sectionType: 'room',
                  propertiesAsync: ref.watch(
                    propertySectionProvider(PropertySection.room),
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
