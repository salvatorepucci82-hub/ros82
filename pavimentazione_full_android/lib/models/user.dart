class AppUser {
  int? id;
  String username;
  String password; // prototype: stored plaintext. Replace with hashing for production.
  String role; // 'operaio' or 'supervisore'

  AppUser({this.id, required this.username, required this.password, required this.role});

  Map<String, dynamic> toMap() => {
    'id': id,
    'username': username,
    'password': password,
    'role': role,
  };

  factory AppUser.fromMap(Map<String, dynamic> map) => AppUser(
    id: map['id'] as int?,
    username: map['username'] as String,
    password: map['password'] as String,
    role: map['role'] as String,
  );
}
