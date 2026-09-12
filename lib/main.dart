import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'state/app_state.dart';
import 'services/ai/ai_settings.dart';
import 'screens/onboarding_screen.dart';
import 'screens/main_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ManaApp());
}

class ManaApp extends StatefulWidget {
  const ManaApp({super.key});

  @override
  State<ManaApp> createState() => _ManaAppState();
}

class _ManaAppState extends State<ManaApp> {
  final AppState _appState = AppState();
  final AiSettings _aiSettings = AiSettings();

  @override
  void initState() {
    super.initState();
    _appState.load();
    _aiSettings.load();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppState>.value(value: _appState),
        ChangeNotifierProvider<AiSettings>.value(value: _aiSettings),
      ],
      child: Consumer<AppState>(
        builder: (context, app, _) {
          final c = app.colors;
          final isFa = app.lang == ManaLang.fa;

          // فونت وزیرمتن برای فارسی، Poppins برای انگلیسی
          final baseTextTheme = isFa
              ? GoogleFonts.vazirmatnTextTheme(ThemeData.dark().textTheme)
              : GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme);

          return MaterialApp(
            title: 'مانا دستیار',
            debugShowCheckedModeBanner: false,
            locale: isFa ? const Locale('fa') : const Locale('en'),
            // 🛠️ رفع باگ بحرانی: بدون این دلیگیت‌ها، ست‌کردن locale فارسی
            // باعث کرش «No MaterialLocalizations found for locale "fa"» میشد.
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('fa'), Locale('en')],
            theme: ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: c.bgDeep,
              textTheme: baseTextTheme.apply(
                bodyColor: c.textHi,
                displayColor: c.textHi,
              ),
              colorScheme: ColorScheme.dark(
                primary: c.accent1,
                secondary: c.accent2,
                surface: c.bgDeep2,
              ),
              useMaterial3: true,
            ),
            builder: (context, child) {
              // اعمال جهت راست‌به‌چپ/چپ‌به‌راست بر اساس زبان انتخابی
              return Directionality(
                textDirection: app.textDirection,
                child: child ?? const SizedBox.shrink(),
              );
            },
            home: !app.isLoaded
                ? const _SplashLoader()
                : (app.onboardingDone
                    ? const MainShell()
                    : const OnboardingScreen()),
          );
        },
      ),
    );
  }
}

class _SplashLoader extends StatelessWidget {
  const _SplashLoader();

  @override
  Widget build(BuildContext context) {
    return const Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Color(0xFF0D0A1A),
        body: Center(
          child: Text('🌙', style: TextStyle(fontSize: 40)),
        ),
      ),
    );
  }
}
