import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:domini/models/note.dart';

class NoteListItem extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final bool showDeletedInfo;

  const NoteListItem({
    super.key,
    required this.note,
    required this.onTap,
    this.onDelete,
    this.showDeletedInfo = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final title = note.title.isNotEmpty ? note.title : 'Untitled Note';
    final content = note.content;
    final dateFormat = DateFormat('MMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');
    
    // Format the date for display
    final now = DateTime.now();
    // Use the updated date if available, otherwise use created date
    final noteDate = note.updatedAt ?? note.createdAt;
    final isToday = noteDate.day == now.day && 
                    noteDate.month == now.month && 
                    noteDate.year == now.year;
    final yesterday = now.subtract(const Duration(days: 1));
    final isYesterday = noteDate.day == yesterday.day && 
                        noteDate.month == yesterday.month && 
                        noteDate.year == yesterday.year;
    
    String formattedDate;
    if (isToday) {
      formattedDate = timeFormat.format(noteDate);
    } else if (isYesterday) {
      formattedDate = 'Yesterday';
    } else {
      formattedDate = dateFormat.format(noteDate);
    }
    
    // Calculate time remaining if note is deleted
    String? timeRemaining;
    if (showDeletedInfo && note.deletedAt != null) {
      final deletionDate = note.deletedAt!.add(const Duration(days: 30));
      final daysRemaining = deletionDate.difference(DateTime.now()).inDays;
      timeRemaining = 'Auto-delete in $daysRemaining days';
    }

    return Dismissible(
      key: Key(note.id),
      direction: showDeletedInfo ? DismissDirection.horizontal : DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        color: Colors.red,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (direction) async {
        if (onDelete != null && !showDeletedInfo) {
          onDelete!();
          return true;
        }
        return false;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey.shade900 : Colors.white,
          border: Border(
            bottom: BorderSide(
              color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
              width: 0.5,
            ),
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode 
                          ? Colors.grey.shade400 
                          : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              if (content.isNotEmpty) ...[  
                const SizedBox(height: 4),
                Text(
                  content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode 
                        ? Colors.grey.shade300 
                        : Colors.grey.shade700,
                  ),
                ),
              ],
              if (showDeletedInfo && timeRemaining != null) ...[  
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.timer,
                      size: 14,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      timeRemaining,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.error,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }


}
