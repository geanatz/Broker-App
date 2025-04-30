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
import 'dart:async'; // Add this import for runZonedGuarded

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

void main() async { 
  // Wrap the app initialization in runZonedGuarded
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized(); 
    await Firebase.initializeApp( 
      options: DefaultFirebaseOptions.currentPlatform, 
  );
  runApp(const MyApp());
  }, (error, stackTrace) {
    // Handle errors that might occur during initialization or later
    print('Caught error in runZonedGuarded: $error');
    print(stackTrace);
    // You might want to report this error to a service like Crashlytics
  });
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
        // Log the connection state
        print('AuthWrapper: ConnectionState: ${snapshot.connectionState}');

        // Show loading indicator while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          print('AuthWrapper: Waiting for auth state...');
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        // Log whether user data exists
        print('AuthWrapper: Has user data? ${snapshot.hasData}');
        if (snapshot.hasData) {
          print('AuthWrapper: User is logged in (UID: ${snapshot.data?.uid}). Navigating to CalendarScreen.');
          return const CalendarScreen();
        }
        
        // User is logged out, show LoginScreen
        print('AuthWrapper: User is logged out. Navigating to LoginScreen.');
        return const LoginScreen();
      },
    );
  }
}