import 'dart:convert';
import 'dart:developer';
import 'dart:math' as mt;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:salam_agent/models/student_model.dart';
import 'package:salam_agent/models/transaction_model.dart';
import 'package:salam_agent/models/type_model.dart';

import '../utilities/constant.dart';
import '../utilities/shared_preferences.dart';
import '../utilities/snack_alerts.dart';
import 'home_controller.dart';

class PaymentController extends GetxController {
  final hc = Get.find<HomeController>();
  var isLoading = false
      .obs; // For showing loading indicator during QR validation and data fetching
  var isSubmitting = false.obs; // To manage submit button state
  late final String qrdata;
  var sm = Rxn<Student>(); // Holds student data

  var errorText = RxnString();
  var isQRCodeValidated =
      false.obs; // Flag to check if QR code has been validated

  @override
  Future<void> onInit() async {
    super.onInit();
    // Retrieve the QR code from the arguments
    qrdata = Get.arguments['qrdata'] ?? "";
    log('MyLog1');
    log(qrdata);
  }

  // Validate QR code and fetch student data
  Future<void> validateQRCode() async {
    if (isQRCodeValidated.value) return; // Prevent multiple validation calls

    log('MyLog2');
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
    await fetchStudentData();
  }

  // Fetch student data from the API
  Future<void> fetchStudentData() async {
    isLoading.value = true; // Start loading when fetching student data
    var authtoken = await SharedPref.getAuthToken();
    print(authtoken);

    if (authtoken == null) {
      SnackbarUtils.showError("Authentication token is missing.");
      isLoading.value = false;
      return;
    }

    final String apiUrl = BaseUrl + '/etudiant';
    final Uri apiUri = Uri.parse('$apiUrl?identifiant=$qrdata');
    print("api=$apiUri");
    final Map<String, String> headers = {
      'Authorization': 'Bearer $authtoken',
    };

    try {
      final response = await http.get(apiUri, headers: headers);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print(responseData);

        if (responseData['success'] == true && responseData['data'] != null) {
          sm.value = Student.fromJson(responseData["data"]);
        } else {
          SnackbarUtils.showError("Student data not found.");
          sm.value = null;
        }
      } else {
        SnackbarUtils.showError(
            "Error: Unable to fetch data. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      SharedPref.getStudents().then(
        (students) {
          students.forEach((student) {
            if (student.identification == qrdata) {
              sm.value = student;
            }
          });
        },
      );
      print("An error occurred: $e");
      // SnackbarUtils.showError("An error occurred:$e");
    } finally {
      isLoading.value = false;
      isQRCodeValidated.value = true;
    }
  }

// Confirms the payment (submit action)
  Future<void> confirmPayment(context) async {
    isSubmitting.value =
        true; // Start showing loading indicator for submit button
    var authtoken = await SharedPref.getAuthToken();
    var repas = hc.selectedRepas.value!.id;

    if (authtoken == null) {
      SnackbarUtils.showError(auth_token_missing);
      isSubmitting.value = false; // Stop showing indicator on error
      return;
    }

    final String apiUrl = BaseUrl + '/transaction';
    final Map<String, String> headers = {
      'Authorization': 'Bearer $authtoken',
      'Content-Type': 'application/json',
    };

    final Map<String, dynamic> body = {
      'etudiant_id': sm.value?.id,
      'quantite': 1,
      'type_id': repas,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: json.encode(body),
      );

      log(repas.toString(), name: 'repas');
      log(sm.value!.id.toString(), name: 'sm.value?.id');
      log(response.body.toString(), name: 'ConfirmPayment');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          //Get.offNamed(AppRoutes.payment);
          await SharedPref.incrementCounter();
          hc.count.value++;
          SnackbarUtils.showSuccess(responseData['message']);
          await Future.delayed(Duration(seconds: 1));
          Navigator.pop(context);
          // Optional delay to let the Snackbar display
        } else {
          SnackbarUtils.showError(something_went_wrong);
        }
      } else {
        SnackbarUtils.showError("Failed");
      }
    } catch (e) {
      SharedPref.addPendingSyncTrans(PendingTransactionModel(
              etudiantId: sm.value?.id, quantite: 1, typeId: repas))
          .then(
        (value) async {
          final updatedStudent = sm.value!.copyWith(
            solde: sm.value!.solde - hc.selectedRepas.value!.montant,
          );
          await SharedPref.updateStudent(updatedStudent);
          final updatedTransaction = TransactionModel(
            id: generateRandomId(),
            date: DateTime.now().toString(),
            identifiant: qrdata,
            montant: hc.selectedRepas.value!.montant.toString(),
            quantite: 1,
            reference: 'offline mode',
            repas: hc.selectedRepas.value!.libelle,
            type: TypeModel(
                id: hc.selectedRepas.value!.id,
                libelle: hc.selectedRepas.value!.libelle,
                color: '',
                montant: hc.selectedRepas.value!.montant),
          );
          await SharedPref.addTransaction(updatedTransaction);
          await SharedPref.incrementCounter();
          hc.count.value++;

          SnackbarUtils.showSuccess('Transaction added to pending list');
          await Future.delayed(Duration(seconds: 1));
          Navigator.pop(context);
        },
      );
    } finally {
      isSubmitting.value = false; // Stop loading after submission
    }
  }

  int generateRandomId() {
    final random = mt.Random();
    return 1000 + random.nextInt(9000); // gives 1000–9999
  }
}
