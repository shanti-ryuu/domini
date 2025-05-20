import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:domini/models/note.dart';
import 'package:domini/models/folder.dart';
import 'package:domini/models/settings.dart';

class DatabaseService {
  static const String notesBoxName = 'notes';
  static const String foldersBoxName = 'folders';
  static const String settingsBoxName = 'settings';
  static const String encryptionKeyName = 'encryption_key';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  late Box<Note> notesBox;
  late Box<Folder> foldersBox;
  late Box<Settings> settingsBox;

  static final DatabaseService _instance = DatabaseService._internal();

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapters
    Hive.registerAdapter(NoteAdapter());
    Hive.registerAdapter(FolderAdapter());
    Hive.registerAdapter(SettingsAdapter());

    // Get encryption key
    final encryptionKey = await _getEncryptionKey();
    
    // Open boxes
    notesBox = await Hive.openBox<Note>(
      notesBoxName,
      encryptionCipher: HiveAesCipher(encryptionKey),
    );
    
    foldersBox = await Hive.openBox<Folder>(
      foldersBoxName,
      encryptionCipher: HiveAesCipher(encryptionKey),
    );
    
    settingsBox = await Hive.openBox<Settings>(
      settingsBoxName,
      encryptionCipher: HiveAesCipher(encryptionKey),
    );

    // Initialize settings if empty
    if (settingsBox.isEmpty) {
      await settingsBox.add(Settings());
    }
    
    // Create default folder if none exists
    if (foldersBox.isEmpty) {
      await foldersBox.add(Folder(name: 'All Notes'));
    }
  }

  Future<List<int>> _getEncryptionKey() async {
    // Try to get the existing key
    String? existingKey = await _secureStorage.read(key: encryptionKeyName);
    
    if (existingKey == null) {
      // Generate a new key if none exists
      final key = Hive.generateSecureKey();
      await _secureStorage.write(
        key: encryptionKeyName,
        value: base64Encode(key),
      );
      return key;
    } else {
      // Decode the existing key
      return base64Decode(existingKey);
    }
  }

  // PIN Authentication methods
  Future<bool> isPinSet() async {
    final settings = settingsBox.getAt(0);
    return settings != null && settings.encryptedPin.isNotEmpty;
  }

  Future<void> setPin(String pin) async {
    final settings = settingsBox.getAt(0);
    if (settings != null) {
      settings.encryptedPin = _hashPin(pin);
      await settings.save();
    }
  }

  bool verifyPin(String pin) {
    final settings = settingsBox.getAt(0);
    if (settings == null || settings.encryptedPin.isEmpty) {
      return false;
    }
    return settings.encryptedPin == _hashPin(pin);
  }

  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Note methods
  Future<List<Note>> getNotes({bool includeDeleted = false}) async {
    return notesBox.values
        .where((note) => includeDeleted ? true : !note.isDeleted)
        .toList();
  }

  Future<List<Note>> getNotesInFolder(String folderId, {bool includeDeleted = false}) async {
    return notesBox.values
        .where((note) => 
            note.folderIds.contains(folderId) && 
            (includeDeleted ? true : !note.isDeleted))
        .toList();
  }

  Future<Note?> getNoteById(String id) async {
    try {
      return notesBox.values.firstWhere((note) => note.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> addNote(Note note) async {
    await notesBox.add(note);
  }

  Future<void> updateNote(Note note) async {
    final index = notesBox.values.toList().indexWhere((n) => n.id == note.id);
    if (index != -1) {
      await notesBox.putAt(index, note);
    }
  }

  Future<void> softDeleteNote(String noteId) async {
    final note = await getNoteById(noteId);
    if (note != null) {
      note.isDeleted = true;
      note.deletedAt = DateTime.now();
      await updateNote(note);
    }
  }

  Future<void> restoreNote(String noteId) async {
    final note = await getNoteById(noteId);
    if (note != null) {
      note.isDeleted = false;
      note.deletedAt = null;
      await updateNote(note);
    }
  }

  Future<void> permanentlyDeleteNote(String noteId) async {
    final index = notesBox.values.toList().indexWhere((n) => n.id == noteId);
    if (index != -1) {
      await notesBox.deleteAt(index);
    }
  }

  // Folder methods
  Future<List<Folder>> getFolders() async {
    return foldersBox.values.toList();
  }

  Future<Folder?> getFolderById(String id) async {
    try {
      return foldersBox.values.firstWhere((folder) => folder.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> addFolder(Folder folder) async {
    await foldersBox.add(folder);
  }

  Future<void> updateFolder(Folder folder) async {
    final index = foldersBox.values.toList().indexWhere((f) => f.id == folder.id);
    if (index != -1) {
      await foldersBox.putAt(index, folder);
    }
  }

  Future<void> deleteFolder(String folderId) async {
    final index = foldersBox.values.toList().indexWhere((f) => f.id == folderId);
    if (index != -1) {
      await foldersBox.deleteAt(index);
      
      // Remove folder from all notes
      final notes = await getNotes(includeDeleted: true);
      for (final note in notes) {
        if (note.folderIds.contains(folderId)) {
          note.folderIds.remove(folderId);
          await updateNote(note);
        }
      }
    }
  }

  // Settings methods
  Future<Settings?> getSettings() async {
    return settingsBox.getAt(0);
  }

  Future<void> updateSettings(Settings settings) async {
    if (settingsBox.isNotEmpty) {
      await settingsBox.putAt(0, settings);
    } else {
      await settingsBox.add(settings);
    }
  }

  Future<void> toggleDarkMode() async {
    final settings = await getSettings();
    if (settings != null) {
      settings.darkMode = !settings.darkMode;
      await updateSettings(settings);
    }
  }

  Future<void> setUseSystemTheme(bool value) async {
    final settings = await getSettings();
    if (settings != null) {
      settings.useSystemTheme = value;
      await updateSettings(settings);
    }
  }

  Future<void> setBiometricEnabled(bool value) async {
    final settings = await getSettings();
    if (settings != null) {
      settings.biometricEnabled = value;
      await updateSettings(settings);
    }
  }

  Future<void> setPinLength(int length) async {
    final settings = await getSettings();
    if (settings != null) {
      settings.pinLength = length;
      await updateSettings(settings);
    }
  }
}
