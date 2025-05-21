import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 4)
class UserProfile extends HiveObject {
  @HiveField(0)
  String username;

  @HiveField(1)
  String displayName;

  @HiveField(2)
  String? profileImagePath;

  @HiveField(3)
  String? email;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  DateTime lastLoginAt;

  @HiveField(6)
  Map<String, dynamic> preferences;

  UserProfile({
    required this.username,
    String displayName = '',
    this.profileImagePath,
    this.email,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    Map<String, dynamic>? preferences,
  }) : 
    createdAt = createdAt ?? DateTime.now(),
    lastLoginAt = lastLoginAt ?? DateTime.now(),
    preferences = preferences ?? {},
    displayName = displayName.isEmpty ? username : displayName;

  UserProfile copyWith({
    String? username,
    String? displayName,
    String? profileImagePath,
    String? email,
    DateTime? lastLoginAt,
    Map<String, dynamic>? preferences,
  }) {
    return UserProfile(
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      email: email ?? this.email,
      createdAt: this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      preferences: preferences ?? Map.from(this.preferences),
    );
  }
}
