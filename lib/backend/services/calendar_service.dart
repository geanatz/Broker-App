import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Service pentru gestionarea logicii calendarului
/// 
/// Aceasta clasa gestioneaza toate operatiunile legate de calendar:
/// - Calcularea saptamanilor de lucru
/// - Formatarea datelor
/// - Navigarea intre saptamani
/// - Validarea sloturilor de timp
/// - Constante pentru afisarea calendarului
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

  /// Initializeaza serviciul de calendar cu formatarea pentru limba romana
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      await initializeDateFormatting('ro_RO', null);
      _dateFormatter = DateFormat('d MMM', 'ro_RO');
      _isInitialized = true;
  
    } catch (e) {
      _dateFormatter = DateFormat('d MMM');
      _isInitialized = true;
    }
  }

  /// Returneaza formatterul pentru date
  DateFormat get dateFormatter {
    if (!_isInitialized || _dateFormatter == null) {
      _dateFormatter = DateFormat('d MMM');
    }
    return _dateFormatter!;
  }

  /// Calculeaza prima zi (Luni) a saptamanii de afisat
  /// 
  /// [weekOffset] - offset-ul saptamanii (0 = saptamana curenta, -1 = saptamana trecuta, etc.)
  DateTime getStartOfWeekToDisplay(int weekOffset) {
    final now = DateTime.now();
    final currentWeekday = now.weekday; // Monday = 1, Sunday = 7

    DateTime baseMonday;
    
    // Daca este Sambata (6) sau Duminica (7)
    if (currentWeekday >= DateTime.saturday) {
      // Calculeaza zilele pana la urmatoarea Luni
      final daysUntilNextMonday = 8 - currentWeekday;
      // Obtine data urmatoarei Luni
      final nextMonday = now.add(Duration(days: daysUntilNextMonday));
      // Seteaza baseMonday la inceputul acelei Luni
      baseMonday = DateTime(nextMonday.year, nextMonday.month, nextMonday.day);
    } else {
      // Daca este Luni-Vineri, obtine Luni din saptamana curenta
      final currentMonday = now.subtract(Duration(days: currentWeekday - 1));
      // Seteaza baseMonday la inceputul acelei Luni
      baseMonday = DateTime(currentMonday.year, currentMonday.month, currentMonday.day);
    }
    
    // Aplica offset-ul saptamanii
    return baseMonday.add(Duration(days: 7 * weekOffset));
  }

  /// Calculeaza sfarsitul saptamanii de lucru (Vineri)
  DateTime getEndOfWeekToDisplay(int weekOffset) {
    final startOfWeek = getStartOfWeekToDisplay(weekOffset);
    return startOfWeek.add(Duration(days: daysPerWeek - 1, hours: 23, minutes: 59));
  }

  /// Genereaza lista de date pentru saptamana curenta
  List<String> getWeekDates(int weekOffset) {
    final startOfWeek = getStartOfWeekToDisplay(weekOffset);
    return List.generate(daysPerWeek, (index) {
      final date = startOfWeek.add(Duration(days: index));
      return dateFormatter.format(date).split(' ').first; // Doar numarul zilei
    });
  }

  /// Returneaza informatiile despre luna si anul curent
  String getMonthYearString(int weekOffset) {
    final startOfWeek = getStartOfWeekToDisplay(weekOffset);
    final formatted = dateFormatter.format(startOfWeek).split(' ');
    return formatted.length > 1 
        ? formatted.sublist(1).join(' ') 
        : ''; // Luna si potential anul
  }

  /// Genereaza intervalul de date pentru afisare (ex: "1-5 Dec")
  String getDateInterval(int weekOffset) {
    final weekDates = getWeekDates(weekOffset);
    final monthYear = getMonthYearString(weekOffset);
    return "${weekDates.first}-${weekDates.last} $monthYear";
  }

  /// Verifica daca o data este in saptamana de lucru curenta
  bool isDateInCurrentWorkWeek(DateTime date, int weekOffset) {
    final startOfWeek = getStartOfWeekToDisplay(weekOffset);
    final endOfWeek = getEndOfWeekToDisplay(weekOffset);
    
    return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
           date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  /// Calculeaza indexul zilei pentru o data data (0-4 pentru Luni-Vineri)
  int? getDayIndexForDate(DateTime date, int weekOffset) {
    final startOfWeek = getStartOfWeekToDisplay(weekOffset);
    final dayDifference = date.difference(startOfWeek).inDays;
    
    if (dayDifference < 0 || dayDifference >= daysPerWeek) {
      return null; // Data nu este in saptamana de lucru
    }
    
    return dayDifference;
  }

  /// Calculeaza indexul orei pentru o data data
  int getHourIndexForDateTime(DateTime dateTime) {
    final timeString = DateFormat('HH:mm').format(dateTime);
    final index = workingHours.indexOf(timeString);
    return index == -1 ? -1 : index;
  }

  /// Genereaza cheia slotului pentru maparea intalnirilor
  String generateSlotKey(int dayIndex, int hourIndex) {
    return '$dayIndex-$hourIndex';
  }

  /// Parseaza cheia slotului inapoi in indexuri
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

  /// Construieste un DateTime complet din indici de zi si ora
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

  /// Verifica daca o ora este in programul de lucru
  bool isValidWorkingHour(String hour) {
    return workingHours.contains(hour);
  }

  /// Verifica daca o zi este in saptamana de lucru (Luni-Vineri)
  bool isValidWorkingDay(DateTime date) {
    final weekday = date.weekday;
    return weekday >= DateTime.monday && weekday <= DateTime.friday;
  }

  /// Calculeaza prima zi a saptamanii pentru o data specifica
  DateTime getStartOfWeekForDate(DateTime date) {
    final weekday = date.weekday; // Monday = 1, Sunday = 7
    DateTime monday;
    
    if (weekday >= DateTime.saturday) {
      // Daca este Sambata sau Duminica, obtine urmatoarea Luni
      final daysUntilNextMonday = 8 - weekday;
      final nextMonday = date.add(Duration(days: daysUntilNextMonday));
      monday = DateTime(nextMonday.year, nextMonday.month, nextMonday.day);
    } else {
      // Daca este Luni-Vineri, obtine Luni din saptamana curenta
      final currentMonday = date.subtract(Duration(days: weekday - 1));
      monday = DateTime(currentMonday.year, currentMonday.month, currentMonday.day);
    }
    
    return monday;
  }

  /// Calculeaza offset-ul saptamanii pentru o data specifica in raport cu saptamana curenta
  int getWeekOffsetForDate(DateTime date) {
    final dateWeekStart = getStartOfWeekForDate(date);
    final currentWeekStart = getStartOfWeekToDisplay(0);
    final weekDifference = dateWeekStart.difference(currentWeekStart).inDays ~/ 7;
    return weekDifference;
  }

  /// Verifica daca serviciul este initializat
  bool get isInitialized => _isInitialized;

  /// Reseteaza starea serviciului (util pentru testing)
  void reset() {
    _isInitialized = false;
    _dateFormatter = null;
  }
}
