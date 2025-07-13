import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/user.dart';
import '../models/message.dart';
class ChatService {
  static final ChatService _instance = ChatService._internal();

  factory ChatService() => _instance;

  ChatService._internal();

  late IO.Socket _socket;
  bool _isConnected = false;

  // Listen for messages
  void Function(Map<String, dynamic>)? onMessageReceived;

  // Initialize and connect the socket
  void initSocket(String userId) {
    if (_isConnected) return;

    print('🔌 Connecting to socket...');
    _socket = IO.io(
      'http://192.168.200.102:5000', // Replace with your IP
      <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
      },
    );

    _socket.connect();

    _socket.onConnect((_) {
      _isConnected = true;
      print('✅ Connected to socket server');
      _socket.emit('register', userId); // Register user with socket
    });

    _socket.onDisconnect((_) {
      _isConnected = false;
      print('❌ Disconnected from socket');
    });

    _socket.on('receive_private_message', (data) {
      print('📩 Message received: $data');
      if (onMessageReceived != null) {
        onMessageReceived!(Map<String, dynamic>.from(data));
      }
    });
  }

  // Send private message
  void sendMessage({
    required String senderId,
    required String recipientId,
    required String message,
  }) {
    if (!_isConnected) {
      print('⚠️ Not connected to socket');
      return;
    }

    final data = {
      'senderId': senderId,
      'recipientId': recipientId,
      'message': message,
    };

    _socket.emit('send_private_message', data);
    print('📤 Sent message: $data');
  }

  // Disconnect the socket
  void disconnect() {
    if (_isConnected) {
      _socket.disconnect();
      _isConnected = false;
    }
  }
  Future<String> saveMessageToDb(Message msg) async{
    return Future.delayed(const Duration(seconds: 1));"";
  }
}
