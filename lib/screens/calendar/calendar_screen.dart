import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../theme/app_theme.dart';
import '../../widgets/navigation/sidebar_widget.dart';
import '../../widgets/navigation/navigation_widget.dart';
import '../../widgets/common/panel_container.dart';

/// Tipurile de calendar disponibile
enum CalendarType {
  meetings,       // Întâlniri cu clienții
  creditBureau    // Stergere birou de credit
}

/// Ecranul principal de calendar al aplicației
class CalendarScreen extends StatefulWidget {
  /// Numele consultantului
  final String consultantName;
  
  /// Numele echipei
  final String teamName;
  
  /// Callback pentru schimbarea ecranului
  final Function(NavigationScreen) onScreenChanged;

  const CalendarScreen({
    Key? key,
    required this.consultantName,
    required this.teamName,
    required this.onScreenChanged,
  }) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  // Formatter pentru date
  late DateFormat dateFormatter;
  
  // Tipul de calendar selectat
  CalendarType _selectedCalendarType = CalendarType.meetings;
  
  // Controller pentru input nume client
  final TextEditingController _clientNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    
    // Inițializează formatarea datelor pentru limba română
    initializeDateFormatting('ro_RO', null).then((_) {
      if (mounted) {
        setState(() {
          dateFormatter = DateFormat('d MMM', 'ro_RO');
        });
      }
    });
  }

  @override
  void dispose() {
    _clientNameController.dispose();
    super.dispose();
  }

  // Helper pentru a obține numele colecției din Firestore în funcție de tipul de calendar
  String _getCollectionName(CalendarType type) {
    switch (type) {
      case CalendarType.meetings:
        return 'reservations';
      case CalendarType.creditBureau:
        return 'creditBureauAppointments';
    }
  }

  // Helper pentru a obține numele afișat al calendarului în funcție de tip
  String _getCalendarDisplayName(CalendarType type) {
    switch (type) {
      case CalendarType.meetings:
        return 'Întâlniri cu clienții';
      case CalendarType.creditBureau:
        return 'Ștergere birou credit';
    }
  }

  // Helper pentru a obține numele următorului tip de calendar (pentru tooltip buton)
  String _getNextCalendarDisplayName() {
    return _getCalendarDisplayName(
        _selectedCalendarType == CalendarType.meetings 
        ? CalendarType.creditBureau 
        : CalendarType.meetings);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 1200;
    final mainContentHeight = screenSize.height - 48;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppTheme.appBackgroundGradient,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.largeGap),
          child: isSmallScreen
            ? _buildSmallScreenLayout(mainContentHeight)
            : _buildLargeScreenLayout(mainContentHeight),
        ),
      ),
    );
  }

  /// Construiește layout-ul pentru ecrane mici (< 1200px)
  Widget _buildSmallScreenLayout(double contentHeight) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PanelContainer(
            width: double.infinity,
            height: 300,
            child: _buildUpcomingWidget(),
          ),
          const SizedBox(height: AppTheme.largeGap),
          PanelContainer(
            width: double.infinity,
            child: _buildCalendarWidget(),
          ),
          const SizedBox(height: AppTheme.largeGap),
          SidebarWidget(
            currentScreen: NavigationScreen.calendar,
            onScreenChanged: widget.onScreenChanged,
            consultantName: widget.consultantName,
            teamName: widget.teamName,
          ),
        ],
      ),
    );
  }

  /// Construiește layout-ul pentru ecrane mari (>= 1200px)
  Widget _buildLargeScreenLayout(double contentHeight) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PanelContainer(
          width: 224,
          height: contentHeight,
          child: _buildUpcomingWidget(),
        ),
        const SizedBox(width: AppTheme.largeGap),
        PanelContainer(
          width: 1100, // Lățimea panoului de calendar
          height: contentHeight,
          isExpanded: true,
          child: _buildCalendarWidget(),
        ),
        const SizedBox(width: AppTheme.largeGap),
        SidebarWidget(
          currentScreen: NavigationScreen.calendar,
          onScreenChanged: widget.onScreenChanged,
          consultantName: widget.consultantName,
          teamName: widget.teamName,
          height: contentHeight,
        ),
      ],
    );
  }

  /// Construiește widget-ul pentru "Upcoming" (programări viitoare)
  Widget _buildUpcomingWidget() {
    // TODO: Implementarea completă a UpcomingWidget va fi adăugată ulterior
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.mediumGap, 
            0, 
            AppTheme.mediumGap, 
            AppTheme.defaultGap
          ),
          child: Text(
            'Programările mele',
            style: AppTheme.headerTitleStyle,
          ),
        ),
        
        Expanded(
          child: Center(
            child: Text(
              'Programările viitoare vor fi afișate aici',
              style: AppTheme.secondaryTitleStyle,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  /// Construiește widget-ul pentru calendar
  Widget _buildCalendarWidget() {
    // TODO: Implementarea completă a CalendarWidget va fi adăugată ulterior
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.mediumGap, 
            0, 
            AppTheme.mediumGap, 
            AppTheme.defaultGap
          ),
          child: SizedBox(
            height: 24,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Calendar',
                    style: AppTheme.headerTitleStyle,
                  ),
                ),
                Text(
                  _getCalendarDisplayName(_selectedCalendarType),
                  style: AppTheme.subHeaderStyle,
                ),
                const SizedBox(width: AppTheme.defaultGap),
                Tooltip(
                  message: "Schimbă pe ${_getNextCalendarDisplayName()}",
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedCalendarType = 
                            _selectedCalendarType == CalendarType.meetings 
                            ? CalendarType.creditBureau 
                            : CalendarType.meetings;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: SvgPicture.asset(
                      'assets/SwapIcon.svg',
                      width: AppTheme.iconSizeSmall,
                      height: AppTheme.iconSizeSmall,
                      colorFilter: ColorFilter.mode(
                        AppTheme.fontLightPurple,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        Expanded(
          child: Container(
            decoration: AppTheme.calendarContainerDecoration,
            child: Center(
              child: Text(
                'Conținutul calendarului va fi afișat aici',
                style: AppTheme.secondaryTitleStyle.copyWith(
                  color: AppTheme.fontMediumPurple,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
} 