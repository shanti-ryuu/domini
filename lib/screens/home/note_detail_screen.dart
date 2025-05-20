import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:domini/models/note.dart';
import 'package:domini/services/note_service.dart';
import 'package:domini/widgets/folder_selection_dialog.dart';

class NoteDetailScreen extends StatefulWidget {
  final String noteId;

  const NoteDetailScreen({
    super.key,
    required this.noteId,
  });

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late Note _note;
  bool _isLoading = true;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
    _loadNote();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _saveNote();
    super.dispose();
  }

  Future<void> _loadNote() async {
    final noteService = Provider.of<NoteService>(context, listen: false);
    final note = await noteService.getNoteById(widget.noteId);
    
    if (note != null) {
      setState(() {
        _note = note;
        _titleController.text = note.title;
        _contentController.text = note.content;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveNote() async {
    if (!_isLoading && (_titleController.text != _note.title || _contentController.text != _note.content)) {
      final noteService = Provider.of<NoteService>(context, listen: false);
      
      final updatedNote = _note.copyWith(
        title: _titleController.text,
        content: _contentController.text,
        updatedAt: DateTime.now(),
      );
      
      await noteService.updateNote(updatedNote);
    }
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        _saveNote();
      }
    });
  }

  void _deleteNote() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
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
              noteService.deleteNote(_note.id).then((_) {
                Navigator.pop(context);
              });
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _shareNote() {
    final title = _titleController.text.isNotEmpty 
        ? _titleController.text 
        : 'Untitled Note';
    final content = _contentController.text;
    
    Share.share(
      '$title\n\n$content',
      subject: title,
    );
  }

  void _showFolderSelection() {
    showDialog(
      context: context,
      builder: (context) => FolderSelectionDialog(
        note: _note,
        onFoldersUpdated: (folderIds) {
          setState(() {
            _note = _note.copyWith(folderIds: folderIds);
          });
          _saveNote();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () {
            _saveNote();
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.folder_badge_plus),
            onPressed: _showFolderSelection,
            tooltip: 'Move to Folder',
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.share),
            onPressed: _shareNote,
            tooltip: 'Share',
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.delete),
            onPressed: _deleteNote,
            tooltip: 'Delete',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              decoration: const InputDecoration(
                hintText: 'Title',
                border: InputBorder.none,
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            Text(
              'Edited ${_formatDate(_note.updatedAt)}',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _contentController,
                style: const TextStyle(
                  fontSize: 16,
                ),
                decoration: const InputDecoration(
                  hintText: 'Note',
                  border: InputBorder.none,
                ),
                maxLines: null,
                expands: true,
                keyboardType: TextInputType.multiline,
                textAlignVertical: TextAlignVertical.top,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today, ${_formatTime(date)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday, ${_formatTime(date)}';
    } else if (difference.inDays < 7) {
      return '${_getDayOfWeek(date)}, ${_formatTime(date)}';
    } else {
      return '${date.day}/${date.month}/${date.year}, ${_formatTime(date)}';
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final period = date.hour >= 12 ? 'PM' : 'AM';
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  String _getDayOfWeek(DateTime date) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[date.weekday - 1];
  }
}
