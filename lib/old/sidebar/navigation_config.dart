import 'package:flutter/material.dart';

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

/// Enum defining the type of action a sidebar button performs.
enum SidebarButtonActionType {
  navigateToScreen,    // Navigates to a main NavigationScreen
  showSecondaryPanel,  // Shows a SecondaryPanelType within the current screen
  // other actions like 'logout', 'openDialog', etc. could be added here
}

/// Represents the configuration for a single button in the sidebar.
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

// Callback types for sidebar actions
typedef ScreenChangeCallback = void Function(NavigationScreen screen);
typedef PanelChangeCallback = void Function(SecondaryPanelType panel);

// Centralized list of all possible sidebar buttons
final List<SidebarButtonConfig> sidebarButtons = [
  // --- Main Navigation Buttons (visibleOnScreen == null) ---
  const SidebarButtonConfig(
    id: 'dashboard',
    title: 'Dashboard',
    iconPath: 'assets/DashboardIcon.svg',
    actionType: SidebarButtonActionType.navigateToScreen,
    targetScreen: NavigationScreen.dashboard,
  ),
  const SidebarButtonConfig(
    id: 'form',
    title: 'Formular',
    iconPath: 'assets/FormIcon.svg',
    actionType: SidebarButtonActionType.navigateToScreen,
    targetScreen: NavigationScreen.form,
  ),
  const SidebarButtonConfig(
    id: 'calendar',
    title: 'Calendar',
    iconPath: 'assets/CalendarIcon.svg',
    actionType: SidebarButtonActionType.navigateToScreen,
    targetScreen: NavigationScreen.calendar,
  ),
  const SidebarButtonConfig(
    id: 'settings',
    title: 'Setari',
    iconPath: 'assets/SettingsIcon.svg',
    actionType: SidebarButtonActionType.navigateToScreen,
    targetScreen: NavigationScreen.settings,
  ),

  // --- Secondary Panel Buttons for FormScreen (visibleOnScreen == NavigationScreen.form) ---
  const SidebarButtonConfig(
    id: 'form_calls',
    title: 'Apeluri',
    iconPath: 'assets/CallIcon.svg',
    actionType: SidebarButtonActionType.showSecondaryPanel,
    targetPanel: SecondaryPanelType.calls,
    visibleOnScreen: NavigationScreen.form,
  ),
  const SidebarButtonConfig(
    id: 'form_returns',
    title: 'Reveniri',
    iconPath: 'assets/ReturnIcon.svg',
    actionType: SidebarButtonActionType.showSecondaryPanel,
    targetPanel: SecondaryPanelType.returns,
    visibleOnScreen: NavigationScreen.form,
  ),
  const SidebarButtonConfig(
    id: 'form_calculator',
    title: 'Calculator',
    iconPath: 'assets/CalculatorIcon.svg',
    actionType: SidebarButtonActionType.showSecondaryPanel,
    targetPanel: SecondaryPanelType.calculator,
    visibleOnScreen: NavigationScreen.form,
  ),
  const SidebarButtonConfig(
    id: 'form_recommendation',
    title: 'Recomandare',
    iconPath: 'assets/RecommendIcon.svg',
    actionType: SidebarButtonActionType.showSecondaryPanel,
    targetPanel: SecondaryPanelType.recommendation,
    visibleOnScreen: NavigationScreen.form,
  ),
]; 