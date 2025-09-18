class Repas {
  final int id;
  final String libelle;
  final int montant;

  Repas({required this.id, required this.libelle, required this.montant});

  factory Repas.fromJson(Map<String, dynamic> json) {
    return Repas(
      id: json['id'],
      libelle: json['libelle'],
      montant: json['montant'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'libelle': libelle,
      'montant': montant,
    };
  }
}