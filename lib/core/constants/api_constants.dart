import 'package:flutter/foundation.dart';

class ApiConstants {
  static String get baseUrl {
    if (kIsWeb) {
      return "http://localhost/mycare_api";
    } else {
      return "http://10.0.2.2/mycare_api"; 
    }
  }
}
