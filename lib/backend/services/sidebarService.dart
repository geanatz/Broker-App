import 'package:flutter/material.dart';

/// Enum pentru tipurile de arii care pot fi afișate în partea principală a ecranului
enum AreaType {
  formArea,      // Aria de formulare (credite)
  calendarArea,  // Aria de calendar (întâlniri)
  settingsArea,  // Aria de setări
  dashboardArea, // Aria de dashboard (statistici)
}

/// Enum pentru tipurile de panouri care pot fi afișate în partea secundară a ecranului
enum PaneType {
  clientsPane,    // Panoul cu clienți
  meetingsPane,   // Panoul cu întâlniri
  calculatorPane, // Panoul cu calculator
  matcherPane,    // Panoul cu recomandări (matcher)
}

/// Enum pentru tipurile de popup-uri care pot fi afișate peste ecran
enum PopupType {
  clientsPopup,     // Popup pentru adăugare/editare clienți
  consultantPopup,  // Popup cu informațiile consultantului
  meetingPopup,     // Popup pentru adăugare/editare întâlniri
  amortizationPopup // Popup pentru graficul de amortizare
}

/// Configurație pentru un buton din sidebar
class SidebarButtonConfig {
  final String id;         // ID unic pentru buton
  final String title;      // Textul afișat pe buton
  final String iconPath;   // Calea către iconița SVG
  final dynamic target;    // Ținta butonului (AreaType, PaneType, sau PopupType)
  final bool isVisible;    // Dacă butonul este vizibil

  const SidebarButtonConfig({
    required this.id,
    required this.title,
    required this.iconPath,
    required this.target,
    this.isVisible = true,
  });
}

/// Tipuri de callback-uri pentru gestionarea acțiunilor din sidebar
typedef AreaChangeCallback = void Function(AreaType area);
typedef PaneChangeCallback = void Function(PaneType pane);
typedef PopupShowCallback = void Function(PopupType popup);

/// Service pentru gestionarea stării și acțiunilor sidebar-ului
class SidebarService {
  // Singleton pattern
  static final SidebarService _instance = SidebarService._internal();
  
  factory SidebarService() => _instance;
  
  SidebarService._internal();

  // Stare curentă
  AreaType _currentArea = AreaType.formArea;
  PaneType _currentPane = PaneType.clientsPane;
  String _consultantName = '';
  String _teamName = '';

  // Getteri pentru starea curentă
  AreaType get currentArea => _currentArea;
  PaneType get currentPane => _currentPane;
  String get consultantName => _consultantName;
  String get teamName => _teamName;

  // Setteri pentru starea inițială
  void setInitialState({
    required String consultantName,
    required String teamName,
    AreaType initialArea = AreaType.formArea,
    PaneType initialPane = PaneType.clientsPane,
  }) {
    _consultantName = consultantName;
    _teamName = teamName;
    _currentArea = initialArea;
    _currentPane = initialPane;
  }

  // Metode pentru schimbarea stării
  void changeArea(AreaType newArea) {
    _currentArea = newArea;
  }

  void changePane(PaneType newPane) {
    _currentPane = newPane;
  }

  // Configurațiile butoanelor pentru fiecare secțiune
  
  // Buton User
  SidebarButtonConfig getUserButton() {
    return const SidebarButtonConfig(
      id: 'user',
      title: 'Profil',
      iconPath: 'assets/icons/UserIcon.svg',
      target: PopupType.consultantPopup,
    );
  }
  
  // Butoane Function
  List<SidebarButtonConfig> getFunctionButtons() {
    return [
      const SidebarButtonConfig(
        id: 'clients_function',
        title: 'Clienți',
        iconPath: 'assets/icons/ContactsIcon.svg',
        target: PopupType.clientsPopup,
      ),
    ];
  }
  
  // Butoane Areas
  List<SidebarButtonConfig> getAreaButtons() {
    return [
      const SidebarButtonConfig(
        id: 'form_area',
        title: 'Formular',
        iconPath: 'assets/icons/FormIcon.svg',
        target: AreaType.formArea,
      ),
      const SidebarButtonConfig(
        id: 'calendar_area',
        title: 'Calendar',
        iconPath: 'assets/icons/CalendarIcon.svg',
        target: AreaType.calendarArea,
      ),
      const SidebarButtonConfig(
        id: 'dashboard_area',
        title: 'Dashboard',
        iconPath: 'assets/icons/DashboardIcon.svg',
        target: AreaType.dashboardArea,
      ),
      const SidebarButtonConfig(
        id: 'settings_area',
        title: 'Setări',
        iconPath: 'assets/icons/SettingsIcon.svg',
        target: AreaType.settingsArea,
      ),
    ];
  }
  
  // Butoane Panes
  List<SidebarButtonConfig> getPaneButtons() {
    return [
      const SidebarButtonConfig(
        id: 'clients_pane',
        title: 'Clienți',
        iconPath: 'assets/icons/ContactsIcon.svg',
        target: PaneType.clientsPane,
      ),
      const SidebarButtonConfig(
        id: 'meetings_pane',
        title: 'Întâlniri',
        iconPath: 'assets/icons/MeetingIcon.svg',
        target: PaneType.meetingsPane,
      ),
      const SidebarButtonConfig(
        id: 'calculator_pane',
        title: 'Calculator',
        iconPath: 'assets/icons/CalculatorIcon.svg',
        target: PaneType.calculatorPane,
      ),
      const SidebarButtonConfig(
        id: 'matcher_pane',
        title: 'Recomandare',
        iconPath: 'assets/icons/RecommendIcon.svg',
        target: PaneType.matcherPane,
      ),
    ];
  }
  
  // Verifică dacă un buton este activ în funcție de starea curentă
  bool isButtonActive(dynamic buttonTarget) {
    if (buttonTarget is AreaType) {
      return _currentArea == buttonTarget;
    } else if (buttonTarget is PaneType) {
      return _currentPane == buttonTarget;
    }
    return false;
  }
}
