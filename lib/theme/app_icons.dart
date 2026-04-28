import 'package:flutter/cupertino.dart';

/// Standard icon dimensions used across the app (Apple-like rhythm).
abstract final class AppIconSizes {
  static const double sm = 20;
  static const double md = 24;
  static const double lg = 28;
}

/// Unified SF Symbols–style icons ([CupertinoIcons]) used across the app.
abstract final class AppIcons {
  static const IconData checklist = CupertinoIcons.list_bullet;
  static const IconData edit = CupertinoIcons.pencil;
  static const IconData settings = CupertinoIcons.gear;
  static const IconData refresh = CupertinoIcons.arrow_clockwise;
  static const IconData upload = CupertinoIcons.cloud_upload;
  static const IconData share = CupertinoIcons.share;
  static const IconData info = CupertinoIcons.info;

  static const IconData add = CupertinoIcons.add;
  static const IconData play = CupertinoIcons.play_arrow_solid;
  static const IconData delete = CupertinoIcons.trash;

  static const IconData mic = CupertinoIcons.mic;
  static const IconData close = CupertinoIcons.xmark;
  static const IconData send = CupertinoIcons.paperplane;

  static const IconData copy = CupertinoIcons.doc_on_doc;
  static const IconData document = CupertinoIcons.doc_text;
  static const IconData chevronDown = CupertinoIcons.chevron_down;

  static const IconData hourglass = CupertinoIcons.hourglass;
  static const IconData success = CupertinoIcons.check_mark_circled;
  static const IconData error = CupertinoIcons.exclamationmark_circle;

  static const IconData emptyState = CupertinoIcons.tray;
}
