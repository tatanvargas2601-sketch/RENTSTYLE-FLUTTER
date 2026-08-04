import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/prenda.dart';
import '../../providers/catalog_provider.dart';

class ProductoFormScreen extends ConsumerStatefulWidget {
  final Prenda? existing;
  const ProductoFormScreen({super.key, this.existing});

  @override
  ConsumerState<ProductoFormScreen> createState() => _ProductoFormScreenState();
}

class _ProductoFormScreenState extends ConsumerState<ProductoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _nombreCtrl = TextEditingController(text: widget.existing?.nombrePrenda ?? '');
  late final _descripcionCtrl = TextEditingController(text: widget.existing?.descripcion ?? '');
  late final _colorCtrl = TextEditingController(text: widget.existing?.color ?? '');
  late final _precioCtrl =
      TextEditingController(text: widget.existing?.precioAlquiler.toString() ?? '');
  int? _idCategoria;
  XFile? _imagenSeleccionada;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _idCategoria = widget.existing?.idCategoria;
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate() || _idCategoria == null) return;
    setState(() => _loading = true);

    final prenda = Prenda(
      idPrenda: widget.existing?.idPrenda ?? 0,
      idCategoria: _idCategoria!,
      nombrePrenda: _nombreCtrl.text.trim(),
      descripcion: _descripcionCtrl.text.trim(),
      color: _colorCtrl.text.trim(),
      precioAlquiler: double.tryParse(_precioCtrl.text) ?? 0,
    );

    try {
      final service = ref.read(prendaServiceProvider);
      final saved = widget.existing == null
          ? await service.create(prenda)
          : await service.update(widget.existing!.idPrenda, prenda);

      if (_imagenSeleccionada != null) {
        await service.uploadImagen(saved.idPrenda, _imagenSeleccionada!.path);
      }

      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriasAsync = ref.watch(categoriasProvider);

    return Scaffold(
      appBar: AppBar(title: Text(widget.existing == null ? 'Nueva prenda' : 'Editar prenda')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nombreCtrl,
              decoration: const InputDecoration(labelText: 'Nombre'),
              validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            categoriasAsync.when(
              data: (categorias) => DropdownButtonFormField<int>(
                value: _idCategoria,
                decoration: const InputDecoration(labelText: 'Categoría'),
                items: categorias
                    .map((c) => DropdownMenuItem(value: c.idCategoria, child: Text(c.nombre)))
                    .toList(),
                onChanged: (v) => setState(() => _idCategoria = v),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, st) => Text('Error cargando categorías: $e'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descripcionCtrl,
              decoration: const InputDecoration(labelText: 'Descripción'),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _colorCtrl,
              decoration: const InputDecoration(labelText: 'Color'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _precioCtrl,
              decoration: const InputDecoration(labelText: 'Precio de alquiler'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) => (v == null || double.tryParse(v) == null) ? 'Precio inválido' : null,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              icon: const Icon(Icons.image_outlined),
              label: Text(_imagenSeleccionada == null ? 'Elegir imagen' : 'Imagen seleccionada ✓'),
              onPressed: () async {
                final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
                if (picked != null) setState(() => _imagenSeleccionada = picked);
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
