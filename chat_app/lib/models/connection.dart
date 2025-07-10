class Connection {
  final String id;
  final String name;
  final String avatar;
  final String email;
  final bool isOnline;

  Connection({
    required this.id,
    required this.name,
    required this.avatar,
    required this.email,
    required this.isOnline,
  });

  factory Connection.fromJson(Map<String, dynamic> json) {
    return Connection(
      id: json['id'],
      name: json['name'],
      avatar: json['avatar'],
      email: json['email'],
      isOnline: json['isOnline'],
    );
  }
}