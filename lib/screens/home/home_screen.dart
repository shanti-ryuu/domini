import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:domini/constants/app_colors.dart';
import 'package:domini/services/note_service.dart';
import 'package:domini/services/theme_service.dart';
import 'package:domini/services/database_service.dart';
import 'package:domini/screens/home/note_detail_screen.dart';
import 'package:domini/screens/home/trash_screen.dart';
import 'package:domini/screens/home/settings_screen.dart';
import 'package:domini/screens/home/profile_screen.dart';
import 'package:domini/widgets/note_list_item.dart';
import 'package:domini/widgets/empty_state.dart';
import 'package:domini/models/user_profile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  UserProfile? _userProfile;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }
  
  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoadingProfile = true;
    });
    
    try {
      final databaseService = DatabaseService();
      final userProfile = await databaseService.getCurrentUserProfile();
      
      if (mounted) {
        setState(() {
          _userProfile = userProfile;
          _isLoadingProfile = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
    }
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        Provider.of<NoteService>(context, listen: false).setSearchQuery('');
      }
    });
  }

  void _createNewNote() {
    final noteService = Provider.of<NoteService>(context, listen: false);
    noteService.createNote().then((note) {
      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => NoteDetailScreen(noteId: note.id),
        ),
      );
    });
  }

  void _openTrash() {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const TrashScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final noteService = Provider.of<NoteService>(context);
    final themeService = Provider.of<ThemeService>(context);
    final isDarkMode = themeService.isDarkMode;
    
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
          ? TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search notes...',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
                fontSize: 18,
              ),
              onChanged: (value) {
                noteService.setSearchQuery(value);
              },
              autofocus: true,
            )
          : const Text('Notes', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
          if (!_isLoadingProfile && _userProfile != null)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                ).then((_) => _loadUserProfile());
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: _userProfile!.profileImagePath != null
                    ? CircleAvatar(
                        radius: 16,
                        backgroundImage: FileImage(File(_userProfile!.profileImagePath!)),
                      )
                    : CircleAvatar(
                        radius: 16,
                        backgroundColor: isDarkMode ? AppColors.primaryDark : AppColors.primaryLight,
                        child: Text(
                          _userProfile!.displayName.isNotEmpty
                              ? _userProfile!.displayName.substring(0, 1).toUpperCase()
                              : _userProfile!.username.substring(0, 1).toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
        ],
      ),
      body: noteService.notes.isEmpty
          ? EmptyState(
              icon: Icons.note,
              title: 'No Notes',
              message: noteService.searchQuery.isNotEmpty
                  ? 'No notes found matching "${noteService.searchQuery}"'
                  : 'No notes yet',
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: noteService.notes.length,
              separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
              itemBuilder: (context, index) {
                final note = noteService.notes[index];
                return NoteListItem(
                  note: note,
                  onTap: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => NoteDetailScreen(noteId: note.id),
                      ),
                    );
                  },

                );
              },
            ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(CupertinoIcons.delete),
              onPressed: _openTrash,
              tooltip: 'Recently Deleted',
            ),
            Text(
              '${noteService.notes.length} note${noteService.notes.length == 1 ? '' : 's'}',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
              ),
            ),
            IconButton(
              icon: const Icon(CupertinoIcons.brightness),
              onPressed: () {
                themeService.toggleDarkMode();
              },
              tooltip: 'Toggle Dark Mode',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewNote,
        backgroundColor: isDarkMode ? AppColors.primaryDark : AppColors.primaryLight,
        child: const Icon(Icons.add),
        elevation: 4,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
