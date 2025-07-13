class Message{
   final String sender;
   final String receiver;
   final String content;
   final DateTime timestamp;
   Message(
     this.sender,
     this.receiver,
     this.content,
     this.timestamp
   );
  factory Message.toJson(Map<String, dynamic> json) {
    return Message(
      json['sender'],
      json['receiver'],
      json['conversationId'],
      json['content'],
    );  
  }
  factory Message.fromJson(Map<String, dynamic> json) {
  return Message(
    json['sender'],
    json['receiver'],
    json['conversationId'],
    json['content'],
  
  );
  

   //write message to database
  //  write Tojson(),


  

  }
}