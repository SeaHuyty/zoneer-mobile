import 'package:flutter/material.dart';

class ImageWidget extends StatelessWidget {
  final String imageUrl;

  const ImageWidget({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Image.network(
        imageUrl,
        height: 220,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }
}
