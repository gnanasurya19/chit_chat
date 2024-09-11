// import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CircularProfileImage extends StatelessWidget {
  final String? image;
  final bool isNetworkImage;
  const CircularProfileImage({
    super.key,
    this.image,
    required this.isNetworkImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: Builder(
        builder: (context) {
          return isNetworkImage
              ? CachedNetworkImage(
                  imageUrl: image ?? '',
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Image.asset(
                    'assets/images/profile.png',
                    fit: BoxFit.cover,
                  ),
                  errorWidget: (context, url, error) => Image.asset(
                    'assets/images/profile.png',
                    fit: BoxFit.cover,
                  ),
                )
              : Image.asset(
                  'assets/images/profile.png',
                  fit: BoxFit.cover,
                );
        },
      ),
    );
  }
}
