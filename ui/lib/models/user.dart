class User {
  final String id;
  final String email;
  final String name;
  final int age;
  final bool isCaregiver;

  User({required this.id, required this.email, required this.name, required this.age, required this.isCaregiver});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      age: json['age'],
      isCaregiver: json['isCaregiver']
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'email': email, 'name': name, 'age': age};
  }
}
