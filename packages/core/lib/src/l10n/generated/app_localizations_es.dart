// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'EasyFleet';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get email => 'Correo';

  @override
  String get password => 'Contraseña';

  @override
  String get dashboard => 'Panel';

  @override
  String get trips => 'Viajes';

  @override
  String get liveTracking => 'Seguimiento en vivo';

  @override
  String get inspections => 'Inspecciones';

  @override
  String get alerts => 'Alertas';

  @override
  String get settings => 'Ajustes';

  @override
  String get map => 'Mapa';

  @override
  String get offline => 'Estás sin conexión';

  @override
  String get retry => 'Reintentar';

  @override
  String get noData => 'Aún no hay datos';

  @override
  String get loading => 'Cargando…';

  @override
  String get error => 'Algo salió mal';

  @override
  String get currentTrip => 'Viaje actual';

  @override
  String get wallet => 'Cartera';

  @override
  String get payouts => 'Pagos';

  @override
  String get vehicles => 'Vehículos';

  @override
  String get dispatch => 'Despacho';

  @override
  String get loadingReceipts => 'Recibos de carga';

  @override
  String get unloadTrips => 'Descargas';

  @override
  String get signUp => 'Registrarse';

  @override
  String get fullName => 'Nombre completo';

  @override
  String get confirmPassword => 'Confirmar contraseña';

  @override
  String get alreadyHaveAccount => '¿Ya tienes una cuenta? Inicia sesión';

  @override
  String get dontHaveAccount => '¿No tienes una cuenta? Regístrate';

  @override
  String get checkYourEmail =>
      'Cuenta creada. Revisa tu correo para confirmarla y luego inicia sesión.';

  @override
  String get signUpSuccess => 'Cuenta creada.';

  @override
  String get nameRequired => 'Introduce tu nombre';

  @override
  String get passwordTooShort => 'Usa al menos 6 caracteres';

  @override
  String get passwordMismatch => 'Las contraseñas no coinciden';
}
