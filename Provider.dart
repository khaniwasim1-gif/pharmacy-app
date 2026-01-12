import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model.dart';

class PharmacyProvider with ChangeNotifier {
  List<Medicine> _medicines = [];
  List<Map<String, String>> _history = [];

  List<Medicine> get medicines => _medicines;
  List<Map<String, String>> get history => _history;

  double get totalStockValue =>
      _medicines.fold(0, (sum, m) => sum + m.quantity * m.price);

  void addMedicine(String name, int quantity, double price, String expiry, String category) {
    int index = _medicines.indexWhere((m) => m.name == name);
    String timestamp = DateTime.now().toString();
    if (index >= 0) {
      _medicines[index].quantity += quantity;
      _history.add({'event': "Added $quantity to $name", 'time': timestamp});
    } else {
      _medicines.add(Medicine(
        name: name,
        quantity: quantity,
        price: price,
        expiry: expiry,
        category: category,
      ));
      _history.add({'event': "Added new medicine $name ($quantity)", 'time': timestamp});
    }
    saveData();
    notifyListeners();
  }

  void sellMedicine(int index) {
    String timestamp = DateTime.now().toString();
    if (_medicines[index].quantity > 1) {
      _medicines[index].quantity -= 1;
      _history.add({'event': "Sold 1 of ${_medicines[index].name}", 'time': timestamp});
    } else {
      _history.add({'event': "Sold last of ${_medicines[index].name}", 'time': timestamp});
      _medicines.removeAt(index);
    }
    saveData();
    notifyListeners();
  }

  void increaseQuantity(int index) {
    _medicines[index].quantity += 1;
    _history.add({'event': "Increased 1 of ${_medicines[index].name}", 'time': DateTime.now().toString()});
    saveData();
    notifyListeners();
  }

  void sortByExpiry() {
    _medicines.sort((a, b) => a.expiry.compareTo(b.expiry));
    notifyListeners();
  }

  List<Medicine> search(String query) {
    return _medicines
        .where((m) => m.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  void deleteMedicine(int index) {
    String name = _medicines[index].name;

    _history.removeWhere((h) => h['event']!.contains(name));
    _history.add({'event': "Deleted $name", 'time': DateTime.now().toString()});

    _medicines.removeAt(index);
    saveData();
    notifyListeners();
  }

  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> medsJson = _medicines.map((m) => json.encode(m.toJson())).toList();
    prefs.setStringList('medicines', medsJson);

    List<String> historyJson = _history.map((h) => json.encode(h)).toList();
    prefs.setStringList('history', historyJson);
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? medsJson = prefs.getStringList('medicines');
    List<String>? historyJson = prefs.getStringList('history');

    if (medsJson != null) {
      _medicines = medsJson.map((m) => Medicine.fromJson(json.decode(m))).toList();
    }
    if (historyJson != null) {
      _history = historyJson.map((h) => Map<String, String>.from(json.decode(h))).toList();
    }
    notifyListeners();
  }
}
