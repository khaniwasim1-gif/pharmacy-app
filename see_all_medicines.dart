import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import 'Provider.dart';



class SeeAllMedicinesScreen extends StatefulWidget {
  const SeeAllMedicinesScreen({super.key});

  @override
  State<SeeAllMedicinesScreen> createState() => _SeeAllMedicinesScreenState();
}

class _SeeAllMedicinesScreenState extends State<SeeAllMedicinesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PharmacyProvider>();
    final displayList = _searchQuery.isEmpty
        ? provider.medicines
        : provider.search(_searchQuery);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "All Medicines",
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.explicit_outlined, color: Colors.red),
            tooltip: "Sort by Expiry",
            onPressed: () => provider.sortByExpiry(),
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
            tooltip: "Export PDF",
            onPressed: () => exportPDF(provider),
          ),
        ],backgroundColor: Colors.black38,
      ),backgroundColor: Colors.blueGrey,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search Medicines...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),
          Expanded(
            child: displayList.isEmpty
                ? const Center(child: Text("No medicines found."))
                : ListView.builder(
              itemCount: displayList.length,
              itemBuilder: (context, index) {
                final med = displayList[index];
                DateTime today = DateTime.now();
                DateTime expiryDate;
                try {
                  expiryDate = DateTime.parse(med.expiry.trim());
                } catch (_) {
                  expiryDate = today;
                }

                bool isExpired = expiryDate.isBefore(today);
                bool expiringSoon =
                    !isExpired && expiryDate.isBefore(today.add(const Duration(days: 7)));
                bool lowStock = !isExpired && !expiringSoon && med.quantity <= 5;

                Color cardColor;
                if (isExpired) {
                  cardColor = Colors.red[100]!;
                } else if (expiringSoon) {
                  cardColor = Colors.orange[100]!;
                } else if (lowStock) {
                  cardColor = Colors.yellow[100]!;
                } else {
                  cardColor = Colors.green[50]!;
                }

                return Card(
                  color: cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: ListTile(
                    leading: Icon(
                      Icons.medication,
                      color: Colors.green[700],
                    ),
                    title: Text(
                      med.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "Qty: ${med.quantity}\n"
                          "Unit Price: PKR ${med.price}\n"
                          "Total: PKR ${med.totalPrice.toStringAsFixed(2)}\n"
                          "Exp: ${med.expiry}\n"
                          "Cat: ${med.category}",
                      style: const TextStyle(fontSize: 10),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle, color: Colors.orange),
                          onPressed: () => provider.sellMedicine(
                            provider.medicines.indexOf(med),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle, color: Colors.blue),
                          onPressed: () => provider.increaseQuantity(
                            provider.medicines.indexOf(med),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => provider.deleteMedicine(
                            provider.medicines.indexOf(med),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
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
            headers: ["Name", "Quantity", "Price", "Total Price", "Expiry", "Category"],
            data: provider.medicines
                .map(
                  (m) => [
                m.name,
                m.quantity.toString(),
                "PKR ${m.price}",
                "PKR ${m.totalPrice.toStringAsFixed(2)}",
                m.expiry,
                m.category
              ],
            )
                .toList(),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }
}
