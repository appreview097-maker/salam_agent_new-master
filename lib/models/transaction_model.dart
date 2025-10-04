import 'package:get/get.dart';

import 'type_model.dart';

class TransactionModel {
  // Reactive fields
  final Rx<int?> id;
  final Rx<String?> identifiant; // NEW: nullable string
  final Rx<String?> date;
  final Rx<String?> montant; // String type for montant
  final Rx<int> quantite;
  final Rx<String> repas;
  final Rx<String> reference;
  final Rx<TypeModel?> type;

  // Constructor
  TransactionModel({
    int? id,
    String? identifiant, // NEW
    String? date,
    String? montant,
    int quantite = -1,
    String repas = "",
    String reference = "",
    TypeModel? type,
  })  : id = Rx<int?>(id),
        identifiant = Rx<String?>(identifiant), // NEW
        date = Rx<String?>(date),
        montant = Rx<String?>(montant),
        quantite = Rx<int>(quantite),
        repas = Rx<String>(repas),
        reference = Rx<String>(reference),
        type = Rx<TypeModel?>(type);

  // Factory method for JSON parsing
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      identifiant: json['identifiant'], // NEW
      date: json['date'] ?? "",
      montant: json['montant']?.toString() ?? "",
      quantite: json['quantite'] ?? -1,
      repas: json['repas'] ?? "",
      reference: json['reference'] ?? "",
      type: json['type'] != null ? TypeModel.fromJson(json['type']) : null,
    );
  }
}

extension TransactionModelToJson on TransactionModel {
  Map<String, dynamic> toJson() {
    return {
      'id': id.value,
      'identifiant': identifiant.value, // NEW
      'date': date.value,
      'montant': montant.value,
      'quantite': quantite.value,
      'repas': repas.value,
      'reference': reference.value,
      'type': type.value?.toJson(),
    };
  }
}

// extension TransactionColorExtension on TransactionModel {
// Color get statusColor {
//   final hex = type.value?.color ?? "#999999"; // fallback grey
//   return _hexToColor(hex);
// }
//
// Color _hexToColor(String hex) {
//   String formatted = hex.trim().toLowerCase();
//
//   // Remove # or 0x if present
//   if (formatted.startsWith("#")) {
//     formatted = formatted.substring(1);
//   }
//   if (formatted.startsWith("0x")) {
//     formatted = formatted.substring(2);
//   }
//
//   // If only RGB is provided, prepend FF (full opacity)
//   if (formatted.length == 6) {
//     formatted = "ff$formatted";
//   }
//
//   return Color(int.parse("0x$formatted"));
// }
// }

class PendingTransactionModel {
  final String uuid; // local unique id
  final int? etudiantId;
  final int quantite;
  final int? typeId;

  PendingTransactionModel({
    String? uuid,
    required this.etudiantId,
    required this.quantite,
    required this.typeId,
  }) : uuid = uuid ?? DateTime.now().millisecondsSinceEpoch.toString();
  // ✅ unique timestamp string

  /// Factory to build from JSON
  factory PendingTransactionModel.fromJson(Map<String, dynamic> json) {
    return PendingTransactionModel(
      uuid: json['uuid'],
      etudiantId: json['etudiant_id'],
      quantite: json['quantite'],
      typeId: json['type_id'],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'etudiant_id': etudiantId,
      'quantite': quantite,
      'type_id': typeId,
    };
  }

  /// API body (without uuid)
  Map<String, dynamic> toApiBody() {
    return {
      'etudiant_id': etudiantId,
      'quantite': quantite,
      'type_id': typeId,
    };
  }
}
