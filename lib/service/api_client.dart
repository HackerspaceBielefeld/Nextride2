import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:tuple/tuple.dart';

import '../constants.dart' as constants;

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart' as http;

typedef APIClientResponse = Tuple2<http.Response, DateTime>;

bool _badCertificateCallback(X509Certificate cert, String host, int port) {
  debugPrint('cert error for $host:$port (sha1 ${cert.sha1})');
  return false;
}

http.Client? _client;

/// Ein einziger, wiederverwendeter Client. Frueher wurde pro Request ein neuer
/// HttpClient erzeugt und nie geschlossen - auf einem Dauerlaeufer-Display
/// haeuften sich so die offenen Verbindungen/Sockets an.
http.Client get httpex {
  if (_client != null) {
    return _client!;
  }

  if (kIsWeb) {
    return _client = http.Client();
  }

  var ioClient = HttpClient();
  ioClient.badCertificateCallback = _badCertificateCallback;
  ioClient.userAgent = 'Dart/${constants.buildInfo}';

  return _client = http.IOClient(ioClient);
}

abstract class APIClient {
  static String _url(String filename) {
    final String base =
        constants.endpoint.endsWith('/') ? constants.endpoint.substring(0, constants.endpoint.length - 1) : constants.endpoint;
    return '$base/$filename';
  }

  static Future<APIClientResponse> get(String filename) async {
    String strUri = _url(filename);
    debugPrint('APIClient fetching $strUri');

    final response = await httpex.get(Uri.parse(strUri));

    if (response.statusCode == 200) {
      return APIClientResponse(response, DateTime.now());
    } else {
      throw Exception('Failed to load $filename (${response.statusCode})');
    }
  }

  static Future<APIClientResponse> post(String filename, Map<String, dynamic> data) async {
    String strUri = _url(filename);
    debugPrint('APIClient posting $strUri');

    final response = await httpex.post(Uri.parse(strUri), body: data);

    if (response.statusCode == 200) {
      return APIClientResponse(response, DateTime.now());
    } else {
      throw Exception('Failed to load $filename (${response.statusCode})');
    }
  }
}
