import 'package:broker_app/old/sidebar/sidebar_service.dart';

/// Adapter class to map between old NavigationScreen values and new AreaType
class NavigationAdapter {
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
      default:
        return AreaType.dashboard;
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
      default:
        return PaneType.clients;
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
      default:
        return NavigationScreen.dashboard;
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
      default:
        return SecondaryPanelType.calls;
    }
  }
}

/// An adapter for ScreenChangeCallback to AreaChangeCallback
AreaChangeCallback adaptScreenChangeCallback(ScreenChangeCallback callback) {
  return (AreaType area) {
    callback(NavigationAdapter.mapToScreen(area));
  };
}

/// An adapter for old panel callback to new pane callback
PaneChangeCallback adaptPanelChangeCallback(PanelChangeCallback callback) {
  return (PaneType pane) {
    callback(NavigationAdapter.mapToPanel(pane));
  };
} 