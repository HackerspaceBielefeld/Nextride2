import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class NetworkProvider extends ChangeNotifier {
  NetworkImageCommand? nic;
  Timer? _timer;
  int _secondsRemaining = 0;
  int get secondsRemaining => _secondsRemaining;

  NetworkProvider() {
    RawDatagramSocket.bind('0.0.0.0', 31337).then((RawDatagramSocket udpSocket) {
      udpSocket.listen((e) {
        Datagram? dg = udpSocket.receive();

        if (dg != null) {
          if (_timer != null) {
            _timer!.cancel();
          }

          try {
            nic = NetworkImageCommand.fromUDPData(dg.data);
            _secondsRemaining = nic!.displaySeconds;
            _timer = Timer.periodic(const Duration(seconds: 1), (t) {
              _secondsRemaining--;
              if (_secondsRemaining <= 0) {
                _timer!.cancel();
                _timer = null;
                nic = null;
              }
              notifyListeners();
            });
            notifyListeners();
          } catch (e) {
            debugPrint('Error parsing UDP data: $e');
          }
        }
      });
    });
  }
}

class NetworkImageCommand {
  final String uri;
  final int displaySeconds;

  NetworkImageCommand({required this.uri, required this.displaySeconds});

  factory NetworkImageCommand.fromUDPData(Uint8List data) {
    if (data.length < 2) {
      throw Exception('Invalid data');
    }

    int displaySeconds = data[0];
    int uriength = data[1];

    if (data.length < 2 + uriength) {
      throw Exception('Invalid data');
    }

    String uri = String.fromCharCodes(data.sublist(2, 2 + uriength));
    return NetworkImageCommand(uri: uri, displaySeconds: displaySeconds);
  }
}
