import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

class NetworkProvider extends ChangeNotifier {
  NetworkImageCommand? nic;
  Timer? _timer;
  RawDatagramSocket? _udpSocket;
  bool _disposed = false;

  int _secondsRemaining = 0;
  int get secondsRemaining => _secondsRemaining;

  NetworkProvider() {
    RawDatagramSocket.bind('0.0.0.0', 31337).then((RawDatagramSocket udpSocket) {
      if (_disposed) {
        udpSocket.close();
        return;
      }

      _udpSocket = udpSocket;
      udpSocket.listen((e) {
        Datagram? dg = udpSocket.receive();
        if (dg == null) {
          return;
        }

        try {
          final command = NetworkImageCommand.fromUDPData(dg.data);

          _timer?.cancel();
          nic = command;
          _secondsRemaining = command.displaySeconds;

          _timer = Timer.periodic(const Duration(seconds: 1), (t) {
            _secondsRemaining--;
            if (_secondsRemaining <= 0) {
              t.cancel();
              _timer = null;
              nic = null;
            }
            notifyListeners();
          });
          notifyListeners();
        } catch (e) {
          debugPrint('Error parsing UDP data: $e');
        }
      });
    }).catchError((Object e) {
      debugPrint('Network UDP bind on 31337 failed: $e');
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _timer = null;
    _udpSocket?.close();
    _udpSocket = null;
    super.dispose();
  }
}

class NetworkImageCommand {
  final String uri;
  final int displaySeconds;

  NetworkImageCommand({required this.uri, required this.displaySeconds});

  factory NetworkImageCommand.fromUDPData(Uint8List data) {
    if (data.length < 2) {
      throw const FormatException('Invalid data');
    }

    int displaySeconds = data[0];
    int uriLength = data[1];

    if (data.length < 2 + uriLength) {
      throw const FormatException('Invalid data');
    }

    if (displaySeconds <= 0) {
      throw const FormatException('displaySeconds must be > 0');
    }

    String uri = String.fromCharCodes(data.sublist(2, 2 + uriLength));

    // Ohne diese Pruefung wuerde jedes beliebige Paket aus dem Netz zu einem
    // NetworkImage-Request werden; ein ungueltiger String liesse Image.network
    // im build() werfen.
    final Uri? parsed = Uri.tryParse(uri);
    if (parsed == null || !parsed.hasScheme || !(parsed.isScheme('http') || parsed.isScheme('https'))) {
      throw FormatException('Invalid image URI "$uri"');
    }

    return NetworkImageCommand(uri: uri, displaySeconds: displaySeconds);
  }
}
