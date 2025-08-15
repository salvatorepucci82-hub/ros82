import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../db/database.dart';
import '../../models/work_entry.dart';
import 'work_detail.dart';

class SupervisorCalendar extends StatefulWidget {
  const SupervisorCalendar({super.key});

  @override
  State<SupervisorCalendar> createState() => _SupervisorCalendarState();
}

class _SupervisorCalendarState extends State<SupervisorCalendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<WorkEntry>> _events = {};
  List<WorkEntry> _selectedEvents = [];
  String _search = '';

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  Future<void> _loadEvents() async {
    final all = await AppDatabase.instance.readAllWorks();
    final map = <DateTime, List<WorkEntry>>{};
    for (final w in all) {
      final parts = w.date.split('-');
      if (parts.length == 3) {
        final day = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
        final key = _normalize(day);
        map.putIfAbsent(key, () => []).add(w);
      }
    }
    setState(() {
      _events = map;
      _onDaySelected(_selectedDay ?? _normalize(DateTime.now()), _events[_normalize(DateTime.now())] ?? []);
    });
  }

  List<WorkEntry> _getEventsForDay(DateTime day) => _events[_normalize(day)] ?? [];

  void _onDaySelected(DateTime selectedDay, List<WorkEntry> events) {
    setState(() {
      _selectedDay = selectedDay;
      _selectedEvents = events.where((e) =>
        _search.isEmpty ||
        e.userId.toLowerCase().contains(_search) ||
        e.address.toLowerCase().contains(_search) ||
        e.unitNumber.toLowerCase().contains(_search)
      ).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendario lavori (Supervisore)')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(labelText: 'Cerca per operaio / indirizzo / unità'),
              onChanged: (v) {
                _search = v.toLowerCase();
                _onDaySelected(_selectedDay ?? _focusedDay, _getEventsForDay(_selectedDay ?? _focusedDay));
              },
            ),
          ),
          TableCalendar<WorkEntry>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2050, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() { _focusedDay = focusedDay; });
              _onDaySelected(selectedDay, _getEventsForDay(selectedDay));
            },
            eventLoader: _getEventsForDay,
            headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
          ),
          const Divider(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadEvents,
              child: _selectedEvents.isEmpty
                  ? ListView(children: const [Padding(padding: EdgeInsets.all(16), child: Text('Nessun lavoro in questo giorno'))])
                  : ListView.builder(
                      itemCount: _selectedEvents.length,
                      itemBuilder: (context, i) {
                        final w = _selectedEvents[i];
                        final color = w.status == 'completed' ? Colors.green : Colors.orange;
                        return Card(
                          child: ListTile(
                            leading: Icon(Icons.work, color: color),
                            title: Text('${w.unitNumber} — ${w.meters} m'),
                            subtitle: Text('${w.address}\nOperaio: ${w.userId} — ${w.status == 'completed' ? 'Completato' : 'Da completare'}'),
                            isThreeLine: true,
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () async {
                              final changed = await Navigator.of(context).push(MaterialPageRoute(builder: (_) => WorkDetail(entry: w)));
                              if (changed == true) _loadEvents();
                            },
                          ),
                        );
                      },
                    ),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadEvents,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
