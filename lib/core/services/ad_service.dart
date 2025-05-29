import 'package:flutter_dotenv/flutter_dotenv.dart';

class AdService {
  static String get bannerAdUnitId =>
      dotenv.env['ADMOB_BANNER_ID_ANDROID'] ?? '';
}