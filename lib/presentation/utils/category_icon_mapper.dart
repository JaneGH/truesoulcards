import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

const _fallbackIconPath = 'assets/icon/categories/sparkle.svg';

/// Maps custom category icon names to bundled SVG asset stems.
const Map<String, String> kCategoryIconAssetNames = {
  'sun': 'sun',
  'moon': 'cloud',
  'heart': 'heart',
  'star': 'star',
  'cloud': 'cloud',
  'book': 'squares_four',
  'chat': 'chat',
  'spark': 'sparkle',
  'tree': 'leaf',
  'dream': 'sparkle',
  'childhood': 'face_smile',
  'relationship': 'handshake',
  'lightning': 'lightning',
  'flower': 'flower',
};

final Map<String, Future<bool>> _assetExistsCache = {};

String resolveCategoryIconAsset(String? iconName) {
  final raw = iconName?.trim();
  if (raw == null || raw.isEmpty) {
    return 'sparkle';
  }
  final stem = raw.endsWith('.svg') ? raw.substring(0, raw.length - 4) : raw;
  return kCategoryIconAssetNames[stem] ?? stem;
}

Widget categoryIcon(
    String? img, {
      double size = 28,
      Color? color,
    }) {
  var file = resolveCategoryIconAsset(img);

  if (!file.endsWith('.svg')) {
    file = '$file.svg';
  }

  final path = 'assets/icon/categories/$file';
  final cacheKey = img?.trim().isEmpty ?? true ? '_default_' : img!.trim();

  return FutureBuilder<bool>(
    key: ValueKey<String>('category-icon-$cacheKey'),
    future: _assetExistsCache.putIfAbsent(
      path,
      () => _assetExists(path),
    ),
    builder: (context, snapshot) {
      final iconPath = snapshot.data == true ? path : _fallbackIconPath;

      return SvgPicture.asset(
        iconPath,
        key: ValueKey<String>(iconPath),
        width: size,
        height: size,
        colorFilter: color == null
            ? null
            : ColorFilter.mode(color, BlendMode.srcIn),
      );
    },
  );
}

Future<bool> _assetExists(String path) async {
  try {
    await rootBundle.load(path);
    return true;
  } catch (_) {
    return false;
  }
}