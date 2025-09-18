import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../models/response_transaction_model.dart';
import '../models/student_model.dart';
import '../models/transaction_model.dart';
import '../utilities/constant.dart';
import '../utilities/shared_preferences.dart';
import '../utilities/snack_alerts.dart';
import 'home_controller.dart';

class VerificationController extends GetxController {
  final hc = Get.find<HomeController>();
  var transactions = <TransactionModel>[].obs; // Reactive list for transactions
  var res = Rxn<ResponseTransactionModel>();
  late final String qrdata;
  var isLoading = false
      .obs; // For showing loading indicator during QR validation and data fetching
  var isSubmitting = false.obs; // To manage submit button state
  var sm = Rxn<Student>(); // Holds student data
  var errorText = RxnString();
  var isQRCodeValidated = false.obs;
  late String type;

  @override
  Future<void> onInit() async {
    super.onInit();
    qrdata = Get.arguments['qrdata'] ?? "";
    print(qrdata);
  }

  Future<void> validateQRCode() async {
    if (isQRCodeValidated.value) return; // Prevent multiple validation calls

    print("QR DATA RECEIVED: $qrdata");

    if (qrdata.isEmpty) {
      print("Error: QR code is empty.");
      Get.defaultDialog(
        title: "Invalid QR Code",
        middleText: "The provided QR code is empty.",
        onConfirm: () => Get.back(),
        textConfirm: "OK",
      );
      return;
    }

    if (!qrdata.startsWith("\$2y\$10")) {
      print("Error: QR code does not have the required prefix.");
      Get.defaultDialog(
        title: "Invalid QR Code",
        middleText: "The provided QR code format is invalid.",
        onConfirm: () => Get.back(),
        textConfirm: "OK",
      );
      return;
    }

    print("QR code is valid. Proceeding to fetch student data...");
    await loadTransactions();
  }

  Future<void> loadTransactions() async {
    isLoading.value = true;

    final authtoken = await SharedPref.getAuthToken();
    final selectedRepas = hc.selectedRepas.value;

    if (authtoken == null) {
      SnackbarUtils.showError("Token is missing");
      isLoading.value = false;
      return;
    }

    if (selectedRepas == null) {
      SnackbarUtils.showError("No repas selected");
      isLoading.value = false;
      return;
    }

    final String apiUrl = BaseUrl + '/verification';
    final Map<String, String> headers = {
      'Authorization': 'Bearer $authtoken',
    };

    final Map<String, String> queryParams = {
      'type': selectedRepas.id.toString(),
      'identification': qrdata, // make sure backend expects this exact key
    };

    log(queryParams.toString(), name: 'loadTransactions');

    final uri = Uri.parse(apiUrl).replace(queryParameters: queryParams);

    try {
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print(responseData["data"]);

        res.value = ResponseTransactionModel.fromJson(responseData["data"]);
        transactions = res.value!.transactions;

        sm.value = Student.fromJson(responseData["data"]["etudiant"]);
      } else {
        log(response.body, name: 'API Error Response');
        SnackbarUtils.showError("Failed to fetch data");
      }
    } catch (e, st) {
      log("An exception occurred: $e", name: 'loadTransactions');
      log(st.toString(), name: 'StackTrace');

      // Offline fallback
      final localStudents = await SharedPref.getStudents();
      if (localStudents.isNotEmpty) {
        for (final student in localStudents) {
          if (student.identification == qrdata) {
            sm.value = student;

            final localTransactions = await SharedPref.getTransactions();
            transactions.clear();
            transactions.addAll(
              localTransactions.where(
                (t) =>
                    t.identifiant.value == student.identification &&
                    t.type.value!.libelle == selectedRepas.libelle,
              ),
            );
          }
        }
      }
    } finally {
      isLoading.value = false;
      isQRCodeValidated.value = true;
    }
  }

  @override
  void onClose() {
    transactions.close();
    super.onClose();
  }
}
