import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'screens/auth/register.dart';
import 'screens/auth/login.dart';
import 'screens/auth/reset_password.dart';
import 'screens/auth/token.dart';
import 'screens/calendar/calendar_screen.dart';
import 'screens/form/form_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'sidebar/navigation_config.dart';
import 'theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'dart:async';

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
      // Use AuthWrapper to determine the initial screen
      home: const AuthWrapper(),
      // Routes pentru navigare
      routes: {
        '/register': (context) => const RegisterScreen(),
        '/login': (context) => const LoginScreen(),
        '/token': (context) => const TokenScreen(),
        '/reset_password': (context) => const ResetPasswordScreen(),
      },
    );
  }
}

// AuthWrapper verifica starea autentificarii
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
          print('AuthWrapper: User is logged in (UID: ${snapshot.data?.uid}). Navigating to MainApp.');
          return const MainAppWrapper();
        }
        
        // User is logged out, show LoginScreen
        print('AuthWrapper: User is logged out. Navigating to LoginScreen.');
        return const LoginScreen();
      },
    );
  }
}

// Wrapper pentru aplicatia principala care gestioneaza navigarea
class MainAppWrapper extends StatefulWidget {
  const MainAppWrapper({super.key});

  @override
  State<MainAppWrapper> createState() => _MainAppWrapperState();
}

class _MainAppWrapperState extends State<MainAppWrapper> {
  // Stare pentru ecranul activ
  NavigationScreen _currentScreen = NavigationScreen.calendar;
  
  // Datele consultantului (vor fi incarcate din Firebase)
  Map<String, dynamic>? _consultantData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchConsultantData();
  }

  // Incarcarea datelor consultantului din Firebase
  Future<void> _fetchConsultantData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _consultantData = null;
        });
      }
      return;
    }

    try {
      final consultantDoc = await FirebaseFirestore.instance
          .collection('consultants')
          .doc(currentUser.uid)
          .get();
      
      if (!mounted) return;

      if (consultantDoc.exists) {
        setState(() {
          _consultantData = consultantDoc.data() as Map<String, dynamic>?;
          _isLoading = false;
        });
      } else {
        // Daca utilizatorul nu are date de consultant asociate, deconecteaza-l
        await FirebaseAuth.instance.signOut();
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
        });
      }
    }
  }

  // Handler pentru schimbarea ecranului
  void _handleScreenChange(NavigationScreen screen) {
    setState(() {
      _currentScreen = screen;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Afiseaza indicator de incarcare in timp ce se incarca datele
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Verifica daca datele consultantului exista
    if (_consultantData == null) {
      return const Scaffold(
        body: Center(
          child: Text("Nu exista date de consultant asociate acestui cont."),
        ),
      );
    }

    // Extrage numele si echipa consultantului
    final String consultantName = _consultantData!['name'] ?? 'Consultant';
    final String teamName = _consultantData!['team'] ?? 'Echipa';

    // Afiseaza ecranul corespunzator
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
          onScreenChanged: _handleScreenChange,
        );
    }
  }
}