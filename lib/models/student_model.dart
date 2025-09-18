import 'dart:convert';

class Student {
  final int id;
  final String nomComplet;
  final String email;
  final String matricule;
  final String dateNaissance;
  final String numero;
  final String code;
  final int solde;
  String photo;
  final String role;

  /// Optional field (not always present)
  final String? identification;

  Student({
    required this.id,
    required this.nomComplet,
    required this.email,
    required this.matricule,
    required this.dateNaissance,
    required this.numero,
    required this.code,
    required this.solde,
    required this.photo,
    required this.role,
    this.identification,
  });

  /// Create object from JSON
  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      nomComplet: json['nomComplet'] ?? '',
      email: json['email'] ?? '',
      matricule: json['matricule'] ?? '',
      dateNaissance: json['date_naissance'] ?? '',
      numero: json['numero'] ?? '',
      code: json['code'] ?? '',
      solde: json['solde'] ?? 0,
      photo: json['photo'] ?? '',
      role: json['role'] ?? '',
      identification: json['identification'], // only set if present
    );
  }

  /// Convert object to JSON
  Map<String, dynamic> toJson() {
    final data = {
      'id': id,
      'nomComplet': nomComplet,
      'email': email,
      'matricule': matricule,
      'date_naissance': dateNaissance,
      'numero': numero,
      'code': code,
      'solde': solde,
      'photo': photo,
      'role': role,
    };

    if (identification != null) {
      data['identification'] = identification!;
    }

    return data;
  }

  /// CopyWith for immutability
  Student copyWith({
    int? id,
    String? nomComplet,
    String? email,
    String? matricule,
    String? dateNaissance,
    String? numero,
    String? code,
    int? solde,
    String? photo,
    String? role,
    String? identification,
  }) {
    return Student(
      id: id ?? this.id,
      nomComplet: nomComplet ?? this.nomComplet,
      email: email ?? this.email,
      matricule: matricule ?? this.matricule,
      dateNaissance: dateNaissance ?? this.dateNaissance,
      numero: numero ?? this.numero,
      code: code ?? this.code,
      solde: solde ?? this.solde,
      photo: photo ?? this.photo,
      role: role ?? this.role,
      identification: identification ?? this.identification,
    );
  }

  /// Value equality
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Student &&
        other.id == id &&
        other.nomComplet == nomComplet &&
        other.email == email &&
        other.matricule == matricule &&
        other.dateNaissance == dateNaissance &&
        other.numero == numero &&
        other.code == code &&
        other.solde == solde &&
        other.photo == photo &&
        other.role == role &&
        other.identification == identification;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        nomComplet.hashCode ^
        email.hashCode ^
        matricule.hashCode ^
        dateNaissance.hashCode ^
        numero.hashCode ^
        code.hashCode ^
        solde.hashCode ^
        photo.hashCode ^
        role.hashCode ^
        identification.hashCode;
  }

  /// For debugging/logging
  @override
  String toString() => jsonEncode(toJson());
}
