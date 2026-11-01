// Carlos - 30/10/2026: Pantalla de ajustes para conmutar idioma (ES/EN), tema claro/oscuro, permisos y aviso de privacidad.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../controllers/ajustes_controller.dart';
import '../../core/platform_support.dart';
import '../../l10n/app_localizations.dart';

/// Pantalla 10: tema, idioma, permisos y aviso de privacidad.
class AjustesScreen extends StatelessWidget {
  const AjustesScreen({super.key});

  void _privacidad(BuildContext context) {
    final l = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.privacy_tip_outlined),
        title: Text(l.privacyTitle),
        content: SingleChildScrollView(child: Text(l.privacyBody)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.close),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final ajustes = context.watch<AjustesController>();
    final tema = Theme.of(context);
    final idioma = ajustes.locale?.languageCode ?? 'sys';

    return Scaffold(
      appBar: AppBar(title: Text(l.settings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l.themeSection, style: tema.textTheme.titleMedium),
          const SizedBox(height: 8),
          SegmentedButton<ThemeMode>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(
                value: ThemeMode.system,
                icon: const Icon(Icons.brightness_auto),
                label: Text(l.themeSystem),
              ),
              ButtonSegment(
                value: ThemeMode.light,
                icon: const Icon(Icons.light_mode),
                label: Text(l.themeLight),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                icon: const Icon(Icons.dark_mode),
                label: Text(l.themeDark),
              ),
            ],
            selected: {ajustes.themeMode},
            onSelectionChanged: (s) => ajustes.setThemeMode(s.first),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.tonalIcon(
              onPressed: ajustes.alternarTema,
              icon: const Icon(Icons.contrast),
              label: Text(l.toggleTheme),
            ),
          ),
          const SizedBox(height: 24),
          Text(l.languageSection, style: tema.textTheme.titleMedium),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(
                value: 'sys',
                icon: const Icon(Icons.language),
                label: Text(l.themeSystem),
              ),
              ButtonSegment(value: 'es', label: Text(l.langSpanish)),
              ButtonSegment(value: 'en', label: Text(l.langEnglish)),
            ],
            selected: {idioma},
            onSelectionChanged: (s) => ajustes.setLocale(
              s.first == 'sys' ? null : Locale(s.first),
            ),
          ),
          const SizedBox(height: 24),
          Text(l.permissionsSection, style: tema.textTheme.titleMedium),
          _PermisoTile(
            permiso: Permission.camera,
            etiqueta: l.permCamera,
            icono: Icons.photo_camera_outlined,
          ),
          _PermisoTile(
            permiso: Permission.microphone,
            etiqueta: l.permMicrophone,
            icono: Icons.mic_none,
          ),
          const SizedBox(height: 16),
          Text(l.privacySection, style: tema.textTheme.titleMedium),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(l.privacyTitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _privacidad(context),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.view_in_ar_outlined),
            title: Text(l.arPrototype),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/ajustes/ar'),
          ),
        ],
      ),
    );
  }
}

class _PermisoTile extends StatefulWidget {
  const _PermisoTile({
    required this.permiso,
    required this.etiqueta,
    required this.icono,
  });

  final Permission permiso;
  final String etiqueta;
  final IconData icono;

  @override
  State<_PermisoTile> createState() => _PermisoTileState();
}

class _PermisoTileState extends State<_PermisoTile>
    with WidgetsBindingObserver {
  PermissionStatus? _estado;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _leer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Al volver de los ajustes del sistema se vuelve a leer el estado.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _leer();
  }

  Future<void> _leer() async {
    if (!esMovil) return;
    final estado = await widget.permiso.status;
    if (mounted) setState(() => _estado = estado);
  }

  Future<void> _pedir() async {
    final actual = _estado;
    if (actual != null && (actual.isPermanentlyDenied || actual.isRestricted)) {
      await openAppSettings();
      return;
    }
    final nuevo = await widget.permiso.request();
    if (mounted) setState(() => _estado = nuevo);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final concedido = _estado?.isGranted ?? false;
    final bloqueado = (_estado?.isPermanentlyDenied ?? false) ||
        (_estado?.isRestricted ?? false);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(widget.icono),
      title: Text(widget.etiqueta),
      subtitle: Text(
        !esMovil
            ? l.permNotApplicable
            : concedido
                ? l.permGranted
                : l.permDenied,
      ),
      trailing: !esMovil || concedido
          ? Icon(
              concedido ? Icons.check_circle : Icons.remove_circle_outline,
              color: concedido ? Theme.of(context).colorScheme.primary : null,
            )
          : OutlinedButton(
              onPressed: _pedir,
              child: Text(bloqueado ? l.permOpenSettings : l.permAsk),
            ),
    );
  }
}
