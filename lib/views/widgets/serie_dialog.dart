import 'package:flutter/material.dart';

import '../../core/formatters.dart';
import '../../data/models/ejercicio.dart';
import '../../data/models/serie.dart';
import '../../l10n/app_localizations.dart';
import 'campo_desplegable.dart';

/// Diálogo para añadir o editar una serie. Devuelve la serie o null.
Future<Serie?> mostrarFormularioSerie(
  BuildContext context, {
  required int sesionId,
  required List<Ejercicio> ejercicios,
  Serie? existente,
}) {
  return showDialog<Serie>(
    context: context,
    builder: (_) => _SerieDialog(
      sesionId: sesionId,
      ejercicios: ejercicios,
      existente: existente,
    ),
  );
}

class _SerieDialog extends StatefulWidget {
  const _SerieDialog({
    required this.sesionId,
    required this.ejercicios,
    this.existente,
  });

  final int sesionId;
  final List<Ejercicio> ejercicios;
  final Serie? existente;

  @override
  State<_SerieDialog> createState() => _SerieDialogState();
}

class _SerieDialogState extends State<_SerieDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _reps;
  late final TextEditingController _peso;
  int? _ejercicioId;
  int? _rir;
  bool _intentado = false;

  @override
  void initState() {
    super.initState();
    final s = widget.existente;
    _ejercicioId = s?.ejercicioId ??
        (widget.ejercicios.isEmpty ? null : widget.ejercicios.first.id);
    _reps = TextEditingController(text: s == null ? '' : '${s.reps}');
    _peso = TextEditingController(text: s == null ? '' : formatearKg(s.pesoKg));
    _rir = s?.rir;
  }

  @override
  void dispose() {
    _reps.dispose();
    _peso.dispose();
    super.dispose();
  }

  void _guardar() {
    setState(() => _intentado = true);
    if (_ejercicioId == null || !_formKey.currentState!.validate()) return;
    final peso = double.parse(_peso.text.trim().replaceAll(',', '.'));
    final base = widget.existente;
    Navigator.of(context).pop(
      Serie(
        id: base?.id,
        sesionId: widget.sesionId,
        ejercicioId: _ejercicioId!,
        reps: int.parse(_reps.text.trim()),
        pesoKg: peso,
        origen: base?.origen ?? SerieOrigen.manual,
        rir: _rir,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.existente == null ? l.newSet : l.editSet),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CampoDesplegable<int>(
                etiqueta: l.exerciseLabel,
                valor: _ejercicioId,
                textoError:
                    _intentado && _ejercicioId == null ? l.chooseExercise : null,
                items: [
                  for (final e in widget.ejercicios)
                    DropdownMenuItem<int>(
                      value: e.id,
                      child: Text(e.nombre, overflow: TextOverflow.ellipsis),
                    ),
                ],
                onChanged: (v) => setState(() => _ejercicioId = v),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _reps,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l.repsLabel),
                validator: (v) {
                  final n = int.tryParse((v ?? '').trim());
                  return (n == null || n <= 0) ? l.repsInvalid : null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _peso,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: l.weightLabel),
                validator: (v) {
                  final n =
                      double.tryParse((v ?? '').trim().replaceAll(',', '.'));
                  return (n == null || n < 0) ? l.weightInvalid : null;
                },
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Intensidad (RIR):',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('RIR 0 (Fallo)'),
                    selected: _rir == 0,
                    selectedColor:
                        const Color(0xFFFF5252).withValues(alpha: 0.3),
                    onSelected: (sel) => setState(() => _rir = sel ? 0 : null),
                  ),
                  ChoiceChip(
                    label: const Text('RIR 1 (1 en recámara)'),
                    selected: _rir == 1,
                    selectedColor:
                        const Color(0xFFFFAB00).withValues(alpha: 0.3),
                    onSelected: (sel) => setState(() => _rir = sel ? 1 : null),
                  ),
                  ChoiceChip(
                    label: const Text('RIR 2'),
                    selected: _rir == 2,
                    onSelected: (sel) => setState(() => _rir = sel ? 2 : null),
                  ),
                ],
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
