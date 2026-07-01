import 'package:flutter/material.dart';

enum TaskStatus {
  todo('À faire', Colors.grey),
  inProgress('En cours', Colors.blue),
  review('En revue', Colors.purple),
  done('Terminé', Colors.green),
  blocked('Bloqué', Colors.red),
  overdue('En retard', Colors.orange),
  cancelled('Annulé', Colors.black54);

  final String label;
  final Color color;
  const TaskStatus(this.label, this.color);
}

enum TaskPriority {
  low('Basse', Colors.blueGrey),
  medium('Moyenne', Colors.blue),
  high('Haute', Colors.orange),
  urgent('Urgente', Colors.red);

  final String label;
  final Color color;
  const TaskPriority(this.label, this.color);
}

class TaskItem {
  final String id;
  final String title;
  final String description;
  final String projectName;
  final String assignee;
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime dueDate;
  final double progress;
  final int commentCount;
  final int fileCount;
  final bool hasDependencies;
  final bool isBlocked;

  TaskItem({
    required this.id,
    required this.title,
    required this.description,
    required this.projectName,
    required this.assignee,
    required this.status,
    required this.priority,
    required this.dueDate,
    this.progress = 0.0,
    this.commentCount = 0,
    this.fileCount = 0,
    this.hasDependencies = false,
    this.isBlocked = false,
  });
}
