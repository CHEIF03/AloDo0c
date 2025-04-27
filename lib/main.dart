import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

// Importez vos écrans
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/authentification/connexion_screen.dart';
import 'screens/authentification/inscription_screen.dart';
import 'screens/authentification/inscription_medecin_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);
  runApp(const AloDocApp());
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
      // Définissez le SplashScreen comme écran initial
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const ConnexionScreen(),
        '/signup': (context) => const InscriptionScreen(),
        '/doctor_signup': (context) => const InscriptionMedecinScreen(),
        '/home': (context) => const HomeScreen(), // Nouvelle route pour la page d'accueil
      },
    );
  }
}