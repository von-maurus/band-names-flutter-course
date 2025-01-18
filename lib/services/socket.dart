import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:band_names/utils/enums/server_enums.dart';

class SocketService with ChangeNotifier {
  static const _baseUrl = 'http://192.168.1.95:3000/';
  ServerStates _serverStates = ServerStates.connecting;
  ServerStates get serverStates => _serverStates;

  final io.Socket _socket = io.io(_baseUrl, {
    'transports': ['websocket'],
    'autoConnect': true,
  });
  io.Socket get socket => _socket;

  SocketService() {
    _initConfig();
  }

  void _initConfig() {
    // Dart client
    _socket.on('connect', (_) {
      _serverStates = ServerStates.online;
      notifyListeners();
    });

    _socket.on('reply', (data) {
      print('Incoming reply from server: $data');
    });

    _socket.on('disconnect', (_) {
      _serverStates = ServerStates.offline;
      notifyListeners();
    });

    _socket.on('connect_error', (error) {
      _serverStates = ServerStates.offline;
      notifyListeners();
      print('Connection Error: $error');
    });

    _socket.on('connect_timeout', (_) {
      _serverStates = ServerStates.offline;
      notifyListeners();
      print('Connection Timeout');
    });
  }
}
