class Info {
  final int id;
  final String nomComplet;
  final String email;
  final String matricule;
  final String role;
  final String type;

  Info({
    required this.id,
    required this.nomComplet,
    required this.email,
    required this.matricule,
    required this.role,
    required this.type,
  });

  factory Info.fromJson(Map<String, dynamic> json) {
    return Info(
      id: json['id'],
      nomComplet: json['nomComplet'],
      email: json['email'],
      matricule: json['matricule'],
      role: json['role'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nomComplet': nomComplet,
      'email': email,
      'matricule': matricule,
      'role': role,
      'type': type,
    };
  }
}