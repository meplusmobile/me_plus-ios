import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:me_plus/core/theme/app_theme.dart';
import 'package:me_plus/core/localization/app_localizations.dart';
import 'package:me_plus/presentation/providers/signup_provider.dart';
import 'package:me_plus/presentation/providers/profile_provider.dart';
import 'package:me_plus/presentation/providers/locale_provider.dart';
import 'package:me_plus/presentation/providers/market_owner_provider.dart';
import 'package:me_plus/presentation/providers/market_profile_provider.dart';
import 'package:me_plus/presentation/providers/parent_profile_provider.dart';
import 'package:me_plus/presentation/providers/children_provider.dart';
import 'package:me_plus/routes/app_router.dart';

/// Main entry point of the application
void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Load environment variables
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Failed to load .env file: $e');
    // Continue with default values
  }

  // Set up error handlers
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('Flutter Error: ${details.exception}');
    debugPrint('Stack trace: ${details.stack}');
  };

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SignupData()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => MarketOwnerProvider()),
        ChangeNotifierProvider(create: (_) => MarketProfileProvider()),
        ChangeNotifierProvider(create: (_) => ParentProfileProvider()),
        ChangeNotifierProvider(create: (_) => ChildrenProvider()),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, child) {
          // iOS fix: Load locale after first frame
          WidgetsBinding.instance.addPostFrameCallback((_) {
            localeProvider.loadSavedLocale();
          });
          
          return MaterialApp.router(
            title: dotenv.env['APP_NAME'] ?? 'Me Plus',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            locale: localeProvider.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en', ''), Locale('ar', '')],
            routerConfig: AppRouter.router,
            builder: (context, child) {
              // Wrap with error boundary
              ErrorWidget.builder = (FlutterErrorDetails details) {
                return Material(
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(
                            'حدث خطأ غير متوقع\nAn unexpected error occurred',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16),
                          ),
                          if (details.exception != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              details.exception.toString(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              };
              return child ?? const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }
}
