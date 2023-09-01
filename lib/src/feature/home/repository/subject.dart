class Subject {
  final String? id;
  final String name;
  final String imageUrl;
  final String teacher;
  final List classes;

  Subject({
    this.id,
    required this.name,
    required this.imageUrl,
    required this.classes,
    required this.teacher,
  });
}
