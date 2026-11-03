// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'AGC GYM';

  @override
  String get navHome => 'Inicio';

  @override
  String get navRoutines => 'Rutinas';

  @override
  String get navExercises => 'Ejercicios';

  @override
  String get navHistory => 'Historial';

  @override
  String get navStats => 'Estadísticas';

  @override
  String get settings => 'Ajustes';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get delete => 'Eliminar';

  @override
  String get create => 'Crear';

  @override
  String get undo => 'Deshacer';

  @override
  String get finish => 'Terminar';

  @override
  String get close => 'Cerrar';

  @override
  String get newLabel => 'Nuevo';

  @override
  String nSets(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count series',
      one: '1 serie',
      zero: 'Sin series',
    );
    return '$_temp0';
  }

  @override
  String nExercises(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ejercicios',
      one: '1 ejercicio',
      zero: 'Sin ejercicios',
    );
    return '$_temp0';
  }

  @override
  String sessionDate(DateTime fecha) {
    final intl.DateFormat fechaDateFormat =
        intl.DateFormat.yMMMMEEEEd(localeName);
    final String fechaString = fechaDateFormat.format(fecha);

    return '$fechaString';
  }

  @override
  String minutesShort(int minutes) {
    return '$minutes min';
  }

  @override
  String get repsUnit => 'reps';

  @override
  String setSubtitle(int reps, String kg) {
    return '$reps reps × $kg kg';
  }

  @override
  String get editTooltip => 'Editar';

  @override
  String get originManual => 'Manual';

  @override
  String get originVoice => 'Voz';

  @override
  String get originPose => 'Pose';

  @override
  String get last7Days => 'Últimos 7 días';

  @override
  String get sessionsLabel => 'sesiones';

  @override
  String get volumeLabel => 'volumen';

  @override
  String get startSession => 'Empezar sesión';

  @override
  String get lastWorkout => 'Último entreno';

  @override
  String get noWorkoutsYet => 'Todavía no has registrado ningún entreno.';

  @override
  String get searchExercise => 'Buscar ejercicio';

  @override
  String get allGroups => 'Todos';

  @override
  String get noExercisesFilter => 'No hay ejercicios con ese filtro.';

  @override
  String get newExercise => 'Nuevo ejercicio';

  @override
  String get editExercise => 'Editar ejercicio';

  @override
  String get nameLabel => 'Nombre';

  @override
  String get muscleGroupLabel => 'Grupo muscular';

  @override
  String get nameRequired => 'El nombre es obligatorio';

  @override
  String get chooseGroup => 'Elige un grupo';

  @override
  String get deleteExerciseTitle => 'Eliminar ejercicio';

  @override
  String deleteExerciseQuestion(String name) {
    return '¿Eliminar \"$name\"?';
  }

  @override
  String get errExerciseDuplicate => 'Ya existe un ejercicio con ese nombre';

  @override
  String get errExerciseInUse =>
      'No se puede borrar: el ejercicio tiene series registradas';

  @override
  String get errSaveExercise => 'No se pudo guardar el ejercicio';

  @override
  String get errDeleteExercise => 'No se pudo borrar el ejercicio';

  @override
  String get groupChest => 'Pecho';

  @override
  String get groupBack => 'Espalda';

  @override
  String get groupLegs => 'Pierna';

  @override
  String get groupShoulders => 'Hombro';

  @override
  String get groupArms => 'Brazo';

  @override
  String get groupCore => 'Core';

  @override
  String get noRoutines =>
      'Aún no tienes rutinas.\nCrea la primera con \"Nueva\".';

  @override
  String get newRoutine => 'Nueva rutina';

  @override
  String get routineNameRequired => 'El nombre es obligatorio';

  @override
  String get chooseAtLeastOne => 'Elige al menos un ejercicio';

  @override
  String get routineFallbackTitle => 'Rutina';

  @override
  String get deleteRoutineTitle => 'Eliminar rutina';

  @override
  String deleteRoutineQuestion(String name) {
    return '¿Eliminar \"$name\"?';
  }

  @override
  String get startWithRoutine => 'Empezar con esta rutina';

  @override
  String get routineNotFound => 'No se encontró la rutina.';

  @override
  String get sessionInProgress => 'Sesión en curso';

  @override
  String get addSet => 'Añadir serie';

  @override
  String get newSet => 'Nueva serie';

  @override
  String get editSet => 'Editar serie';

  @override
  String get exerciseLabel => 'Ejercicio';

  @override
  String get repsLabel => 'Repeticiones';

  @override
  String get weightLabel => 'Peso (kg)';

  @override
  String get chooseExercise => 'Elige un ejercicio';

  @override
  String get repsInvalid => 'Introduce un número mayor que 0';

  @override
  String get weightInvalid => 'Introduce un peso (0 si es sin carga)';

  @override
  String get createExerciseFirst => 'Crea antes algún ejercicio en el catálogo';

  @override
  String get setDeleted => 'Serie eliminada';

  @override
  String get sessionSaved => 'Sesión guardada';

  @override
  String get emptySessionDiscarded => 'Sesión vacía descartada';

  @override
  String get sessionNotFound => 'No se encontró la sesión.';

  @override
  String get noSetsYet =>
      'Aún no hay series.\nPulsa \"Añadir serie\" o Ctrl+N.';

  @override
  String get sessionRepsGoal => 'Repeticiones de la sesión';

  @override
  String get sessionGoalReached => '¡Objetivo de repeticiones alcanzado!';

  @override
  String get openPoseCounter => 'Contador por pose';

  @override
  String get shortcutsHint =>
      'Atajos: Ctrl+N nueva serie · Espacio +1 repetición';

  @override
  String get voiceTapToSpeak => 'Toca el micrófono y habla';

  @override
  String get voiceHint =>
      'Di, por ejemplo: «añade tres series de sentadilla con sesenta kilos»';

  @override
  String get voiceListening => 'Escuchando…';

  @override
  String get voiceProcessing => 'Procesando…';

  @override
  String get voiceMicTooltip => 'Hablar';

  @override
  String get voiceStopTooltip => 'Dejar de escuchar';

  @override
  String get voiceUnavailable => 'La voz solo está disponible en Android e iOS';

  @override
  String get voiceNoPermission => 'Hace falta el permiso del micrófono';

  @override
  String get voiceNotReady => 'No se pudo iniciar el reconocimiento de voz';

  @override
  String get poseTitle => 'Contador por pose';

  @override
  String get poseStart => 'Empezar';

  @override
  String get poseStop => 'Parar';

  @override
  String get poseSave => 'Guardar serie';

  @override
  String get poseReset => 'Reiniciar';

  @override
  String get poseGoalLabel => 'Objetivo';

  @override
  String get poseWeightLabel => 'Peso (kg)';

  @override
  String get poseIncomplete => 'Sentadilla incompleta';

  @override
  String get poseGoalReached => '¡Objetivo alcanzado!';

  @override
  String get poseUnavailable =>
      'La detección de pose solo funciona en Android o iOS, con una cámara real.';

  @override
  String get poseNeedsCamera => 'Hace falta el permiso de la cámara';

  @override
  String get poseNoCamera => 'No se encontró ninguna cámara';

  @override
  String get poseAddRep => '+1 manual';

  @override
  String get poseFlipCamera => 'Cambiar de cámara';

  @override
  String get poseNoBody =>
      'No te veo entero: colócate de lado y de cuerpo completo';

  @override
  String poseKneeAngle(String angle) {
    return 'Rodilla: $angle°';
  }

  @override
  String poseSaved(int reps) {
    return 'Serie guardada: $reps repeticiones';
  }

  @override
  String get poseNothingToSave => 'Todavía no hay repeticiones que guardar';

  @override
  String get poseHowTo =>
      'Apoya el móvil de lado y colócate a un par de metros, de cuerpo entero.';

  @override
  String get poseError => 'No se pudo iniciar la cámara';

  @override
  String get poseExerciseSquats => 'Sentadillas';

  @override
  String get poseExerciseBurpees => 'Burpees';

  @override
  String get poseBurpeePhaseGround => 'En suelo: ¡salto y arriba!';

  @override
  String get poseBurpeePhaseStanding => 'De pie: ¡al suelo para el burpee!';

  @override
  String get poseExercisePullUps => 'Dominadas';

  @override
  String poseElbowAngle(String angle) {
    return 'Codo: $angle°';
  }

  @override
  String get poseIncompletePullUp => 'Dominada incompleta (sube la barbilla)';

  @override
  String get noSessions =>
      'Todavía no hay sesiones.\nEmpieza una desde Inicio.';

  @override
  String get deleteSessionTitle => 'Eliminar sesión';

  @override
  String deleteSessionQuestion(String date) {
    return 'Se borrará la sesión del $date con todas sus series.';
  }

  @override
  String get sessionDetail => 'Detalle de sesión';

  @override
  String get sessionWithoutSets => 'Esta sesión no tiene series.';

  @override
  String get weeklyVolume => 'Volumen semanal';

  @override
  String weekShort(int week) {
    return 'S$week';
  }

  @override
  String get setsByGroup => 'Series por grupo muscular';

  @override
  String get noStats => 'Todavía no hay datos para las estadísticas.';

  @override
  String totalVolumeKg(String kg) {
    return '$kg kg';
  }

  @override
  String get themeSection => 'Tema';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get toggleTheme => 'Cambiar tema';

  @override
  String get languageSection => 'Idioma';

  @override
  String get langSpanish => 'Español';

  @override
  String get langEnglish => 'English';

  @override
  String get permissionsSection => 'Permisos';

  @override
  String get permCamera => 'Cámara';

  @override
  String get permMicrophone => 'Micrófono';

  @override
  String get permGranted => 'Concedido';

  @override
  String get permDenied => 'Denegado';

  @override
  String get permAsk => 'Conceder';

  @override
  String get permOpenSettings => 'Abrir ajustes';

  @override
  String get permNotApplicable => 'No aplica en esta plataforma';

  @override
  String get privacySection => 'Privacidad';

  @override
  String get privacyTitle => 'Aviso de privacidad';

  @override
  String get privacyBody =>
      'agc-gym guarda tus entrenamientos únicamente en este dispositivo, en una base de datos SQLite. La cámara se usa solo para contar repeticiones en directo: las imágenes no se graban ni se envían a ningún servidor. El micrófono se usa para reconocer órdenes de voz; el reconocimiento puede apoyarse en el servicio de voz del sistema. Puedes retirar los permisos cuando quieras desde los ajustes del dispositivo.';

  @override
  String get arPrototype => 'Marca de pies (AR)';

  @override
  String get arTitle => 'Marca de pies';

  @override
  String get arSeparation => 'Separación entre pies';

  @override
  String get arFootSize => 'Tamaño de las huellas';

  @override
  String get arExplain =>
      'Maqueta con cámara y superposición 2D: coloca los pies sobre las huellas antes de empezar la sentadilla.';

  @override
  String get arCameraUnavailable =>
      'Cámara no disponible: se muestra un fondo de prueba.';

  @override
  String arSeparationValue(int cm) {
    return '$cm cm';
  }
}
