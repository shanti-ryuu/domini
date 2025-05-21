import 'package:hive/hive.dart';

part 'settings.g.dart';

@HiveType(typeId: 2)
class Settings extends HiveObject {
  @HiveField(0)
  String encryptedPin;

  @HiveField(1)
  bool darkMode;

  @HiveField(2)
  bool useSystemTheme;

  @HiveField(3)
  bool biometricEnabled;

  @HiveField(4)
  int pinLength;
  
  @HiveField(5)
  String securityQuestion;
  
  @HiveField(6)
  String encryptedSecurityAnswer;
  
  @HiveField(7)
  int failedPinAttempts;
  
  @HiveField(8)
  DateTime? lastFailedAttempt;
  
  @HiveField(9)
  bool isPinLocked;
  
  @HiveField(10)
  String username;
  
  @HiveField(11)
  String displayName;
  
  @HiveField(12)
  String? profileImagePath;

  Settings({
    this.encryptedPin = '',
    this.darkMode = false,
    this.useSystemTheme = true,
    this.biometricEnabled = false,
    this.pinLength = 6,
    this.securityQuestion = '',
    this.encryptedSecurityAnswer = '',
    this.failedPinAttempts = 0,
    this.lastFailedAttempt,
    this.isPinLocked = false,
    this.username = '',
    this.displayName = '',
    this.profileImagePath,
  });

  Settings copyWith({
    String? encryptedPin,
    bool? darkMode,
    bool? useSystemTheme,
    bool? biometricEnabled,
    int? pinLength,
    String? securityQuestion,
    String? encryptedSecurityAnswer,
    int? failedPinAttempts,
    DateTime? lastFailedAttempt,
    bool? isPinLocked,
    String? username,
    String? displayName,
    String? profileImagePath,
  }) {
    return Settings(
      encryptedPin: encryptedPin ?? this.encryptedPin,
      darkMode: darkMode ?? this.darkMode,
      useSystemTheme: useSystemTheme ?? this.useSystemTheme,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      pinLength: pinLength ?? this.pinLength,
      securityQuestion: securityQuestion ?? this.securityQuestion,
      encryptedSecurityAnswer: encryptedSecurityAnswer ?? this.encryptedSecurityAnswer,
      failedPinAttempts: failedPinAttempts ?? this.failedPinAttempts,
      lastFailedAttempt: lastFailedAttempt ?? this.lastFailedAttempt,
      isPinLocked: isPinLocked ?? this.isPinLocked,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }
}
