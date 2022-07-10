import 'package:flutter/cupertino.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

enum ServerStatus {
  online,
  offline,
  connecting,
}

class SocketService with ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.connecting;

  late io.Socket _client;

  ServerStatus get serverStatus => _serverStatus;

  io.Socket get client => _client;

  SocketService() {
    _initConfig();
  }

  void _initConfig() {
    // Dart client
    _client = io.io('http://localhost:3001', {
      'transports': ['websocket'],
      'autoConnect': true,
    });

    // Client hears server connection status from server
    _client.on('connect', (_) {
      _serverStatus = ServerStatus.online;
      notifyListeners();
    });
    _client.on('disconnect', (_) {
      _serverStatus = ServerStatus.offline;
      notifyListeners();
    });

    _client.on('message', (data) {
      print(data);
    });
  }
}
