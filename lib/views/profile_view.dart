import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


import 'package:get/get.dart';

import '../controllers/home_controller.dart';
import '../controllers/profile_controller.dart';

class ProfilePage extends StatelessWidget {
  final ProfileController controller = Get.put(ProfileController());
  final HomeController hc = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profile",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.indigo,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.indigo,
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    child: Text(
                      hc.user.value!.nomComplet,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  Container(
                    width: double.infinity,
                    child: Text(
                      '@' + hc.user.value!.matricule,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  Container(
                    width: double.infinity,
                    child: Text(
                      hc.user.value!.role,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.indigo,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),

            // Password Change Section
            Text(
              "Change Password",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            SizedBox(height: 15),
            Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Old Password Field
                TextField(
                  controller: controller.oldPasswordController,
                  obscureText: !controller.isPasswordVisible.value,
                  decoration: InputDecoration(
                    labelText: "Old Password",
                    errorText: controller.oldPasswordError.value ? "Old password is required" : null,
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(controller.isPasswordVisible.value ? Icons.visibility : Icons.visibility_off),
                      onPressed: controller.togglePasswordVisibility,
                    ),
                  ),
                ),
                SizedBox(height: 15),
                // New Password Field
                TextField(
                  controller: controller.newPasswordController,
                  obscureText: !controller.isPasswordVisible.value,
                  decoration: InputDecoration(
                    labelText: "New Password",
                    errorText: controller.newPasswordError.value ? "Password must be at least 5 characters" : null,
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(controller.isPasswordVisible.value ? Icons.visibility : Icons.visibility_off),
                      onPressed: controller.togglePasswordVisibility,
                    ),
                  ),
                ),
                SizedBox(height: 15),
                // Confirm New Password Field
                TextField(
                  controller: controller.confirmPasswordController,
                  obscureText: !controller.isPasswordVisible.value,
                  decoration: InputDecoration(
                    labelText: "Confirm Password",
                    errorText: controller.confirmPasswordError.value ? "Passwords do not match" : null,
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(controller.isPasswordVisible.value ? Icons.visibility : Icons.visibility_off),
                      onPressed: controller.togglePasswordVisibility,
                    ),
                  ),
                ),
                SizedBox(height: 25),

                // Update Button (Centered and Styled)
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      controller.updatePassword();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: controller.isLoading.value
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                      "Update Password",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }
}




