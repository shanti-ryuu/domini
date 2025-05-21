import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:domini/models/note.dart';
import 'package:domini/models/folder.dart';
import 'package:domini/models/settings.dart';
import 'package:domini/models/user_profile.dart';

class DatabaseService {
  static const String notesBoxName = 'notes';
  static const String foldersBoxName = 'folders';
  static const String settingsBoxName = 'settings';
  static const String userProfilesBoxName = 'user_profiles';
  static const String encryptionKeyName = 'encryption_key';
  static const String currentUserKey = 'current_user';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  late Box<Note> notesBox;
  late Box<Folder> foldersBox;
  late Box<Settings> settingsBox;
  late Box<UserProfile> userProfilesBox;

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
    Hive.registerAdapter(UserProfileAdapter());

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
    
    userProfilesBox = await Hive.openBox<UserProfile>(
      userProfilesBoxName,
      encryptionCipher: HiveAesCipher(encryptionKey),
    );
    
    // Initialize settings if empty
    if (settingsBox.isEmpty) {
      await settingsBox.put('settings', Settings());
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
  
  // Security Question methods
  Future<void> setSecurityQuestion(String question, String answer) async {
    final settings = await getSettings();
    if (settings != null) {
      settings.securityQuestion = question;
      settings.encryptedSecurityAnswer = _hashSecurityAnswer(answer);
      await settings.save();
    }
  }
  
  Future<bool> verifySecurityAnswer(String answer) async {
    final settings = settingsBox.getAt(0);
    if (settings == null || settings.encryptedSecurityAnswer.isEmpty) {
      return false;
    }
    return settings.encryptedSecurityAnswer == _hashSecurityAnswer(answer);
  }
  
  Future<String?> getSecurityQuestion() async {
    final settings = await getSettings();
    return settings?.securityQuestion;
  }
  
  // User Profile Methods
  Future<UserProfile?> getCurrentUserProfile() async {
    final currentUsername = await _secureStorage.read(key: currentUserKey);
    if (currentUsername == null || currentUsername.isEmpty) {
      return null;
    }
    
    return userProfilesBox.get(currentUsername);
  }
  
  Future<void> setCurrentUser(String username) async {
    await _secureStorage.write(key: currentUserKey, value: username);
  }
  
  Future<UserProfile> createUserProfile({
    required String username,
    String displayName = '',
    String? email,
  }) async {
    // Check if username already exists
    if (userProfilesBox.containsKey(username)) {
      throw Exception('Username already exists');
    }
    
    final userProfile = UserProfile(
      username: username,
      displayName: displayName.isEmpty ? username : displayName,
      email: email,
    );
    
    await userProfilesBox.put(username, userProfile);
    await setCurrentUser(username);
    
    // Update settings with username
    final settings = await getSettings();
    if (settings != null) {
      settings.username = username;
      settings.displayName = userProfile.displayName;
      await settings.save();
    }
    
    return userProfile;
  }
  
  Future<List<UserProfile>> getAllUserProfiles() async {
    return userProfilesBox.values.toList();
  }
  
  Future<void> updateUserProfile(UserProfile userProfile) async {
    await userProfilesBox.put(userProfile.username, userProfile);
    
    // Update settings if this is the current user
    final currentUsername = await _secureStorage.read(key: currentUserKey);
    if (currentUsername == userProfile.username) {
      final settings = await getSettings();
      if (settings != null) {
        settings.displayName = userProfile.displayName;
        settings.profileImagePath = userProfile.profileImagePath;
        await settings.save();
      }
    }
  }
  
  Future<void> deleteUserProfile(String username) async {
    await userProfilesBox.delete(username);
    
    // If this was the current user, clear the current user
    final currentUsername = await _secureStorage.read(key: currentUserKey);
    if (currentUsername == username) {
      await _secureStorage.delete(key: currentUserKey);
    }
  }
  
  Future<String?> saveProfileImage(String username, File imageFile) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final profileImagesDir = Directory('${appDir.path}/profile_images');
      
      if (!await profileImagesDir.exists()) {
        await profileImagesDir.create(recursive: true);
      }
      
      final fileName = '${username}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedImage = await imageFile.copy('${profileImagesDir.path}/$fileName');
      
      return savedImage.path;
    } catch (e) {
      print('Error saving profile image: $e');
      return null;
    }
  }
  
  Future<bool> hasSecurityQuestion() async {
    final settings = settingsBox.getAt(0);
    return settings != null && 
           settings.securityQuestion.isNotEmpty && 
           settings.encryptedSecurityAnswer.isNotEmpty;
  }
  
  // This method is already defined elsewhere in the class, removing the duplicate

  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  String _hashSecurityAnswer(String answer) {
    // Normalize the answer by trimming and converting to lowercase
    final normalizedAnswer = answer.trim().toLowerCase();
    final bytes = utf8.encode(normalizedAnswer);
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
