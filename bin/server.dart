import 'dart:convert';
import 'dart:io';

import 'package:color/color.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:riverpod/riverpod.dart';

import 'models/cell.dart';
import 'providers/board_provider.dart';

Response _restHandler(Request req) {
  return Response.ok('Hello, World!\n');
}

// Response _echoHandler(Request request) {
//   final message = request.params['message'];
//   return Response.ok('$message\n');
// }

void publish(Set<WebSocketChannel> webSockets, message) {
  print("PUBLISH: '$message'");
  for (var ws in webSockets) {
    ws.sink.add(message);
  }
}

void publishUserCount(Set<WebSocketChannel> webSockets) {
  publish(webSockets, "USERCOUNT#${webSockets.length}");
}

void main(List<String> args) async {
  final container = ProviderContainer();
  var board = container.read(boardRepositoryRiverpodProvider);
  var boardNotifier = container.read(boardRepositoryRiverpodProvider.notifier);
  // Use any available host or container IP (usually `0.0.0.0`).
  final ip = InternetAddress.anyIPv4;

  final webSockets = <WebSocketChannel>{};

  final wsHandler = webSocketHandler((WebSocketChannel newWS) {
    print("${newWS.hashCode.toString()} joined at ${DateTime.now()}");
    webSockets.add(newWS);
    publishUserCount(webSockets);
    newWS.sink.add("Connected as ${newWS.hashCode.toString()}");
    newWS.stream.listen((message) {
      print("Incoming: $message");
      //webSocket.sink.add("echo $message");
      var tokens = message.toString().split('#');
      if (tokens.isNotEmpty) {
        var command = tokens[0];
        print(tokens);
        switch (command) {
          case 'SETCELL':
            print(command);
            var col = int.parse(tokens[1]);
            var row = int.parse(tokens[2]);
            var cell = Cell.fromJson(jsonDecode(tokens[3]));
            boardNotifier.setCell(col, row, cell);
            var broadcastMessage =
                'UPDATECELL#$col#$row#${jsonEncode(cell.toJson())}';
            // var t = broadcastMessage.replaceFirst('UPDATECELL#', '');
            // var c = Cell.fromJson(jsonDecode(t));
            for (var ws in webSockets) {
              ws.sink.add(broadcastMessage);
            }
            break;
          default:
            print('Command $command not yet implemented');
        }
      } else {
        for (var ws in webSockets) {
          ws.sink.add("${newWS.hashCode.toString()} says '$message'");
        }
      }
    }, onDone: () {
      print("${newWS.hashCode.toString()} disconnected at ${DateTime.now()}");
      webSockets.remove(newWS);
      publishUserCount(webSockets);
    });
  });

  // Configure routes.
  final router = Router()
    ..get('/rest', _restHandler)
    ..get('/ws', wsHandler);

  // Configure a pipeline that logs requests.
  final handler = Pipeline().addMiddleware(logRequests()).addHandler(router);

  // For running in containers, we respect the PORT environment variable.
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await shelf_io.serve(handler, ip, port);
  print('Server listening on port ${server.port}');
}
