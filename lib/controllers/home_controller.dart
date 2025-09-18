import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salam_agent/main.dart';
import 'package:salam_agent/models/student_model.dart';
import 'package:salam_agent/models/transaction_model.dart';
import 'package:salam_agent/models/user_model.dart';
import 'package:salam_agent/routes/routes.dart';
import 'package:salam_agent/utilities/constant.dart';
import 'package:salam_agent/utilities/file_helper.dart';
import 'package:salam_agent/utilities/snack_alerts.dart';
import 'package:salam_agent/utilities/sync_dialog.dart';

import '../models/mode_model.dart';
import '../models/repas_model.dart';
import '../models/restaurant_model.dart';
import '../utilities/shared_preferences.dart';
import 'helper_controller.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';

class HomeController extends GetxController {
  final hlp_c = Get.find<HelperController>();
  var name;
  var user = Rxn<User>();
  var selectedRestaurant = Rxn<Restaurant>();
  var selectedRepas = Rxn<Repas>();
  var selectedMode = Rxn<Mode>();
  var displayStudentImage = false.obs;
  var isEntreeSelected = false.obs; // Observable for "entree" mode
  var count = RxInt(0);

  @override
  Future<void> onInit() async {
    super.onInit();
    name = hlp_c.user.value?.nomComplet;
    print(name);

    await loadUserData();
    await loadSavedConfig();

    count.value = await SharedPref.getCounter();

    final List<ConnectivityResult> connectivityResult =
        await (Connectivity().checkConnectivity());
    if (!connectivityResult.contains(ConnectivityResult.none)) {
      if (navigatorKey.currentContext != null) {
        syncPendingTransactionsWithoutLoad(navigatorKey.currentContext!);
      }
    }
  }

  Future<void> loadSavedConfig() async {
    try {
      selectedRepas.value = hlp_c.savedRepas != null
          ? Repas.fromJson(json.decode(hlp_c.savedRepas))
          : null;

      selectedMode.value = hlp_c.savedMode != null
          ? Mode.fromJson(json.decode(hlp_c.savedMode))
          : null;

      displayStudentImage.value = hlp_c.savedDisplayImage ?? false;
      isEntreeSelected.value = selectedMode.value?.type == "entree";
      print("congif home=${isEntreeSelected.value}");
      print(selectedMode.value?.type);
    } catch (e) {
      print('Error loading config: $e');
    }
  }

  Future<void> loadUserData() async {
    user.value = hlp_c.user.value;

    if (user.value == null) {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  Future<void> logout() async {
    bool? confirmLogout = await Get.dialog(
      AlertDialog(
        title: Text("Êtes-vous sûr ?"),
        content: Text("Voulez-vous vraiment vous déconnecter ?"),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(result: false);
            },
            child: Text("Annuler"),
          ),
          TextButton(
            onPressed: () {
              Get.back(result: true);
            },
            child: Text("Se déconnecter"),
          ),
        ],
      ),
    );

    if (confirmLogout == true) {
      await SharedPref.clear();
      Get.offAllNamed(AppRoutes.login);
    }
  }

  Future<void> toggleMode() async {
    if (isEntreeSelected.value) {
      selectedMode.value = Mode(id: 2, type: "controle");
    } else {
      selectedMode.value = Mode(id: 1, type: "entree");
    }
    isEntreeSelected.value = !isEntreeSelected.value;

    await setMode();
  }

  Future<void> setMode() async {
    print("hom con = ${selectedMode.value!.type}");
    await SharedPref.setMode(selectedMode.value);
    await hlp_c.loadSavedConfig();
    await loadSavedConfig();
  }

  Future<void> syncPendingTransactions(BuildContext context) async {
    showSyncDialog(context); // show loading dialog

    String message = 'Sync completed!';

    final authtoken = await SharedPref.getAuthToken();
    if (authtoken == null) {
      hideDialog(context);
      SnackbarUtils.showError("Token missing. Cannot sync transactions.");
      return;
    }

    final String apiUrl = BaseUrl + '/transaction';
    final Map<String, String> headers = {
      'Authorization': 'Bearer $authtoken',
      'Content-Type': 'application/json',
    };

    final pendingList = await SharedPref.getPendingSyncTrans();

    if (pendingList.isEmpty) {
      hideDialog(context);
      SnackbarUtils.showSuccess("No pending transactions to sync.");
      return;
    }

    for (final txn in pendingList) {
      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: headers,
          body: json.encode(txn.toApiBody()),
        );

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          if (responseData['success'] == true) {
            await SharedPref.deletePendingSyncTrans(txn.uuid);
          }
        }
      } catch (e) {
        message = 'Something gone wrong';
        print("Error syncing txn ${txn.uuid}: $e");
      }
    }

    hideDialog(context);
    if (message == 'Something gone wrong') {
      SnackbarUtils.showError(message);
    } else {
      SnackbarUtils.showSuccess(message);
    }

    getTransactions();
  }

  Future<void> syncPendingTransactionsWithoutLoad(BuildContext context) async {
    final authtoken = await SharedPref.getAuthToken();
    if (authtoken == null) {
      return;
    }

    final String apiUrl = BaseUrl + '/transaction';
    final String apiUrl2 = BaseUrl + '/get-transacion-data';

    final Map<String, String> headers = {
      'Authorization': 'Bearer $authtoken',
      'Content-Type': 'application/json',
    };

    final pendingList = await SharedPref.getPendingSyncTrans();

    if (pendingList.isEmpty) {
      return;
    }

    for (final txn in pendingList) {
      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: headers,
          body: json.encode(txn.toApiBody()),
        );

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          if (responseData['success'] == true) {
            await SharedPref.deletePendingSyncTrans(txn.uuid);
          }
        }
      } catch (e) {
        print("Error syncing txn ${txn.uuid}: $e");
      }
    }

    final response = await http.get(Uri.parse(apiUrl2), headers: headers);

    var responseData = json.decode(response.body);
    if (responseData['success']) {
      final studentsJson = responseData['data']['student_list'] as List;

      final students = await Future.wait(studentsJson.map((e) async {
        final student = Student.fromJson(e);

        if (student.photo.isNotEmpty && student.photo.startsWith("http")) {
          final fileName = "student_${student.id}.png";
          final localPath =
              await FileHelper.downloadImage(student.photo, fileName);
          if (localPath != null) {
            student.photo = localPath;
          }
        }

        return student;
      }));

      await SharedPref.deleteStudentsList();
      await SharedPref.saveStudents(students);

      final transactionsJson = responseData['data']['transactions'] as List;
      final transactions =
          transactionsJson.map((e) => TransactionModel.fromJson(e)).toList();
      await SharedPref.deleteTransactions();
      await SharedPref.saveTransactions(transactions);
    }
  }

  Future<void> getTransactions() async {
    final authtoken = await SharedPref.getAuthToken();
    if (authtoken == null) {
      SnackbarUtils.showError("Token missing. Cannot sync transactions.");
      return;
    }

    final String apiUrl = BaseUrl + '/get-transacion-data';
    final Map<String, String> headers = {
      'Authorization': 'Bearer $authtoken',
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.get(Uri.parse(apiUrl), headers: headers);

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        if (responseData['success']) {
          final studentsJson = responseData['data']['student_list'] as List;

          final students = await Future.wait(studentsJson.map((e) async {
            final student = Student.fromJson(e);

            if (student.photo.isNotEmpty && student.photo.startsWith("http")) {
              final fileName = "student_${student.id}.png";
              final localPath =
                  await FileHelper.downloadImage(student.photo, fileName);
              if (localPath != null) {
                student.photo = localPath;
              }
            }

            return student;
          }));

          await SharedPref.deleteStudentsList();
          await SharedPref.saveStudents(students);

          final transactionsJson = responseData['data']['transactions'] as List;
          final transactions = transactionsJson
              .map((e) => TransactionModel.fromJson(e))
              .toList();
          await SharedPref.deleteTransactions();
          await SharedPref.saveTransactions(transactions);
        } else {
          SnackbarUtils.showError(login_failed);
        }
      } else {
        SnackbarUtils.showError("Error: ${response.statusCode}");
      }
    } catch (e) {
      print(e);

      SnackbarUtils.showError(something_went_wrong);
    } finally {}
  }

  void hideDialog(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  void scanner() {
    int type = 0;
    if (isEntreeSelected.value) {
      type = 0;
    } else {
      type = 1;
    }
    Get.toNamed(AppRoutes.scan, arguments: {'type': type});
  }

  void profile() {
    Get.toNamed(AppRoutes.profile);
  }

  void config() {
    Get.toNamed(AppRoutes.config);
  }

  void trans() {
    Get.toNamed(AppRoutes.trans);
  }
}
