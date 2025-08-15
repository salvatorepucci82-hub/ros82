import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../models/work_entry.dart';
import '../../db/database.dart';

class WorkDetail extends StatefulWidget {
  final WorkEntry entry;
  const WorkDetail({super.key, required this.entry});

  @override
  State<WorkDetail> createState() => _WorkDetailState();
}

class _WorkDetailState extends State<WorkDetail> {
  late TextEditingController _invoiceCtrl;

  @override
  void initState() {
    super.initState();
    _invoiceCtrl = TextEditingController(text: widget.entry.invoiceCode);
  }

  Future<void> _saveInvoice() async {
    if (widget.entry.id != null) {
      await AppDatabase.instance.updateInvoiceCode(widget.entry.id!, _invoiceCtrl.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Codice fattura salvato')));
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _exportPdf() async {
    final pdf = pw.Document();
    pdf.addPage(pw.MultiPage(build: (context) {
      return [
        pw.Header(level: 0, child: pw.Text('Scheda lavoro - ${widget.entry.date}')),
        pw.Text('Operaio: ${widget.entry.userId}'),
        pw.Text('Indirizzo: ${widget.entry.address}'),
        pw.Text('Unità: ${widget.entry.unitNumber}'),
        pw.Text('Metri di posa: ${widget.entry.meters}'),
        pw.Text('Stato: ${widget.entry.status}'),
        pw.Text('Orario: ${widget.entry.startTime} - ${widget.entry.endTime}'),
        pw.Text('Note: ${widget.entry.notes}'),
        pw.SizedBox(height: 10),
      ];
    }));
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dettaglio lavoro')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Data: ${widget.entry.date}', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Operaio: ${widget.entry.userId}'),
          const SizedBox(height: 8),
          Text('Indirizzo: ${widget.entry.address}'),
          const SizedBox(height: 8),
          Text('Unità: ${widget.entry.unitNumber}'),
          const SizedBox(height: 8),
          Text('Metri di posa: ${widget.entry.meters}'),
          const SizedBox(height: 8),
          Text('Stato: ${widget.entry.status == 'completed' ? 'Completato' : 'Da completare'}'),
          const SizedBox(height: 8),
          Text('Orario: ${widget.entry.startTime} - ${widget.entry.endTime}'),
          const SizedBox(height: 16),
          if (widget.entry.photoBeforePath.isNotEmpty) ...[
            const Text('Foto prima:'),
            const SizedBox(height: 8),
            Image.file(File(widget.entry.photoBeforePath), height: 180, fit: BoxFit.cover),
            const SizedBox(height: 16),
          ],
          if (widget.entry.photoAfterPath.isNotEmpty) ...[
            const Text('Foto dopo:'),
            const SizedBox(height: 8),
            Image.file(File(widget.entry.photoAfterPath), height: 180, fit: BoxFit.cover),
            const SizedBox(height: 16),
          ],
          const Divider(),
          const SizedBox(height: 8),
          TextField(controller: _invoiceCtrl, decoration: const InputDecoration(labelText: 'Codice fattura (solo supervisore)')),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _saveInvoice, child: const Text('Salva codice fattura')),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _exportPdf, child: const Text('Esporta PDF')),
        ],
      ),
    );
  }
}
