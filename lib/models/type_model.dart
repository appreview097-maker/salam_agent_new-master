class TypeModel{
  final int id;
  final String libelle;
  final String color;
  final int montant;

  TypeModel({
    required this.id,
    required this.libelle,
    required this.color,
    required this.montant
  });

  factory TypeModel.fromJson(Map<String, dynamic> json)
  {
    return TypeModel(
      id: json["id"],
      libelle: json["libelle"],
      color: json["color"],
      montant: json["montant"],);

  }
}

extension TypeModelToJson on TypeModel {
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'libelle': libelle,
      'color': color,
      'montant': montant,
    };
  }
}
