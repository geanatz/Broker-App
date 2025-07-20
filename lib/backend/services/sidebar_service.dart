import 'package:flutter/material.dart';

// ========== ENUMS ==========

/// Enum defining the main navigation areas accessible via the sidebar.
enum AreaType {
  dashboard,  // Dashboard area - default first  
  form,       // Form area for client information
  calendar,   // Calendar area for meetings
  settings,   // Settings area
}

/// Enum defining the different pane types that can be displayed.
enum PaneType {
  clients,       // Client management pane
  meetings,      // Meetings management pane
  calculator,    // Financial calculator pane
  matches        // Bank matching recommendations pane
}

/// Enum defining the type of action a sidebar button performs.
enum ActionType {
  navigateToArea,      // Changes the main content area
  openPane,            // Opens or focuses a specific pane
  openPopup,           // Opens a popup dialog
  special              // Special actions like showing consultant details
}

/// Enum defining the different types of statistics that can be displayed
/// in the UserWidget's rotating section.
enum UserStatType {
  callsToday,
  callsThisWeek,
  meetingsToday,
  meetingsThisWeek,
  progressToMonthlyGoal, // Example: based on calls, revenue, etc.
}

// ========== LEGACY ENUMS (for backwards compatibility) ==========

/// Enum defining the main navigation screens accessible via the sidebar.
/// This helps in identifying the primary context for showing/hiding buttons.
enum NavigationScreen {
  dashboard,
  calendar,
  form,
  settings
}

/// Enum defining the types of secondary panels, typically shown within a specific screen (e.g., FormScreen).
/// Also used to identify specific buttons within the secondary panel.
enum SecondaryPanelType {
  calls,
  returns,
  calculator,
  recommendation
}

/// Enum defining the type of action a sidebar button performs in old navigation system.
enum SidebarButtonActionType {
  navigateToScreen,    // Navigates to a main NavigationScreen
  showSecondaryPanel,  // Shows a SecondaryPanelType within the current screen
}

// ========== CALLBACK TYPES ==========

typedef ScreenChangeCallback = void Function(NavigationScreen screen);
typedef PanelChangeCallback = void Function(SecondaryPanelType panel);
typedef AreaChangeCallback = void Function(AreaType area);
typedef PaneChangeCallback = void Function(PaneType pane);
typedef PopupCallback = void Function();

// ========== CONFIGURATION CLASSES ==========

/// Configuration for a sidebar button in the new system
class ButtonConfig {
  final String id;          // Unique identifier
  final String title;       // Text displayed on the button
  final String iconPath;    // Path to the SVG icon
  final ActionType actionType;  // What happens when button is clicked
  
  // Target based on action type
  final AreaType? targetArea;
  final PaneType? targetPane;
  final PopupCallback? popupAction;
  
  const ButtonConfig({
    required this.id,
    required this.title,
    required this.iconPath,
    required this.actionType,
    this.targetArea,
    this.targetPane,
    this.popupAction,
  });
}

/// Represents the configuration for a single button in the sidebar (legacy).
class SidebarButtonConfig {
  final String id;                     // Unique identifier (e.g., 'dashboard', 'form_calls')
  final String title;                  // Text displayed on the button
  final String iconPath;               // Path to the SVG icon
  final SidebarButtonActionType actionType; // What the button does

  // Action-specific parameters:
  final NavigationScreen? targetScreen;      // Used when actionType is navigateToScreen
  final SecondaryPanelType? targetPanel;     // Used when actionType is showSecondaryPanel

  // Visibility control:
  // If null, the button is always visible in the main navigation section.
  // If set, the button is only visible when the current screen matches.
  final NavigationScreen? visibleOnScreen;

  const SidebarButtonConfig({
    required this.id,
    required this.title,
    required this.iconPath,
    required this.actionType,
    this.targetScreen,
    this.targetPanel,
    this.visibleOnScreen,
  });
}

/// Represents the configuration for a single user statistic display.
class UserStatConfig {
  final UserStatType type;
          final String label;          // Text label (e.g., "Clienti Azi", "Progres Lunar")
  final String value;          // The formatted value to display (e.g., "15", "75%")
  final double? progress;      // Optional progress value (0.0 to 1.0) for progress bar stats
  final IconData? icon;        // Optional icon to display alongside the stat

  const UserStatConfig({
    required this.type,
    required this.label,
    required this.value,
    this.progress,
    this.icon,
  });
}

// ========== MAIN SERVICE CLASS ==========

/// Service class that manages sidebar navigation state and configurations
class SidebarService {
  // Current navigation state
  AreaType _currentArea = AreaType.dashboard;
  PaneType? _currentPane = PaneType.clients;
  
  // Debounce mechanism to prevent rapid clicks
  DateTime? _lastClickTime;
  static const Duration _clickDebounceDelay = Duration(milliseconds: 300);
  
  // Getters for current state
  AreaType get currentArea => _currentArea;
  PaneType? get currentPane => _currentPane;
  
  // Callback functions
  final AreaChangeCallback onAreaChanged;
  final PaneChangeCallback onPaneChanged;
  
  // Constructor
  SidebarService({
    required this.onAreaChanged,
    required this.onPaneChanged,
    AreaType initialArea = AreaType.dashboard,
    PaneType? initialPane,
  }) : 
    _currentArea = initialArea,
    _currentPane = initialPane;
  
  // ========== STATE MANAGEMENT ==========
  
  /// Change the current area
  void changeArea(AreaType area) {
    if (_currentArea != area) {
      debugPrint('🔄 SIDEBAR: Area change - From: $_currentArea, To: $area');
      _currentArea = area;
      onAreaChanged(area);
    } else {
      debugPrint('🔄 SIDEBAR: Area unchanged - Current: $_currentArea');
    }
  }
  
  /// Change the current pane
  void changePane(PaneType pane) {
    if (_currentPane != pane) {
      debugPrint('🔄 SIDEBAR: Pane change - From: $_currentPane, To: $pane');
      _currentPane = pane;
      onPaneChanged(pane);
    } else {
      debugPrint('🔄 SIDEBAR: Pane unchanged - Current: $_currentPane');
    }
  }
  
  /// Synchronize area state without triggering callbacks (for state restoration)
  void syncArea(AreaType area) {
    _currentArea = area;
  }
  
  /// Synchronize pane state without triggering callbacks (for state restoration)
  void syncPane(PaneType pane) {
    _currentPane = pane;
  }
  
  /// Handle button click based on its action type
  void handleButtonClick(ButtonConfig button) {

    
    // Debounce rapid clicks
    final now = DateTime.now();
    if (_lastClickTime != null && now.difference(_lastClickTime!) < _clickDebounceDelay) {
  
      return;
    }
    _lastClickTime = now;
    
    switch (button.actionType) {
      case ActionType.navigateToArea:
        if (button.targetArea != null) {
      
          changeArea(button.targetArea!);
        }
        break;
      case ActionType.openPane:
        if (button.targetPane != null) {
      
          changePane(button.targetPane!);
        }
        break;
      case ActionType.openPopup:
      case ActionType.special:
        if (button.popupAction != null) {
      
          button.popupAction!();
        }
        break;
    }
  }
  
  // ========== BUTTON CONFIGURATIONS ==========
  
  /// Predefined button configurations for the area section
  List<ButtonConfig> get areaButtons => [
    const ButtonConfig(
      id: 'home',
      title: 'Acasa',
      iconPath: 'assets/homeIcon.svg',
      actionType: ActionType.navigateToArea,
      targetArea: AreaType.dashboard,
    ),
    const ButtonConfig(
      id: 'form',
      title: 'Formular',
      iconPath: 'assets/formIcon.svg',
      actionType: ActionType.navigateToArea,
      targetArea: AreaType.form,
    ),
    const ButtonConfig(
      id: 'calendar',
      title: 'Calendar',
      iconPath: 'assets/calendarIcon.svg',
      actionType: ActionType.navigateToArea,
      targetArea: AreaType.calendar,
    ),
    const ButtonConfig(
      id: 'settings',
      title: 'Setari',
      iconPath: 'assets/settingsIcon.svg',
      actionType: ActionType.navigateToArea,
      targetArea: AreaType.settings,
    ),
  ];
  
  /// Predefined button configurations for the pane section
  List<ButtonConfig> get paneButtons => [
    const ButtonConfig(
      id: 'clients',
      title: 'Clienti',
      iconPath: 'assets/clientsIcon.svg',
      actionType: ActionType.openPane,
      targetPane: PaneType.clients,
    ),
    const ButtonConfig(
      id: 'meetings',
      title: 'Intalniri',
      iconPath: 'assets/meetingIcon.svg',
      actionType: ActionType.openPane,
      targetPane: PaneType.meetings,
    ),
    const ButtonConfig(
      id: 'calculator',
      title: 'Calculator',
      iconPath: 'assets/calculatorIcon.svg',
      actionType: ActionType.openPane,
      targetPane: PaneType.calculator,
    ),
    const ButtonConfig(
      id: 'matches',
      title: 'Recomandare',
      iconPath: 'assets/matcherIcon.svg',
      actionType: ActionType.openPane,
      targetPane: PaneType.matches,
    ),
  ];

  /// Butoane pentru functii speciale (export etc.)
  List<ButtonConfig> get specialButtons => [];

  // ========== LEGACY SUPPORT & ADAPTERS ==========

  /// Centralized list of all possible sidebar buttons (for backwards compatibility)
  static final List<SidebarButtonConfig> sidebarButtons = [
    // --- Main Navigation Buttons (visibleOnScreen == null) ---
    const SidebarButtonConfig(
      id: 'home',
      title: 'Acasa',
      iconPath: 'assets/homeIcon.svg',
      actionType: SidebarButtonActionType.navigateToScreen,
      targetScreen: NavigationScreen.dashboard,
    ),
    const SidebarButtonConfig(
      id: 'form',
      title: 'Formular',
      iconPath: 'assets/formIcon.svg',
      actionType: SidebarButtonActionType.navigateToScreen,
      targetScreen: NavigationScreen.form,
    ),
    const SidebarButtonConfig(
      id: 'calendar',
      title: 'Calendar',
      iconPath: 'assets/calendarIcon.svg',
      actionType: SidebarButtonActionType.navigateToScreen,
      targetScreen: NavigationScreen.calendar,
    ),
    const SidebarButtonConfig(
      id: 'settings',
      title: 'Setari',
      iconPath: 'assets/settingsIcon.svg',
      actionType: SidebarButtonActionType.navigateToScreen,
      targetScreen: NavigationScreen.settings,
    ),

    // --- Secondary Panel Buttons for FormScreen (visibleOnScreen == NavigationScreen.form) ---
    const SidebarButtonConfig(
      id: 'form_calls',
      title: 'Clienti',
      iconPath: 'assets/callIcon.svg',
      actionType: SidebarButtonActionType.showSecondaryPanel,
      targetPanel: SecondaryPanelType.calls,
      visibleOnScreen: NavigationScreen.form,
    ),
    const SidebarButtonConfig(
      id: 'form_returns',
      title: 'Reveniri',
      iconPath: 'assets/returnIcon.svg',
      actionType: SidebarButtonActionType.showSecondaryPanel,
      targetPanel: SecondaryPanelType.returns,
      visibleOnScreen: NavigationScreen.form,
    ),
    const SidebarButtonConfig(
      id: 'form_calculator',
      title: 'Calculator',
      iconPath: 'assets/calculatorIcon.svg',
      actionType: SidebarButtonActionType.showSecondaryPanel,
      targetPanel: SecondaryPanelType.calculator,
      visibleOnScreen: NavigationScreen.form,
    ),
    const SidebarButtonConfig(
      id: 'form_recommendation',
      title: 'Recomandare',
      iconPath: 'assets/matcherIcon.svg',
      actionType: SidebarButtonActionType.showSecondaryPanel,
      targetPanel: SecondaryPanelType.recommendation,
      visibleOnScreen: NavigationScreen.form,
    ),
  ];

  /// Function to get sample stats (for backwards compatibility)
  static List<UserStatConfig> getSampleUserStats() {
    return [
      // Progress bar stat (no label needed as it's shown differently)
      const UserStatConfig(
        type: UserStatType.progressToMonthlyGoal,
        label: '', // Empty label since progress bar doesn't show labels
        value: '68%',
        progress: 0.68,
        icon: Icons.show_chart,
      ),
      // Value stats with concise labels for horizontal display
      const UserStatConfig(
        type: UserStatType.callsToday,
        label: 'Clienti azi',
        value: '12',
        icon: Icons.call,
      ),
      const UserStatConfig(
        type: UserStatType.meetingsThisWeek,
        label: 'Intalniri sapt.',
        value: '5',
        icon: Icons.calendar_today,
      ),
      const UserStatConfig(
        type: UserStatType.callsThisWeek,
        label: 'Clienti sapt.',
        value: '42',
        icon: Icons.call,
      ),
    ];
  }

  // ========== MAPPING METHODS ==========

  /// Map old NavigationScreen to new AreaType
  static AreaType mapToArea(NavigationScreen screen) {
    switch (screen) {
      case NavigationScreen.dashboard:
        return AreaType.dashboard;
      case NavigationScreen.calendar:
        return AreaType.calendar;
      case NavigationScreen.form:
        return AreaType.form;
      case NavigationScreen.settings:
        return AreaType.settings;
    }
  }

  /// Map old SecondaryPanelType to new PaneType
  static PaneType mapToPane(SecondaryPanelType panel) {
    switch (panel) {
      case SecondaryPanelType.calls:
        return PaneType.clients;
      case SecondaryPanelType.returns:
        return PaneType.meetings;
      case SecondaryPanelType.calculator:
        return PaneType.calculator;
      case SecondaryPanelType.recommendation:
        return PaneType.matches;
    }
  }

  /// Map new AreaType to old NavigationScreen
  static NavigationScreen mapToScreen(AreaType area) {
    switch (area) {
      case AreaType.dashboard:
        return NavigationScreen.dashboard;
      case AreaType.calendar:
        return NavigationScreen.calendar;
      case AreaType.form:
        return NavigationScreen.form;
      case AreaType.settings:
        return NavigationScreen.settings;
    }
  }

  /// Map new PaneType to old SecondaryPanelType
  static SecondaryPanelType mapToPanel(PaneType pane) {
    switch (pane) {
      case PaneType.clients:
        return SecondaryPanelType.calls;
      case PaneType.meetings:
        return SecondaryPanelType.returns;
      case PaneType.calculator:
        return SecondaryPanelType.calculator;
      case PaneType.matches:
        return SecondaryPanelType.recommendation;
    }
  }

  // ========== ADAPTER METHODS ==========

  /// An adapter for ScreenChangeCallback to AreaChangeCallback
  static AreaChangeCallback adaptScreenChangeCallback(ScreenChangeCallback callback) {
    return (AreaType area) {
      callback(mapToScreen(area));
    };
  }

  /// An adapter for old panel callback to new pane callback
  static PaneChangeCallback adaptPanelChangeCallback(PanelChangeCallback callback) {
    return (PaneType pane) {
      callback(mapToPanel(pane));
    };
  }
}
