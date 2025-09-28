import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salam_agent/controllers/home_controller.dart';

import '../controllers/payment_controller.dart';

class PaymentPage extends StatelessWidget {
  final PaymentController pc = Get.put(PaymentController());

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    if (pc.sm.value == null &&
        !pc.isLoading.value &&
        !pc.isQRCodeValidated.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        pc.validateQRCode();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Payment Page"),
      ),
      body: Obx(() {
        if (pc.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text("Verifying the QR code..."),
              ],
            ),
          );
        }

        if (pc.sm.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Student not found or invalid QR code!",
                    style: TextStyle(color: Colors.red)),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  child: Text("Go Back"),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                child: Column(
                  children: [
                    Obx(() {
                      if (pc.hc.displayStudentImage.value) {
                        return Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black,
                            image: pc.sm.value?.photo != null
                                ? DecorationImage(
                                    image: NetworkImage(pc.sm.value!.photo!),
                                    fit: BoxFit.cover)
                                : null,
                          ),
                        );
                      } else {
                        // Optionally, add a fallback widget here when displayStudentImage is false
                        return Container(); // Return an empty container or any other widget you prefer
                      }
                    }),
                    Text(pc.sm.value?.nomComplet ?? "Unknown",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(pc.sm.value!.role,
                        style: TextStyle(fontStyle: FontStyle.italic)),
                    Text(pc.sm.value!.solde.toString() + " FCFA",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              FutureBuilder<List<ConnectivityResult>>(
                future: Connectivity().checkConnectivity(),
                builder: (context, ccc) {
                  if (!ccc.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return Obx(() {
                    final hasEnoughBalance =
                        pc.hc.selectedRepas.value!.montant <=
                            pc.sm.value!.solde;
                    final noInternet =
                        ccc.data!.contains(ConnectivityResult.none);

                    // if (hasEnoughBalance && noInternet) {
                      return Container(
                        width: size.width * 0.9,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 3),
                        child: Column(
                          children: [
                            const SizedBox(height: 30),
                            ElevatedButton(
                              onPressed: () {
                                pc.confirmPayment(context);
                              },
                              style: ElevatedButton.styleFrom(
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(20),
                                backgroundColor: Colors.green,
                              ),
                              child: pc.isSubmitting.value
                                  ? const CircularProgressIndicator(
                                      color: Colors.white)
                                  : const Icon(Icons.check,
                                      color: Colors.white, size: 120),
                            ),
                          ],
                        ),
                      );
                    // } else {
                    //   return Container(
                    //     width: size.width * 0.9,
                    //     padding: const EdgeInsets.symmetric(
                    //         horizontal: 15, vertical: 3),
                    //     child: Column(
                    //       children: [
                    //         const SizedBox(height: 30),
                    //         ElevatedButton(
                    //           onPressed: () {},
                    //           style: ElevatedButton.styleFrom(
                    //             shape: const CircleBorder(),
                    //             padding: const EdgeInsets.all(20),
                    //             backgroundColor: Colors.red,
                    //           ),
                    //           child: const Icon(Icons.close,
                    //               color: Colors.white, size: 120),
                    //         ),
                    //       ],
                    //     ),
                    //   );
                    // }
                  });
                },
              )
            ],
          ),
        );
      }),
    );
  }
}
