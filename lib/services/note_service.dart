import 'package:flutter/material.dart';
import 'package:domini/models/note.dart';
import 'package:domini/models/folder.dart';
import 'package:domini/services/database_service.dart';

class NoteService extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  
  List<Note> _notes = [];
  List<Note> _filteredNotes = [];
  List<Note> _recentlyDeletedNotes = [];
  List<Folder> _folders = [];
  String _currentFolderId = '';
  String _searchQuery = '';

  NoteService() {
    _loadData();
  }

  List<Note> get notes => _filteredNotes;
  List<Note> get recentlyDeletedNotes => _recentlyDeletedNotes;
  List<Folder> get folders => _folders;
  String get currentFolderId => _currentFolderId;
  String get searchQuery => _searchQuery;

  Future<void> _loadData() async {
    await _loadFolders();
    await _loadNotes();
    await _loadRecentlyDeletedNotes();
    
    if (_folders.isNotEmpty && _currentFolderId.isEmpty) {
      _currentFolderId = _folders[0].id;
    }
    
    _filterNotes();
    notifyListeners();
  }

  Future<void> _loadNotes() async {
    _notes = await _databaseService.getNotes();
    _filterNotes();
  }
  
  Future<Note?> getNoteById(String noteId) async {
    try {
      return _notes.firstWhere((note) => note.id == noteId);
    } catch (e) {
      return null;
    }
  }

  Future<void> _loadRecentlyDeletedNotes() async {
    _recentlyDeletedNotes = (await _databaseService.getNotes(includeDeleted: true))
        .where((note) => note.isDeleted)
        .toList();
  }

  Future<void> _loadFolders() async {
    _folders = await _databaseService.getFolders();
  }

  void _filterNotes() {
    if (_currentFolderId.isEmpty) {
      _filteredNotes = List.from(_notes);
    } else {
      _filteredNotes = _notes
          .where((note) => note.folderIds.contains(_currentFolderId))
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      _filteredNotes = _filteredNotes
          .where((note) => 
              note.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              note.content.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Sort by updated date, newest first
    _filteredNotes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  void setCurrentFolder(String folderId) {
    _currentFolderId = folderId;
    _filterNotes();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _filterNotes();
    notifyListeners();
  }

  Future<Note> createNote({String title = '', String content = ''}) async {
    final note = Note(
      title: title,
      content: content,
      folderIds: _currentFolderId.isNotEmpty ? [_currentFolderId] : [],
    );
    
    await _databaseService.addNote(note);
    await _loadNotes();
    notifyListeners();
    return note;
  }

  Future<void> updateNote(Note note) async {
    note.updatedAt = DateTime.now();
    await _databaseService.updateNote(note);
    await _loadNotes();
    notifyListeners();
  }

  Future<void> deleteNote(String noteId) async {
    await _databaseService.softDeleteNote(noteId);
    await _loadNotes();
    await _loadRecentlyDeletedNotes();
    notifyListeners();
  }

  Future<void> restoreNote(String noteId) async {
    await _databaseService.restoreNote(noteId);
    await _loadNotes();
    await _loadRecentlyDeletedNotes();
    notifyListeners();
  }

  Future<void> permanentlyDeleteNote(String noteId) async {
    await _databaseService.permanentlyDeleteNote(noteId);
    await _loadRecentlyDeletedNotes();
    notifyListeners();
  }

  Future<void> addNoteToFolder(String noteId, String folderId) async {
    final note = await _databaseService.getNoteById(noteId);
    if (note != null && !note.folderIds.contains(folderId)) {
      note.folderIds.add(folderId);
      await _databaseService.updateNote(note);
      await _loadNotes();
      notifyListeners();
    }
  }

  Future<void> removeNoteFromFolder(String noteId, String folderId) async {
    final note = await _databaseService.getNoteById(noteId);
    if (note != null && note.folderIds.contains(folderId)) {
      note.folderIds.remove(folderId);
      await _databaseService.updateNote(note);
      await _loadNotes();
      notifyListeners();
    }
  }

  Future<Folder> createFolder(String name) async {
    final folder = Folder(name: name);
    await _databaseService.addFolder(folder);
    await _loadFolders();
    notifyListeners();
    return folder;
  }

  Future<void> updateFolder(Folder folder) async {
    folder.updatedAt = DateTime.now();
    await _databaseService.updateFolder(folder);
    await _loadFolders();
    notifyListeners();
  }

  Future<void> deleteFolder(String folderId) async {
    await _databaseService.deleteFolder(folderId);
    
    if (_currentFolderId == folderId && _folders.isNotEmpty) {
      _currentFolderId = _folders[0].id;
    }
    
    await _loadFolders();
    await _loadNotes();
    notifyListeners();
  }

  int getNoteCountInFolder(String folderId) {
    return _notes.where((note) => note.folderIds.contains(folderId)).length;
  }

  Future<void> refreshData() async {
    await _loadData();
  }
}
