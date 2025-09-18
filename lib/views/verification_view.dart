import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salam_agent/controllers/verification_controller.dart';

import 'shimmer_historique.dart';
import 'transaction_info_view.dart';


class VerificationPage extends StatelessWidget {
  final VerificationController vc = Get.put(VerificationController());

  @override
  Widget build(BuildContext context) {

    if (vc.sm.value == null && !vc.isLoading.value && !vc.isQRCodeValidated.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        vc.validateQRCode();
      });
    }
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            "Verification Page",
            style: TextStyle(color: Colors.white), // Set text color to white
          ),
        ),

        backgroundColor: Colors.indigo, // Set background color to indigo
      ),
      body: Obx((){
        if (vc.isLoading.value) {
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

        if (vc.sm.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Student not found or invalid QR code!", style: TextStyle(color: Colors.red)),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  child: Text("Go Back"),
                ),
              ],
            ),
          );
        }

         return Column(
          children: [
            Container(
              decoration: BoxDecoration(
                  color: Colors.indigo,
                  borderRadius:
                  const BorderRadius.only(bottomRight: Radius.circular(50))),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 15),
                    title: Text(
                      vc.sm.value!.nomComplet,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(color: Colors.white),
                    ),
                    subtitle: Text(
                      vc.sm.value!.matricule,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: Colors.white54),
                    ),
                    trailing: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 65,
                        backgroundImage: NetworkImage(vc.sm.value!.photo),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        ""+vc.sm.value!.solde.toString(),
                        style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                            color: Colors.white),
                      ),
                      Text(
                        " FCFA",
                        style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                            color: Colors.white),
                      )
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 30),
            // Start of HomePage Body
            Expanded(
              child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25),
                          topRight: Radius.circular(25))),
                  child: Column(
                    children: [
                      Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20, top: 10),
                            child: Text(
                              "Repas:"+vc.hc.selectedRepas.value!.libelle,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo,
                                  fontSize: 20),
                            ),
                          )),
                      // Start of Filtered Area
                      Expanded(
                        child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10)),
                            child: Obx(() {
                              // Check if the response is null or transactions is empty
                              if (vc.sm.value == null) {
                                return ShimmerHistorique(); // Show shimmer while loading
                              }
                              return ListView.builder(
                                itemBuilder: (context, index) =>
                                    TransactionInfo(item: vc.transactions[index]),
                                itemCount: vc.transactions.length,
                              );
                            })),
                      )
                      // End of Filtered Area
                    ],
                  )),
            )
            // End of HomePage Body
          ],
        );

      })

    );
  }
}

