import 'package:broker_app/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:broker_app/backend/services/firebase_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:async';
import 'package:broker_app/frontend/screens/auth_screen.dart';
import 'package:broker_app/frontend/screens/splash_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:broker_app/backend/services/consultant_service.dart';

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
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Enable offline persistence using the new Settings API
  if (kIsWeb) {
    try {
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
    } catch (e) {
      debugPrint('[ERROR] Error enabling persistence: $e');
    }
  }

  // Set up error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    debugPrint('[ERROR][FLUTTER] ${details.exception}');
    debugPrint('${details.stack}');
  };

  // Handle platform errors
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('[ERROR][PLATFORM] $error');
    debugPrint('$stack');
    return true;
  };

  // Run the app in the same zone as ensureInitialized
  runApp(const MyApp());
  
  // Set up uncaught error handling after runApp
  runZonedGuarded(() {
    // This zone is only for catching uncaught errors, not for running the app
  }, (error, stackTrace) {
    debugPrint('[ERROR][UNCAUGHT] $error');
    debugPrint('$stackTrace');
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.appBackground,
      ),
      child: MaterialApp(
        title: 'Aplicatie de Consultanta Financiara',
        debugShowCheckedModeBanner: false,
        locale: const Locale('ro', 'RO'),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ro', 'RO'),
          Locale('en', 'US'),
        ],
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppTheme.elementColor2,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          textTheme: GoogleFonts.outfitTextTheme(),
          scaffoldBackgroundColor: Colors.transparent, // Make scaffold transparent to show gradient
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.transparent, // Make app bar transparent
            elevation: 0,
            centerTitle: true,
            titleTextStyle: GoogleFonts.outfit(
              color: AppTheme.elementColor2,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            iconTheme: IconThemeData(
              color: AppTheme.elementColor1,
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
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  late StreamSubscription<User?> _authSubscription;
  User? _lastKnownUser;

  @override
  void initState() {
    super.initState();
    
    // Listener manual optimizat - doar când se schimbă efectiv starea
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      // Doar dacă utilizatorul s-a schimbat efectiv
      if (_lastKnownUser?.uid != user?.uid) {
        _lastKnownUser = user;
        if (mounted) {
          setState(() {
            // Force rebuild when auth state actually changes
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Simplificam folosind doar authStateChanges pentru consistency
    return StreamBuilder<User?>( 
      stream: FirebaseAuth.instance.authStateChanges(), 
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        // Folosim datele din stream ca sursă primară de adevăr
        final streamUser = snapshot.data;
        final currentUser = FirebaseAuth.instance.currentUser;
        
        // Verificare dublă - considerăm utilizatorul autentificat doar dacă ambele confirmă
        final hasUser = streamUser != null && currentUser != null;
        
        if (hasUser) {
          return const MainAppWrapper();
        }
        
        return const AuthScreen(); // Navigheaza la noul AuthScreen
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
      // Nu mai facem signOut aici, AuthWrapper va duce la AuthScreen daca user e null
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
        // Daca utilizatorul autentificat nu are date in Firestore, ar trebui deconectat
        // pentru a preveni o stare invalida in aplicatie.
        await FirebaseAuth.instance.signOut(); // Acest signOut va fi detectat de AuthWrapper
        // setState-ul de mai jos nu va mai fi relevant imediat, dar e bun ca fallback.
        setState(() {
          _consultantData = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("❌ MAIN_APP_WRAPPER: Error fetching consultant data: $e");
      if (mounted) {
        setState(() {
          _consultantData = null;
          _isLoading = false;
          // Considera deconectarea si aici in caz de eroare la fetch
          // await FirebaseAuth.instance.signOut();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_consultantData == null) {
      // Aceasta stare nu ar trebui atinsa daca AuthWrapper functioneaza corect
      // si daca _fetchConsultantData deconecteaza user-ul daca nu are date.
      // Ca fallback, afisam un mesaj si AuthWrapper ar trebui sa intervina.
      debugPrint("MainAppWrapper: _consultantData is null, user should be redirected to AuthScreen by AuthWrapper.");
      return Scaffold(
        body: Center(
          child: Text("Date consultant indisponibile. Redirectionare...",
             style: TextStyle(color: AppTheme.elementColor2)),
        ),
      );
    }

    // Pass consultant data to SplashScreen which will pre-load services
    return SplashScreen(
      consultantData: _consultantData!,
    );
  }
}
