import 'package:flutter/material.dart';
import 'package:broker_app/old/sidebar/sidebar_widget.dart';
import 'package:broker_app/old/sidebar/sidebar_service.dart';
import 'package:broker_app/old/sidebar/navigation_adapter.dart';

/// A compatibility wrapper for SidebarWidget that accepts old navigation parameters
/// and converts them to the new format
class SidebarWidgetAdapter extends StatelessWidget {
  final String consultantName;
  final String teamName;
  final NavigationScreen currentScreen;
  final SecondaryPanelType? activeSecondaryPanel;
  final ScreenChangeCallback onScreenChanged;
  final PanelChangeCallback? onPanelChanged;

  const SidebarWidgetAdapter({
    Key? key,
    required this.consultantName,
    required this.teamName,
    required this.currentScreen,
    this.activeSecondaryPanel,
    required this.onScreenChanged,
    this.onPanelChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Convert old navigation parameters to new ones
    final AreaType currentArea = NavigationAdapter.mapToArea(currentScreen);
    
    // Convert old panel to new pane if it exists
    PaneType? currentPane;
    if (activeSecondaryPanel != null) {
      currentPane = NavigationAdapter.mapToPane(activeSecondaryPanel!);
    }
    
    // Create adapters for the callbacks
    final areaChangedCallback = adaptScreenChangeCallback(onScreenChanged);
    
    // Create an adapter for panel change callback if it exists
    PaneChangeCallback? paneChangedCallback;
    if (onPanelChanged != null) {
      paneChangedCallback = adaptPanelChangeCallback(onPanelChanged!);
    }
    
    // Return new sidebar widget with converted parameters
    return SidebarWidget(
      consultantName: consultantName,
      teamName: teamName,
      currentArea: currentArea,
      currentPane: currentPane,
      onAreaChanged: areaChangedCallback,
      onPaneChanged: paneChangedCallback ?? (_) {}, // Provide empty callback if none exists
      onClientsPopupRequested: () {
        // Simple implementation that doesn't do anything
        // This could be expanded later if needed
      },
    );
  }
} 