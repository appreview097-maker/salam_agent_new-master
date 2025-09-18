import 'info_model.dart';

class User {
  final int id;
  final String nomComplet;
  final String email;
  final String matricule;
  final String role;
  final Info info;

  User({
    required this.id,
    required this.nomComplet,
    required this.email,
    required this.matricule,
    required this.role,
    required this.info,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      nomComplet: json['nomComplet'],
      email: json['email'],
      matricule: json['matricule'],
      role: json['role'],
      info: Info.fromJson(json['info']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nomComplet': nomComplet,
      'email': email,
      'matricule': matricule,
      'role': role,
      'info': info.toJson(),
    };
  }


}