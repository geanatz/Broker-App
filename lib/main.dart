import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/auth/register.dart';
import 'screens/auth/login.dart';
import 'screens/auth/reset_password.dart';
import 'screens/auth/token.dart'; // Poți păstra acest ecran pentru moment, dar nu va fi folosit în fluxul standard de resetare parolă Firebase
import 'screens/calendar_screen.dart'; // Import the CalendarScreen
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'package:firebase_auth/firebase_auth.dart'; // Added FirebaseAuth import
// Importă opțiunile default generate de FlutterFire CLI
import 'firebase_options.dart'; // Acest fișier este generat de comanda `flutterfire configure`

// For DevTools inspection
class DebugOptions {
  static bool showMaterialGrid = false;
  static bool showSemanticsDebugger = false;
  static bool showWidgetInspector = false;

  static void toggleMaterialGrid() {
    showMaterialGrid = !showMaterialGrid;
  }

  static void toggleSemanticsDebugger() {
    showSemanticsDebugger = !showSemanticsDebugger;
  }

  static void toggleWidgetInspector() {
    showWidgetInspector = !showWidgetInspector;
  }
}

void main() async { // Make main async
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter binding is initialized
  await Firebase.initializeApp( // Initialize Firebase
    options: DefaultFirebaseOptions.currentPlatform, // Use default options
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Removed GestureDetector and state management for debug toggles for simplicity now
    // Can be added back around AuthWrapper if needed
    return MaterialApp(
      title: 'Broker App',
      // Debug flags can be set here directly if needed for testing
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF866C93),
          primary: const Color(0xFF77677E),
          secondary: const Color(0xFF866C93),
          background: const Color(0xFFF2F2F2),
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.outfitTextTheme(),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Color(0xFF77677E),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: IconThemeData(
            color: Color(0xFF866C93),
          ),
        ),
      ),
      // Use AuthWrapper to determine the initial screen
      home: const AuthWrapper(),
      // Routes might still be useful for named navigation elsewhere
      routes: {
        '/register': (context) => const RegisterScreen(),
        '/login': (context) => const LoginScreen(),
        '/token': (context) => const TokenScreen(), // Keeping for now, but explain its role
        '/reset_password': (context) => const ResetPasswordScreen(),
        '/dashboard': (context) => const Placeholder(), // Replace with your dashboard screen
        '/calendar': (context) => const CalendarScreen(), // Add CalendarScreen route
      },
    );
  }
}

// New AuthWrapper Widget
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading indicator while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        // User is logged in, show CalendarScreen
        if (snapshot.hasData) {
          return const CalendarScreen();
        }
        
        // User is logged out, show LoginScreen
        return const LoginScreen();
      },
    );
  }
}