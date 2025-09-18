import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../controllers/config_controller.dart';

class ConfigPage extends StatelessWidget {
  final ConfigController controller = Get.put(ConfigController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Form key

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: const Text(
          "Configuration Restaurant",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(
          color: Colors.white, // Back button color
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        // Check the loading state
        if (!controller.isLoading.value &&
            controller.restaurants.isEmpty &&
            controller.repas.isEmpty &&
            controller.mode.isEmpty) {
          return Center(
            child: Text(
              "No configuration available. Please connect to the internet.",
              style: TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          );
        }

        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 80, // Adjust the size of the CircularProgressIndicator
                  height: 80,
                  child: CircularProgressIndicator(
                    strokeWidth: 6.0, // Thickness of the progress indicator
                    color: Colors.indigo, // Progress indicator color
                  ),
                ),
                const SizedBox(height: 16), // Space between indicator and text
                const Text(
                  "Please Wait. Getting Prepared...",
                  style: TextStyle(
                    fontSize: 18, // Larger font size
                    fontWeight: FontWeight.bold,
                    color: Colors.grey, // Text color
                  ),
                ),
              ],
            ),
          );
        }

        // Render the form if not loading
        return Padding(
          padding: const EdgeInsets.all(16.0), // General page padding
          child: Form(
            key: _formKey, // Assign the form key here
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              // Align items from top
              children: [
                // Label and Restaurant Dropdown
                const Text(
                  'Select Restaurant',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => DropdownButtonFormField<int>(
                    value: controller.selectedRestaurant.value?.id,
                    // Bind selected value
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      errorStyle: const TextStyle(
                        fontSize: 12,
                        color: Colors.red,
                      ),
                    ),
                    items: controller.restaurants
                        .map(
                          (restaurant) => DropdownMenuItem<int>(
                            value: restaurant.id,
                            child: Text(restaurant.libelle),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      controller.selectedRestaurant.value = controller
                          .restaurants
                          .firstWhere((restaurant) => restaurant.id == value);
                    },
                    validator: (value) =>
                        value == null ? 'Please select a restaurant' : null,
                  ),
                ),

                const SizedBox(height: 20),

                // Label and Repas Dropdown
                const Text(
                  'Select Repas',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => DropdownButtonFormField<int>(
                    value: controller.selectedRepas.value?.id,
                    // Bind selected value
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      errorStyle: const TextStyle(
                        fontSize: 12,
                        color: Colors.red,
                      ),
                    ),
                    items: controller.repas
                        .map(
                          (repas) => DropdownMenuItem<int>(
                            value: repas.id,
                            child: Text(repas.libelle),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      controller.selectedRepas.value = controller.repas
                          .firstWhere((repas) => repas.id == value);
                    },
                    validator: (value) =>
                        value == null ? 'Please select a repas' : null,
                  ),
                ),

                const SizedBox(height: 30),

                // Label and Mode Dropdown
                const Text(
                  'Select Mode',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => DropdownButtonFormField<int>(
                    value: controller.selectedMode.value?.id,
                    // Bind selected value
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      errorStyle: const TextStyle(
                        fontSize: 12,
                        color: Colors.red,
                      ),
                    ),
                    items: controller.mode
                        .map(
                          (mode) => DropdownMenuItem<int>(
                            value: mode.id,
                            child: Text(mode.type),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      controller.selectedMode.value = controller.mode
                          .firstWhere((mode) => mode.id == value);
                    },
                    validator: (value) =>
                        value == null ? 'Please select a Mode' : null,
                  ),
                ),

                const SizedBox(height: 30),

                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.scale(
                      scale: 2.0,
                      // Change scale value to adjust the size of the checkbox
                      child: Checkbox(
                        value: controller.displayStudentImage.value,
                        onChanged: (value) {
                          controller.displayStudentImage.value = value!;
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    // Add some space between the checkbox and the label
                    Text(
                      'Display Student Image',
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),

                // Submit Button
                SizedBox(
                  width: double.infinity, // Button width full
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo, // Button background color
                      foregroundColor: Colors.white, // Text color
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            8), // Slightly rounded corners
                      ),
                    ),
                    onPressed: () {
                      // Validate the form
                      if (_formKey.currentState!.validate()) {
                        // Call your server and handle the response
                        controller.proceed();
                      }
                    },
                    child: const Text(
                      "Sauver",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
