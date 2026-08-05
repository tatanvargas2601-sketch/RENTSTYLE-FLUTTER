import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/roles.dart';
import '../../models/usuario.dart';
import '../../services/rol_service.dart';
import 'usuarios_admin_screen.dart'; // reutiliza usuarioServiceProvider

final rolServiceProvider = Provider((ref) => RolService());
final rolesProvider = FutureProvider.autoDispose<List<Rol>>((ref) {
  return ref.read(rolServiceProvider).getAll();
});

class UsuarioFormScreen extends ConsumerStatefulWidget {
  final Usuario? existing;
  const UsuarioFormScreen({super.key, this.existing});

  @override
  ConsumerState<UsuarioFormScreen> createState() => _UsuarioFormScreenState();
}

class _UsuarioFormScreenState extends ConsumerState<UsuarioFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _nombreCtrl = TextEditingController(text: widget.existing?.nombre ?? '');
  late final _documentoCtrl = TextEditingController(text: widget.existing?.documento ?? '');
  late final _telefonoCtrl = TextEditingController(text: widget.existing?.telefono ?? '');
  late final _correoCtrl = TextEditingController(text: widget.existing?.correo ?? '');
  final _passCtrl = TextEditingController();
  int? _idRol;
  bool _loading = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _idRol = widget.existing?.idRol;
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate() || _idRol == null) return;
    setState(() => _loading = true);
    try {
      final service = ref.read(usuarioServiceProvider);
      if (_isEditing) {
        await service.update(widget.existing!.idUsuario, {
          'idRol': _idRol,
          'nombre': _nombreCtrl.text.trim(),
          'documento': _documentoCtrl.text.trim(),
          'telefono': _telefonoCtrl.text.trim(),
          'correo': _correoCtrl.text.trim(),
          if (_passCtrl.text.isNotEmpty) 'Contrasena': _passCtrl.text,
        });
      } else {
        await service.create(
          idRol: _idRol!,
          nombre: _nombreCtrl.text.trim(),
          documento: _documentoCtrl.text.trim(),
          telefono: _telefonoCtrl.text.trim(),
          correo: _correoCtrl.text.trim(),
          contrasena: _passCtrl.text,
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rolesAsync = ref.watch(rolesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Editar usuario' : 'Nuevo usuario')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nombreCtrl,
              decoration: const InputDecoration(labelText: 'Nombre completo'),
              validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _documentoCtrl,
              decoration: const InputDecoration(labelText: 'Documento'),
              validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _telefonoCtrl,
              decoration: const InputDecoration(labelText: 'Teléfono'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _correoCtrl,
              decoration: const InputDecoration(labelText: 'Correo'),
              keyboardType: TextInputType.emailAddress,
              validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            rolesAsync.when(
              data: (roles) => DropdownButtonFormField<int>(
                value: _idRol,
                decoration: const InputDecoration(labelText: 'Rol'),
                items: roles
                    .map((r) => DropdownMenuItem(value: r.idRol, child: Text(r.nombre)))
                    .toList(),
                onChanged: (v) => setState(() => _idRol = v),
                validator: (v) => v == null ? 'Selecciona un rol' : null,
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, st) => Text('Error cargando roles: $e'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passCtrl,
              decoration: InputDecoration(
                labelText: _isEditing ? 'Nueva contraseña (opcional)' : 'Contraseña',
              ),
              obscureText: true,
              validator: (v) {
                if (_isEditing) return null; // opcional al editar
                if (v == null || v.length < 6) return 'Mínimo 6 caracteres';
                return null;
              },
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _loading ? null : _guardar,
              child: _loading ? const CircularProgressIndicator() : const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}