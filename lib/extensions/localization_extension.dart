import 'package:flutter/material.dart';
import 'package:truesoulcards/l10n/app_localizations.dart';

extension SubcategoryLocalization on String {
  String trSub(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    switch (this) {
      case 'adults':
        return loc.adults;
      case 'kids':
        return loc.kids;
      default:
        return this;
    }
  }
}