import 'dart:async';
import 'dart:developer';
import 'package:socket_io_client/socket_io_client.dart';
import '../../../util/helper/crash_report.dart';
import 'base_api_response.dart';
import 'socket_path.dart';

class BaseSocket {
  static late Socket _authSocket;
  static late Socket _profileSocket;
  static late Socket _countrySocket;
  static late Socket _termOfServiceSocket;
  static late Socket _feedbackSocket;
  static late Socket _contactkSocket;
  static late Socket _addFriendSocket;
  static late Socket _reportSocket;
  static late Socket _roomSocket;
  static late Socket _messageSocket;
  static late Socket _listMessage;
  static late Socket _groupSocket;
  static late Socket _deviceSocket;

  static late String baseSocketUrl;
  static late String token;

  static Future<Socket> initConnection(String nameSpace) async {
    return _switchNameSpace(nameSpace);
  }

  static Future<Socket> initConnectWithHeader(String nameSpace) async {
    return _switchNameSpace(nameSpace);
  }

  static Future<void> initSocketConnection(String accessToken, String baseUrl) async {
    baseSocketUrl = baseUrl;
    token = accessToken;
    _roomSocket = await _connectWithAuth(SocketPath.room);
    _messageSocket = await _connectWithAuth(SocketPath.message);
  }

  static void destroyAllAuthSocketConnection() {
    _roomSocket.destroy();
    _messageSocket.destroy();
  }

  static Socket _switchNameSpace(String nameSpace) {
    switch (nameSpace) {
      case SocketPath.auth:
        return _authSocket;
      case SocketPath.country:
        return _countrySocket;
      case SocketPath.termOfService:
        return _termOfServiceSocket;
      // authenticate
      case SocketPath.profile:
        return _profileSocket;
      case SocketPath.addFriend:
        return _addFriendSocket;
      case SocketPath.contact:
        return _contactkSocket;
      case SocketPath.message:
        return _messageSocket;
      case SocketPath.group:
        return _groupSocket;
      case SocketPath.feedback:
        return _feedbackSocket;
      case SocketPath.room:
        return _roomSocket;
      case SocketPath.device:
        return _deviceSocket;
      case SocketPath.report:
        return _reportSocket;
      case SocketPath.listMessage:
        return _listMessage;

      default:
        return _authSocket;
    }
  }

  static Future<Socket> _connectWithAuth(String nameSpace) async {
    final completor = Completer<Socket>();
    late Socket socket;
    socket = io(
      '$baseSocketUrl$nameSpace',
      OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .enableForceNew()
          .setReconnectionAttempts(10000)
          .enableReconnection()
          .setExtraHeaders({'token': token})
          .build(),
    );

    socket.on('error', (error) async {
      print('socket error:$error');
      if (error['message'] == 'token expired') {
      } else if (error['message'] == 'unauthorized') {
        // BaseSocket.destroyAllAuthSocketConnection();
      }
    });

    try {
      socket.connect();
      print(socket.nsp);
      completor.complete(socket);
    } catch (e) {
      completor.completeError(socket);
      rethrow;
    }
    socket.onConnect((_) {
      log('authConnect nameSpace:$nameSpace', name: 'Basesocket');
    });
    socket.onDisconnect((e) {
      log('autDisconnec:$nameSpace', name: 'Basesocket');
      print(e);
    });
    return completor.future;
  }

  //TODO: refactor to use the pattern
  static Future<T> request<T>(
    String event,
    Map<String, dynamic> data,
    T Function(Map<String, dynamic>) parser, {
    String? path,
    Socket? socket,
  }) async {
    final completer = Completer();
    late Socket socket0;
    try {
      socket0 = socket ?? await BaseSocket.initConnectWithHeader(path!);
      socket0.emitWithAck(
        event,
        data,
        ack: (result) async {
          var res = BaseApiResponse.generateResponse(
            response: result,
            parseData: (_) => parser(result),
          );
          if (res.success) {
            completer.complete(res.result);
          } else {
            completer.completeError(res.error ?? res.message ?? res.otherInfo ?? 'Unknown Error');
          }
        },
      );
    } catch (e) {
      final message = e.toString();
      await CrashReport.send(ReportModel(message: message));
      completer.completeError(e);
    } finally {
      if (socket == null) {
        socket0.destroy();
      }
    }
    return await completer.future;
  }
}
