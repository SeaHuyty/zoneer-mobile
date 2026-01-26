import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zoneer_mobile/features/property/widgets/home_header.dart';
import 'package:zoneer_mobile/features/property/widgets/home_properties_category.dart';
import 'package:zoneer_mobile/shared/widgets/seach_bar.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: const HomeHeader(),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SearchBarApp(),
            SizedBox(height: 20),
            HomePropertiesCategory(),
          ],
        ),
      ),
    );
  }
}
