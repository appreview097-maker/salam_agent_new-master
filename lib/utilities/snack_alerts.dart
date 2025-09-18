import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SnackbarUtils {
  /// Show success snackbar
  static void showSuccess(String message) {
    Get.snackbar(
      "Success",
      message,
      backgroundColor: Colors.green, // Green background for success
      colorText: Colors.white, // White text for contrast
      snackPosition: SnackPosition.BOTTOM, // Position at the bottom
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      borderRadius: 8,
      duration: Duration(seconds: 3), // Automatically dismiss after 3 seconds
      icon: Icon(Icons.check_circle, color: Colors.white), // Optional icon
    );
  }

  /// Show error snackbar
  static void showError(String message) {
    Get.snackbar(
      "Error",
      message,
      backgroundColor: Colors.red, // Red background for errors
      colorText: Colors.white, // White text for contrast
      snackPosition: SnackPosition.BOTTOM, // Position at the bottom
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      borderRadius: 8,
      duration: Duration(seconds: 3), // Automatically dismiss after 3 seconds
      icon: Icon(Icons.error, color: Colors.white), // Optional icon
    );
  }
}