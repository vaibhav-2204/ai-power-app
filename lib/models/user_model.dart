import 'dart:convert';

class UserModel {
  final String name;
  final String email;
  final String password;
  final int? age;
  final double? weight;
  final double? height;
  final String? goal;
  final String? level;
  final int? daysPerWeek;
  final bool profileCompleted;

  UserModel({
    required this.name,
    required this.email,
    required this.password,
    this.age,
    this.weight,
    this.height,
    this.goal,
    this.level,
    this.daysPerWeek,
    this.profileCompleted = false,
  });

  UserModel copyWith({
    String? name,
    String? email,
    String? password,
    int? age,
    double? weight,
    double? height,
    String? goal,
    String? level,
    int? daysPerWeek,
    bool? profileCompleted,
  }) {
    return UserModel(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      goal: goal ?? this.goal,
      level: level ?? this.level,
      daysPerWeek: daysPerWeek ?? this.daysPerWeek,
      profileCompleted: profileCompleted ?? this.profileCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'age': age,
      'weight': weight,
      'height': height,
      'goal': goal,
      'level': level,
      'daysPerWeek': daysPerWeek,
      'profileCompleted': profileCompleted,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      age: map['age']?.toInt(),
      weight: map['weight']?.toDouble(),
      height: map['height']?.toDouble(),
      goal: map['goal'],
      level: map['level'],
      daysPerWeek: map['daysPerWeek']?.toInt(),
      profileCompleted: map['profileCompleted'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source));
}
