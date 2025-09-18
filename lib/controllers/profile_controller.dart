import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../routes/routes.dart';
import '../utilities/constant.dart';
import '../utilities/shared_preferences.dart';
import '../utilities/snack_alerts.dart';

class ProfileController extends GetxController {
  var oldPasswordController = TextEditingController();
  var newPasswordController = TextEditingController();
  var confirmPasswordController = TextEditingController();

  var isPasswordVisible = false.obs;
  var isLoading = false.obs;

  var oldPasswordError = false.obs;
  var newPasswordError = false.obs;
  var confirmPasswordError = false.obs;

  // Method to toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  // Method to validate fields before sending data to API
  bool validateFields() {
    bool isValid = true;

    if (oldPasswordController.text.isEmpty) {
      oldPasswordError.value = true;
      isValid = false;
    } else {
      oldPasswordError.value = false;
    }

    if (newPasswordController.text.isEmpty || newPasswordController.text.length < 5) {
      newPasswordError.value = true;
      isValid = false;
    } else {
      newPasswordError.value = false;
    }

    if (confirmPasswordController.text.isEmpty || confirmPasswordController.text != newPasswordController.text) {
      confirmPasswordError.value = true;
      isValid = false;
    } else {
      confirmPasswordError.value = false;
    }

    return isValid;
  }

  // Method to update password via API
  Future<void> updatePassword() async {
    if (!validateFields()) {
      return;
    }

    try {
      isLoading.value = true;

      // Assume the token is fetched from somewhere (e.g., shared preferences)
      var token = await SharedPref.getAuthToken(); // Replace with actual token

      var url = Uri.parse(BaseUrl + '/update-password');
      var headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/x-www-form-urlencoded',
      };

      var response = await http.post(url, headers: headers, body: {
        'current_pwd': oldPasswordController.text,
        'new_pwd': newPasswordController.text,
        'confirm_pwd': confirmPasswordController.text,
      });

      isLoading.value = false;

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['success'] == true) {
          SnackbarUtils.showSuccess(data['message']);

          // Clear fields after success
          oldPasswordController.clear();
          newPasswordController.clear();
          confirmPasswordController.clear();
        } else {
          SnackbarUtils.showError(data['message']);
        }
      } else {
        SnackbarUtils.showError('Something went wrong. Please try again!');
      }
    } catch (e) {
      isLoading.value = false;
      SnackbarUtils.showError(e.toString());
    }
  }


}

