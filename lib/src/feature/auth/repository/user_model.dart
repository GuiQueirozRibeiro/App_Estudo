class User {
  int? age;
  String? email;
  String? name;
  String? phoneNumber;

  User({
    this.age,
    this.email,
    this.name,
    this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'age': age ?? 0,
      'email': email ?? '',
      'name': name ?? '',
      'phoneNumber': phoneNumber ?? '',
    };
  }
}
