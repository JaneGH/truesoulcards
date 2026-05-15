import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

const _fallbackIconPath = 'assets/icon/categories/sparkle.svg';

final Map<String, Future<bool>> _assetExistsCache = {};

Widget categoryIcon(
    String? img, {
      double size = 28,
      Color? color,
    }) {
  var file = img?.trim();

  if (file == null || file.isEmpty) {
    file = 'sparkle.svg';
  }

  if (!file.endsWith('.svg')) {
    file = '$file.svg';
  }

  final path = 'assets/icon/categories/$file';

  return FutureBuilder<bool>(
    future: _assetExistsCache.putIfAbsent(
      path,
          () => _assetExists(path),
    ),
    builder: (context, snapshot) {
      final iconPath = snapshot.data == true ? path : _fallbackIconPath;

      return SvgPicture.asset(
        iconPath,
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