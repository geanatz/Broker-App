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
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:broker_app/backend/services/consultant_service.dart';
import 'package:broker_app/backend/services/settings_service.dart';
import 'package:window_manager/window_manager.dart';

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
    debugPrint('Flutter error caught: ${details.exception}');
    debugPrint('${details.stack}');
  };

  // Run app in a guarded zone to catch all errors
  await runZonedGuarded(() async {
    // Initialize Flutter binding as early as possible
    WidgetsFlutterBinding.ensureInitialized();
    
    // Configure window manager for desktop platforms
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      await windowManager.ensureInitialized();
      
      WindowOptions windowOptions = const WindowOptions(
        size: Size(1496, 904),
        minimumSize: Size(1496, 904),
        center: true,
        backgroundColor: Colors.transparent,
        skipTaskbar: false,
        titleBarStyle: TitleBarStyle.normal,
      );
      
      windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
      });
    } 
    
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
          FirebaseFirestore.instance.settings = Settings(
            persistenceEnabled: true,
            cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
          );
        } catch (e) {
          debugPrint('Error enabling persistence: $e');
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
      debugPrint('PlatformDispatcher error: $error');
      debugPrint('$stack');
      return true;
    };
    
    // Initialize SettingsService early
    final settingsService = SettingsService();
    await settingsService.initialize();
    
    runApp(const MyApp());
  }, (error, stackTrace) {
    debugPrint('Caught error in runZonedGuarded: $error');
    debugPrint('$stackTrace');
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final SettingsService _settingsService = SettingsService();

  @override
  void initState() {
    super.initState();
    // Listen to theme changes
    _settingsService.addListener(_onThemeChanged);
    
    // Listen to AppTheme changes
    AppTheme().addListener(_onAppThemeChanged);
    
    // Listen to system brightness changes at app level
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _settingsService.removeListener(_onThemeChanged);
    AppTheme().removeListener(_onAppThemeChanged);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    // Update AppTheme when system brightness changes
    final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    debugPrint('🎨 MYAPP: System brightness changed to: $brightness');
    debugPrint('🎨 MYAPP: Current theme mode: ${AppTheme.currentThemeMode}');
    debugPrint('🎨 MYAPP: Settings service theme mode: ${_settingsService.currentThemeMode}');
    debugPrint('🎨 MYAPP: AppTheme.isDarkMode: ${AppTheme.isDarkMode}');
    debugPrint('🎨 MYAPP: AppTheme.popupBackground: ${AppTheme.popupBackground}');
    debugPrint('🎨 MYAPP: AppTheme.containerColor1: ${AppTheme.containerColor1}');
    
    AppTheme.refreshSystemBrightness();
    // Note: setState will be triggered by AppTheme listener
  }

  void _onThemeChanged() {
    setState(() {
      // Rebuild the app when theme changes
    });
  }

  void _onAppThemeChanged() {
    debugPrint('🎨 MYAPP: AppTheme changed, rebuilding entire app');
    setState(() {
      // Rebuild the entire app when AppTheme changes
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.appBackground,
      ),
      child: MaterialApp(
        title: 'Broker App',
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
            brightness: AppTheme.isDarkMode ? Brightness.dark : Brightness.light,
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
  final SettingsService _settingsService = SettingsService();
  late StreamSubscription<User?> _authSubscription;
  User? _lastKnownUser;

  @override
  void initState() {
    super.initState();
    // Listen to theme changes from SettingsService
    _settingsService.addListener(_onSettingsChanged);
    
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
    _settingsService.removeListener(_onSettingsChanged);
    _authSubscription.cancel();
    super.dispose();
  }

  void _onSettingsChanged() {
    if (mounted) {
      setState(() {
        // Rebuild when settings change
      });
    }
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
        
        // When user is logged out, reset to default theme
        _resetToDefaultTheme();
        
        return const AuthScreen(); // Navigheaza la noul AuthScreen
      },
    );
  }

  /// Reset theme to default when user logs out
  void _resetToDefaultTheme() async {
    // Use addPostFrameCallback to ensure this runs after the current build
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _settingsService.onConsultantChanged(); // This will load default theme
      // The listener will automatically trigger setState to rebuild the UI
    });
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
  final SettingsService _settingsService = SettingsService();

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
        // Reload theme settings for the current consultant
        await _settingsService.onConsultantChanged();
        
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
