import 'package:flutter/material.dart';

class SubtasksScreen extends StatefulWidget {
  final int taskId;
  const SubtasksScreen({Key? key, this.taskId = 1}) : super(key: key);

  @override
  _SubtasksScreenState createState() => _SubtasksScreenState();
}

class _SubtasksScreenState extends State<SubtasksScreen> {
  final List<Map<String, dynamic>> _subtasks = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Simulate empty state for now since subtasks API is not fully mapped
  }

  void _showAddSubtaskDialog() {
    String subtaskTitle = '';
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Nouvelle sous-tâche',
            style: TextStyle(color: Color(0xFF1E1B4B), fontWeight: FontWeight.bold),
          ),
          content: TextField(
            onChanged: (value) => subtaskTitle = value,
            style: const TextStyle(color: Color(0xFF1E1B4B)),
            decoration: InputDecoration(
              hintText: 'Titre de la sous-tâche',
              hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF4F46E5)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Annuler', style: TextStyle(color: Color(0xFF6B7280))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                if (subtaskTitle.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Le titre ne peut pas être vide.')),
                  );
                  return;
                }
                setState(() {
                  _subtasks.add({
                    'title': subtaskTitle.trim(),
                    'status': 'À faire',
                    'color': Colors.blue,
                    'icon': Icons.check,
                  });
                });
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sous-tâche ajoutée avec succès'), backgroundColor: Colors.green),
                );
              },
              child: const Text('Ajouter', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _toggleSubtaskStatus(int index) {
    setState(() {
      final subtask = _subtasks[index];
      if (subtask['status'] == 'À faire') {
        subtask['status'] = 'Terminée';
        subtask['color'] = const Color(0xFF10B981); // Green
        subtask['icon'] = Icons.check;
      } else {
        subtask['status'] = 'À faire';
      }
    });
  }

  void _deleteSubtask(int index) {
    setState(() {
      _subtasks.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sous-tâche supprimée')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Sous-tâches',
          style: TextStyle(
            color: Color(0xFF1E1B4B),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Color(0xFF1E1B4B)),
            onSelected: (value) {
              if (value == 'mark_all_done') {
                setState(() {
                  for (var subtask in _subtasks) {
                    subtask['status'] = 'Terminée';
                    subtask['color'] = const Color(0xFF10B981);
                    subtask['icon'] = Icons.check;
                  }
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Toutes les sous-tâches sont terminées.')),
                );
              } else if (value == 'delete_all') {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Confirmation'),
                    content: const Text('Voulez-vous vraiment supprimer toutes les sous-tâches ?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _subtasks.clear();
                          });
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Toutes les sous-tâches ont été supprimées.')),
                          );
                        },
                        child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'mark_all_done',
                child: Row(
                  children: [
                    Icon(Icons.done_all, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Tout marquer terminé'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete_all',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Tout supprimer', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator()) 
          : _subtasks.isEmpty
            ? const Center(child: Text('Aucune sous-tâche pour le moment.', style: TextStyle(color: Color(0xFF6B7280))))
            : ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        itemCount: _subtasks.length,
        separatorBuilder: (context, index) => const SizedBox(height: 24),
        itemBuilder: (context, index) {
          final subtask = _subtasks[index];
          final isTodo = subtask['status'] == 'À faire';

          return GestureDetector(
            onTap: () => _toggleSubtaskStatus(index),
            onLongPress: () => _deleteSubtask(index),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isTodo ? Colors.white : subtask['color'],
                    borderRadius: BorderRadius.circular(6),
                    border: isTodo ? Border.all(color: const Color(0xFFD1D5DB), width: 2) : null,
                  ),
                  child: isTodo
                      ? null
                      : Icon(subtask['icon'], color: Colors.white, size: 16),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subtask['title'],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isTodo ? const Color(0xFF1E1B4B) : const Color(0xFF9CA3AF),
                          decoration: isTodo ? null : TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  subtask['status'],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isTodo ? const Color(0xFF6B7280) : subtask['color'],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ElevatedButton.icon(
          onPressed: _showAddSubtaskDialog,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'Ajouter une sous-tâche',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4F46E5),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}
