import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'persistent_cache_manager.dart';

Widget cachedNetworkImageWrapper({
  required String imageUrl,
  double? height,
  double? width,
  BoxFit? fit,
  required Widget Function(BuildContext, ImageProvider<Object>) imageBuilder,
  required Widget Function(BuildContext, String) placeholderBuilder,
  required Widget Function(BuildContext, String, Object) errorWidgetBuilder,
}) {
  return CachedNetworkImage(
    imageUrl: imageUrl,
    imageBuilder: imageBuilder,
    placeholder: placeholderBuilder,
    errorWidget: errorWidgetBuilder,
    errorListener: (e) {
      print('');
    },
    fit: fit ?? BoxFit.fill,
    height: height,
    width: width,
    // Use persistent cache manager that caches across app restarts
    cacheManager: PersistentImageCacheManager(),
    cacheKey: imageUrl, // Assign a cache key to avoid re-downloading
  );
}

class LargeCardImageHolder extends StatelessWidget {
  const LargeCardImageHolder({
    super.key,
    required this.image,
  });

  final Image image;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(15),
        topRight: Radius.circular(15),
      ),
      child: image,
    );
  }
}

class SmallCardImageHolder extends StatelessWidget {
  const SmallCardImageHolder({
    super.key,
    required this.image,
  });

  final Image image;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(
        Radius.circular(15),
      ),
      child: image,
    );
  }
}

class CircularImageHolder extends StatelessWidget {
  const CircularImageHolder({
    super.key,
    required this.image,
  });

  final Image image;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(shape: BoxShape.circle),
        child:
            ClipRRect(borderRadius: BorderRadius.circular(100), child: image));
  }
}
