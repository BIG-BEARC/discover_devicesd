import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'models.dart';


/// * @Author: chuxiong
/// * @Created at: 28/12/2023 09:18
/// * @Email: 
/// * @Company: 嘉联支付
/// * description
abstract class ServerSockets implements Stream<Socket> {
  static Future<ServerSocket> bind(address, int port,
      {int backlog = 0, bool v6Only = false, bool shared = false}) {
    final IOOverrides? overrides = IOOverrides.current;
    if (overrides == null) {
      return ServerSocket.bind(address, port,
          backlog: backlog, v6Only: v6Only, shared: shared);
    }
    return overrides.serverSocketBind(address, port,
        backlog: backlog, v6Only: v6Only, shared: shared);
  }

  external static Future<ServerSocket> _bind(address, int port,
      {int backlog = 0, bool v6Only = false, bool shared = false});

  int get port;

  InternetAddress get address;

  Future<ServerSocket> close();
}





class Server {

  Server({required this.onError, required this.onData});

  Uint8ListCallback onData;
  DynamicCallback onError;
  ServerSocket? server;
  bool running = false;
  List<Socket> sockets = [];

  start() async {
    runZoned(() async {
      server = await ServerSocket.bind('192.168.26.140', 4040);
      running = true;
      server?.listen(onRequest);
      onData(Uint8List.fromList('Server listening on port 4040'.codeUnits));
    }, onError: (e) {
      onError(e);
    });
  }

  stop() async {
    await server?.close();
    server = null;
    running = false;
  }

  broadCast(String message) {
    onData(Uint8List.fromList('Broadcasting : $message'.codeUnits));
    for (Socket socket in sockets) {
      socket.write( '$message\n' );
    }
  }


  onRequest(Socket socket) {
    if (!sockets.contains(socket)) {
      sockets.add(socket);
    }
    socket.listen((Uint8List data) {
      onData(data);
    });
  }
}