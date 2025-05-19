import 'package:flutter/material.dart';
import 'package:broker_app/frontend/common/appTheme.dart';
import 'package:broker_app/old/sidebar/sidebar_widget.dart';
import 'package:broker_app/old/sidebar/sidebar_service.dart';
import 'package:broker_app/frontend/areas/dashboardArea.dart';
import 'package:broker_app/frontend/areas/formArea.dart';
import 'package:broker_app/frontend/areas/calendarArea.dart';
import 'package:broker_app/frontend/areas/settingsArea.dart';
import 'package:broker_app/frontend/panes/meetingsPane.dart';
import 'package:broker_app/frontend/panes/calculatorPane.dart';

/// Ecranul principal al aplicației care conține cele 3 coloane:
/// - pane (stânga, lățime 312)
/// - area (centru, lățime flexibilă)
/// - sidebar (dreapta, lățime 224)
class MainScreen extends StatefulWidget {
  final String? consultantName;
  final String? teamName;
  
  const MainScreen({
    Key? key, 
    this.consultantName,
    this.teamName,
  }) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Starea actuală de navigare
  AreaType _currentArea = AreaType.form;
  PaneType _currentPane = PaneType.clients;
  
  // Consultant info
  late String _consultantName;
  late String _teamName;
  
  @override
  void initState() {
    super.initState();
    _consultantName = widget.consultantName ?? 'Consultant';
    _teamName = widget.teamName ?? 'Echipa';
  }
  
  // Widgets pentru area
  final Map<AreaType, Widget> _areaWidgets = {
    AreaType.dashboard: const DashboardArea(),
    AreaType.form: const FormArea(),
    AreaType.calendar: const CalendarArea(),
    AreaType.settings: const SettingsArea(),
  };
  
  final Map<PaneType, Widget> _paneWidgets = {
    PaneType.clients: const PlaceholderWidget('Clients Pane', Colors.red),
    PaneType.meetings: const MeetingsPane(),
    PaneType.calculator: const CalculatorPane(),
    PaneType.matches: const PlaceholderWidget('Matches Pane', Colors.pink),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.appBackground,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.mediumGap),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Pane Column (stânga) - lățime fixă 312
              SizedBox(
                width: 312,
                child: _paneWidgets[_currentPane]!,
              ),
              
              // Spacing
              const SizedBox(width: AppTheme.mediumGap),
              
              // Area Column (centru) - lățime flexibilă
              Expanded(
                child: _areaWidgets[_currentArea]!,
              ),
              
              // Spacing
              const SizedBox(width: AppTheme.mediumGap),
              
              // Sidebar Column (dreapta) - lățime fixă 224
              SidebarWidget(
                consultantName: _consultantName,
                teamName: _teamName,
                currentArea: _currentArea,
                currentPane: _currentPane,
                onAreaChanged: _handleAreaChanged,
                onPaneChanged: _handlePaneChanged,
                onClientsPopupRequested: _handleClientsPopupRequested,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _handleAreaChanged(AreaType area) {
    setState(() {
      _currentArea = area;
    });
  }
  
  void _handlePaneChanged(PaneType pane) {
    setState(() {
      _currentPane = pane;
    });
  }
  
  void _handleClientsPopupRequested() {
    // Implementarea popup-ului va fi adăugată mai târziu
    // cum a fost menționat în cerințe
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Clients Popup - not implemented yet')),
    );
  }
}

/// Widget simplu pentru placeholder
class PlaceholderWidget extends StatelessWidget {
  final String text;
  final Color color;
  
  const PlaceholderWidget(this.text, this.color, {Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
      ),
      child: Center(
        child: Text(
          text,
          style: AppTheme.headerTitleStyle,
        ),
      ),
    );
  }
}
