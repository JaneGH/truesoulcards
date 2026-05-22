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
  'compass': 'compass',
  'butterfly': 'butterfly',
  'music_note': 'music_note',
  'mountain': 'mountain',
  'waves': 'waves',
  'key': 'key',
  'crown': 'crown',
  'palette': 'palette',
  'anchor': 'anchor',
  'gift': 'gift',
};

final Map<String, Future<bool>> _assetExistsCache = {};
int _iconCacheGeneration = 0;

/// Clears cached SVG existence checks (call after remote category sync).
void clearCategoryIconAssetCache() {
  _assetExistsCache.clear();
  _iconCacheGeneration++;
}

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
  final cacheKey = img?.trim().isEmpty ?? true
      ? '_default_'
      : '${img!.trim()}:${resolveCategoryIconAsset(img)}';

  return FutureBuilder<bool>(
    key: ValueKey<String>('category-icon-$_iconCacheGeneration-$cacheKey'),
    future: _assetExistsCache.putIfAbsent(
      path,
      () => _assetExists(path),
    ),
    builder: (context, snapshot) {
      final iconPath = snapshot.data == true ? path : _fallbackIconPath;

      return SvgPicture.asset(
        iconPath,
        key: ValueKey<String>('$_iconCacheGeneration-$iconPath'),
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
