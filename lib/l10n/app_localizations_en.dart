// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'AGC GYM';

  @override
  String get navHome => 'Home';

  @override
  String get navRoutines => 'Routines';

  @override
  String get navExercises => 'Exercises';

  @override
  String get navHistory => 'History';

  @override
  String get navStats => 'Statistics';

  @override
  String get settings => 'Settings';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get create => 'Create';

  @override
  String get undo => 'Undo';

  @override
  String get finish => 'Finish';

  @override
  String get close => 'Close';

  @override
  String get newLabel => 'New';

  @override
  String nSets(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sets',
      one: '1 set',
      zero: 'No sets',
    );
    return '$_temp0';
  }

  @override
  String nExercises(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count exercises',
      one: '1 exercise',
      zero: 'No exercises',
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
  String get editTooltip => 'Edit';

  @override
  String get originManual => 'Manual';

  @override
  String get originVoice => 'Voice';

  @override
  String get originPose => 'Pose';

  @override
  String get last7Days => 'Last 7 days';

  @override
  String get sessionsLabel => 'sessions';

  @override
  String get volumeLabel => 'volume';

  @override
  String get startSession => 'Start session';

  @override
  String get lastWorkout => 'Latest workout';

  @override
  String get noWorkoutsYet => 'No workouts logged yet.';

  @override
  String get searchExercise => 'Search exercise';

  @override
  String get allGroups => 'All';

  @override
  String get noExercisesFilter => 'No exercises match this filter.';

  @override
  String get newExercise => 'New exercise';

  @override
  String get editExercise => 'Edit exercise';

  @override
  String get nameLabel => 'Name';

  @override
  String get muscleGroupLabel => 'Muscle group';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get chooseGroup => 'Choose a group';

  @override
  String get deleteExerciseTitle => 'Delete exercise';

  @override
  String deleteExerciseQuestion(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get errExerciseDuplicate =>
      'An exercise with that name already exists';

  @override
  String get errExerciseInUse => 'Cannot delete: the exercise has logged sets';

  @override
  String get errSaveExercise => 'Could not save the exercise';

  @override
  String get errDeleteExercise => 'Could not delete the exercise';

  @override
  String get groupChest => 'Chest';

  @override
  String get groupBack => 'Back';

  @override
  String get groupLegs => 'Legs';

  @override
  String get groupShoulders => 'Shoulders';

  @override
  String get groupArms => 'Arms';

  @override
  String get groupCore => 'Core';

  @override
  String get noRoutines =>
      'You have no routines yet.\nCreate the first one with \"New\".';

  @override
  String get newRoutine => 'New routine';

  @override
  String get routineNameRequired => 'Name is required';

  @override
  String get chooseAtLeastOne => 'Choose at least one exercise';

  @override
  String get routineFallbackTitle => 'Routine';

  @override
  String get deleteRoutineTitle => 'Delete routine';

  @override
  String deleteRoutineQuestion(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get startWithRoutine => 'Start with this routine';

  @override
  String get routineNotFound => 'Routine not found.';

  @override
  String get sessionInProgress => 'Session in progress';

  @override
  String get addSet => 'Add set';

  @override
  String get newSet => 'New set';

  @override
  String get editSet => 'Edit set';

  @override
  String get exerciseLabel => 'Exercise';

  @override
  String get repsLabel => 'Repetitions';

  @override
  String get weightLabel => 'Weight (kg)';

  @override
  String get chooseExercise => 'Choose an exercise';

  @override
  String get repsInvalid => 'Enter a number greater than 0';

  @override
  String get weightInvalid => 'Enter a weight (0 for bodyweight)';

  @override
  String get createExerciseFirst => 'Create an exercise in the catalogue first';

  @override
  String get setDeleted => 'Set deleted';

  @override
  String get sessionSaved => 'Session saved';

  @override
  String get emptySessionDiscarded => 'Empty session discarded';

  @override
  String get sessionNotFound => 'Session not found.';

  @override
  String get noSetsYet => 'No sets yet.\nTap \"Add set\" or press Ctrl+N.';

  @override
  String get sessionRepsGoal => 'Session repetitions';

  @override
  String get sessionGoalReached => 'Repetition goal reached!';

  @override
  String get openPoseCounter => 'Pose counter';

  @override
  String get shortcutsHint => 'Shortcuts: Ctrl+N new set · Space +1 repetition';

  @override
  String get voiceTapToSpeak => 'Tap the microphone and speak';

  @override
  String get voiceHint =>
      'Say (in Spanish), for example: «añade tres series de sentadilla con sesenta kilos»';

  @override
  String get voiceListening => 'Listening…';

  @override
  String get voiceProcessing => 'Processing…';

  @override
  String get voiceMicTooltip => 'Speak';

  @override
  String get voiceStopTooltip => 'Stop listening';

  @override
  String get voiceUnavailable => 'Voice is only available on Android and iOS';

  @override
  String get voiceNoPermission => 'Microphone permission is required';

  @override
  String get voiceNotReady => 'Could not start speech recognition';

  @override
  String get poseTitle => 'Pose counter';

  @override
  String get poseStart => 'Start';

  @override
  String get poseStop => 'Stop';

  @override
  String get poseSave => 'Save set';

  @override
  String get poseReset => 'Reset';

  @override
  String get poseGoalLabel => 'Goal';

  @override
  String get poseWeightLabel => 'Weight (kg)';

  @override
  String get poseIncomplete => 'Incomplete squat';

  @override
  String get poseGoalReached => 'Goal reached!';

  @override
  String get poseUnavailable =>
      'Pose detection only works on Android or iOS with a real camera.';

  @override
  String get poseNeedsCamera => 'Camera permission is required';

  @override
  String get poseNoCamera => 'No camera found';

  @override
  String get poseAddRep => '+1 manual';

  @override
  String get poseFlipCamera => 'Switch camera';

  @override
  String get poseNoBody =>
      'Cannot see you: stand sideways with your full body in frame';

  @override
  String poseKneeAngle(String angle) {
    return 'Knee: $angle°';
  }

  @override
  String poseSaved(int reps) {
    return 'Set saved: $reps repetitions';
  }

  @override
  String get poseNothingToSave => 'There are no repetitions to save yet';

  @override
  String get poseHowTo =>
      'Place the phone sideways and stand a couple of metres away, full body in frame.';

  @override
  String get poseError => 'Could not start the camera';

  @override
  String get poseExerciseSquats => 'Squats';

  @override
  String get poseExerciseBurpees => 'Burpees';

  @override
  String get poseBurpeePhaseGround => 'On ground: jump up!';

  @override
  String get poseBurpeePhaseStanding => 'Standing: drop to ground!';

  @override
  String get poseExercisePullUps => 'Pull-ups';

  @override
  String poseElbowAngle(String angle) {
    return 'Elbow: $angle°';
  }

  @override
  String get poseIncompletePullUp => 'Incomplete pull-up (chin over bar)';

  @override
  String get noSessions => 'No sessions yet.\nStart one from Home.';

  @override
  String get deleteSessionTitle => 'Delete session';

  @override
  String deleteSessionQuestion(String date) {
    return 'The session on $date will be deleted with all its sets.';
  }

  @override
  String get sessionDetail => 'Session detail';

  @override
  String get sessionWithoutSets => 'This session has no sets.';

  @override
  String get weeklyVolume => 'Weekly volume';

  @override
  String weekShort(int week) {
    return 'W$week';
  }

  @override
  String get setsByGroup => 'Sets by muscle group';

  @override
  String get noStats => 'There is no data for the statistics yet.';

  @override
  String totalVolumeKg(String kg) {
    return '$kg kg';
  }

  @override
  String get themeSection => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get toggleTheme => 'Toggle theme';

  @override
  String get languageSection => 'Language';

  @override
  String get langSpanish => 'Español';

  @override
  String get langEnglish => 'English';

  @override
  String get permissionsSection => 'Permissions';

  @override
  String get permCamera => 'Camera';

  @override
  String get permMicrophone => 'Microphone';

  @override
  String get permGranted => 'Granted';

  @override
  String get permDenied => 'Denied';

  @override
  String get permAsk => 'Grant';

  @override
  String get permOpenSettings => 'Open settings';

  @override
  String get permNotApplicable => 'Not applicable on this platform';

  @override
  String get privacySection => 'Privacy';

  @override
  String get privacyTitle => 'Privacy notice';

  @override
  String get privacyBody =>
      'agc-gym stores your workouts only on this device, in a SQLite database. The camera is used only to count repetitions live: images are neither recorded nor sent to any server. The microphone is used to recognise voice commands; recognition may rely on the system speech service. You can revoke the permissions at any time from the device settings.';

  @override
  String get arPrototype => 'Foot marker (AR)';

  @override
  String get arTitle => 'Foot marker';

  @override
  String get arSeparation => 'Feet separation';

  @override
  String get arFootSize => 'Footprint size';

  @override
  String get arExplain =>
      'Camera mock-up with a 2D overlay: place your feet on the footprints before starting the squat.';

  @override
  String get arCameraUnavailable =>
      'Camera not available: showing a test background.';

  @override
  String arSeparationValue(int cm) {
    return '$cm cm';
  }
}
