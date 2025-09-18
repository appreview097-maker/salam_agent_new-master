import 'dart:convert';
import 'package:salam_agent/models/transaction_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mode_model.dart';
import '../models/repas_model.dart';
import '../models/restaurant_model.dart';
import '../models/user_model.dart';
import '../models/student_model.dart';

class SharedPref {
  // -------------------- AUTH & USER --------------------

  static Future<void> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('auth_token', token);
  }

  static Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('user_data', jsonEncode(userData));
  }

  static Future<User?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    String? userDataString = prefs.getString('user_data');
    if (userDataString != null) {
      return User.fromJson(jsonDecode(userDataString));
    }
    return null;
  }

  static Future<void> updateSolde(double solde) async {
    final prefs = await SharedPreferences.getInstance();
    String? userDataString = prefs.getString('user_data');

    if (userDataString != null) {
      Map<String, dynamic> userDataMap = jsonDecode(userDataString);

      if (userDataMap['info'] != null) {
        userDataMap['info']['solde'] = solde;
        prefs.setString('user_data', jsonEncode(userDataMap));
      }
    }
  }

// -------------------- STUDENTS --------------------

  static Future<void> saveStudents(List<Student> students) async {
    final prefs = await SharedPreferences.getInstance();
    final studentList = students.map((student) => student.toJson()).toList();
    prefs.setString('student_list', jsonEncode(studentList));
  }

  static Future<List<Student>> getStudents() async {
    final prefs = await SharedPreferences.getInstance();
    final studentListString = prefs.getString('student_list');
    if (studentListString != null) {
      final decoded = jsonDecode(studentListString) as List;
      return decoded.map((e) => Student.fromJson(e)).toList();
    }
    return [];
  }

  static Future<void> updateStudent(Student updatedStudent) async {
    final students = await getStudents();

    final index = students.indexWhere((s) => s.id == updatedStudent.id);
    if (index != -1) {
      students[index] = updatedStudent;
      await saveStudents(students);
    }
  }

// -------------------- TRANSACTIONS --------------------

  static Future<void> saveTransactions(
      List<TransactionModel> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    final txnList = transactions.map((txn) => txn.toJson()).toList();
    prefs.setString('transaction_list', jsonEncode(txnList));
  }

  static Future<List<TransactionModel>> getTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final txnListString = prefs.getString('transaction_list');
    if (txnListString != null) {
      final decoded = jsonDecode(txnListString) as List;
      return decoded.map((e) => TransactionModel.fromJson(e)).toList();
    }
    return [];
  }

  static Future<void> updateTransaction(TransactionModel updatedTxn) async {
    final transactions = await getTransactions();

    final index = transactions.indexWhere((t) => t.id == updatedTxn.id);
    if (index != -1) {
      transactions[index] = updatedTxn;
      await saveTransactions(transactions);
    }
  }

  static Future<void> addTransaction(TransactionModel newTxn) async {
    final transactions = await getTransactions();
    transactions.add(newTxn);
    await saveTransactions(transactions);
  }


  static const String _pendingSyncKey = "pending_sync_transaction_list";

  /// Save full list (overwrite)
  static Future<void> savePendingSyncTrans(
      List<PendingTransactionModel> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    final txnList = transactions.map((txn) => txn.toJson()).toList();
    await prefs.setString(_pendingSyncKey, jsonEncode(txnList));
  }

  /// Add a new txn
  static Future<void> addPendingSyncTrans(PendingTransactionModel txn) async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_pendingSyncKey);

    List<Map<String, dynamic>> pendingList = [];
    if (data != null) {
      pendingList = List<Map<String, dynamic>>.from(jsonDecode(data));
    }

    pendingList.add(txn.toJson());
    await prefs.setString(_pendingSyncKey, jsonEncode(pendingList));
  }

  /// Get all txns
  static Future<List<PendingTransactionModel>> getPendingSyncTrans() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_pendingSyncKey);

    if (data != null) {
      final decoded = List<Map<String, dynamic>>.from(jsonDecode(data));
      return decoded.map((e) => PendingTransactionModel.fromJson(e)).toList();
    }
    return [];
  }

  /// Delete by uuid
  static Future<void> deletePendingSyncTrans(String uuid) async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_pendingSyncKey);

    if (data != null) {
      List<Map<String, dynamic>> pendingList =
          List<Map<String, dynamic>>.from(jsonDecode(data));

      pendingList.removeWhere((item) => item['uuid'] == uuid);

      await prefs.setString(_pendingSyncKey, jsonEncode(pendingList));
    }
  }

  /// Clear all
  static Future<void> clearPendingSyncTrans() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingSyncKey);
  }

  // -------------------- CONFIG --------------------

  static Future<void> setConfig({
    required Restaurant? selectedRestaurant,
    required Repas? selectedRepas,
    required Mode? selectedMode,
    required bool displayImage,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'selectedRestaurant', jsonEncode(selectedRestaurant!.toJson()));
    await prefs.setString('selectedRepas', jsonEncode(selectedRepas!.toJson()));
    await prefs.setString('selectedMode', jsonEncode(selectedMode!.toJson()));
    await prefs.setString('restaurant', "config");
    await prefs.setBool('displayImage', displayImage);
  }

  static Future<void> setMode(Mode? selectedMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedMode', jsonEncode(selectedMode!.toJson()));
  }

  static Future<String?> getConfigValue(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static Future<bool?> getConfigDisplay(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }

  static Future<String?> getRepas() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('repas');
  }

  static Future<String?> geRestaurant() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('restaurant');
  }

  static Future<bool?> getDisplay() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('displayImage') ?? false;
  }

  // -------------------- CONFIG LISTS --------------------

  static Future<void> saveRestaurants(List<Restaurant> restaurants) async {
    final prefs = await SharedPreferences.getInstance();
    final list = restaurants.map((r) => r.toJson()).toList();
    prefs.setString('restaurants_list', jsonEncode(list));
  }

  static Future<List<Restaurant>> getRestaurants() async {
    final prefs = await SharedPreferences.getInstance();
    final listString = prefs.getString('restaurants_list');
    if (listString != null) {
      final decoded = jsonDecode(listString) as List;
      return decoded.map((e) => Restaurant.fromJson(e)).toList();
    }
    return [];
  }

  static Future<void> saveRepas(List<Repas> repas) async {
    final prefs = await SharedPreferences.getInstance();
    final list = repas.map((r) => r.toJson()).toList();
    prefs.setString('repas_list', jsonEncode(list));
  }

  static Future<List<Repas>> getRepasList() async {
    final prefs = await SharedPreferences.getInstance();
    final listString = prefs.getString('repas_list');
    if (listString != null) {
      final decoded = jsonDecode(listString) as List;
      return decoded.map((e) => Repas.fromJson(e)).toList();
    }
    return [];
  }

  static Future<void> saveModes(List<Mode> modes) async {
    final prefs = await SharedPreferences.getInstance();
    final list = modes.map((m) => m.toJson()).toList();
    prefs.setString('modes_list', jsonEncode(list));
  }

  static Future<List<Mode>> getModes() async {
    final prefs = await SharedPreferences.getInstance();
    final listString = prefs.getString('modes_list');
    if (listString != null) {
      final decoded = jsonDecode(listString) as List;
      return decoded.map((e) => Mode.fromJson(e)).toList();
    }
    return [];
  }

  static const String _counterKey = "app_counter";

  /// Save or update counter value
  static Future<void> setCounter(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_counterKey, value);
  }

  /// Get current counter value (default = 0 if not set)
  static Future<int> getCounter() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_counterKey) ?? 0;
  }

  /// Increment counter by 1
  static Future<int> incrementCounter() async {
    final prefs = await SharedPreferences.getInstance();
    int current = prefs.getInt(_counterKey) ?? 0;
    current++;
    await prefs.setInt(_counterKey, current);
    return current;
  }

  /// Reset counter to 0
  static Future<void> resetCounter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_counterKey, 0);
  }

  // -------------------- CLEAR --------------------

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
    await prefs.remove('student_list');
    await prefs.remove('transaction_list');
    await prefs.remove('restaurant');
    await prefs.remove('repas');
    await prefs.remove('selectedRestaurant');
    await prefs.remove('selectedRepas');
    await prefs.remove('selectedMode');
    await prefs.remove('displayImage');
  }

  static Future<void> deleteStudentsList() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('student_list');
  }

  static Future<void> deleteTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('transaction_list');
  }
}
