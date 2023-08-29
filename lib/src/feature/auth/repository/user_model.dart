class UserModel {
  final String id;
  final String name;
  final String classroom;
  final String imageUrl;
  final bool isProfessor;

  const UserModel({
    required this.id,
    required this.name,
    required this.classroom,
    required this.imageUrl,
    required this.isProfessor,
  });
}
