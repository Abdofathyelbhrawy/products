import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class InvoiceScreen extends StatelessWidget {
  const InvoiceScreen({super.key});

  Future<void> _printInvoice() async {
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Text('Hello World'), // Replace with your invoice layout
          );
        },
      ),
    );
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice'),
        actions: [
          IconButton(icon: const Icon(Icons.print), onPressed: _printInvoice),
        ],
      ),
      body: const Center(child: Text('Invoice details will be shown here.')),
    );
  }
}
