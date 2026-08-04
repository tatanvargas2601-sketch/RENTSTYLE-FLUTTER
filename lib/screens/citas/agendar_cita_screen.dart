import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/cita.dart';
import '../../providers/auth_provider.dart';
import '../../services/cita_service.dart';

class AgendarCitaScreen extends ConsumerStatefulWidget {
  const AgendarCitaScreen({super.key});

  @override
  ConsumerState<AgendarCitaScreen> createState() => _AgendarCitaScreenState();
}

class _AgendarCitaScreenState extends ConsumerState<AgendarCitaScreen> {
  final _motivoCtrl = TextEditingController();
  DateTime? _fecha;
  TimeOfDay? _hora;
  bool _loading = false;

  // Ajusta a un id de administrador/empleado real, o pide al backend
  // un endpoint de "disponibilidad" para elegir a quién agendar.
  static const int kAdministradorId = 1;

  Future<void> _guardar() async {
    final auth = ref.read(authProvider);
    if (_fecha == null || _hora == null || auth.usuario == null) return;

    setState(() => _loading = true);
    try {
      final fechaCita = DateTime(
        _fecha!.year, _fecha!.month, _fecha!.day, _hora!.hour, _hora!.minute,
      );
      await CitaService().create(Cita(
        idCita: 0,
        idAdministrador: kAdministradorId,
        idCliente: auth.usuario!.idUsuario,
        fechaCita: fechaCita,
        motivo: _motivoCtrl.text.trim(),
        estado: EstadoCita.pendiente,
      ));
      if (mounted) context.pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agendar cita')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _motivoCtrl,
              decoration: const InputDecoration(labelText: 'Motivo'),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(_fecha == null ? 'Selecciona fecha' : _fecha.toString().split(' ').first),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 180)),
                );
                if (picked != null) setState(() => _fecha = picked);
              },
            ),
            ListTile(
              title: Text(_hora == null ? 'Selecciona hora' : _hora!.format(context)),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                if (picked != null) setState(() => _hora = picked);
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _loading ? null : _guardar,
                child: _loading ? const CircularProgressIndicator() : const Text('Guardar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
