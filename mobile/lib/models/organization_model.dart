class OrganizationModel {
  final String id;
  final String name;
  final String description;
  final String visibility; // Public, Private
  final String leader;
  final int memberCount;
  final int projectCount;
  final String latestActivity;
  final String role; // Admin, Member, Viewer
  final String healthStatus; // Stable, Warning, Critical
  final bool isActive;
  final String accessCode;

  OrganizationModel({
    required this.id,
    required this.name,
    required this.description,
    this.visibility = 'Privé',
    required this.leader,
    required this.memberCount,
    required this.projectCount,
    required this.latestActivity,
    this.role = 'Membre',
    this.healthStatus = 'Stable',
    this.isActive = true,
    this.accessCode = '',
  });
}
