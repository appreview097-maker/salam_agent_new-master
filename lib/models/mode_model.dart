class Mode {
  final int id;
  final String type;


  Mode({required this.id, required this.type, });

  factory Mode.fromJson(Map<String, dynamic> json) {
    return Mode(
      id: json['id'],
      type: json['type'],

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
    };
  }
}