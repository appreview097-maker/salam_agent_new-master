class Restaurant {
  final int id;
  final String libelle;
  final int? nombrePlace;

  Restaurant({required this.id, required this.libelle, required this.nombrePlace});

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'],
      libelle: json['libelle'],
      nombrePlace: json['nombre_place'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'libelle': libelle,
      'nombrePlace': nombrePlace,
    };
  }
}