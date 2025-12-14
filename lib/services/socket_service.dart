import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;

  IO.Socket? getSocket() => _socket;

  void initSocket() {
    if (_socket != null && _socket!.connected) return;

    _socket = IO.io('http://10.0.2.2:3000', IO.OptionBuilder()
        .setTransports(['websocket'])
        .enableAutoConnect()
        .build());

    _socket?.connect();

    _socket?.onConnect((_) {
      print('✅ Driver App connected to Socket Server');
    });

    _socket?.onDisconnect((_) => print('❌ Driver Disconnected'));
    
    _socket?.onConnectError((data) => print('⚠️ Connect Error: $data'));
  }

  void sendLocationUpdate(Map<String, dynamic> data) {
    if (_socket != null && _socket!.connected) {
      _socket?.emit('driver_send_location', data);
      
      print("🚀 Sent: ${data['lat']}, ${data['lng']}"); // Debug nếu cần
    } else {
      print("⚠️ Socket not connected, cannot send location");
    }
  }

  // 3. (Tuỳ chọn) Join room để nhận thông báo từ khách (VD: Khách huỷ đơn)
  void joinOrderRoom(String orderId) {
    if (_socket != null && _socket!.connected) {
      _socket?.emit('join_order', orderId);
    }
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }
}