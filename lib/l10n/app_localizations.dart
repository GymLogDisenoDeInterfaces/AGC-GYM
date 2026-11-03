import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// appTitle
  ///
  /// In es, this message translates to:
  /// **'AGC GYM'**
  String get appTitle;

  /// navHome
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get navHome;

  /// navRoutines
  ///
  /// In es, this message translates to:
  /// **'Rutinas'**
  String get navRoutines;

  /// navExercises
  ///
  /// In es, this message translates to:
  /// **'Ejercicios'**
  String get navExercises;

  /// navHistory
  ///
  /// In es, this message translates to:
  /// **'Historial'**
  String get navHistory;

  /// navStats
  ///
  /// In es, this message translates to:
  /// **'Estadísticas'**
  String get navStats;

  /// settings
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get settings;

  /// cancel
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// save
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get save;

  /// delete
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get delete;

  /// create
  ///
  /// In es, this message translates to:
  /// **'Crear'**
  String get create;

  /// undo
  ///
  /// In es, this message translates to:
  /// **'Deshacer'**
  String get undo;

  /// finish
  ///
  /// In es, this message translates to:
  /// **'Terminar'**
  String get finish;

  /// close
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get close;

  /// newLabel
  ///
  /// In es, this message translates to:
  /// **'Nuevo'**
  String get newLabel;

  /// nSets
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{Sin series} =1{1 serie} other{{count} series}}'**
  String nSets(int count);

  /// nExercises
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{Sin ejercicios} =1{1 ejercicio} other{{count} ejercicios}}'**
  String nExercises(int count);

  /// sessionDate
  ///
  /// In es, this message translates to:
  /// **'{fecha}'**
  String sessionDate(DateTime fecha);

  /// minutesShort
  ///
  /// In es, this message translates to:
  /// **'{minutes} min'**
  String minutesShort(int minutes);

  /// repsUnit
  ///
  /// In es, this message translates to:
  /// **'reps'**
  String get repsUnit;

  /// setSubtitle
  ///
  /// In es, this message translates to:
  /// **'{reps} reps × {kg} kg'**
  String setSubtitle(int reps, String kg);

  /// editTooltip
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get editTooltip;

  /// originManual
  ///
  /// In es, this message translates to:
  /// **'Manual'**
  String get originManual;

  /// originVoice
  ///
  /// In es, this message translates to:
  /// **'Voz'**
  String get originVoice;

  /// originPose
  ///
  /// In es, this message translates to:
  /// **'Pose'**
  String get originPose;

  /// last7Days
  ///
  /// In es, this message translates to:
  /// **'Últimos 7 días'**
  String get last7Days;

  /// sessionsLabel
  ///
  /// In es, this message translates to:
  /// **'sesiones'**
  String get sessionsLabel;

  /// volumeLabel
  ///
  /// In es, this message translates to:
  /// **'volumen'**
  String get volumeLabel;

  /// startSession
  ///
  /// In es, this message translates to:
  /// **'Empezar sesión'**
  String get startSession;

  /// lastWorkout
  ///
  /// In es, this message translates to:
  /// **'Último entreno'**
  String get lastWorkout;

  /// noWorkoutsYet
  ///
  /// In es, this message translates to:
  /// **'Todavía no has registrado ningún entreno.'**
  String get noWorkoutsYet;

  /// searchExercise
  ///
  /// In es, this message translates to:
  /// **'Buscar ejercicio'**
  String get searchExercise;

  /// allGroups
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get allGroups;

  /// noExercisesFilter
  ///
  /// In es, this message translates to:
  /// **'No hay ejercicios con ese filtro.'**
  String get noExercisesFilter;

  /// newExercise
  ///
  /// In es, this message translates to:
  /// **'Nuevo ejercicio'**
  String get newExercise;

  /// editExercise
  ///
  /// In es, this message translates to:
  /// **'Editar ejercicio'**
  String get editExercise;

  /// nameLabel
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get nameLabel;

  /// muscleGroupLabel
  ///
  /// In es, this message translates to:
  /// **'Grupo muscular'**
  String get muscleGroupLabel;

  /// nameRequired
  ///
  /// In es, this message translates to:
  /// **'El nombre es obligatorio'**
  String get nameRequired;

  /// chooseGroup
  ///
  /// In es, this message translates to:
  /// **'Elige un grupo'**
  String get chooseGroup;

  /// deleteExerciseTitle
  ///
  /// In es, this message translates to:
  /// **'Eliminar ejercicio'**
  String get deleteExerciseTitle;

  /// deleteExerciseQuestion
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar \"{name}\"?'**
  String deleteExerciseQuestion(String name);

  /// errExerciseDuplicate
  ///
  /// In es, this message translates to:
  /// **'Ya existe un ejercicio con ese nombre'**
  String get errExerciseDuplicate;

  /// errExerciseInUse
  ///
  /// In es, this message translates to:
  /// **'No se puede borrar: el ejercicio tiene series registradas'**
  String get errExerciseInUse;

  /// errSaveExercise
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar el ejercicio'**
  String get errSaveExercise;

  /// errDeleteExercise
  ///
  /// In es, this message translates to:
  /// **'No se pudo borrar el ejercicio'**
  String get errDeleteExercise;

  /// groupChest
  ///
  /// In es, this message translates to:
  /// **'Pecho'**
  String get groupChest;

  /// groupBack
  ///
  /// In es, this message translates to:
  /// **'Espalda'**
  String get groupBack;

  /// groupLegs
  ///
  /// In es, this message translates to:
  /// **'Pierna'**
  String get groupLegs;

  /// groupShoulders
  ///
  /// In es, this message translates to:
  /// **'Hombro'**
  String get groupShoulders;

  /// groupArms
  ///
  /// In es, this message translates to:
  /// **'Brazo'**
  String get groupArms;

  /// groupCore
  ///
  /// In es, this message translates to:
  /// **'Core'**
  String get groupCore;

  /// noRoutines
  ///
  /// In es, this message translates to:
  /// **'Aún no tienes rutinas.\nCrea la primera con \"Nueva\".'**
  String get noRoutines;

  /// newRoutine
  ///
  /// In es, this message translates to:
  /// **'Nueva rutina'**
  String get newRoutine;

  /// routineNameRequired
  ///
  /// In es, this message translates to:
  /// **'El nombre es obligatorio'**
  String get routineNameRequired;

  /// chooseAtLeastOne
  ///
  /// In es, this message translates to:
  /// **'Elige al menos un ejercicio'**
  String get chooseAtLeastOne;

  /// routineFallbackTitle
  ///
  /// In es, this message translates to:
  /// **'Rutina'**
  String get routineFallbackTitle;

  /// deleteRoutineTitle
  ///
  /// In es, this message translates to:
  /// **'Eliminar rutina'**
  String get deleteRoutineTitle;

  /// deleteRoutineQuestion
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar \"{name}\"?'**
  String deleteRoutineQuestion(String name);

  /// startWithRoutine
  ///
  /// In es, this message translates to:
  /// **'Empezar con esta rutina'**
  String get startWithRoutine;

  /// routineNotFound
  ///
  /// In es, this message translates to:
  /// **'No se encontró la rutina.'**
  String get routineNotFound;

  /// sessionInProgress
  ///
  /// In es, this message translates to:
  /// **'Sesión en curso'**
  String get sessionInProgress;

  /// addSet
  ///
  /// In es, this message translates to:
  /// **'Añadir serie'**
  String get addSet;

  /// newSet
  ///
  /// In es, this message translates to:
  /// **'Nueva serie'**
  String get newSet;

  /// editSet
  ///
  /// In es, this message translates to:
  /// **'Editar serie'**
  String get editSet;

  /// exerciseLabel
  ///
  /// In es, this message translates to:
  /// **'Ejercicio'**
  String get exerciseLabel;

  /// repsLabel
  ///
  /// In es, this message translates to:
  /// **'Repeticiones'**
  String get repsLabel;

  /// weightLabel
  ///
  /// In es, this message translates to:
  /// **'Peso (kg)'**
  String get weightLabel;

  /// chooseExercise
  ///
  /// In es, this message translates to:
  /// **'Elige un ejercicio'**
  String get chooseExercise;

  /// repsInvalid
  ///
  /// In es, this message translates to:
  /// **'Introduce un número mayor que 0'**
  String get repsInvalid;

  /// weightInvalid
  ///
  /// In es, this message translates to:
  /// **'Introduce un peso (0 si es sin carga)'**
  String get weightInvalid;

  /// createExerciseFirst
  ///
  /// In es, this message translates to:
  /// **'Crea antes algún ejercicio en el catálogo'**
  String get createExerciseFirst;

  /// setDeleted
  ///
  /// In es, this message translates to:
  /// **'Serie eliminada'**
  String get setDeleted;

  /// sessionSaved
  ///
  /// In es, this message translates to:
  /// **'Sesión guardada'**
  String get sessionSaved;

  /// emptySessionDiscarded
  ///
  /// In es, this message translates to:
  /// **'Sesión vacía descartada'**
  String get emptySessionDiscarded;

  /// sessionNotFound
  ///
  /// In es, this message translates to:
  /// **'No se encontró la sesión.'**
  String get sessionNotFound;

  /// noSetsYet
  ///
  /// In es, this message translates to:
  /// **'Aún no hay series.\nPulsa \"Añadir serie\" o Ctrl+N.'**
  String get noSetsYet;

  /// sessionRepsGoal
  ///
  /// In es, this message translates to:
  /// **'Repeticiones de la sesión'**
  String get sessionRepsGoal;

  /// sessionGoalReached
  ///
  /// In es, this message translates to:
  /// **'¡Objetivo de repeticiones alcanzado!'**
  String get sessionGoalReached;

  /// openPoseCounter
  ///
  /// In es, this message translates to:
  /// **'Contador por pose'**
  String get openPoseCounter;

  /// shortcutsHint
  ///
  /// In es, this message translates to:
  /// **'Atajos: Ctrl+N nueva serie · Espacio +1 repetición'**
  String get shortcutsHint;

  /// voiceTapToSpeak
  ///
  /// In es, this message translates to:
  /// **'Toca el micrófono y habla'**
  String get voiceTapToSpeak;

  /// voiceHint
  ///
  /// In es, this message translates to:
  /// **'Di, por ejemplo: «añade tres series de sentadilla con sesenta kilos»'**
  String get voiceHint;

  /// voiceListening
  ///
  /// In es, this message translates to:
  /// **'Escuchando…'**
  String get voiceListening;

  /// voiceProcessing
  ///
  /// In es, this message translates to:
  /// **'Procesando…'**
  String get voiceProcessing;

  /// voiceMicTooltip
  ///
  /// In es, this message translates to:
  /// **'Hablar'**
  String get voiceMicTooltip;

  /// voiceStopTooltip
  ///
  /// In es, this message translates to:
  /// **'Dejar de escuchar'**
  String get voiceStopTooltip;

  /// voiceUnavailable
  ///
  /// In es, this message translates to:
  /// **'La voz solo está disponible en Android e iOS'**
  String get voiceUnavailable;

  /// voiceNoPermission
  ///
  /// In es, this message translates to:
  /// **'Hace falta el permiso del micrófono'**
  String get voiceNoPermission;

  /// voiceNotReady
  ///
  /// In es, this message translates to:
  /// **'No se pudo iniciar el reconocimiento de voz'**
  String get voiceNotReady;

  /// poseTitle
  ///
  /// In es, this message translates to:
  /// **'Contador por pose'**
  String get poseTitle;

  /// poseStart
  ///
  /// In es, this message translates to:
  /// **'Empezar'**
  String get poseStart;

  /// poseStop
  ///
  /// In es, this message translates to:
  /// **'Parar'**
  String get poseStop;

  /// poseSave
  ///
  /// In es, this message translates to:
  /// **'Guardar serie'**
  String get poseSave;

  /// poseReset
  ///
  /// In es, this message translates to:
  /// **'Reiniciar'**
  String get poseReset;

  /// poseGoalLabel
  ///
  /// In es, this message translates to:
  /// **'Objetivo'**
  String get poseGoalLabel;

  /// poseWeightLabel
  ///
  /// In es, this message translates to:
  /// **'Peso (kg)'**
  String get poseWeightLabel;

  /// poseIncomplete
  ///
  /// In es, this message translates to:
  /// **'Sentadilla incompleta'**
  String get poseIncomplete;

  /// poseGoalReached
  ///
  /// In es, this message translates to:
  /// **'¡Objetivo alcanzado!'**
  String get poseGoalReached;

  /// poseUnavailable
  ///
  /// In es, this message translates to:
  /// **'La detección de pose solo funciona en Android o iOS, con una cámara real.'**
  String get poseUnavailable;

  /// poseNeedsCamera
  ///
  /// In es, this message translates to:
  /// **'Hace falta el permiso de la cámara'**
  String get poseNeedsCamera;

  /// poseNoCamera
  ///
  /// In es, this message translates to:
  /// **'No se encontró ninguna cámara'**
  String get poseNoCamera;

  /// poseAddRep
  ///
  /// In es, this message translates to:
  /// **'+1 manual'**
  String get poseAddRep;

  /// poseFlipCamera
  ///
  /// In es, this message translates to:
  /// **'Cambiar de cámara'**
  String get poseFlipCamera;

  /// poseNoBody
  ///
  /// In es, this message translates to:
  /// **'No te veo entero: colócate de lado y de cuerpo completo'**
  String get poseNoBody;

  /// poseKneeAngle
  ///
  /// In es, this message translates to:
  /// **'Rodilla: {angle}°'**
  String poseKneeAngle(String angle);

  /// poseSaved
  ///
  /// In es, this message translates to:
  /// **'Serie guardada: {reps} repeticiones'**
  String poseSaved(int reps);

  /// poseNothingToSave
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay repeticiones que guardar'**
  String get poseNothingToSave;

  /// poseHowTo
  ///
  /// In es, this message translates to:
  /// **'Apoya el móvil de lado y colócate a un par de metros, de cuerpo entero.'**
  String get poseHowTo;

  /// poseError
  ///
  /// In es, this message translates to:
  /// **'No se pudo iniciar la cámara'**
  String get poseError;

  /// poseExerciseSquats
  ///
  /// In es, this message translates to:
  /// **'Sentadillas'**
  String get poseExerciseSquats;

  /// poseExerciseBurpees
  ///
  /// In es, this message translates to:
  /// **'Burpees'**
  String get poseExerciseBurpees;

  /// poseBurpeePhaseGround
  ///
  /// In es, this message translates to:
  /// **'En suelo: ¡salto y arriba!'**
  String get poseBurpeePhaseGround;

  /// poseBurpeePhaseStanding
  ///
  /// In es, this message translates to:
  /// **'De pie: ¡al suelo para el burpee!'**
  String get poseBurpeePhaseStanding;

  /// poseExercisePullUps
  ///
  /// In es, this message translates to:
  /// **'Dominadas'**
  String get poseExercisePullUps;

  /// poseElbowAngle
  ///
  /// In es, this message translates to:
  /// **'Codo: {angle}°'**
  String poseElbowAngle(String angle);

  /// poseIncompletePullUp
  ///
  /// In es, this message translates to:
  /// **'Dominada incompleta (sube la barbilla)'**
  String get poseIncompletePullUp;

  /// noSessions
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay sesiones.\nEmpieza una desde Inicio.'**
  String get noSessions;

  /// deleteSessionTitle
  ///
  /// In es, this message translates to:
  /// **'Eliminar sesión'**
  String get deleteSessionTitle;

  /// deleteSessionQuestion
  ///
  /// In es, this message translates to:
  /// **'Se borrará la sesión del {date} con todas sus series.'**
  String deleteSessionQuestion(String date);

  /// sessionDetail
  ///
  /// In es, this message translates to:
  /// **'Detalle de sesión'**
  String get sessionDetail;

  /// sessionWithoutSets
  ///
  /// In es, this message translates to:
  /// **'Esta sesión no tiene series.'**
  String get sessionWithoutSets;

  /// weeklyVolume
  ///
  /// In es, this message translates to:
  /// **'Volumen semanal'**
  String get weeklyVolume;

  /// weekShort
  ///
  /// In es, this message translates to:
  /// **'S{week}'**
  String weekShort(int week);

  /// setsByGroup
  ///
  /// In es, this message translates to:
  /// **'Series por grupo muscular'**
  String get setsByGroup;

  /// noStats
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay datos para las estadísticas.'**
  String get noStats;

  /// totalVolumeKg
  ///
  /// In es, this message translates to:
  /// **'{kg} kg'**
  String totalVolumeKg(String kg);

  /// themeSection
  ///
  /// In es, this message translates to:
  /// **'Tema'**
  String get themeSection;

  /// themeSystem
  ///
  /// In es, this message translates to:
  /// **'Sistema'**
  String get themeSystem;

  /// themeLight
  ///
  /// In es, this message translates to:
  /// **'Claro'**
  String get themeLight;

  /// themeDark
  ///
  /// In es, this message translates to:
  /// **'Oscuro'**
  String get themeDark;

  /// toggleTheme
  ///
  /// In es, this message translates to:
  /// **'Cambiar tema'**
  String get toggleTheme;

  /// languageSection
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get languageSection;

  /// langSpanish
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get langSpanish;

  /// langEnglish
  ///
  /// In es, this message translates to:
  /// **'English'**
  String get langEnglish;

  /// permissionsSection
  ///
  /// In es, this message translates to:
  /// **'Permisos'**
  String get permissionsSection;

  /// permCamera
  ///
  /// In es, this message translates to:
  /// **'Cámara'**
  String get permCamera;

  /// permMicrophone
  ///
  /// In es, this message translates to:
  /// **'Micrófono'**
  String get permMicrophone;

  /// permGranted
  ///
  /// In es, this message translates to:
  /// **'Concedido'**
  String get permGranted;

  /// permDenied
  ///
  /// In es, this message translates to:
  /// **'Denegado'**
  String get permDenied;

  /// permAsk
  ///
  /// In es, this message translates to:
  /// **'Conceder'**
  String get permAsk;

  /// permOpenSettings
  ///
  /// In es, this message translates to:
  /// **'Abrir ajustes'**
  String get permOpenSettings;

  /// permNotApplicable
  ///
  /// In es, this message translates to:
  /// **'No aplica en esta plataforma'**
  String get permNotApplicable;

  /// privacySection
  ///
  /// In es, this message translates to:
  /// **'Privacidad'**
  String get privacySection;

  /// privacyTitle
  ///
  /// In es, this message translates to:
  /// **'Aviso de privacidad'**
  String get privacyTitle;

  /// privacyBody
  ///
  /// In es, this message translates to:
  /// **'agc-gym guarda tus entrenamientos únicamente en este dispositivo, en una base de datos SQLite. La cámara se usa solo para contar repeticiones en directo: las imágenes no se graban ni se envían a ningún servidor. El micrófono se usa para reconocer órdenes de voz; el reconocimiento puede apoyarse en el servicio de voz del sistema. Puedes retirar los permisos cuando quieras desde los ajustes del dispositivo.'**
  String get privacyBody;

  /// arPrototype
  ///
  /// In es, this message translates to:
  /// **'Marca de pies (AR)'**
  String get arPrototype;

  /// arTitle
  ///
  /// In es, this message translates to:
  /// **'Marca de pies'**
  String get arTitle;

  /// arSeparation
  ///
  /// In es, this message translates to:
  /// **'Separación entre pies'**
  String get arSeparation;

  /// arFootSize
  ///
  /// In es, this message translates to:
  /// **'Tamaño de las huellas'**
  String get arFootSize;

  /// arExplain
  ///
  /// In es, this message translates to:
  /// **'Maqueta con cámara y superposición 2D: coloca los pies sobre las huellas antes de empezar la sentadilla.'**
  String get arExplain;

  /// arCameraUnavailable
  ///
  /// In es, this message translates to:
  /// **'Cámara no disponible: se muestra un fondo de prueba.'**
  String get arCameraUnavailable;

  /// arSeparationValue
  ///
  /// In es, this message translates to:
  /// **'{cm} cm'**
  String arSeparationValue(int cm);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
