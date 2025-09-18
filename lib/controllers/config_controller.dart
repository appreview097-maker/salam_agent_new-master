import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../models/mode_model.dart';
import '../models/repas_model.dart';
import '../models/restaurant_model.dart';
import '../routes/routes.dart';
import '../utilities/constant.dart';
import '../utilities/shared_preferences.dart';
import '../utilities/snack_alerts.dart';
import 'helper_controller.dart';

class ConfigController extends GetxController {
  final hlp_c = Get.find<HelperController>();
  var restaurants = <Restaurant>[].obs;
  var repas = <Repas>[].obs;
  var mode = <Mode>[].obs;
  var selectedRestaurant = Rxn<Restaurant>();
  var selectedRepas = Rxn<Repas>();
  var selectedMode = Rxn<Mode>();
  var displayStudentImage = false.obs;
  var isLoading = true.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadDropdownData();
    loadSavedConfig();
  }

  Future<void> loadSavedConfig() async {
    try {
      final savedRestaurant =
          await SharedPref.getConfigValue('selectedRestaurant');
      final savedRepas = await SharedPref.getConfigValue('selectedRepas');
      final savedMode = await SharedPref.getConfigValue('selectedMode');
      final savedDisplayImage =
          await SharedPref.getConfigDisplay('displayImage');

      if (savedRestaurant != null) {
        selectedRestaurant.value =
            Restaurant.fromJson(json.decode(savedRestaurant));
        print(selectedRestaurant.value!.libelle);
      }
      if (savedRepas != null) {
        selectedRepas.value = Repas.fromJson(json.decode(savedRepas));
      }
      if (savedMode != null) {
        selectedMode.value = Mode.fromJson(json.decode(savedMode));
      }
      if (savedDisplayImage != null) {
        displayStudentImage.value = savedDisplayImage;
      }
    } catch (e) {
      SnackbarUtils.showError("Failed to load configuration.");
    }
  }

  Future<void> loadDropdownData() async {
    final String apiUrl = BaseUrl + '/restaurants';
    try {
      isLoading.value = true;

      // Retrieve token from Shared Preferences
      String? token = await SharedPref.getAuthToken();
      if (token == null) {
        throw Exception("User not authenticated");
      }

      // Make API call
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      // Handle API response
      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        if (responseData['success']) {
          var restaurantData = (responseData['data']['restaurant'] as List)
              .map((e) => Restaurant.fromJson(e))
              .toList();

          var repasData = (responseData['data']['repas'] as List)
              .map((e) => Repas.fromJson(e))
              .toList();

          var modeData = (responseData['data']['mode'] as List)
              .map((e) => Mode.fromJson(e))
              .toList();

          restaurants.assignAll(restaurantData);
          repas.assignAll(repasData);
          mode.assignAll(modeData);

          await SharedPref.saveRestaurants(restaurantData);
          await SharedPref.saveRepas(repasData);
          await SharedPref.saveModes(modeData);

          await SharedPref.getConfigValue('selectedRestaurant');

          return; // ✅ exit after success
        } else {
          throw Exception(something_went_wrong);
        }
      } else {
        throw Exception("Error: ${response.statusCode}");
      }
    } catch (e) {
      errorMessage.value = e.toString();

      // 🔹 Try to load local config if internet fails
      final savedRestaurant =
          await SharedPref.getConfigValue('selectedRestaurant');
      final savedRepas = await SharedPref.getConfigValue('selectedRepas');
      final savedMode = await SharedPref.getConfigValue('selectedMode');

      restaurants.assignAll(await SharedPref.getRestaurants());
      repas.assignAll(await SharedPref.getRepasList());
      mode.assignAll(await SharedPref.getModes());

      if (savedRestaurant != null && savedRepas != null && savedMode != null) {
        // At least load saved values so user can proceed
        selectedRestaurant.value =
            Restaurant.fromJson(json.decode(savedRestaurant));
        selectedRepas.value = Repas.fromJson(json.decode(savedRepas));
        selectedMode.value = Mode.fromJson(json.decode(savedMode));
      } else {
        // ❌ No internet and no local data
        SnackbarUtils.showError(
            "No internet and no local configuration found.");
      }
    } finally {
      isLoading.value = false;
    }
  }

  bool validateSelections() {
    if (selectedRestaurant.value == null ||
        selectedRepas.value == null ||
        selectedMode.value == null) {
      return false;
    }
    return true;
  }

  Future<void> proceed() async {
    validateSelections();

    // Save selected models and checkbox value
    await SharedPref.setConfig(
      selectedRestaurant: selectedRestaurant.value,
      selectedRepas: selectedRepas.value,
      selectedMode: selectedMode.value,
      displayImage: displayStudentImage.value,
    );
    await SharedPref.resetCounter();
    hlp_c.loadSavedConfig();
    hlp_c.loaduserinfo();
    Get.offAllNamed(AppRoutes.home);
  }
}
