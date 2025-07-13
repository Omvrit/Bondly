class User {
  final String id;
  final String username;
  final String avatar;
  final String email;
  final bool isOnline;
  

  User({
    required this.id,
    required this.username,
    required this.avatar,
    required this.email,
    required this.isOnline,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
  return User(
    id: json['_id'] ?? json['id'],
    username: json['username'] ?? '',
    email: json['email'] ?? '',
    avatar: json['avatar'] ?? '',
    isOnline: json['online'] ?? json['isOnline'] ?? false, // fallback default
  );
  
}

}