import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui'; // Для ImageFilter
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import 'l10n/app_localizations.dart';
import 'theme/app_theme.dart';

// Импорты моделей (для регистрации адаптеров)
import 'models/cycle_model.dart';
import 'models/personal_model.dart';

// Импорты Провайдеров
import 'providers/cycle_provider.dart';
import 'providers/wellness_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/prediction_provider.dart';
import 'providers/coc_provider.dart';

// Сервисы
import 'services/secure_storage_service.dart';
import 'services/notification_service.dart';
import 'services/auth_service.dart';

// Виджеты
import 'widgets/mesh_background.dart';

// Экраны
import 'screens/home_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/insights_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/splash_screen.dart'; // ✅ Используем наш новый красивый сплэш

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Инициализация Hive (База данных)
  await Hive.initFlutter();

  // 2. Регистрация Адаптеров (Чтобы Hive понимал наши классы)
  // Важно: ID должны совпадать с теми, что в @HiveType(typeId: ...)
  if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(CycleModelAdapter());
  if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(SymptomLogAdapter());
  if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(PersonalModelAdapter());
  if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(FlowIntensityAdapter());
  if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(CyclePhaseAdapter());

  // 3. Открытие Боксов (Таблиц)
  // Мы открываем их здесь, чтобы передать "горячими" в провайдеры
  // Имена боксов произвольные, но должны быть уникальными
  final settingsBox = await Hive.openBox('settings');
  final cycleBox = await Hive.openBox('cycles');
  final wellnessBox = await Hive.openBox<SymptomLog>('symptom_logs'); // Типизированный бокс
  final cocBox = await Hive.openBox('coc_settings');

  // Бокс для предсказаний открывается внутри PredictionProvider.init(),
  // но можно открыть и тут для надежности, если хотите.

  // 4. Настройка Системного UI
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

  // 5. Инициализация Сервисов
  final storageService = SecureStorageService();
  final notificationService = NotificationService();
  await notificationService.init();

  runApp(EviMoonAppRoot(
    settingsBox: settingsBox,
    cycleBox: cycleBox,
    wellnessBox: wellnessBox,
    cocBox: cocBox,
    storageService: storageService,
    notificationService: notificationService,
  ));
}

// Корневой виджет для настройки DI (Dependency Injection)
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
        // А. Базовые сервисы
        Provider<SecureStorageService>.value(value: storageService),
        Provider<NotificationService>.value(value: notificationService),

        // Б. Провайдеры (State Management)

        // 1. SettingsProvider: (Hive Box, SecureStorage)
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(settingsBox, storageService),
        ),

        // 2. CycleProvider: (Cycle Box, Settings Box, Notifications)
        ChangeNotifierProvider(
          create: (_) => CycleProvider(cycleBox, settingsBox, notificationService),
        ),

        // 3. WellnessProvider: (Wellness Box)
        ChangeNotifierProvider(
          create: (_) => WellnessProvider(wellnessBox),
        ),

        // 4. COCProvider: (COC Box, Notifications)
        ChangeNotifierProvider(
          create: (_) => COCProvider(cocBox, notificationService),
        ),

        // 5. PredictionProvider: Инициализируется сам
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
    // Слушаем настройки
    final settings = Provider.of<SettingsProvider>(context);

    // Устанавливаем локаль для форматирования дат
    Intl.defaultLocale = settings.locale.languageCode;

    return MaterialApp(
      title: 'EviMoon',
      debugShowCheckedModeBanner: false,

      // Тема
      theme: AppTheme.lightTheme,

      // Локализация
      locale: settings.locale,
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

      // 🔥 СТАРТ: SplashScreen
      // Он не требует аргументов, так как берет данные из Provider
      home: const SplashScreen(),
    );
  }
}

// --- AUTH GUARD (BIOMETRICS) ---
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
    // Получаем провайдер безопасным способом
    final settings = context.read<SettingsProvider>();

    // Если биометрия выключена -> пускаем
    if (!settings.biometricsEnabled) {
      if (mounted) setState(() { _isAuthenticated = true; _isChecking = false; });
      return;
    }

    // Иначе проверяем
    final auth = AuthService();
    bool canCheck = await auth.canCheckBiometrics;

    if (canCheck) {
      bool success = await auth.authenticate("Unlock EviMoon");
      if (mounted) setState(() { _isAuthenticated = success; _isChecking = false; });
    } else {
      // Fail-safe: если датчика нет, но настройка включена
      if (mounted) setState(() { _isAuthenticated = true; _isChecking = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      // Пока проверяем - белый экран или лоадер
      return const Scaffold(body: Center(child: CupertinoActivityIndicator()));
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
                const Text("EviMoon Locked", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                CupertinoButton.filled(
                    child: const Text("Unlock"),
                    onPressed: _checkAuth
                )
              ],
            )
        )
    );
  }
}

// --- MAIN SCREEN (NAVIGATION HOST) ---
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const CalendarScreen(),
    const InsightsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Триггер обновления данных при входе на главный экран
    final cyclePhase = Provider.of<CycleProvider>(context).currentData.phase;

    // Оборачиваем в AuthGuard для защиты всего приложения
    return AuthGuard(
      child: Scaffold(
        extendBody: true,
        // Живой фон
        body: MeshCycleBackground(
          phase: cyclePhase,
          child: Stack(
            children: [
              IndexedStack(
                index: _currentIndex,
                children: _screens,
              ),

              Positioned(
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewPadding.bottom > 0
                    ? MediaQuery.of(context).viewPadding.bottom + 10
                    : 25,
                child: _CrystalNavBar(
                  currentIndex: _currentIndex,
                  onTap: (index) {
                    HapticFeedback.lightImpact();
                    setState(() => _currentIndex = index);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- CRYSTAL NAV BAR ---
class _CrystalNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _CrystalNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.75),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavBarItem(icon: CupertinoIcons.drop_fill, index: 0, isSelected: currentIndex == 0, onTap: onTap),
              _NavBarItem(icon: CupertinoIcons.calendar, index: 1, isSelected: currentIndex == 1, onTap: onTap),
              _NavBarItem(icon: CupertinoIcons.graph_square_fill, index: 2, isSelected: currentIndex == 2, onTap: onTap),
              _NavBarItem(icon: CupertinoIcons.person_crop_circle, index: 3, isSelected: currentIndex == 3, onTap: onTap),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final int index;
  final bool isSelected;
  final ValueChanged<int> onTap;

  const _NavBarItem({required this.icon, required this.index, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: isSelected
            ? BoxDecoration(color: AppColors.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(20))
            : const BoxDecoration(color: Colors.transparent),
        child: Icon(icon, size: 26, color: isSelected ? AppColors.primary : AppColors.textSecondary),
      ),
    );
  }
}