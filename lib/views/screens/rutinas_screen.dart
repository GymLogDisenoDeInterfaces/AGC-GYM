// Carlos - 27/10/2026: Pantalla del listado de rutinas PPL con imágenes temáticas y acceso al detalle de ejercicios.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../controllers/rutinas_controller.dart';
import '../../data/models/ejercicio.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/estado_vacio.dart';
import '../widgets/serie_ui.dart';

String? _imagenRutina(String nombre) {
  final min = nombre.toLowerCase();
  if (min.contains('push') || min.contains('empuje')) return 'assets/images/push.jpg';
  if (min.contains('pull') || min.contains('tir')) return 'assets/images/pull.jpg';
  if (min.contains('leg') || min.contains('pierna')) return 'assets/images/legs.jpg';
  return null;
}

Widget _avatarPorDefecto(ThemeData tema) => Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: tema.colorScheme.primary.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: tema.colorScheme.primary.withValues(alpha: 0.45),
          width: 1.5,
        ),
      ),
      child: Icon(
        Icons.view_timeline_rounded,
        color: tema.colorScheme.primary,
        size: 22,
      ),
    );

/// Pantalla 2: lista de rutinas (con nº de ejercicios por COUNT).
class RutinasScreen extends StatefulWidget {
  const RutinasScreen({super.key});

  @override
  State<RutinasScreen> createState() => _RutinasScreenState();
}

class _RutinasScreenState extends State<RutinasScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<RutinasController>().cargar();
    });
  }

  Future<void> _nueva() async {
    final ctrl = context.read<RutinasController>();
    final catalogo = await ctrl.catalogo();
    if (!mounted) return;
    final resultado = await showDialog<_NuevaRutina>(
      context: context,
      builder: (_) => _RutinaDialog(catalogo: catalogo),
    );
    if (resultado != null) {
      await ctrl.crear(resultado.nombre, resultado.ejercicioIds);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final ctrl = context.watch<RutinasController>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _nueva,
        icon: const Icon(Icons.add),
        label: Text(l.newLabel),
      ),
      body: ctrl.cargando
          ? const Center(child: CircularProgressIndicator())
          : ctrl.items.isEmpty
              ? EstadoVacio(icono: Icons.list_alt, mensaje: l.noRoutines)
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 88),
                  itemCount: ctrl.items.length,
                  itemBuilder: (context, index) {
                    final r = ctrl.items[index];
                    final tema = Theme.of(context);
                    final img = _imagenRutina(r.nombre);
                    return ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: img != null
                            ? Image.asset(
                                img,
                                width: 46,
                                height: 46,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _avatarPorDefecto(tema),
                              )
                            : _avatarPorDefecto(tema),
                      ),
                      title: Text(
                        r.nombre,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(l.nExercises(r.numEjercicios)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        await context.push('/rutinas/${r.id}');
                        if (context.mounted) {
                          context.read<RutinasController>().cargar();
                        }
                      },
                    );
                  },
                ),
    );
  }
}

class _NuevaRutina {
  const _NuevaRutina(this.nombre, this.ejercicioIds);

  final String nombre;
  final List<int> ejercicioIds;
}

class _RutinaDialog extends StatefulWidget {
  const _RutinaDialog({required this.catalogo});

  final List<Ejercicio> catalogo;

  @override
  State<_RutinaDialog> createState() => _RutinaDialogState();
}

class _RutinaDialogState extends State<_RutinaDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final Set<int> _elegidos = {};
  bool _intentado = false;

  @override
  void dispose() {
    _nombre.dispose();
    super.dispose();
  }

  void _crear() {
    setState(() => _intentado = true);
    if (_elegidos.isEmpty || !_formKey.currentState!.validate()) return;
    // Se conserva el orden del catálogo.
    final ids = [
      for (final e in widget.catalogo)
        if (_elegidos.contains(e.id)) e.id!,
    ];
    Navigator.of(context).pop(_NuevaRutina(_nombre.text.trim(), ids));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final tema = Theme.of(context);
    return AlertDialog(
      title: Text(l.newRoutine),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nombre,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(labelText: l.nameLabel),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? l.routineNameRequired
                    : null,
              ),
              if (_intentado && _elegidos.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l.chooseAtLeastOne,
                      style: TextStyle(color: tema.colorScheme.error),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final e in widget.catalogo)
                      CheckboxListTile(
                        dense: true,
                        value: _elegidos.contains(e.id),
                        title: Text(e.nombre),
                        subtitle: Text(nombreGrupo(l, e.grupoMuscular)),
                        onChanged: (v) => setState(() {
                          if (v == true) {
                            _elegidos.add(e.id!);
                          } else {
                            _elegidos.remove(e.id);
                          }
                        }),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.cancel),
        ),
        FilledButton(onPressed: _crear, child: Text(l.create)),
      ],
    );
  }
}
