import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/login_controller.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';

class LoginPage extends StatelessWidget {
  final LoginController controller = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return PopScope(
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: size.height * 0.3,
                child: Image.asset("images/plat.jpeg"),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(226, 221, 213, 213),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 25),
                          child: Column(
                            children: [
                              Text(
                                'Salam Agent',
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Login',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.normal,
                                  //color: Colors.grey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: size.width * 0.9,
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 3),
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Matricule',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ),
                              TextField(
                                controller: controller.matriculeController,
                                decoration: InputDecoration(
                                  isDense: true,
                                  hintText: "Votre matricule identifiant",
                                  errorText: controller.matriculeError.isNotEmpty
                                      ? controller.matriculeError.value
                                      : null, // Error handling
                                ),
                              ),
                              SizedBox(height: 16),

                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Mot de Passe',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Obx(() => TextField(
                                controller: controller.passwordController,
                                obscureText: !controller.isPasswordVisible.value,
                                decoration: InputDecoration(
                                  isDense: true,
                                  hintText: "Mot de Passe",
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      controller.isPasswordVisible.value
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      controller.togglePasswordVisibility();
                                    },
                                  ),
                                  errorText: controller.passwordError.isNotEmpty
                                      ? controller.passwordError.value
                                      : null,
                                ),
                              )),
                              SizedBox(height: 16),

                              Container(
                                width: size.width * 0.8,
                                decoration: BoxDecoration(
                                  color: const Color(0xff233743),
                                  borderRadius: BorderRadius.circular(26),
                                ),
                                child: Obx(() => TextButton(
                                  onPressed: controller.isLoading.value
                                      ? null
                                      : () {

                                    controller.login();

                                  },
                                  child: controller.isLoading.value
                                      ? CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                      : Text(
                                    "Se connecter",
                                    style: const TextStyle(color: Colors.white, fontSize: 20),
                                  ),
                                )),
                              ),

                              SizedBox(height: 16),

                              GestureDetector(
                                onTap: () {
                                 controller.fpstepone();
                                },
                                child: Container(
                                  width: size.width * 0.8,
                                  child: Center(
                                    child: Text(
                                      "Retrouver Mot de passe",
                                      style: TextStyle(color: Colors.indigoAccent, fontSize: 20),
                                    ),
                                  ),
                                ),
                              ),

                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}