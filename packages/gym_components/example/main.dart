import 'package:flutter/material.dart';
import 'package:gym_components/gym_components.dart';

void main() => runApp(const MaterialApp(home: Ejemplo()));

/// Ejemplo mínimo de uso de los dos componentes.
class Ejemplo extends StatefulWidget {
  /// Crea el ejemplo.
  const Ejemplo({super.key});

  @override
  State<Ejemplo> createState() => _EjemploState();
}

class _EjemploState extends State<Ejemplo> {
  int _reps = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RepCounter(count: _reps, goal: 10),
          TextButton(
            onPressed: () => setState(() => _reps++),
            child: const Text('+1'),
          ),
          const SetTile(
            ejercicio: 'Sentadilla',
            reps: 8,
            pesoKg: 60,
            origen: SetOrigin.pose,
          ),
        ],
      ),
    );
  }
}
