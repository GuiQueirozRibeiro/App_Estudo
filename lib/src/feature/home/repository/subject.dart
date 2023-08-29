class Subject {
  final String? id;
  final String name;
  final String imageUrl;
  final List classes;
  final List teachers;

  Subject({
    this.id,
    required this.name,
    required this.imageUrl,
    required this.classes,
    required this.teachers,
  });
}
