import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    const override = String.fromEnvironment('API_BASE_URL');
    final url = override.isNotEmpty
        ? override
        : (!kIsWeb && defaultTargetPlatform == TargetPlatform.android
              ? 'http://10.0.2.2:3000'
              : 'http://localhost:3000');
    return url.replaceFirst(RegExp(r'/+$'), '');
  }
}
