import 'package:mat_finance/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mat_finance/backend/services/firebase_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:async';
import 'package:mat_finance/frontend/screens/auth_screen.dart';
import 'package:mat_finance/backend/services/update_service.dart';
import 'package:mat_finance/frontend/screens/splash_screen.dart';
import 'package:mat_finance/frontend/screens/mobile_auth_screen.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:mat_finance/backend/services/consultant_service.dart';
import 'package:mat_finance/backend/services/connection_service.dart';
import 'package:window_manager/window_manager.dart';
import 'package:mat_finance/utils/smooth_scroll_behavior.dart';

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

/// Custom logging filter to reduce Firebase verbosity
class FirebaseLogFilter {
  static bool shouldLog(String message) {
    // Filter out verbose Firestore internal logs
    final verbosePatterns = [
      'I/Firestore',
      'target_change',
      'read_time',
      'resume_token',
      'Persistence',
      'WatchStream',
      'document_change',
      'fields {',
      'value {',
      'string_value:',
      'integer_value:',
      'boolean_value:',
      'timestamp_value:',
      'null_value:',
      'map_value {',
      'array_value {',
      'name: "projects/',
      'update_time {',
      'create_time {',
      'nanos:',
      'seconds:',
      'target_ids:',
      'removed_target_ids:',
      'IndexBackfiller',
      'LruGarbageCollector',
      'Collect garbage',
      'Backfill Indexes',
      'Documents written:',
      'Cache size',
      'threshold',
      'No changes detected',
      'Duplicate update detected',
      'Using cached clients',
      'Refreshed clients from Firebase',
      'Real-time update received',
      'Operations update received',
      'Operation detected',
      'Client modified',
      'Category changes detected',
      'getClient called',
      'getClient consultantToken',
      'getClient fetching',
      'getClient document data',
      'Using cached consultant token',
      'Cached consultant token',
      'getCurrentConsultantToken called',
      'getCurrentConsultantToken currentUser',
      'getCurrentConsultantToken fetching',
      'getCurrentConsultantToken document exists',
      'getCurrentConsultantToken document data',
      'getCurrentConsultantToken token',
    ];
    
    // Check if message contains any verbose patterns
    for (final pattern in verbosePatterns) {
      if (message.contains(pattern)) {
        return false; // Don't log verbose messages
      }
    }
    
    // Allow only critical patterns
    final criticalPatterns = [
      'ERROR',
      'Exception',
      'Error',
      'CRITICAL',
      'FAILED',
      'Success',
      'Warning',
      'CLIENT: added',
      'CLIENT: removed',
      'CLIENT: category_change',
      'FIREBASE: added',
      'FIREBASE: removed',
      'FIREBASE: category_change',
    ];
    
    for (final pattern in criticalPatterns) {
      if (message.contains(pattern)) {
        return true; // Log critical messages
      }
    }
    
    // Default: don't log Firebase internal messages
    return !message.contains('I/Firestore') && !message.contains('Firestore(');
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
    // Headless pre-launch update on Windows before any window is shown
    if (!kIsWeb && Platform.isWindows) {
      try {
        final updater = UpdateService();
        await updater.initialize();
        // If an installer is cached, fetch release info to persist then install
        final ready = await updater.checkForReadyUpdate();
        if (ready) {
          try { await updater.checkForUpdates(); } catch (_) {}
          await updater.installUpdate();
          return; // process exits inside installUpdate
        }
        // Else check online
        final has = await updater.checkForUpdates();
        if (has) {
          final ok = await updater.startDownload();
          if (ok) {
            await updater.installUpdate();
            return; // process exits inside installUpdate
          }
        }
      } catch (e) {
        debugPrint('PRELAUNCH: update exception: $e');
      }
    }
    
    // Configure window manager for desktop platforms
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      await windowManager.ensureInitialized();
      
      WindowOptions windowOptions = const WindowOptions(
        size: Size(1496, 864),
        minimumSize: Size(1496, 864),
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
        ignoreUndefinedProperties: true,
      );
      
      // FIX: Disable verbose Firebase logging on mobile
      FirebaseFirestore.setLoggingEnabled(false);
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
            ignoreUndefinedProperties: true,
          );
        } catch (e) {
          debugPrint('Error enabling persistence: $e');
          // Fall back to memory-only mode if persistence fails
          FirebaseFirestore.instance.settings = Settings(
            persistenceEnabled: false,
            cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
            ignoreUndefinedProperties: true,
          );
        }
      } else {
        // Desktop platforms
        FirebaseFirestore.instance.settings = Settings(
          persistenceEnabled: true,
          cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
          ignoreUndefinedProperties: true,
        );
      }
      
      // FIX: Disable verbose Firebase logging on desktop
      FirebaseFirestore.setLoggingEnabled(false);
    }
    
    // Defer connection monitoring to after first frame to avoid platform-thread warnings
    
    // Set up global error handling for platform errors
    PlatformDispatcher.instance.onError = (error, stack) {
      debugPrint('PlatformDispatcher error: $error');
      debugPrint('$stack');
      return true;
    };
    
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

class _MyAppState extends State<MyApp> {
  final ConnectionService _connectionService = ConnectionService();
  @override
  void initState() {
    super.initState();
    // Initialize connection monitoring after first frame to ensure platform thread
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _connectionService.initialize();
    });
  }

  @override
  void dispose() {
    // ConnectionService is a singleton; no explicit dispose needed here
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.appBackground,
      ),
      child: MaterialApp(
        title: 'MAT Finance',
        debugShowCheckedModeBanner: false,
        scrollBehavior: SmoothScrollBehavior(),
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
            backgroundColor: Colors.transparent,
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
    
    // Listener manual optimizat - doar cand se schimaa efectiv starea
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      // Doar daca utilizatorul s-a schimbat efectiv
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
        
        // Folosim datele din stream ca sursa primara de adevar
        final streamUser = snapshot.data;
        final currentUser = FirebaseAuth.instance.currentUser;
        
        // Verificare dubla - consideram utilizatorul autentificat doar daca ambele confirma
        final hasUser = streamUser != null && currentUser != null;
        
        if (hasUser) {
          return const MainAppWrapper();
        }
        
        // Detect platform and show appropriate auth screen
        if (Platform.isAndroid || Platform.isIOS) {
          return const MobileAuthScreen();
        } else {
          return const AuthScreen(); // Desktop auth screen
        }
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

