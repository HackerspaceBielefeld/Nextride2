import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

import '../constants.dart' as constants;

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart' as http;

typedef APIClientResponse = Tuple2<http.Response, DateTime>;

const int apiDebugDelay = 1;

bool? acceptAPICertErrors;

bool _badCertificateCallback(X509Certificate cert, String host, int port) {
  debugPrint('cert error');
  debugPrint(cert.sha1.toString());

  Uri uri = Uri.parse(constants.endpoint);
  debugPrint(uri.host);

  return false;
}

http.Client get httpex {
  if (kIsWeb) {
    return http.Client();
  }

  var ioClient = HttpClient();
  ioClient.badCertificateCallback = _badCertificateCallback;
  ioClient.userAgent = 'Dart/${constants.buildInfo}';

  return http.IOClient(ioClient);
}

abstract class APIClient {
  static Future<APIClientResponse> get(String filename) async {
    String strUri = '${constants.endpoint}/$filename';
    debugPrint('APIClient fetching $strUri');

    final response = await httpex.get(Uri.parse(strUri));

    if (response.statusCode == 200) {
      return APIClientResponse(response, DateTime.now());
    } else {
      throw Exception('Failed to load $filename');
    }
  }

  static Future<APIClientResponse> post(
      String filename, Map<String, dynamic> data) async {
    String strUri = '${constants.endpoint}/$filename';
    debugPrint('APIClient fetching $strUri');

    final response = await httpex.post(Uri.parse(strUri), body: data);

    if (response.statusCode == 200) {
      return APIClientResponse(response, DateTime.now());
    } else {
      throw Exception('Failed to load $filename');
    }
  }
}
