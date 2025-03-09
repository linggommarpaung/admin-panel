// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart' as rf;
import 'package:responsive_grid/responsive_grid.dart';
import 'package:url_strategy/url_strategy.dart';

// 🌎 Project imports:
import 'app/core/app_config/app_config.dart';
import 'app/core/static/static.dart';
import 'app/core/theme/theme.dart';
import 'app/providers/providers.dart';
import 'app/routes/app_routes.dart';
import 'generated/l10n.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> main() async {
  setPathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyB6Mo1w81l_OtySo1SCqlhJhCL9weGd-_k",
        appId: "1:88945434212:web:91575d58ef673fc48c4971",
        messagingSenderId: "88945434212",
        projectId: "deutsche-freunde-indonesia",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  ResponsiveGridBreakpoints.value = ResponsiveGridBreakpoints(
    sm: 576,
    md: 1240,
    lg: double.infinity,
  );

  final _app = MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AppThemeProvider()),
      ChangeNotifierProvider(create: (_) => AppLanguageProvider()),
      ChangeNotifierProvider(create: (_) => ECommerceMockProductsNotifier()),
      ChangeNotifierProvider(create: (_) => AuthProvider()), // Tambahkan ini
    ],
    child: const AcnooApp(),
  );
  runApp(_app);
}

class AcnooApp extends StatelessWidget {
  const AcnooApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppThemeProvider, AppLanguageProvider>(
      builder: (context, appTheme, appLang, child) {
        return rf.ResponsiveBreakpoints.builder(
          breakpoints: [
            rf.Breakpoint(
              start: BreakpointName.XS.start,
              end: BreakpointName.XS.end,
              name: BreakpointName.XS.name,
            ),
            rf.Breakpoint(
              start: BreakpointName.SM.start,
              end: BreakpointName.SM.end,
              name: BreakpointName.SM.name,
            ),
            rf.Breakpoint(
              start: BreakpointName.MD.start,
              end: BreakpointName.MD.end,
              name: BreakpointName.MD.name,
            ),
            rf.Breakpoint(
              start: BreakpointName.LG.start,
              end: BreakpointName.LG.end,
              name: BreakpointName.LG.name,
            ),
            rf.Breakpoint(
              start: BreakpointName.XL.start,
              end: BreakpointName.XL.end,
              name: BreakpointName.XL.name,
            ),
          ],
          child: MaterialApp.router(
            title: AppConfig.appName,
            theme: AcnooAppTheme.kLightTheme(),
            darkTheme: AcnooAppTheme.kDarkTheme(),
            themeMode: appTheme.themeMode,

            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(rf.ResponsiveValue<double>(
                  context,
                  conditionalValues: [],
                  defaultValue: 1.0,
                ).value),
              ),
              child: Directionality(
                textDirection: appLang.isRTL
                    ? TextDirection.rtl
                    : Directionality.of(context),
                child: Stack(
                  children: [
                    Positioned.fill(child: child!),
                    if (kDebugMode)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Material(
                          child: Text("${MediaQuery.sizeOf(context)}"),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Language & Locale
            locale: appLang.currentLocale,
            localizationsDelegates: const [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: S.delegate.supportedLocales,

            // Navigation Configuration
            routerConfig: AcnooAppRoutes.routerConfig,
            debugShowCheckedModeBanner: false,
          ),
        );
      },
    );
  }
}

class AuthProvider with ChangeNotifier {
  User? _user;

  User? get user => _user;

  AuthProvider() {
    _listenAuthStateChanges();
  }

  void _listenAuthStateChanges() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }
}
