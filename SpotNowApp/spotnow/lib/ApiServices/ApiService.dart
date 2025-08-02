import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:spotnow/ApiServices/AppConfig.dart';

class ApiService {
  late final IOClient _client;
  final String _baseUrl;

  ApiService() : _baseUrl = AppConfig.baseUrl {
    final ioc = HttpClient();
    ioc.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    _client = IOClient(ioc);
  }

  Future<http.Response> get(String endpoint) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    return await _client.get(uri, headers: {'content-type': 'application/json'});
  }

  // Add other HTTP methods like post, put, delete if needed
}
