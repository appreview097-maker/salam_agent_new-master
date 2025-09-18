import 'package:get/get.dart';

import 'transaction_model.dart';
import 'user_model.dart';

class ResponseTransactionModel {
  // Reactive fields
  final RxList<TransactionModel> transactions;


  // Constructor
  ResponseTransactionModel({
    required List<TransactionModel> transactions,

  })  : transactions = RxList(transactions);

  // Factory method for JSON parsing
  factory ResponseTransactionModel.fromJson(Map<String, dynamic> json) {
    return ResponseTransactionModel(
      transactions: (json["transactions"] is List)
          ? (json["transactions"] as List)
          .map((item) => TransactionModel.fromJson(item))
          .toList()
          : <TransactionModel>[],
    );
  }


}

