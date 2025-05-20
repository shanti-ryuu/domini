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

  Settings({
    this.encryptedPin = '',
    this.darkMode = false,
    this.useSystemTheme = true,
    this.biometricEnabled = false,
    this.pinLength = 6,
  });

  Settings copyWith({
    String? encryptedPin,
    bool? darkMode,
    bool? useSystemTheme,
    bool? biometricEnabled,
    int? pinLength,
  }) {
    return Settings(
      encryptedPin: encryptedPin ?? this.encryptedPin,
      darkMode: darkMode ?? this.darkMode,
      useSystemTheme: useSystemTheme ?? this.useSystemTheme,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      pinLength: pinLength ?? this.pinLength,
    );
  }
}
