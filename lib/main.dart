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
import 'package:mat_finance/backend/services/update_config.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mat_finance/frontend/components/dialog_overlay_controller.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:mat_finance/backend/services/sidebar_service.dart';

// For DevTools inspection
class DebugOptions {
  static bool showMaterialGrid = false;
  static bool showSemanticsDebugger = false;
  static bool showWidgetInspector = false;
  // Control AI debug verbosity globally (affects '🤖 AI_DEBUG' logs)
  static bool aiDebugEnabled = false;

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

/// Global ValueNotifier for current area (used by titlebar)
class GlobalState {
  static final ValueNotifier<AreaType> currentAreaNotifier = ValueNotifier<AreaType>(AreaType.dashboard);
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
    // Setup filtered debugPrint to reduce noisy logs in debug without affecting business logic
    if (kDebugMode) {
      final originalDebugPrint = debugPrint;
      debugPrint = (String? message, {int? wrapWidth}) {
        if (message == null) return;
        // Hide AI_DEBUG logs when disabled
        if (!DebugOptions.aiDebugEnabled && message.startsWith('🤖 AI_DEBUG')) {
          return;
        }
        // Hide GoogleDrive verbose logs when AI debug disabled
        if (!DebugOptions.aiDebugEnabled && (message.startsWith('GD_VERIFY') || message.contains('GOOGLE_DRIVE_SERVICE'))) {
          return;
        }
        // Filter known Firestore desktop warnings about non-platform thread (cosmetic only)
        if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
          if (message.contains("plugins.flutter.io/firebase_firestore") &&
              message.contains("non-platform thread")) {
            return; // ignore cosmetic plugin warning in debug
          }
        }
        originalDebugPrint(message, wrapWidth: wrapWidth);
      };
    }
    // Headless pre-launch update on Windows before any window is shown
    if (!kIsWeb && Platform.isWindows && UpdateConfig.preLaunchUpdaterEnabled && !kDebugMode) {
      try {
        final updater = UpdateService();
        await updater.initialize();
        // If a cached installer exists, only install if a newer version is available
        final ready = await updater.checkForReadyUpdate();
        if (ready) {
          final has = await updater.checkForUpdates();
          if (has) {
            final installed = await updater.installUpdate();
            // Only abort normal startup if install succeeded and process exited inside installUpdate.
            // If installation failed (returns false), continue normal startup to avoid headless hang.
            if (installed) {
              return; // process exits inside installUpdate when relaunch succeeds
            }
            // Cleanup stale/corrupt installer and continue
            try { await updater.cancelUpdate(); } catch (_) {}
          } else {
            // Stale installer, clean up and continue normal startup
            await updater.cancelUpdate();
          }
        }
        // Online check: download+install only when newer version exists
        final has = await updater.checkForUpdates();
        if (has) {
          final ok = await updater.startDownload();
          if (ok) {
            final installed = await updater.installUpdate();
            if (installed) {
              return; // process exits inside installUpdate when relaunch succeeds
            }
            // If installation failed, fall through to normal app startup
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
        titleBarStyle: TitleBarStyle.hidden,
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
        gradient: AppTheme.backgroundColor1Gradient,
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
        builder: (context, child) {
          if (!kIsWeb && Platform.isWindows) {
            // Wrap desktop layout in a Stack so we can overlay the blurred dimmer above the custom titlebar
            return Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      width: double.infinity,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: const [
                          // Drag region (fills remaining space on the left)
                          _TitleBarDragRegion(),
                          SizedBox(width: 16),
                          _TitleBarIcon(assetPath: 'assets/minus_outlined.svg', action: TitleBarAction.minimize),
                          SizedBox(width: 16),
                          _TitleBarIcon(assetPath: 'assets/maximize_outlined.svg', action: TitleBarAction.maximizeToggle),
                          SizedBox(width: 16),
                          _TitleBarIcon(assetPath: 'assets/close_outlined.svg', action: TitleBarAction.close),
                        ],
                      ),
                    ),
                    Expanded(child: child ?? const SizedBox.shrink()),
                  ],
                ),
                // Titlebar-only dimmer when any dialog/popup is shown
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  height: 40,
                  child: IgnorePointer(
                    ignoring: true,
                    child: ValueListenableBuilder<bool>(
                      valueListenable: DialogOverlayController.instance.isShown,
                      builder: (context, isShown, _) {
                        return AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOutCubic,
                          opacity: isShown ? 1.0 : 0.0,
                          child: Container(color: Colors.black.withValues(alpha: 0.1)),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          }
          return child ?? const SizedBox.shrink();
        },
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

enum TitleBarAction { minimize, maximizeToggle, close }

class _TitleBarIcon extends StatelessWidget {
  final String assetPath;
  final TitleBarAction action;
  const _TitleBarIcon({required this.assetPath, required this.action});

  Future<void> _handle() async {
    try {
      switch (action) {
        case TitleBarAction.minimize:
          await windowManager.minimize();
          break;
        case TitleBarAction.maximizeToggle:
          final isMax = await windowManager.isMaximized();
          if (isMax) {
            await windowManager.unmaximize();
          } else {
            await windowManager.maximize();
          }
          break;
        case TitleBarAction.close:
          await windowManager.close();
          break;
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _handle,
      child: SizedBox(
        width: 24,
        height: 24,
        child: SvgPicture.asset(
          assetPath,
          width: 24,
          height: 24,
          fit: BoxFit.contain,
          colorFilter: ColorFilter.mode(AppTheme.elementColor1, BlendMode.srcIn),
        ),
      ),
    ),
    );
  }
}

class _TitleBarDragRegion extends StatefulWidget {
  const _TitleBarDragRegion();

  @override
  State<_TitleBarDragRegion> createState() => _TitleBarDragRegionState();
}

class _TitleBarDragRegionState extends State<_TitleBarDragRegion> {
  String _version = '0.1.9'; // Default fallback

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _version = _extractLastTwoVersionParts(packageInfo.version);
        });
      }
    } catch (e) {
      // Keep default version if loading fails
      _version = _extractLastTwoVersionParts(_version);
    }
  }

  String _extractLastTwoVersionParts(String fullVersion) {
    final parts = fullVersion.split('.');
    if (parts.length >= 2) {
      return parts.sublist(parts.length - 2).join('.');
    }
    return fullVersion; // Fallback to original if format is unexpected
  }

  Future<void> _handleDoubleTap() async {
    try {
      final isMax = await windowManager.isMaximized();
      if (isMax) {
        await windowManager.unmaximize();
      } else {
        await windowManager.maximize();
      }
    } catch (_) {}
  }

  Future<String> _loadConsultantName(User? user) async {
    if (user == null) {
      return 'Deconectat';
    }

    try {
      // Verificam daca Firebase este initializat
      if (!Firebase.apps.isNotEmpty) {
        return 'Consultant';
      }

      final doc = await FirebaseFirestore.instance.collection('consultants').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        return data?['name'] ?? 'Consultant';
      }
      return 'Consultant';
    } catch (e) {
      debugPrint('TitleBar: Error loading consultant name: $e');
      return 'Consultant';
    }
  }

  Future<int?> _loadConsultantColor(User? user) async {
    if (user == null) {
      return null;
    }

    try {
      // Verificam daca Firebase este initializat
      if (!Firebase.apps.isNotEmpty) {
        return null;
      }

      final doc = await FirebaseFirestore.instance.collection('consultants').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        final colorIndex = data?['colorIndex'] as int?;
        debugPrint('🎨 TITLEBAR: Loaded color index $colorIndex for consultant ${user.uid}');
        return colorIndex;
      }
      return null;
    } catch (e) {
      debugPrint('TitleBar: Error loading consultant color: $e');
      return null;
    }
  }

  int? _getCurrentConsultantColor(User? user, Map<String, int?>? colorSnapshotData, Map<String, dynamic>? dataSnapshotData) {
    if (user == null) {
      return null;
    }

    // Daca colorSnapshotData este disponibil, cauta culoarea dupa numele consultantului
    if (colorSnapshotData != null && colorSnapshotData.isNotEmpty) {
      // FIX: Cauta culoarea dupa numele consultantului din dataSnapshotData
      final consultantName = dataSnapshotData?['name'] as String?;
      if (consultantName != null && colorSnapshotData.containsKey(consultantName)) {
        return colorSnapshotData[consultantName];
      }
    }

    // Altfel, daca dataSnapshotData este disponibil, foloseste culoarea din future
    if (dataSnapshotData != null && dataSnapshotData.containsKey('colorIndex')) {
      return dataSnapshotData['colorIndex'] as int?;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanStart: (_) async {
          try {
            await windowManager.startDragging();
          } catch (_) {}
        },
        onDoubleTap: _handleDoubleTap,
        child: Row(
          children: [
            // Version display
            Container(
              width: 40,
              height: 24,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Center(
                child: Text(
                  _version,
                  style: GoogleFonts.martianMono(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.elementColor1,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Consultant name container with StreamBuilder for real-time updates
            StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                // FIX: Adauga un key unic pentru fiecare consultant pentru a forta rebuild-ul
                final userKey = snapshot.data?.uid ?? 'no_user';
                
                return StreamBuilder<Map<String, int?>>(
                  stream: ConsultantService().colorChangeStream,
                  builder: (context, colorSnapshot) {
                    return FutureBuilder<Map<String, dynamic>>(
                      key: ValueKey('consultant_$userKey'), // FIX: Key unic pentru fiecare consultant
                      future: Future.wait([
                        _loadConsultantName(snapshot.data),
                        _loadConsultantColor(snapshot.data),
                      ]).then((results) => {
                        'name': results[0],
                        'colorIndex': results[1],
                      }),
                      builder: (context, dataSnapshot) {
                        final displayName = dataSnapshot.data?['name'] ?? 'Se incarca...';
                        // FIX: Foloseste culoarea din stream doar daca e pentru consultantul curent
                        final colorIndex = _getCurrentConsultantColor(snapshot.data, colorSnapshot.data, dataSnapshot.data);

                        // Determina culoarea de fundal
                        final backgroundColor = colorIndex != null && colorIndex >= 1 && colorIndex <= 10
                            ? AppTheme.getConsultantColor(colorIndex)
                            : AppTheme.backgroundColor2;

                        // Determina culoarea pentru border
                        final borderColor = colorIndex != null && colorIndex >= 1 && colorIndex <= 10
                            ? AppTheme.getConsultantStrokeColor(colorIndex)
                            : AppTheme.backgroundColor3;

                        return Container(
                          height: 24,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: borderColor,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              displayName,
                              style: GoogleFonts.outfit(
                                fontSize: 15,
                                color: AppTheme.elementColor2,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
            // Current area name - centered with semibold, size 17, elementColor1
            Expanded(
              child: ValueListenableBuilder<AreaType>(
                valueListenable: GlobalState.currentAreaNotifier,
                builder: (context, currentArea, child) {
                  return Center(
                    child: Text(
                      SidebarService.getAreaDisplayName(currentArea),
                      style: GoogleFonts.outfit(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.elementColor1,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
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
  bool _startedFetch = false;

  @override
  void initState() {
    super.initState();
    // Amanam fetch-ul pana dupa primul frame pentru a evita mesaje de platform thread pe desktop
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      if (_startedFetch) return;
      _startedFetch = true;
      // Mic delay pe desktop pentru stabilitate plugin Firestore
      if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
        await Future<void>.delayed(const Duration(milliseconds: 1));
      }
      if (!mounted) return;
      await _fetchConsultantData();
    });
  }

  Future<void> _fetchConsultantData() async {
    if (!mounted) return;
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

