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
  List<PendingTransactionModel> pendingTransactions = [];

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
    final remainingTransactions = await SharedPref.getPendingSyncTrans();
    setState(() {
      allTransactions = txns;
      filteredTransactions = txns;
      // pendingTransactions = remainingTransactions.where((txn) => txn.));
    });
  }

  final _dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

  void _applyFilter() {
    final _dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    setState(() {
      filteredTransactions = allTransactions.where((txn) {
        final txnType = txn.type.value?.libelle;
        final txnDateStr = txn.date.value;
        DateTime? txnDate;

        if (txnDateStr != null && txnDateStr.isNotEmpty) {
          try {
            txnDate = _dateFormat.parse(txnDateStr);
          } catch (e) {
            print('Failed to parse date: $txnDateStr');
          }
        }

        if (txnDate == null) return false;

        final txnDay = DateTime(txnDate.year, txnDate.month, txnDate.day);
        final startDay = startDate != null
            ? DateTime(startDate!.year, startDate!.month, startDate!.day)
            : null;
        final endDay = endDate != null
            ? DateTime(endDate!.year, endDate!.month, endDate!.day)
            : null;

        final matchesType = selectedType == null || txnType == selectedType;

        final matchesStart = startDay == null || !txnDay.isBefore(startDay);
        final matchesEnd = endDay == null || !txnDay.isAfter(endDay);

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

  String formatCustomDateString(String dateString) {
    // Input Format (remains the same to handle the semicolon separator)
    final DateFormat inputFormat = DateFormat("yyyy-MM-dd HH:mm':'ss");

    // New Output Format for 12-hour time with seconds
    final DateFormat outputFormat = DateFormat('MMM d, yy, h:mm:ss a');

    try {
      DateTime dateTime = inputFormat.parse(dateString);
      String formattedString = outputFormat.format(dateTime);
      return formattedString;
    } catch (e) {
      return 'Error: Could not parse date. Original error: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    final montant = transaction.montant.value ?? "0";
    final formattedDate = formatCustomDateString(transaction.date.value ?? '');
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
            backgroundColor: montant.contains("+")
                ? Colors.green.shade50
                : Colors.red.shade50,
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
                montant.contains("+") ? "$montant\$ Paid" : "$montant\$ Unpaid",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: montant.contains("+") ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                formattedDate,
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
