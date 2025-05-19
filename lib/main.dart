import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'old/screens/calendar/calendar_screen.dart';
import 'old/screens/form/form_screen.dart';
import 'old/screens/settings/settings_screen.dart';
import 'old/screens/dashboard/dashboard_screen.dart';
import 'old/sidebar/navigation_config.dart';
import 'package:broker_app/frontend/common/appTheme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'dart:async';
import 'package:broker_app/frontend/screens/authScreen.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:broker_app/old/services/consultant_service.dart';

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
  // Set an error handler for all Flutter errors
  FlutterError.onError = (FlutterErrorDetails details) {
    print('Flutter error caught: ${details.exception}');
    print(details.stack);
  };

  // Run app in a guarded zone to catch all errors
  await runZonedGuarded(() async {
    // Initialize Flutter binding as early as possible
    WidgetsFlutterBinding.ensureInitialized(); 
    
    // Initialize Firebase based on platform
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      // Mobile-specific initialization
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      
      // Configure Firestore settings for mobile platforms
      FirebaseFirestore.instance.settings = Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
      
      // Add platform-specific error handling for Firebase on mobile platforms
      if (Platform.isAndroid) {
        // Use correct approach for enabling Firebase logging
        FirebaseFirestore.setLoggingEnabled(true);
      }
    } else {
      // Web and desktop platforms
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      
      // Web-specific settings
      if (kIsWeb) {
        try {
          // Enable multi-tab persistence for web
          await FirebaseFirestore.instance.enablePersistence(
            const PersistenceSettings(synchronizeTabs: true),
          );
        } catch (e) {
          print('Error enabling persistence: $e');
          // Fall back to memory-only mode if persistence fails
          FirebaseFirestore.instance.settings = Settings(
            persistenceEnabled: false,
            cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
          );
        }
      } else {
        // Desktop platforms
        FirebaseFirestore.instance.settings = Settings(
          persistenceEnabled: true,
          cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
        );
      }
    }
    
    // Set up global error handling for platform errors
    PlatformDispatcher.instance.onError = (error, stack) {
      print('PlatformDispatcher error: $error');
      print(stack);
      return true;
    };
    
    runApp(const MyApp());
  }, (error, stackTrace) {
    print('Caught error in runZonedGuarded: $error');
    print(stackTrace);
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Broker App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppTheme.fontLightPurple,
          primary: AppTheme.fontMediumPurple,
          secondary: AppTheme.fontLightPurple,
          background: Colors.white,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.outfitTextTheme(),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.outfit(
            color: AppTheme.fontMediumPurple,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: IconThemeData(
            color: AppTheme.fontLightPurple,
          ),
        ),
      ),
      home: const AuthWrapper(),
      // routes: { // Eliminat vechile rute
      //   '/register': (context) => const RegisterScreen(),
      //   '/login': (context) => const LoginScreen(),
      //   '/token': (context) => const TokenScreen(),
      //   '/reset_password': (context) => const ResetPasswordScreen(),
      // },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>( 
      stream: FirebaseAuth.instance.authStateChanges(), 
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        if (snapshot.hasData) {
          return const MainAppWrapper();
        }
        
        return const AuthScreen(); // Navighează la noul AuthScreen
      },
    );
  }
}

class MainAppWrapper extends StatefulWidget {
  const MainAppWrapper({super.key});

  @override
  State<MainAppWrapper> createState() => _MainAppWrapperState();
}

class _MainAppWrapperState extends State<MainAppWrapper> {
  NavigationScreen _currentScreen = NavigationScreen.calendar;
  Map<String, dynamic>? _consultantData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchConsultantData();
  }

  Future<void> _fetchConsultantData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _consultantData = null;
        });
      }
      // Nu mai facem signOut aici, AuthWrapper va duce la AuthScreen dacă user e null
      return;
    }

    try {
      // Use ConsultantService instead of direct Firestore access
      final consultantService = ConsultantService();
      final consultantData = await consultantService.getCurrentConsultantData();
      
      if (!mounted) return;

      if (consultantData != null) {
        setState(() {
          _consultantData = consultantData;
          _isLoading = false;
        });
      } else {
        // Dacă utilizatorul autentificat nu are date în Firestore, ar trebui deconectat
        // pentru a preveni o stare invalidă în aplicație.
        await FirebaseAuth.instance.signOut(); // Acest signOut va fi detectat de AuthWrapper
        // setState-ul de mai jos nu va mai fi relevant imediat, dar e bun ca fallback.
        setState(() {
          _consultantData = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching consultant data: $e");
      if (mounted) {
        setState(() {
          _consultantData = null;
          _isLoading = false;
          // Consideră deconectarea și aici în caz de eroare la fetch
          // await FirebaseAuth.instance.signOut();
        });
      }
    }
  }

  void _handleScreenChange(NavigationScreen screen) {
    setState(() {
      _currentScreen = screen;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_consultantData == null) {
      // Această stare nu ar trebui atinsă dacă AuthWrapper funcționează corect
      // și dacă _fetchConsultantData deconectează user-ul dacă nu are date.
      // Ca fallback, afișăm un mesaj și AuthWrapper ar trebui să intervină.
      print("MainAppWrapper: _consultantData is null, user should be redirected to AuthScreen by AuthWrapper.");
      return const Scaffold(
        body: Center(
          child: Text("Date consultant indisponibile. Redirecționare...",
             style: TextStyle(color: AppTheme.fontMediumRed)),
        ),
      );
    }

    final String consultantName = _consultantData!['name'] ?? 'Consultant';
    final String teamName = _consultantData!['team'] ?? 'Echipa';

    switch (_currentScreen) {
      case NavigationScreen.calendar:
        return CalendarScreen(
          consultantName: consultantName,
          teamName: teamName,
          onScreenChanged: _handleScreenChange,
        );
      case NavigationScreen.form:
        return FormScreen(
          consultantName: consultantName,
          teamName: teamName,
          onScreenChanged: _handleScreenChange,
        );
      case NavigationScreen.settings:
        return SettingsScreen(
          consultantName: consultantName,
          teamName: teamName,
          onScreenChanged: _handleScreenChange,
        );
      case NavigationScreen.dashboard:
        return DashboardScreen(
          consultantName: consultantName,
          teamName: teamName,
          onScreenChanged: _handleScreenChange,
        );
      default:
        return CalendarScreen(
            consultantName: consultantName,
            teamName: teamName,
            onScreenChanged: _handleScreenChange);
    }
  }
}