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
  static Uri _uri(String filename, Map<String, String>? queryParameters) {
    final String base = constants.efaEndpoint.endsWith('/')
        ? constants.efaEndpoint.substring(0, constants.efaEndpoint.length - 1)
        : constants.efaEndpoint;
    // queryParameters statt String-Verkettung: Haltestellen-IDs wie
    // 'de:05711:5614' muessen korrekt kodiert werden.
    return Uri.parse('$base/$filename').replace(queryParameters: queryParameters);
  }

  static Future<APIClientResponse> get(String filename, [Map<String, String>? queryParameters]) async {
    final Uri uri = _uri(filename, queryParameters);
    debugPrint('APIClient fetching $uri');

    final response = await httpex.get(uri);

    if (response.statusCode == 200) {
      return APIClientResponse(response, DateTime.now());
    } else {
      throw Exception('Failed to load $filename (${response.statusCode})');
    }
  }
}
