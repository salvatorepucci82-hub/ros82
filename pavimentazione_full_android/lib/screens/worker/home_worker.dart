import 'package:flutter/material.dart';
import '../../db/database.dart';
import '../../models/work_entry.dart';
import 'work_form.dart';

class HomeWorker extends StatefulWidget {
  final String userId;
  const HomeWorker({super.key, required this.userId});

  @override
  State<HomeWorker> createState() => _HomeWorkerState();
}

class _HomeWorkerState extends State<HomeWorker> {
  List<WorkEntry> _works = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await AppDatabase.instance.readWorksByUser(widget.userId);
    setState(() => _works = items);
  }

  void _newWork() async {
    final ok = await Navigator.of(context).push(MaterialPageRoute(builder: (_) => WorkForm(userId: widget.userId)));
    if (ok == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Schede lavoro (Operaio)')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _works.isEmpty
            ? ListView(children: const [Padding(padding: EdgeInsets.all(24), child: Text('Nessun lavoro. Premi + per aggiungere.'))])
            : ListView.builder(
                itemCount: _works.length,
                itemBuilder: (context, i) {
                  final w = _works[i];
                  final color = w.status == 'completed' ? Colors.green : Colors.orange;
                  return Card(
                    child: ListTile(
                      leading: Icon(Icons.work, color: color),
                      title: Text('${w.date} — ${w.unitNumber}'),
                      subtitle: Text('${w.address}\nMetri: ${w.meters} — Stato: ${w.status == 'completed' ? 'Completato' : 'Da completare'}'),
                      isThreeLine: true,
                      trailing: w.invoiceCode.isEmpty ? const Text('') : const Icon(Icons.receipt_long),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: _newWork, child: const Icon(Icons.add)),
    );
  }
}
