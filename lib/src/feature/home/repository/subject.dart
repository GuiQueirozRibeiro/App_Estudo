class Subject {
  final String? id;
  String name;
  String imageUrl;
  String teacher;
  List classes;

  Subject({
    this.id,
    required this.name,
    required this.imageUrl,
    required this.classes,
    required this.teacher,
  });
}
