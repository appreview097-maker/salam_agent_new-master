import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:salam_agent/models/student_model.dart';
import 'package:salam_agent/models/transaction_model.dart';
import 'package:salam_agent/routes/routes.dart';
import 'package:salam_agent/utilities/file_helper.dart';

import '../utilities/constant.dart';
import '../utilities/shared_preferences.dart';
import '../utilities/snack_alerts.dart';

class LoginController extends GetxController {
  // Controllers for form fields
  final matriculeController = TextEditingController();
  final passwordController = TextEditingController();

  // Reactive variables for UI binding (only for loading, error, etc.)
  var isLoading = false.obs;
  var matriculeError = ''.obs; // For Matricule specific error
  var passwordError = ''.obs; // For Password specific error
  var authToken = ''.obs;
  var isPasswordVisible = false.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  // Function to validate matricule (username)
  String? validateMatricule(String matricule) {
    if (matricule.isEmpty) {
      return "Matricule cannot be empty";
    }
    return null; // No error
  }

  // Function to validate password
  String? validatePassword(String password) {
    if (password.isEmpty) {
      return "Password cannot be empty";
    } else if (password.length < 5) {
      return "Password must be at least 5 characters long";
    }
    return null; // No error
  }

  // Function to handle login
  Future<void> login() async {
    String matricule = matriculeController.text.trim();
    String password = passwordController.text.trim();

    // Validate matricule and password before proceeding
    matriculeError.value = validateMatricule(matricule) ?? '';
    passwordError.value = validatePassword(password) ?? '';

    // If there are any validation errors, do not proceed
    if (matriculeError.isNotEmpty || passwordError.isNotEmpty) {
      return;
    }

    isLoading.value = true;

    final String apiUrl = BaseUrl + '/login'; // Replace with your API URL
    final Map<String, String> data = {
      'matricule': matricule,
      'password': password,
    };

    try {
      final response = await http.post(Uri.parse(apiUrl), body: data);

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        if (responseData['success']) {
          // You can store user info in shared preferences here
          await SharedPref.saveAuthToken(responseData['data']['token']);
          await SharedPref.saveUserData(responseData['data']['user']);

          final studentsJson = responseData['data']['student_list'] as List;

          final students = await Future.wait(studentsJson.map((e) async {
            final student = Student.fromJson(e);

            if (student.photo.isNotEmpty &&
                student.photo.startsWith("http")) {
              final fileName = "student_${student.id}.png";
              final localPath = await FileHelper.downloadImage(
                  student.photo, fileName);
              if (localPath != null) {
                student.photo = localPath;
              }
            }

            return student;
          }));

          await SharedPref.saveStudents(students);

          final transactionsJson =
              responseData['data']['transactions'] as List;
          final transactions = transactionsJson
              .map((e) => TransactionModel.fromJson(e))
              .toList();
          await SharedPref.saveTransactions(transactions);

          Get.offAllNamed(AppRoutes.config);
        } else {
          SnackbarUtils.showError(login_failed);
        }
      } else {
        SnackbarUtils.showError("Error: ${response.statusCode}");
      }
    } catch (e) {
      print(e);

      SnackbarUtils.showError(something_went_wrong);
    } finally {
      isLoading.value = false;
    }
  }

  void fpstepone() {
    Get.toNamed(AppRoutes.fpso);
  }
}
