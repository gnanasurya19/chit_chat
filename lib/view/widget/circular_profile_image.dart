import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CircularProfileImage extends StatelessWidget {
  final String? image;
  final bool isNetworkImage;
  const CircularProfileImage({
    super.key,
    required this.image,
    required this.isNetworkImage,
  });

  @override
  Widget build(BuildContext context) {
    return isNetworkImage
        ? CachedNetworkImage(imageUrl: image!, fit: BoxFit.cover)
        : Image.asset(
            'assets/images/profile.png',
            fit: BoxFit.cover,
          );
  }
}
