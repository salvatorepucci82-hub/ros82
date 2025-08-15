import 'package:flutter/material.dart';
import '../db/database.dart';
import 'worker/home_worker.dart';
import 'supervisor/supervisor_calendar.dart';
import '../models/user.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final userCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool obscure = true;

  void _login() async {
    final u = userCtrl.text.trim();
    final p = passCtrl.text.trim();
    final user = await AppDatabase.instance.getUserByCredentials(u, p);
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Credenziali non valide')));
      return;
    }
    if (user.role == 'operaio') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeWorker(userId: user.username)));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SupervisorCalendar()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Pavimentazione', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                TextField(controller: userCtrl, decoration: const InputDecoration(labelText: 'Utente')),
                const SizedBox(height: 12),
                TextField(
                  controller: passCtrl,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => obscure = !obscure),
                    ),
                  ),
                  obscureText: obscure,
                ),
                const SizedBox(height: 20),
                SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _login, child: const Text('Entra'))),
                const SizedBox(height: 12),
                const Text('Utenti di prova: operaio/1234, supervisore/4321', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
