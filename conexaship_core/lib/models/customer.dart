class Customer {
  final int? id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? address;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? country;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<String>? roles;
  final List<String>? allowedApps;
  final String? status;
  final String? fullNameFromBackend;

  Customer({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.address,
    this.city,
    this.state,
    this.zipCode,
    this.country,
    this.createdAt,
    this.updatedAt,
    this.roles,
    this.allowedApps,
    this.status,
    this.fullNameFromBackend,
  });

  String get fullName => fullNameFromBackend ?? '$firstName $lastName';

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as int?,
      firstName: json['first_name'] ??
          json['firstName'] ??
          json['full_name']?.toString().split(' ').first ??
          '',
      lastName: json['last_name'] ??
          json['lastName'] ??
          json['full_name']?.toString().split(' ').skip(1).join(' ') ??
          '',
      email: json['email'] ?? json['username'] ?? '',
      phone: json['phone'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      zipCode: json['zip_code'] ?? json['zipCode'],
      country: json['country'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      roles: json['roles'] != null ? List<String>.from(json['roles']) : null,
      allowedApps: json['allowed_apps'] != null ? List<String>.from(json['allowed_apps']) : null,
      status: json['status'],
      fullNameFromBackend: json['full_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'state': state,
      'zip_code': zipCode,
      'country': country,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Customer copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? state,
    String? zipCode,
    String? country,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? roles,
    List<String>? allowedApps,
    String? status,
    String? fullNameFromBackend,
  }) {
    return Customer(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      country: country ?? this.country,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      roles: roles ?? this.roles,
      allowedApps: allowedApps ?? this.allowedApps,
      status: status ?? this.status,
      fullNameFromBackend: fullNameFromBackend ?? this.fullNameFromBackend,
    );
  }
}
