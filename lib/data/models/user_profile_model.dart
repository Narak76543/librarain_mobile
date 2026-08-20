import '../../core/network/api_config.dart';

class UserProfileModel {
  const UserProfileModel({
    required this.id,
    required this.userId,
    this.firstName,
    this.lastName,
    this.firstNameLocal,
    this.lastNameLocal,
    this.phone,
    this.telegram,
    this.email,
    this.address,
    this.avatarUrl,
  });

  final String id;
  final String userId;
  final String? firstName;
  final String? lastName;
  final String? firstNameLocal;
  final String? lastNameLocal;
  final String? phone;
  final String? telegram;
  final String? email;
  final String? address;
  final String? avatarUrl;

  String get displayName {
    final englishName = [firstName, lastName]
        .where((value) => value != null && value.trim().isNotEmpty)
        .map((value) => value!.trim())
        .join(' ');
    if (englishName.isNotEmpty) return englishName;

    final localName = [firstNameLocal, lastNameLocal]
        .where((value) => value != null && value.trim().isNotEmpty)
        .map((value) => value!.trim())
        .join(' ');
    if (localName.isNotEmpty) return localName;

    if (email != null && email!.trim().isNotEmpty) {
      final emailName = email!.trim().split('@').first;
      if (emailName.isNotEmpty) return emailName;
    }

    return 'Member';
  }

  String get initials {
    final parts = displayName
        .split(RegExp(r'\s+'))
        .where((part) => part.trim().isNotEmpty)
        .toList();
    if (parts.isEmpty || displayName == 'Member') return 'MF';
    final first = parts.first.substring(0, 1).toUpperCase();
    final second = parts.length > 1
        ? parts.last.substring(0, 1).toUpperCase()
        : '';
    return '$first$second';
  }

  String? get resolvedAvatarUrl {
    final value = avatarUrl?.trim();
    if (value == null || value.isEmpty) return null;
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    final base = ApiConfig.baseUrl.endsWith('/')
        ? ApiConfig.baseUrl.substring(0, ApiConfig.baseUrl.length - 1)
        : ApiConfig.baseUrl;
    final path = value.startsWith('/') ? value : '/$value';
    return '$base$path';
  }

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id']?.toString() ?? '',
      userId: (json['user_id'] ?? json['userId'])?.toString() ?? '',
      firstName: (json['first_name'] ?? json['firstName'])?.toString(),
      lastName: (json['last_name'] ?? json['lastName'])?.toString(),
      firstNameLocal: (json['first_name_local'] ?? json['firstNameLocal'])
          ?.toString(),
      lastNameLocal: (json['last_name_local'] ?? json['lastNameLocal'])
          ?.toString(),
      phone: json['phone']?.toString(),
      telegram: json['telegram']?.toString(),
      email: json['email']?.toString(),
      address: json['address']?.toString(),
      avatarUrl: (json['avatar_url'] ?? json['avatarUrl'] ?? json['avatar'])
          ?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'first_name': firstName,
      'last_name': lastName,
      'first_name_local': firstNameLocal,
      'last_name_local': lastNameLocal,
      'phone': phone,
      'telegram': telegram,
      'email': email,
      'address': address,
      'avatar_url': avatarUrl,
    };
  }

  UserProfileModel copyWith({
    String? id,
    String? userId,
    String? firstName,
    String? lastName,
    String? firstNameLocal,
    String? lastNameLocal,
    String? phone,
    String? telegram,
    String? email,
    String? address,
    String? avatarUrl,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      firstNameLocal: firstNameLocal ?? this.firstNameLocal,
      lastNameLocal: lastNameLocal ?? this.lastNameLocal,
      phone: phone ?? this.phone,
      telegram: telegram ?? this.telegram,
      email: email ?? this.email,
      address: address ?? this.address,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}

class UserProfileUpdateRequest {
  const UserProfileUpdateRequest({
    required this.firstName,
    required this.lastName,
    required this.firstNameLocal,
    required this.lastNameLocal,
    required this.phone,
    required this.telegram,
    required this.address,
  });

  final String firstName;
  final String lastName;
  final String firstNameLocal;
  final String lastNameLocal;
  final String phone;
  final String telegram;
  final String address;

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'first_name_local': firstNameLocal,
      'last_name_local': lastNameLocal,
      'phone': phone,
      'telegram': telegram,
      'address': address,
    };
  }
}
