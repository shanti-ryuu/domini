import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:domini/models/folder.dart';
import 'package:domini/services/note_service.dart';
import 'package:domini/widgets/folder_list_item.dart';
import 'package:domini/widgets/empty_state.dart';

class FolderListScreen extends StatefulWidget {
  const FolderListScreen({super.key});

  @override
  State<FolderListScreen> createState() => _FolderListScreenState();
}

class _FolderListScreenState extends State<FolderListScreen> {
  final TextEditingController _folderNameController = TextEditingController();

  @override
  void dispose() {
    _folderNameController.dispose();
    super.dispose();
  }

  void _createNewFolder() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Folder'),
        content: TextField(
          controller: _folderNameController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Folder Name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _folderNameController.clear();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_folderNameController.text.isNotEmpty) {
                final noteService = Provider.of<NoteService>(context, listen: false);
                noteService.createFolder(_folderNameController.text);
                Navigator.pop(context);
                _folderNameController.clear();
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _editFolder(Folder folder) {
    _folderNameController.text = folder.name;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Folder'),
        content: TextField(
          controller: _folderNameController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Folder Name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _folderNameController.clear();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_folderNameController.text.isNotEmpty) {
                final noteService = Provider.of<NoteService>(context, listen: false);
                final updatedFolder = folder.copyWith(
                  name: _folderNameController.text,
                );
                noteService.updateFolder(updatedFolder);
                Navigator.pop(context);
                _folderNameController.clear();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteFolder(Folder folder) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete Folder'),
        content: Text(
          'Are you sure you want to delete "${folder.name}"? Notes in this folder will not be deleted.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              final noteService = Provider.of<NoteService>(context, listen: false);
              noteService.deleteFolder(folder.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final noteService = Provider.of<NoteService>(context);
    final folders = noteService.folders;
    final currentFolderId = noteService.currentFolderId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Folders'),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.folder_badge_plus),
            onPressed: _createNewFolder,
            tooltip: 'New Folder',
          ),
        ],
      ),
      body: folders.isEmpty
          ? EmptyState(
              icon: CupertinoIcons.folder,
              title: 'No Folders',
              message: 'Tap the + button to create a new folder',
            )
          : ListView.separated(
              itemCount: folders.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final folder = folders[index];
                final isSelected = folder.id == currentFolderId;
                final noteCount = noteService.getNoteCountInFolder(folder.id);
                
                return FolderListItem(
                  folder: folder,
                  noteCount: noteCount,
                  isSelected: isSelected,
                  onTap: () {
                    noteService.setCurrentFolder(folder.id);
                    Navigator.pop(context);
                  },
                  onEdit: () => _editFolder(folder),
                  onDelete: () => _deleteFolder(folder),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewFolder,
        child: const Icon(CupertinoIcons.folder_badge_plus),
      ),
    );
  }
}
