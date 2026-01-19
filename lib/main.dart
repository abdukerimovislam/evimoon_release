import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import 'l10n/app_localizations.dart';
import 'theme/app_theme.dart';

// Models
import 'models/cycle_model.dart';
import 'models/personal_model.dart';

// Providers
import 'providers/cycle_provider.dart';
import 'providers/wellness_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/prediction_provider.dart';
import 'providers/coc_provider.dart';

// Services
import 'services/secure_storage_service.dart';
import 'services/notification_service.dart';
import 'services/auth_service.dart';
import 'services/subscription_service.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/main_screen.dart';
import 'screens/profile/profile_screen.dart'; // ✅ правильный путь

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SubscriptionService.init();

  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(CycleModelAdapter());
  if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(SymptomLogAdapter());
  if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(PersonalModelAdapter());
  if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(FlowIntensityAdapter());
  if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(CyclePhaseAdapter());
  if (!Hive.isAdapterRegistered(5)) Hive.registerAdapter(OvulationTestResultAdapter());

  final settingsBox = await Hive.openBox('settings');
  final cycleBox = await Hive.openBox('cycles');
  final wellnessBox = await Hive.openBox('symptom_logs');
  final cocBox = await Hive.openBox('coc_settings');

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
  ));
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final storageService = SecureStorageService();

  final notificationService = NotificationService();
  await notificationService.init(
    onNotificationTap: (payload) {
      debugPrint("🚀 Notification Payload: $payload");

      Future.delayed(const Duration(milliseconds: 350), () {
        if (payload == NotificationService.payloadCOC) {
          navigatorKey.currentState?.pushNamed('/profile');
          return;
        }
        if (payload == NotificationService.payloadCalendar) {
          // Если есть отдельный экран календаря — замени на свой route.
          navigatorKey.currentState?.pushNamed('/calendar');
          return;
        }
      });
    },
  );

  runApp(EviMoonAppRoot(
    settingsBox: settingsBox,
    cycleBox: cycleBox,
    wellnessBox: wellnessBox,
    cocBox: cocBox,
    storageService: storageService,
    notificationService: notificationService,
  ));
}

class EviMoonAppRoot extends StatelessWidget {
  final Box settingsBox;
  final Box cycleBox;
  final Box wellnessBox;
  final Box cocBox;
  final SecureStorageService storageService;
  final NotificationService notificationService;

  const EviMoonAppRoot({
    super.key,
    required this.settingsBox,
    required this.cycleBox,
    required this.wellnessBox,
    required this.cocBox,
    required this.storageService,
    required this.notificationService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<SecureStorageService>.value(value: storageService),
        Provider<NotificationService>.value(value: notificationService),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(settingsBox, storageService, notificationService),
        ),
        ChangeNotifierProvider(
          create: (_) => CycleProvider(cycleBox, settingsBox, notificationService),
        ),
        ChangeNotifierProvider(
          create: (_) => WellnessProvider(wellnessBox),
        ),
        ChangeNotifierProvider(
          create: (_) => COCProvider(cocBox, notificationService),
        ),
        ChangeNotifierProvider(
          create: (_) => PredictionProvider()..init(),
        ),
      ],
      child: const EviMoonApp(),
    );
  }
}

class EviMoonApp extends StatelessWidget {
  const EviMoonApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    try {
      Intl.defaultLocale = settings.locale.languageCode;
    } catch (e) {
      debugPrint("Locale error: $e");
    }

    return MaterialApp(
      title: 'EviMoon',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: settings.locale,
      navigatorKey: navigatorKey,
      routes: {
        '/profile': (context) => const Scaffold(
          body: SafeArea(child: ProfileScreen()),
        ),
        '/calendar': (context) => const MainScreen(), // ✅ безопасный fallback
      },
      supportedLocales: const [
        Locale('en'),
        Locale('ru'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const AuthGuard(child: SplashScreen()),
    );
  }
}

class AuthGuard extends StatefulWidget {
  final Widget child;
  const AuthGuard({super.key, required this.child});
  @override
  State<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
  bool _isAuthenticated = false;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(Duration.zero);

    if (!mounted) return;

    final settings = context.read<SettingsProvider>();

    if (!settings.biometricsEnabled) {
      if (mounted) {
        setState(() {
          _isAuthenticated = true;
          _isChecking = false;
        });
      }
      return;
    }

    final auth = AuthService();
    final bool canCheck = await auth.canCheckBiometrics;

    if (canCheck) {
      final bool success = await auth.authenticate("Unlock EviMoon");
      if (mounted) {
        setState(() {
          _isAuthenticated = success;
          _isChecking = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isAuthenticated = true;
          _isChecking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CupertinoActivityIndicator()),
      );
    }

    return _isAuthenticated
        ? widget.child
        : Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 64, color: AppColors.primary),
            const SizedBox(height: 20),
            const Text(
              "EviMoon Locked",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            CupertinoButton.filled(
              child: const Text("Unlock"),
              onPressed: _checkAuth,
            ),
          ],
        ),
      ),
    );
  }
}
