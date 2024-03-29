import 'dart:io';
//import 'package:universal_io/io.dart';

class ApiConfig {
  static final String apiBaseUrl = _getBaseUrl();

  static String _getBaseUrl() {
    if (const bool.fromEnvironment('dart.vm.product')) {
      return 'https://noteabackend-production-cd1d.up.railway.app';
    } else {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:3000';
        //return 'http://192.168.1.2:3000'; //para usar la compu como server
      } else {
        return 'http://localhost:3000'; // fallback para otros sistemas operativos
      }
    }
  }
}
