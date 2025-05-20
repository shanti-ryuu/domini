import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:domini/services/note_service.dart';
import 'package:domini/services/theme_service.dart';
import 'package:domini/screens/home/note_detail_screen.dart';
import 'package:domini/screens/home/folder_list_screen.dart';
import 'package:domini/screens/home/trash_screen.dart';
import 'package:domini/screens/home/settings_screen.dart';
import 'package:domini/widgets/note_list_item.dart';
import 'package:domini/widgets/empty_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

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

  void _openFolders() {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const FolderListScreen(),
      ),
    );
  }

  void _openTrash() {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const TrashScreen(),
      ),
    );
  }

  void _openSettings() {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final noteService = Provider.of<NoteService>(context);
    final themeService = Provider.of<ThemeService>(context);
    final notes = noteService.notes;
    final currentFolder = noteService.folders.firstWhere(
      (folder) => folder.id == noteService.currentFolderId,
      orElse: () => noteService.folders.first,
    );

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? CupertinoSearchTextField(
                controller: _searchController,
                onChanged: (value) {
                  noteService.setSearchQuery(value);
                },
                placeholder: 'Search notes',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              )
            : Text(currentFolder.name),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.folder),
          onPressed: _openFolders,
        ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? CupertinoIcons.xmark : CupertinoIcons.search),
            onPressed: _toggleSearch,
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.settings),
            onPressed: _openSettings,
          ),
        ],
      ),
      body: notes.isEmpty
          ? EmptyState(
              icon: CupertinoIcons.doc_text,
              title: 'No Notes',
              message: 'Tap the + button to create a new note',
            )
          : ListView.separated(
              itemCount: notes.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final note = notes[index];
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
              '${notes.length} note${notes.length == 1 ? '' : 's'}',
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
        child: const Icon(CupertinoIcons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
