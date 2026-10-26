// Carlos - 26/10/2026: Pantalla del catálogo de ejercicios con CRUD completo, cuadro de búsqueda dinámica y chips de filtro.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/ejercicios_controller.dart';
import '../../core/constants.dart';
import '../../data/models/ejercicio.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/campo_desplegable.dart';
import '../widgets/estado_vacio.dart';
import '../widgets/serie_ui.dart';

/// Pantalla 4: catálogo de ejercicios (CRUD completo con búsqueda y filtro).
class EjerciciosScreen extends StatefulWidget {
  const EjerciciosScreen({super.key});

  @override
  State<EjerciciosScreen> createState() => _EjerciciosScreenState();
}

class _EjerciciosScreenState extends State<EjerciciosScreen> {
  final TextEditingController _busqueda = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<EjerciciosController>().cargar();
    });
  }

  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }

  String _textoError(AppLocalizations l, ErrorEjercicio e) => switch (e) {
        ErrorEjercicio.duplicado => l.errExerciseDuplicate,
        ErrorEjercicio.enUso => l.errExerciseInUse,
        ErrorEjercicio.guardar => l.errSaveExercise,
        ErrorEjercicio.borrar => l.errDeleteExercise,
      };

  void _aviso(String texto) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<void> _editar([Ejercicio? ejercicio]) async {
    final ctrl = context.read<EjerciciosController>();
    final l = AppLocalizations.of(context);
    final resultado = await showDialog<Ejercicio>(
      context: context,
      builder: (_) => _EjercicioDialog(existente: ejercicio),
    );
    if (resultado == null) return;
    final error = await ctrl.guardar(resultado);
    if (error != null && mounted) _aviso(_textoError(l, error));
  }

  Future<void> _borrar(Ejercicio ejercicio) async {
    final ctrl = context.read<EjerciciosController>();
    final l = AppLocalizations.of(context);
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.deleteExerciseTitle),
        content: Text(l.deleteExerciseQuestion(ejercicio.nombre)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.delete),
          ),
        ],
      ),
    );
    if (confirmado != true) return;
    final error = await ctrl.eliminar(ejercicio);
    if (error != null && mounted) _aviso(_textoError(l, error));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final ctrl = context.watch<EjerciciosController>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _editar(),
        icon: const Icon(Icons.add),
        label: Text(l.newLabel),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _busqueda,
              onChanged: ctrl.setBusqueda,
              decoration: InputDecoration(
                hintText: l.searchExercise,
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(l.allGroups),
                    selected: ctrl.grupo == null,
                    onSelected: (_) => ctrl.setGrupo(null),
                  ),
                ),
                for (final g in gruposMusculares)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(nombreGrupo(l, g)),
                      selected: ctrl.grupo == g,
                      onSelected: (_) => ctrl.setGrupo(g),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ctrl.cargando
                ? const Center(child: CircularProgressIndicator())
                : ctrl.items.isEmpty
                    ? EstadoVacio(
                        icono: Icons.search_off,
                        mensaje: l.noExercisesFilter,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 88),
                        itemCount: ctrl.items.length,
                        itemBuilder: (context, index) {
                          final e = ctrl.items[index];
                          final oscuro = Theme.of(context).brightness == Brightness.dark;
                          return ListTile(
                            leading: avatarGrupo(e.grupoMuscular, oscuro: oscuro),
                            title: Text(e.nombre),
                            subtitle: Text(nombreGrupo(l, e.grupoMuscular)),
                            onTap: () => _editar(e),
                            onLongPress: () => _borrar(e),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              tooltip: l.delete,
                              onPressed: () => _borrar(e),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _EjercicioDialog extends StatefulWidget {
  const _EjercicioDialog({this.existente});

  final Ejercicio? existente;

  @override
  State<_EjercicioDialog> createState() => _EjercicioDialogState();
}

class _EjercicioDialogState extends State<_EjercicioDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  String? _grupo;
  bool _intentado = false;

  @override
  void initState() {
    super.initState();
    _nombre = TextEditingController(text: widget.existente?.nombre ?? '');
    _grupo = widget.existente?.grupoMuscular;
  }

  @override
  void dispose() {
    _nombre.dispose();
    super.dispose();
  }

  void _guardar() {
    setState(() => _intentado = true);
    if (_grupo == null || !_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      Ejercicio(
        id: widget.existente?.id,
        nombre: _nombre.text.trim(),
        grupoMuscular: _grupo!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.existente == null ? l.newExercise : l.editExercise),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nombre,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(labelText: l.nameLabel),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l.nameRequired : null,
              ),
              const SizedBox(height: 16),
              CampoDesplegable<String>(
                etiqueta: l.muscleGroupLabel,
                valor: _grupo,
                textoError: _intentado && _grupo == null ? l.chooseGroup : null,
                items: [
                  for (final g in gruposMusculares)
                    DropdownMenuItem<String>(
                      value: g,
                      child: Text(nombreGrupo(l, g)),
                    ),
                ],
                onChanged: (v) => setState(() => _grupo = v),
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
        FilledButton(onPressed: _guardar, child: Text(l.save)),
      ],
    );
  }
}
