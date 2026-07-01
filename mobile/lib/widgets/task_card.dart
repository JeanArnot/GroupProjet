import 'package:flutter/material.dart';
import '../models/task_model.dart';
import 'package:intl/intl.dart';

class TaskCard extends StatelessWidget {
  final TaskItem task;
  final VoidCallback onTap;
  final VoidCallback onToggleStatus;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: task.isBlocked ? Colors.red.shade200 : Colors.transparent,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: onToggleStatus,
                    child: Icon(
                      task.status == TaskStatus.done
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: task.status == TaskStatus.done
                          ? Colors.green
                          : Colors.grey,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            decoration: task.status == TaskStatus.done
                                ? TextDecoration.lineThrough
                                : null,
                            color: task.status == TaskStatus.done
                                ? Colors.grey
                                : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          task.projectName,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(task.status),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildPriorityIndicator(task.priority),
                  const SizedBox(width: 12),
                  if (task.hasDependencies || task.isBlocked) ...[
                    Icon(
                      task.isBlocked ? Icons.block : Icons.link,
                      size: 16,
                      color: task.isBlocked ? Colors.red : Colors.grey.shade600,
                    ),
                    const SizedBox(width: 12),
                  ],
                  Icon(Icons.calendar_today,
                      size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('dd MMM').format(task.dueDate),
                    style: TextStyle(
                      fontSize: 12,
                      color: task.dueDate.isBefore(DateTime.now()) &&
                              task.status != TaskStatus.done
                          ? Colors.red
                          : Colors.grey.shade600,
                    ),
                  ),
                  const Spacer(),
                  CircleAvatar(
                    radius: 12,
                    backgroundColor:
                        Theme.of(context).primaryColor.withOpacity(0.2),
                    child: Text(
                      task.assignee.substring(0, 1),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
              if (task.progress > 0 && task.progress < 1) ...[
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: task.progress,
                  backgroundColor: Colors.grey.shade200,
                  color: Theme.of(context).primaryColor,
                  minHeight: 4,
                  borderRadius: BorderRadius.circular(2),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (task.commentCount > 0) ...[
                    Icon(Icons.chat_bubble_outline,
                        size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text('${task.commentCount}',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600)),
                    const SizedBox(width: 12),
                  ],
                  if (task.fileCount > 0) ...[
                    Icon(Icons.attach_file,
                        size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text('${task.fileCount}',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(TaskStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: status.color.withOpacity(0.3)),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 10,
          color: status.color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPriorityIndicator(TaskPriority priority) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: priority.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.flag, size: 12, color: priority.color),
          const SizedBox(width: 4),
          Text(
            priority.label,
            style: TextStyle(
              fontSize: 10,
              color: priority.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
