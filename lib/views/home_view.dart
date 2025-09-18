import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salam_agent/models/mode_model.dart';
import 'package:salam_agent/utilities/shared_preferences.dart';

import '../controllers/home_controller.dart';
import '../routes/routes.dart';

class HomePage extends StatelessWidget {
  final HomeController hc = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        shadowColor: Colors.white,
        title: Obx(() {
          final name = hc.user.value?.nomComplet ?? "NA";
          return Text(
            'Agent: $name',
            style: const TextStyle(color: Colors.white),
          );
        }),
        centerTitle: true,
        backgroundColor: Colors.indigo,
      ),
      drawer: mydrawer(context),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Obx(() {
                final repasType =
                    hc.selectedRepas.value?.libelle ?? "No Repas Selected";

                return Card(
                  child: SizedBox(
                    width: 350,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            "Repas Type: $repasType",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const SizedBox(height: 10),
                        Container(
                          alignment: Alignment.center,
                          child: Card(
                            child: SizedBox(
                              width: 350,
                              child: Column(
                                children: <Widget>[
                                  const Padding(
                                    padding: EdgeInsets.only(top: 10),
                                    child: Text(
                                      "Total Scans",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                    ),
                                  ),
                                  // SizedBox(height: 2),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Obx( () {
                                          return Text(hc.count.value.toString());
                                        }
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          child: const Card(
                            child: SizedBox(
                              width: 350,
                              child: Column(
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(top: 10),
                                    child: Text(
                                      "Scan QR Code",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                          "Veuillez cliquez sur le bouton Scan"),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 10),
              Image.asset("images/scanqr.png", height: height * 0.3),
              const SizedBox(height: 30),
              Obx(() {
                return ElevatedButton(
                  onPressed: () => hc.scanner(),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    backgroundColor: hc.isEntreeSelected.value
                        ? Colors.green
                        : Colors.indigo,
                  ),
                  child: const Text(
                    "Scanner",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                );
              }),
              const SizedBox(height: 15),
              Obx(() {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Afficher Photo",
                          style: TextStyle(fontSize: 18)),
                      Text(hc.displayStudentImage.value ? "Yes" : "No",
                          style: const TextStyle(fontSize: 18)),
                    ],
                  ),
                );
              }),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                child: Obx(() {
                  return GestureDetector(
                    onTap: () => hc.toggleMode(),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Stack(
                        children: [
                          AnimatedAlign(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            alignment: hc.isEntreeSelected.value
                                ? Alignment.centerLeft
                                : Alignment.centerRight,
                            child: Container(
                              width: 50,
                              height: 40,
                              decoration: BoxDecoration(
                                color: hc.isEntreeSelected.value
                                    ? Colors.green
                                    : Colors.indigo,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Center(
                                  child: Text(
                                    "Entree",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: hc.isEntreeSelected.value
                                          ? Colors.green
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    "Controle",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: !hc.isEntreeSelected.value
                                          ? Colors.indigo
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget mydrawer(BuildContext context) {
    return Drawer(
      child: Obx(() {
        if (hc.user.value == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.indigo),
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(
                      hc.user.value!.nomComplet[0],
                      style:
                          const TextStyle(fontSize: 30.0, color: Colors.blue),
                    ),
                  ),
                  Text(hc.user.value!.nomComplet,
                      style:
                          const TextStyle(color: Colors.white, fontSize: 22)),
                  Text(hc.user.value!.matricule,
                      style:
                          const TextStyle(color: Colors.white, fontSize: 18)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Profile"),
              onTap: hc.profile,
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Configuration"),
              onTap: hc.config,
            ),
            ListTile(
              leading: const Icon(Icons.euro),
              title: const Text("Transactions"),
              onTap: hc.trans,
            ),
            ListTile(
              leading: const Icon(Icons.sync),
              title: const Text("Sync"),
              onTap: () => hc.syncPendingTransactions(context),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: hc.logout,
            ),
          ],
        );
      }),
    );
  }
}
