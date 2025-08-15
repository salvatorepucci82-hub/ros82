import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/work_entry.dart';
import '../../db/database.dart';

class WorkForm extends StatefulWidget {
  final String userId;
  const WorkForm({super.key, required this.userId});

  @override
  State<WorkForm> createState() => _WorkFormState();
}

class _WorkFormState extends State<WorkForm> {
  final _unitCtrl = TextEditingController();
  final _metersCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _status = 'incomplete';
  String _address = 'Rilevamento posizione...';
  double _lat = 0.0;
  double _lng = 0.0;
  File? _photoBefore;
  File? _photoAfter;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) { setState(() => _address = 'Servizi di localizzazione disattivi'); return; }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) { setState(() => _address = 'Permesso posizione negato'); return; }
      }
      if (permission == LocationPermission.deniedForever) { setState(() => _address = 'Permesso posizione negato per sempre'); return; }

      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      _lat = pos.latitude; _lng = pos.longitude;
      final placemarks = await placemarkFromCoordinates(_lat, _lng);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        _address = '${p.street ?? ''}, ${p.locality ?? ''} ${p.postalCode ?? ''}';
      } else {
        _address = 'Indirizzo non disponibile';
      }
    } catch (e) {
      _address = 'Errore posizione';
    }
    if (mounted) setState(() {});
  }

  Future<void> _pickImage(bool before) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera, maxWidth: 1600);
    if (image == null) return;
    final saved = await _saveFileLocally(image);
    setState(() { if (before) _photoBefore = saved; else _photoAfter = saved; });
  }

  Future<File> _saveFileLocally(XFile file) async {
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final newPath = '${dir.path}/pav_${timestamp}_${file.name}';
    return await File(file.path).copy(newPath);
  }

  Future<void> _pickTime(bool isStart) async {
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (t == null) return;
    setState(() { if (isStart) _startTime = t; else _endTime = t; });
  }

  Future<void> _save() async {
    final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final entry = WorkEntry(
      userId: widget.userId,
      date: dateStr,
      latitude: _lat,
      longitude: _lng,
      address: _address,
      unitNumber: _unitCtrl.text.trim(),
      status: _status,
      meters: double.tryParse(_metersCtrl.text) ?? 0,
      photoBeforePath: _photoBefore?.path ?? '',
      photoAfterPath: _photoAfter?.path ?? '',
      startTime: _startTime?.format(context) ?? '',
      endTime: _endTime?.format(context) ?? '',
      notes: _notesCtrl.text.trim(),
    );
    await AppDatabase.instance.createWork(entry);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Scheda salvata')));
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuova scheda (Operaio)')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Utente: ${widget.userId}'),
          const SizedBox(height: 8),
          Text('Posizione: $_address'),
          const SizedBox(height: 12),
          TextField(controller: _unitCtrl, decoration: const InputDecoration(labelText: 'Numero unità / Indirizzo')),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _status,
            items: const [
              DropdownMenuItem(value: 'incomplete', child: Text('Da completare')),
              DropdownMenuItem(value: 'completed', child: Text('Completato')),
            ],
            onChanged: (v) => setState(() => _status = v ?? 'incomplete'),
            decoration: const InputDecoration(labelText: 'Stato lavoro'),
          ),
          const SizedBox(height: 12),
          TextField(controller: _metersCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Metri di posa')),
          const SizedBox(height: 12),
          Row(children: [
            ElevatedButton(onPressed: () => _pickTime(true), child: const Text('Ora inizio')), const SizedBox(width: 12),
            Text(_startTime?.format(context) ?? '--:--'),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            ElevatedButton(onPressed: () => _pickTime(false), child: const Text('Ora fine')), const SizedBox(width: 12),
            Text(_endTime?.format(context) ?? '--:--'),
          ]),
          const SizedBox(height: 16),
          const Text('Foto prima'), const SizedBox(height: 8),
          _photoBefore == null ? ElevatedButton(onPressed: () => _pickImage(true), child: const Text('Scatta foto prima'))
            : Column(children: [Image.file(_photoBefore!, width: double.infinity, height: 200, fit: BoxFit.cover),
              TextButton(onPressed: () => setState(() => _photoBefore = null), child: const Text('Rimuovi'))]),
          const SizedBox(height: 16),
          const Text('Foto dopo'), const SizedBox(height: 8),
          _photoAfter == null ? ElevatedButton(onPressed: () => _pickImage(false), child: const Text('Scatta foto dopo'))
            : Column(children: [Image.file(_photoAfter!, width: double.infinity, height: 200, fit: BoxFit.cover),
              TextButton(onPressed: () => setState(() => _photoAfter = null), child: const Text('Rimuovi'))]),
          const SizedBox(height: 16),
          TextField(controller: _notesCtrl, decoration: const InputDecoration(labelText: 'Note'), maxLines: 3),
          const SizedBox(height: 20),
          Center(child: ElevatedButton(onPressed: _save, child: const Text('Salva scheda'))),
        ]),
      ),
    );
  }
}
