import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:domini/services/note_service.dart';
import 'package:domini/widgets/note_list_item.dart';
import 'package:domini/widgets/empty_state.dart';

class TrashScreen extends StatelessWidget {
  const TrashScreen({super.key});

  void _emptyTrash(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Empty Trash'),
        content: const Text(
          'Are you sure you want to permanently delete all notes in the trash? This action cannot be undone.',
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
              final deletedNotes = noteService.recentlyDeletedNotes;
              
              for (final note in deletedNotes) {
                noteService.permanentlyDeleteNote(note.id);
              }
            },
            child: const Text('Empty Trash'),
          ),
        ],
      ),
    );
  }

  void _showNoteOptions(BuildContext context, String noteId) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              final noteService = Provider.of<NoteService>(context, listen: false);
              noteService.restoreNote(noteId);
            },
            child: const Text('Restore Note'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _confirmPermanentDelete(context, noteId);
            },
            isDestructiveAction: true,
            child: const Text('Delete Permanently'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _confirmPermanentDelete(BuildContext context, String noteId) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete Permanently'),
        content: const Text(
          'Are you sure you want to permanently delete this note? This action cannot be undone.',
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
              noteService.permanentlyDeleteNote(noteId);
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
    final deletedNotes = noteService.recentlyDeletedNotes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recently Deleted'),
        actions: [
          if (deletedNotes.isNotEmpty)
            IconButton(
              icon: const Icon(CupertinoIcons.trash),
              onPressed: () => _emptyTrash(context),
              tooltip: 'Empty Trash',
            ),
        ],
      ),
      body: deletedNotes.isEmpty
          ? const EmptyState(
              icon: CupertinoIcons.trash,
              title: 'No Deleted Notes',
              message: 'Notes that you delete will appear here',
            )
          : ListView.separated(
              itemCount: deletedNotes.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final note = deletedNotes[index];
                return NoteListItem(
                  note: note,
                  onTap: () => _showNoteOptions(context, note.id),
                  showDeletedInfo: true,
                );
              },
            ),
    );
  }
}
