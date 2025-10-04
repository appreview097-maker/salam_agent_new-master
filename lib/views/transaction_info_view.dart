import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../models/transaction_model.dart';

class TransactionInfo extends StatelessWidget {
  final TransactionModel item;
  const TransactionInfo({super.key, required this.item});
  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return Card(
        margin: const EdgeInsets.symmetric(vertical: 5),
        child: Container(
          decoration: const BoxDecoration(color: Colors.white
              // ,borderRadius: BorderRadius.circular(10)
              ),
          child: TextButton(
            onPressed: () {
              showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return Container(
                      padding: const EdgeInsets.all(15),
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(50),
                              topLeft: Radius.circular(50))),
                      height: 250,
                      child: _factureTransaction(),
                    );
                  });
            },
            child: _itemWidget(),
          ),
        ));
  }

  Row _itemWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          // width: size.width / 2,
          child: Row(children: [
            // Icon(
            //   item.type == 'rechargement' ? Icons.wallet : Icons.dining,
            //   color: item.type == 'rechargement' ? Colors.green : Colors.red,
            // ),
            Container(
              height: 50,
              width: 50,
              child: Lottie.asset(renderIcon(item.type.value!.libelle)),
            ),
            Text(
              " ${item.quantite == -1 ? '' : item.quantite} ${item.type.value!.libelle}",
              style: const TextStyle(
                  fontSize: 18, color: Color.fromARGB(255, 133, 133, 127)),
            )
          ]),
        ),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(
              "${item.montant}F CFA",
              style: TextStyle(
                  color: item.montant.value!.contains("+")
                      ? Colors.green
                      : Colors.red),
            ),
            Text("${item.date}",
                style: TextStyle(color: const Color.fromARGB(255, 66, 66, 66)))
          ]),
        )
      ],
    );
  }

  String renderIcon(String action) {
    if (action == "rechargement") return "images/wallet.json";
    if (action == "transfert") return "images/out.json";
    return "images/lunch.json";
  }

  String rendel_libelle(TransactionModel item) {
    //  if(item.agent!=null) return "Agent";
    if (item.montant.value!.contains('-'))
      return "envoyé à";
    else
      return "reçu de ";
  }

  Column _factureTransaction() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Reference",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(
          height: 5,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [Text("${item.reference}")],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              rendel_libelle(item),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text("Agent")
            // Text(
            //     "${item.agent != null && item.agent.value != null
            //         ? item.agent.value!.nomComplet
            //         : item.destinataire != null && item.destinataire.value != null
            //         ? item.destinataire.value!.nomComplet
            //         : 'N/A'}"
            // )
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Date",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text("${item.date}")
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Type",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text("${item.type.value!.libelle}")
          ],
        ),
        const SizedBox(
          height: 8,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Montant",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text("${item.montant} FCFA")
          ],
        )
      ],
    );
  }
}
