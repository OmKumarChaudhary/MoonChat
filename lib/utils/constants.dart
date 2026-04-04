import 'package:flutter/foundation.dart';

class AppConstants {
  // Toggle this to switch between Production and Local testing
  static const bool isProduction = true;

  // Live  URL
  static const String liveBaseUrl = 'https://toolsd-moonchat.hf.space/';

  // Local Development URLs
  static const String localBaseUrl = 'http://127.0.0.1:7860';
  static const String androidEmulatorBaseUrl = 'http://10.0.2.2:5000';

  /// Returns the base URL based on the environment and platform.
  static String get baseUrl {
    if (isProduction) {
      return liveBaseUrl;
    }

    // For local testing:
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return androidEmulatorBaseUrl;
    }
    return localBaseUrl;
  }
}
