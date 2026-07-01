class ProjectModel {
  final int id;
  final String name;
  final String description;
  final String status;
  final double progress;

  ProjectModel({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.progress,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['idProject'] ?? 0,
      name: json['projectName'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'PLANNING',
      progress: (json['progress'] ?? 0).toDouble(),
    );
  }
}
