import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'firebase_options.dart';

// Importez vos écrans
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/authentification/connexion_screen.dart';
import 'screens/authentification/inscription_screen.dart';
import 'screens/authentification/inscription_medecin_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text('Error: ${snapshot.error}'),
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.done) {
          return const AloDocApp();
        }

        return const MaterialApp(
          home: Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      },
    );
  }

  Future<void> _initializeApp() async {
    WidgetsFlutterBinding.ensureInitialized();

    if (kIsWeb) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.web,
      );
    } else {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    await initializeDateFormatting('fr_FR', null);
  }
}

class AloDocApp extends StatelessWidget {
  const AloDocApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AloDoc',
      theme: ThemeData(
        primaryColor: const Color(0xFF0D8B8B),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D8B8B),
          primary: const Color(0xFF0D8B8B),
        ),
        fontFamily: 'Roboto',
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0D8B8B),
            foregroundColor: Colors.white,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF0D8B8B),
            side: const BorderSide(color: Color(0xFF0D8B8B)),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const ConnexionScreen(),
        '/signup': (context) => const InscriptionScreen(),
        '/doctor_signup': (context) => const InscriptionMedecinScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}