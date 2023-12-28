import 'package:flutter/material.dart';

/// * @Author: chuxiong
/// * @Created at: 28/12/2023 09:32
/// * @Email: 
/// * @Company: 嘉联支付
/// * description
import 'dart:io';
import 'dart:typed_data';

import 'models.dart';

class Client {
  Client({
    required this.onError,
    required this.onData,
    required this.hostname,
    required this.port,
  });

  String hostname;
  int port;
  Uint8ListCallback onData;
  DynamicCallback onError;
  bool connected = false;

  Socket? socket;

  connect() async {
    try {
      socket = await Socket.connect(hostname, port);
      socket?.listen(
        onData,
        onError: onError,
        onDone: disconnect,
        cancelOnError: false,
      );
      connected = true;
    } on Exception catch (exception) {
      onData(Uint8List.fromList("Error : $exception".codeUnits));
    }
  }

  write(String message) {
    //Connect standard in to the socket
    socket?.write(message + '\n');
  }

  disconnect() {
    if (socket != null) {
      socket?.destroy();
      connected = false;
    }
  }
}