import 'package:band_names/services/socket.dart';
import 'package:band_names/utils/enums/server_enums.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SocketStatusWidget extends StatelessWidget {
  const SocketStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);

    return Container(
      margin: const EdgeInsets.only(right: 15),
      child: socketService.serverStates == ServerStates.online
          ? const Icon(Icons.bolt, color: Colors.green, size: 30)
          : const Icon(Icons.offline_bolt, color: Colors.red, size: 30),
    );
  }
}
