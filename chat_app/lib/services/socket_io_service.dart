import 'package:socket_io_client/socket_io_client.dart' as IO;

late IO.Socket socket;

void connectToSocket(String userId) {
  print("connecting to socket");
  socket = IO.io('http://192.168.200.102:5000', <String, dynamic>{
    'transports': ['websocket'],
    'autoConnect': false,
  });

  socket.connect();

  socket.onConnect((_) {
    print('Connected to socket server');
    
    // Register this user
    socket.emit('register', userId);

    // Listen for private messages
    socket.on('receive_private_message', (data) {
      print('Private message from ${data['senderId']}: ${data['message']}');
    });
  });

  socket.onDisconnect((_) => print('Disconnected from socket'));
}

// Call this to send a private message
void sendPrivateMessage(String senderId, String recipientId, String message) {
  socket.emit('send_private_message', {
    'senderId': senderId,
    'recipientId': recipientId,
    'message': message,
  });
}
