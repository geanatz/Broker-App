import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Service pentru gestionarea logicii calendarului
/// 
/// Această clasă gestionează toate operațiunile legate de calendar:
/// - Calcularea săptămânilor de lucru
/// - Formatarea datelor
/// - Navigarea între săptămâni
/// - Validarea sloturilor de timp
/// - Constante pentru afișarea calendarului
class CalendarService {
  static final CalendarService _instance = CalendarService._internal();
  factory CalendarService() => _instance;
  CalendarService._internal();

  // ===== CALENDAR CONSTANTS =====
  
  // Working hours configuration (9:30 to 16:00, every 30 minutes)
  static const List<String> workingHours = [
    '09:30', '10:00', '10:30', '11:00', '11:30', 
    '12:00', '12:30', '13:00', '13:30', '14:00', '14:30',
    '15:00', '15:30', '16:00'
  ];
  
  // Days of the week (Monday to Friday)
  static const List<String> workingDays = [
    'Luni', 'Marti', 'Miercuri', 'Joi', 'Vineri'
  ];
  
  // Calendar view constants
  static const int daysPerWeek = 5; // Monday to Friday only
  static const int weekdayOffset = 1; // Monday = 1 in DateTime

  // ===== SERVICE STATE =====
  
  // Formatter pentru date
  DateFormat? _dateFormatter;
  bool _isInitialized = false;

  /// Inițializează serviciul de calendar cu formatarea pentru limba română
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      await initializeDateFormatting('ro_RO', null);
      _dateFormatter = DateFormat('d MMM', 'ro_RO');
      _isInitialized = true;
      debugPrint('CalendarService initialized successfully');
    } catch (e) {
      debugPrint('Error initializing calendar date formatting: $e');
      // Fallback to default formatting
      _dateFormatter = DateFormat('d MMM');
      _isInitialized = true;
    }
  }

  /// Returnează formatterul pentru date
  DateFormat get dateFormatter {
    if (!_isInitialized || _dateFormatter == null) {
      _dateFormatter = DateFormat('d MMM');
    }
    return _dateFormatter!;
  }

  /// Calculează prima zi (Luni) a săptămânii de afișat
  /// 
  /// [weekOffset] - offset-ul săptămânii (0 = săptămâna curentă, -1 = săptămâna trecută, etc.)
  DateTime getStartOfWeekToDisplay(int weekOffset) {
    final now = DateTime.now();
    final currentWeekday = now.weekday; // Monday = 1, Sunday = 7

    DateTime baseMonday;
    
    // Dacă este Sâmbătă (6) sau Duminică (7)
    if (currentWeekday >= DateTime.saturday) {
      // Calculează zilele până la următoarea Luni
      final daysUntilNextMonday = 8 - currentWeekday;
      // Obține data următoarei Luni
      final nextMonday = now.add(Duration(days: daysUntilNextMonday));
      // Setează baseMonday la începutul acelei Luni
      baseMonday = DateTime(nextMonday.year, nextMonday.month, nextMonday.day);
    } else {
      // Dacă este Luni-Vineri, obține Luni din săptămâna curentă
      final currentMonday = now.subtract(Duration(days: currentWeekday - 1));
      // Setează baseMonday la începutul acelei Luni
      baseMonday = DateTime(currentMonday.year, currentMonday.month, currentMonday.day);
    }
    
    // Aplică offset-ul săptămânii
    return baseMonday.add(Duration(days: 7 * weekOffset));
  }

  /// Calculează sfârșitul săptămânii de lucru (Vineri)
  DateTime getEndOfWeekToDisplay(int weekOffset) {
    final startOfWeek = getStartOfWeekToDisplay(weekOffset);
    return startOfWeek.add(Duration(days: daysPerWeek - 1, hours: 23, minutes: 59));
  }

  /// Generează lista de date pentru săptămâna curentă
  List<String> getWeekDates(int weekOffset) {
    final startOfWeek = getStartOfWeekToDisplay(weekOffset);
    return List.generate(daysPerWeek, (index) {
      final date = startOfWeek.add(Duration(days: index));
      return dateFormatter.format(date).split(' ').first; // Doar numărul zilei
    });
  }

  /// Returnează informațiile despre luna și anul curent
  String getMonthYearString(int weekOffset) {
    final startOfWeek = getStartOfWeekToDisplay(weekOffset);
    final formatted = dateFormatter.format(startOfWeek).split(' ');
    return formatted.length > 1 
        ? formatted.sublist(1).join(' ') 
        : ''; // Luna și potențial anul
  }

  /// Generează intervalul de date pentru afișare (ex: "1-5 Dec")
  String getDateInterval(int weekOffset) {
    final weekDates = getWeekDates(weekOffset);
    final monthYear = getMonthYearString(weekOffset);
    return "${weekDates.first}-${weekDates.last} $monthYear";
  }

  /// Verifică dacă o dată este în săptămâna de lucru curentă
  bool isDateInCurrentWorkWeek(DateTime date, int weekOffset) {
    final startOfWeek = getStartOfWeekToDisplay(weekOffset);
    final endOfWeek = getEndOfWeekToDisplay(weekOffset);
    
    return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
           date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  /// Calculează indexul zilei pentru o dată dată (0-4 pentru Luni-Vineri)
  int? getDayIndexForDate(DateTime date, int weekOffset) {
    final startOfWeek = getStartOfWeekToDisplay(weekOffset);
    final dayDifference = date.difference(startOfWeek).inDays;
    
    if (dayDifference < 0 || dayDifference >= daysPerWeek) {
      return null; // Data nu este în săptămâna de lucru
    }
    
    return dayDifference;
  }

  /// Calculează indexul orei pentru o dată dată
  int getHourIndexForDateTime(DateTime dateTime) {
    final timeString = DateFormat('HH:mm').format(dateTime);
    final index = workingHours.indexOf(timeString);
    return index == -1 ? -1 : index;
  }

  /// Generează cheia slotului pentru maparea întâlnirilor
  String generateSlotKey(int dayIndex, int hourIndex) {
    return '$dayIndex-$hourIndex';
  }

  /// Parsează cheia slotului înapoi în indexuri
  Map<String, int>? parseSlotKey(String slotKey) {
    final parts = slotKey.split('-');
    if (parts.length != 2) return null;
    
    final dayIndex = int.tryParse(parts[0]);
    final hourIndex = int.tryParse(parts[1]);
    
    if (dayIndex == null || hourIndex == null) return null;
    
    return {
      'dayIndex': dayIndex,
      'hourIndex': hourIndex,
    };
  }

  /// Construiește un DateTime complet din indici de zi și oră
  DateTime buildDateTimeFromIndices(int weekOffset, int dayIndex, int hourIndex) {
    final startOfWeek = getStartOfWeekToDisplay(weekOffset);
    final selectedDate = startOfWeek.add(Duration(days: dayIndex));
    final selectedHour = workingHours[hourIndex];
    
    final timeParts = selectedHour.split(':');
    return DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );
  }

  /// Verifică dacă o oră este în programul de lucru
  bool isValidWorkingHour(String hour) {
    return workingHours.contains(hour);
  }

  /// Verifică dacă o zi este în săptămâna de lucru (Luni-Vineri)
  bool isValidWorkingDay(DateTime date) {
    final weekday = date.weekday;
    return weekday >= DateTime.monday && weekday <= DateTime.friday;
  }

  /// Calculează prima zi a săptămânii pentru o dată specifică
  DateTime getStartOfWeekForDate(DateTime date) {
    final weekday = date.weekday; // Monday = 1, Sunday = 7
    DateTime monday;
    
    if (weekday >= DateTime.saturday) {
      // Dacă este Sâmbătă sau Duminică, obține următoarea Luni
      final daysUntilNextMonday = 8 - weekday;
      final nextMonday = date.add(Duration(days: daysUntilNextMonday));
      monday = DateTime(nextMonday.year, nextMonday.month, nextMonday.day);
    } else {
      // Dacă este Luni-Vineri, obține Luni din săptămâna curentă
      final currentMonday = date.subtract(Duration(days: weekday - 1));
      monday = DateTime(currentMonday.year, currentMonday.month, currentMonday.day);
    }
    
    return monday;
  }

  /// Calculează offset-ul săptămânii pentru o dată specifică în raport cu săptămâna curentă
  int getWeekOffsetForDate(DateTime date) {
    final dateWeekStart = getStartOfWeekForDate(date);
    final currentWeekStart = getStartOfWeekToDisplay(0);
    final weekDifference = dateWeekStart.difference(currentWeekStart).inDays ~/ 7;
    return weekDifference;
  }

  /// Verifică dacă serviciul este inițializat
  bool get isInitialized => _isInitialized;

  /// Resetează starea serviciului (util pentru testing)
  void reset() {
    _isInitialized = false;
    _dateFormatter = null;
  }
}
