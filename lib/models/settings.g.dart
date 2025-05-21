// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SettingsAdapter extends TypeAdapter<Settings> {
  @override
  final int typeId = 2;

  @override
  Settings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Settings(
      encryptedPin: fields[0] as String,
      darkMode: fields[1] as bool,
      useSystemTheme: fields[2] as bool,
      biometricEnabled: fields[3] as bool,
      pinLength: fields[4] as int,
      securityQuestion: fields[5] as String,
      encryptedSecurityAnswer: fields[6] as String,
      failedPinAttempts: fields[7] as int,
      lastFailedAttempt: fields[8] as DateTime?,
      isPinLocked: fields[9] as bool,
      username: fields[10] as String,
      displayName: fields[11] as String,
      profileImagePath: fields[12] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Settings obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.encryptedPin)
      ..writeByte(1)
      ..write(obj.darkMode)
      ..writeByte(2)
      ..write(obj.useSystemTheme)
      ..writeByte(3)
      ..write(obj.biometricEnabled)
      ..writeByte(4)
      ..write(obj.pinLength)
      ..writeByte(5)
      ..write(obj.securityQuestion)
      ..writeByte(6)
      ..write(obj.encryptedSecurityAnswer)
      ..writeByte(7)
      ..write(obj.failedPinAttempts)
      ..writeByte(8)
      ..write(obj.lastFailedAttempt)
      ..writeByte(9)
      ..write(obj.isPinLocked)
      ..writeByte(10)
      ..write(obj.username)
      ..writeByte(11)
      ..write(obj.displayName)
      ..writeByte(12)
      ..write(obj.profileImagePath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
