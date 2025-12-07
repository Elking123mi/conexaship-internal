class User {
  final int id;
  final String username;
  final String email;
  final List<String> roles;
  final List<String> allowedApps;
  final Map<String, dynamic>? metadata;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.roles,
    required this.allowedApps,
    this.metadata,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      roles: List<String>.from(json['roles'] ?? []),
      allowedApps: List<String>.from(json['allowed_apps'] ?? []),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'roles': roles,
      'allowed_apps': allowedApps,
      if (metadata != null) 'metadata': metadata,
    };
  }

  bool hasRole(String role) => roles.contains(role);

  bool canAccessApp(String app) => allowedApps.contains(app);

  bool hasAnyRole(List<String> roleList) => roleList.any((role) => roles.contains(role));
}
