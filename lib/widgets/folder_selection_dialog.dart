import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:domini/models/note.dart';
import 'package:domini/services/note_service.dart';

class FolderSelectionDialog extends StatefulWidget {
  final Note note;
  final Function(List<String>) onFoldersUpdated;

  const FolderSelectionDialog({
    super.key,
    required this.note,
    required this.onFoldersUpdated,
  });

  @override
  State<FolderSelectionDialog> createState() => _FolderSelectionDialogState();
}

class _FolderSelectionDialogState extends State<FolderSelectionDialog> {
  late List<String> _selectedFolderIds;
  final TextEditingController _newFolderController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedFolderIds = List.from(widget.note.folderIds);
  }

  @override
  void dispose() {
    _newFolderController.dispose();
    super.dispose();
  }

  void _toggleFolder(String folderId) {
    setState(() {
      if (_selectedFolderIds.contains(folderId)) {
        _selectedFolderIds.remove(folderId);
      } else {
        _selectedFolderIds.add(folderId);
      }
    });
  }

  void _createNewFolder() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Folder'),
        content: TextField(
          controller: _newFolderController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Folder Name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _newFolderController.clear();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_newFolderController.text.isNotEmpty) {
                final noteService = Provider.of<NoteService>(context, listen: false);
                noteService.createFolder(_newFolderController.text).then((folder) {
                  setState(() {
                    _selectedFolderIds.add(folder.id);
                  });
                  Navigator.pop(context);
                  _newFolderController.clear();
                });
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final noteService = Provider.of<NoteService>(context);
    final folders = noteService.folders;

    return AlertDialog(
      title: const Text('Move to Folders'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select the folders for this note',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: folders.length,
                itemBuilder: (context, index) {
                  final folder = folders[index];
                  final isSelected = _selectedFolderIds.contains(folder.id);
                  
                  return CheckboxListTile(
                    title: Text(folder.name),
                    value: isSelected,
                    onChanged: (_) => _toggleFolder(folder.id),
                    controlAffinity: ListTileControlAffinity.leading,
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _createNewFolder,
              icon: const Icon(CupertinoIcons.folder_badge_plus),
              label: const Text('New Folder'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            widget.onFoldersUpdated(_selectedFolderIds);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
