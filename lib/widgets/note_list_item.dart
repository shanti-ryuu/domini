import 'package:flutter/material.dart';
import 'package:domini/models/note.dart';

class NoteListItem extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final bool showDeletedInfo;

  const NoteListItem({
    super.key,
    required this.note,
    required this.onTap,
    this.showDeletedInfo = false,
  });

  @override
  Widget build(BuildContext context) {
    final title = note.title.isNotEmpty ? note.title : 'Untitled Note';
    final content = note.content;
    
    // Calculate time remaining if note is deleted
    String? timeRemaining;
    if (showDeletedInfo && note.deletedAt != null) {
      final deletionDate = note.deletedAt!.add(const Duration(days: 30));
      final daysRemaining = deletionDate.difference(DateTime.now()).inDays;
      timeRemaining = 'Auto-delete in $daysRemaining days';
    }

    return ListTile(
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (content.isNotEmpty)
            Text(
              content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
          if (showDeletedInfo && timeRemaining != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                timeRemaining,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.error,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
      trailing: Text(
        _formatDate(note.updatedAt),
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
        ),
      ),
      onTap: onTap,
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return _formatTime(date);
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return _getDayOfWeek(date);
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : date.hour == 0 ? 12 : date.hour;
    final period = date.hour >= 12 ? 'PM' : 'AM';
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  String _getDayOfWeek(DateTime date) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[date.weekday - 1];
  }
}
