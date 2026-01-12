import 'package:flutter/material.dart';
import 'package:project1/see_all_medicines.dart';
import 'package:provider/provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import 'Provider.dart';
import 'model.dart';


class PharmacyHome extends StatefulWidget {
  @override
  _PharmacyHomeState createState() => _PharmacyHomeState();
}

class _PharmacyHomeState extends State<PharmacyHome> {
  int _currentTab = 0;
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _expiryController = TextEditingController();
  final _categoryController = TextEditingController();
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PharmacyProvider>(context);
    List<Medicine> displayList = _searchQuery.isEmpty
        ? provider.medicines
        : provider.search(_searchQuery);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Anwar Pharmacy",
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          if (_currentTab == 0)
            IconButton(
              icon: Icon(Icons.explicit_outlined, color: Colors.red),
              tooltip: "Sort by Expiry",
              onPressed: () => provider.sortByExpiry(),
            ),
          if (_currentTab == 0)
            IconButton(
              icon: Icon(Icons.picture_as_pdf, color: Colors.red),
              tooltip: "Export PDF",
              onPressed: () => exportPDF(provider),
            ),
        ],backgroundColor: Colors.black38,
      ),backgroundColor: Colors.blueGrey,
      body: _currentTab == 0
          ? medicineTab(provider, displayList)
          : _currentTab == 1
          ? historyTab(provider)
          : analyticsTab(provider),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTab,
        onTap: (index) => setState(() => _currentTab = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services),
            label: "Medicines",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: "Analytics",
          ),
        ],
      ),
    );
  }

  Widget medicineTab(PharmacyProvider provider, List<Medicine> displayList) {
    return Padding(
      padding: EdgeInsets.all(12),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 60),
            // Add Medicine Card
            Card(
              color: Colors.blue[50]!,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  children: [SizedBox(height: 10,),
                    const Text(
                      "Add Medicine",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: "Medicine Name",
                        prefixIcon: Icon(Icons.medical_services),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _quantityController,
                            decoration: const InputDecoration(labelText: "Quantity"),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _priceController,
                            decoration: const InputDecoration(labelText: "Price"),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _expiryController,
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: "Expiry Date",
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            onTap: () async {
                              DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                _expiryController.text =
                                picked.toIso8601String().split('T')[0];
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _categoryController,
                            decoration: const InputDecoration(labelText: "Category"),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height:30),
                    ElevatedButton.icon(
                      onPressed: () {
                        String name = _nameController.text.trim();
                        int quantity =
                            int.tryParse(_quantityController.text.trim()) ?? 0;
                        double price =
                            double.tryParse(_priceController.text.trim()) ?? 0;
                        String expiry = _expiryController.text.trim();
                        String category = _categoryController.text.trim();
                        if (name.isNotEmpty &&
                            quantity > 0 &&
                            expiry.isNotEmpty &&
                            category.isNotEmpty) {
                          provider.addMedicine(name, quantity, price, expiry, category);
                          _nameController.clear();
                          _quantityController.clear();
                          _priceController.clear();
                          _expiryController.clear();
                          _categoryController.clear();
                        }
                      },
                      icon: const Icon(Icons.add),
                      label: const Text("Add Medicine"),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),SizedBox(height: 30,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SeeAllMedicinesScreen(),
                              ),
                            );
                          },
                          child: const Text("All Medicines List"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget historyTab(PharmacyProvider provider) {
    return provider.history.isEmpty
        ? const Center(child: Text("No history yet."))
        : ListView.builder(
      itemCount: provider.history.length,
      itemBuilder: (context, index) {
        final h = provider.history[index];
        return Card(
          color: Colors.green[50],
          child: ListTile(
            leading: SizedBox(
              height: 50,
              width: 80,
              child: Card(
                color: Colors.white12,
                child: Center(
                  child: Text(
                    "History",
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
            title: Text(h['event'] ?? "",
                style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(h['time'] ?? "",
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        );
      },
    );
  }

  Widget analyticsTab(PharmacyProvider provider) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Card(
          color: Colors.green[50],
          margin: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  "Total Stock Value",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  "\PKR ${provider.totalStockValue.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: provider.medicines.length,
            itemBuilder: (context, index) {
              final med = provider.medicines[index];
              return Card(
                color: Colors.green[50],
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(med.name),
                  subtitle: Text(
                      "Quantity: ${med.quantity}, Unit: PKR ${med.price.toStringAsFixed(2)}, Total: PKR ${med.totalPrice.toStringAsFixed(2)}"),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> exportPDF(PharmacyProvider provider) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => [
          pw.Text(
            "Anwar Pharmacy – Medicines Report",
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            "Generated on: ${DateTime.now().toString().split('.')[0]}",
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Divider(),
          pw.SizedBox(height: 12),
          pw.Table.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellStyle: const pw.TextStyle(fontSize: 11),
            cellAlignment: pw.Alignment.centerLeft,
            headers: ["Name", "Quantity", "Unit Price", "Total", "Expiry"],
            data: provider.medicines
                .map((m) => [
              m.name,
              m.quantity.toString(),
              "PKR ${m.price}",
              "PKR ${m.totalPrice.toStringAsFixed(2)}",
              m.expiry
            ])
                .toList(),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }
}
