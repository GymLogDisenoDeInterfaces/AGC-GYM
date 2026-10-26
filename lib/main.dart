import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'app.dart';
import 'data/db/database_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // En escritorio sqflite necesita la fábrica FFI; en Android/iOS no.
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await initializeDateFormatting();
  await DatabaseHelper.instance.database; // crea tablas y datos de ejemplo
  runApp(const AgcGymApp());
}
