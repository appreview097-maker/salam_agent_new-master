import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:salam_agent/models/transaction_model.dart';
import '../utilities/shared_preferences.dart';

class TransactionsView extends StatefulWidget {
  const TransactionsView({super.key});

  @override
  State<TransactionsView> createState() => _TransactionsViewState();
}

class _TransactionsViewState extends State<TransactionsView> {
  List<TransactionModel> allTransactions = [];
  List<TransactionModel> filteredTransactions = [];

  String? selectedType;
  DateTime? startDate;
  DateTime? endDate;

  final dateFormat = DateFormat("yyyy-MM-dd");

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final txns = await SharedPref.getTransactions();
    setState(() {
      allTransactions = txns;
      filteredTransactions = txns;
    });
  }

  void _applyFilter() {
    setState(() {
      filteredTransactions = allTransactions.where((txn) {
        final matchesType =
            selectedType == null || txn.type.value?.libelle == selectedType;

        final txnDate = txn.date.value != null && txn.date.value!.isNotEmpty
            ? DateTime.tryParse(txn.date.value!)
            : null;

        final matchesStart = startDate == null ||
            (txnDate != null &&
                txnDate.isAfter(startDate!.subtract(const Duration(days: 1))));
        final matchesEnd = endDate == null ||
            (txnDate != null &&
                txnDate.isBefore(endDate!.add(const Duration(days: 1))));

        return matchesType && matchesStart && matchesEnd;
      }).toList();
    });
  }

  void _resetFilter() {
    setState(() {
      selectedType = null;
      startDate = null;
      endDate = null;
      filteredTransactions = allTransactions;
    });
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "Select Date";
    return dateFormat.format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Transactions"),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: allTransactions.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DropdownButtonFormField<String>(
                        value: selectedType,
                        decoration: InputDecoration(
                          labelText: "Type",
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: ["repas-midi", "repas-matin", "repas-soir"]
                            .map((type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() => selectedType = value);
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        readOnly: true,
                        onTap: () => _pickDate(isStart: true),
                        decoration: InputDecoration(
                          labelText: "Start Date",
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        controller: TextEditingController(
                          text: _formatDate(startDate),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        readOnly: true,
                        onTap: () => _pickDate(isStart: false),
                        decoration: InputDecoration(
                          labelText: "End Date",
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        controller: TextEditingController(
                          text: _formatDate(endDate),
                        ),
                      ),

                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: _resetFilter,
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text("Reset"),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: _applyFilter,
                            icon: const Icon(Icons.filter_list),
                            label: const Text("Filter"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 🔹 Filtered List
                Expanded(
                  child: filteredTransactions.isEmpty
                      ? const Center(child: Text("No transactions found."))
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredTransactions.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final txn = filteredTransactions[index];
                            return TransactionCard(transaction: txn);
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

/// Card Widget that shows only TransactionModel fields
class TransactionCard extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionCard({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: Type Icon
          CircleAvatar(
            radius: 24,
            backgroundColor: transaction.statusColor.withOpacity(0.2),
            child: const Icon(
              Icons.receipt_long,
              color: Colors.indigo,
            ),
          ),

          const SizedBox(width: 12),

          // Middle: Transaction Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.repas.value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  transaction.reference.value,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  transaction.type.value?.libelle ?? "",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // Right: Amount + Date
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${transaction.montant.value ?? "0"} \$",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                transaction.date.value ?? "",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
