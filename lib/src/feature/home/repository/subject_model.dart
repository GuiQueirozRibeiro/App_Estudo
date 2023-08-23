class Subject {
  final String title;
  final String teacher;
  final String imageUrl;

  Subject({
    required this.title,
    required this.teacher,
    required this.imageUrl,
  });

  static final List<Subject> subjects = [
    Subject(
        title: 'Geografia',
        teacher: 'Marcos Bau',
        imageUrl:
            'https://visme.co/blog/wp-content/uploads/2020/12/header-19.png'),
    Subject(
        title: 'Física',
        teacher: 'William Santos',
        imageUrl:
            'https://www.freewebheaders.com/gc-biology-1600x400/cache/colorful-abstract-bubbles-microbiology-transparent-liquid-design-science-biochemistry-biology-banner_gc-banner-1600x400_250784.JPG-nggid0514239-ngg0dyn-1000x250x100-00f0w010c010r110f110r010t010.JPG'),
  ];
}
