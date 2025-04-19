import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/auth/register.dart';
import 'screens/auth/login.dart';
import 'screens/auth/reset_password.dart';
import 'screens/auth/token.dart'; // Poți păstra acest ecran pentru moment, dar nu va fi folosit în fluxul standard de resetare parolă Firebase
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Listen for quick taps to show inspector
  int _tapCount = 0;
  DateTime? _lastTapTime;

  void _handleTap() {
    final now = DateTime.now();
    if (_lastTapTime != null &&
        now.difference(_lastTapTime!).inMilliseconds < 500) {
      _tapCount++;
      if (_tapCount == 5) { // 5 quick taps to toggle inspector
        setState(() {
          DebugOptions.toggleWidgetInspector();
          // Enable DevTools features when widget inspector is enabled
          if (DebugOptions.showWidgetInspector) {
            DebugOptions.showMaterialGrid = true;
          } else {
            DebugOptions.showMaterialGrid = false;
          }
        });
        _tapCount = 0;
      }
    } else {
      _tapCount = 1;
    }
    _lastTapTime = now;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.translucent,
      child: MaterialApp(
        title: 'Broker App',
        debugShowCheckedModeBanner: DebugOptions.showWidgetInspector, // Use this flag for inspection
        debugShowMaterialGrid: DebugOptions.showMaterialGrid,
        showSemanticsDebugger: DebugOptions.showSemanticsDebugger,
        showPerformanceOverlay: false,
        checkerboardRasterCacheImages: false,
        checkerboardOffscreenLayers: false,
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
        initialRoute: '/login', // Or check auth state here
        routes: {
          '/register': (context) => const RegisterScreen(),
          '/login': (context) => const LoginScreen(),
          '/token': (context) => const TokenScreen(), // Keeping for now, but explain its role
          '/reset_password': (context) => const ResetPasswordScreen(),
          '/dashboard': (context) => const Placeholder(), // Replace with your dashboard screen
        },
      ),
    );
  }
}