import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart';
import '../../sidebar/navigation_config.dart';
import '../../sidebar/user_widget.dart';
import '../../sidebar/navigation_widget.dart';
import '../../sidebar/user_config.dart';
import '../../widgets/common/panel_container.dart';
import '../../services/reservation_service.dart';
import '../../widgets/calendar/reservation_dialogs.dart';
import 'calendar_widgets.dart';
import 'calendar_constants.dart';

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
  // Service pentru rezervări
  final ReservationService _reservationService = ReservationService();
  
  // Firebase references
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Formatter pentru date
  late DateFormat dateFormatter = DateFormat('d MMM');
  
  // Tipul de calendar selectat
  ReservationType _selectedReservationType = ReservationType.meeting;
  
  // Controller pentru input nume client
  final TextEditingController _clientNameController = TextEditingController();

  // Calendar data
  final List<String> daysOfWeek = ['Luni', 'Marti', 'Miercuri', 'Joi', 'Vineri'];
  final List<String> hours = [
    '09:30', '10:00', '10:30', '11:00', '11:30', 
    '12:00', '12:30', '13:00', '13:30', '14:00', 
    '14:30', '15:00', '15:30', '16:00'
  ];
  
  // Current week offset (0 = current week, -1 = previous week, 1 = next week)
  int _currentWeekOffset = 0;

  @override
  void initState() {
    super.initState();
    
    // Initializeaza formatarea datelor pentru limba romana
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

  // Helper pentru a obtine numele afisat al calendarului in functie de tip
  String _getCalendarDisplayName(ReservationType type) {
    switch (type) {
      case ReservationType.meeting:
        return 'Intalniri cu clientii';
      case ReservationType.bureauDelete:
        return 'Stergere birou credit';
    }
  }

  // Helper pentru a obtine numele urmatorului tip de calendar (pentru tooltip buton)
  String _getNextCalendarDisplayName() {
    return _getCalendarDisplayName(
        _selectedReservationType == ReservationType.meeting 
        ? ReservationType.bureauDelete 
        : ReservationType.meeting);
  }
  
  // Helper function to determine the Monday of the week to display
  DateTime _getStartOfWeekToDisplay() {
    final now = DateTime.now();
    final currentWeekday = now.weekday; // Monday = 1, Sunday = 7

    DateTime baseMonday;
    // If it's Saturday (6) or Sunday (7)
    if (currentWeekday >= DateTime.saturday) {
      // Calculate days until next Monday
      final daysUntilNextMonday = 8 - currentWeekday;
      // Get next Monday's date
      final nextMonday = now.add(Duration(days: daysUntilNextMonday));
      // Set baseMonday to the beginning of that Monday
      baseMonday = DateTime(nextMonday.year, nextMonday.month, nextMonday.day);
    } else {
      // If it's Monday to Friday, get the current week's Monday
      final currentMonday = now.subtract(Duration(days: currentWeekday - 1));
      // Set baseMonday to the beginning of that Monday
      baseMonday = DateTime(currentMonday.year, currentMonday.month, currentMonday.day);
    }
    
    // Apply the week offset
    return baseMonday.add(Duration(days: 7 * _currentWeekOffset));
  }
  
  // Navigate to previous week
  void _navigateToPreviousWeek() {
    setState(() {
      _currentWeekOffset--;
    });
  }
  
  // Navigate to next week
  void _navigateToNextWeek() {
    setState(() {
      _currentWeekOffset++;
    });
  }
  
  // Navigate to current week
  void _navigateToCurrentWeek() {
    setState(() {
      _currentWeekOffset = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (dateFormatter == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator())
      );
    }

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

  /// Construieste layout-ul pentru ecrane mici (< 1200px)
  Widget _buildSmallScreenLayout(double contentHeight) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PanelContainer(
            width: double.infinity,
            child: _buildUpcomingWidget(),
          ),
          const SizedBox(height: AppTheme.largeGap),
          PanelContainer(
            width: double.infinity,
            child: _buildCalendarWidget(),
          ),
          const SizedBox(height: AppTheme.largeGap),
          Container(
            width: 224,
            child: Column(
              children: [
                UserWidget(
                  consultantName: widget.consultantName,
                  teamName: widget.teamName,
                  progress: 0.0,
                  callCount: 0,
                ),
                const SizedBox(height: AppTheme.mediumGap),
                NavigationWidget(
                  currentScreen: NavigationScreen.calendar,
                  onScreenChanged: widget.onScreenChanged,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construieste layout-ul pentru ecrane mari (>= 1200px)
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
          width: 1100,
          height: contentHeight,
          isExpanded: true,
          child: _buildCalendarWidget(),
        ),
        const SizedBox(width: AppTheme.largeGap),
        SizedBox(
          width: 224,
          height: contentHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              UserWidget(
                consultantName: widget.consultantName,
                teamName: widget.teamName,
                progress: 0.0,
                callCount: 0,
              ),
              const SizedBox(height: AppTheme.mediumGap),
              Expanded(
                child: NavigationWidget(
                  currentScreen: NavigationScreen.calendar,
                  onScreenChanged: widget.onScreenChanged,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Construieste widget-ul pentru "Upcoming" (programari viitoare)
  Widget _buildUpcomingWidget() {
    // Corrected header style according to meetingsSecondaryPanel.md
    final TextStyle headerStyle = GoogleFonts.outfit(
      fontSize: AppTheme.fontSizeLarge, // 19px
      fontWeight: FontWeight.w600,
      color: AppTheme.fontLightPurple, // #927B9D
    );
    final TextStyle secondaryStyle = const TextStyle(fontSize: AppTheme.fontSizeMedium, color: AppTheme.fontMediumPurple);

    final currentUserId = _auth.currentUser?.uid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch, // Changed from CrossAxisAlignment.start
      children: [
        // Header part - Title "Intalnirile mele"
        // PanelContainer has 8px padding. Header has 0px top/bottom, 16px left/right internal padding.
        // Total height of this header area should be 24px.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.mediumGap), // 16px horizontal to achieve 0px 16px internal
          child: SizedBox(
            height: 24.0, // Enforce header height
            child: Align(
              alignment: Alignment.centerLeft, // Align text to the left
              child: Text(
                'Intalnirile mele', // As per existing code, can be changed if "Întâlniri" is preferred from MD
                style: headerStyle,
              ),
            ),
          ),
        ),
        
        const SizedBox(height: AppTheme.smallGap), // 8px gap between header and list container

        Expanded(
          child: currentUserId == null
              ? Center(child: Text(
                  "Utilizator neconectat", 
                  style: secondaryStyle,
                ))
              : UpcomingAppointmentsList(
                  userId: currentUserId, 
                  dateFormatter: dateFormatter!,
                ),
        ),
      ],
    );
  }

  /// Construieste widget-ul pentru calendar
  Widget _buildCalendarWidget() {
    // Styling based on Figma design
    final DateTime startOfWeek = _getStartOfWeekToDisplay();
    final endOfWeek = startOfWeek.add(const Duration(days: 5)); 
    final List<String> weekDates = List.generate(5, (index) {
      return startOfWeek.add(Duration(days: index)).day.toString();
    });

    final dateInterval = "${weekDates.first}-${weekDates.last} ${dateFormatter!.format(startOfWeek).split(' ').last}";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Widget header with title and date navigation
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.smallGap),
          child: SizedBox(
            height: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Title "Calendar"
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.smallGap),
                  child: Text(
                    'Calendar',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w600,
                      fontSize: AppTheme.fontSizeLarge,
                      color: AppTheme.fontLightPurple,
                    ),
                  ),
                ),
                
                // Calendar switch - date navigation and type
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Arrow left
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: _navigateToPreviousWeek,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppTheme.smallGap),
                          child: SvgPicture.asset(
                            'assets/ArrowLeftIcon.svg',
                            width: 24,
                            height: 24,
                            colorFilter: ColorFilter.mode(
                              AppTheme.fontLightPurple,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Date interval text
                    GestureDetector(
                      onTap: _navigateToCurrentWeek,
                      child: SizedBox(
                        width: 128,
                        child: Center(
                          child: Tooltip(
                            message: _currentWeekOffset != 0 ? "Revenire la săptămâna curentă" : "",
                            child: Text(
                              dateInterval,
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w500,
                                fontSize: AppTheme.fontSizeSmall,
                                color: _currentWeekOffset != 0 
                                    ? AppTheme.fontMediumPurple 
                                    : AppTheme.fontLightPurple,
                                decoration: _currentWeekOffset != 0 
                                    ? TextDecoration.underline 
                                    : TextDecoration.none,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Arrow right
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: _navigateToNextWeek,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppTheme.smallGap),
                          child: SvgPicture.asset(
                            'assets/ArrowRightIcon.svg',
                            width: 24,
                            height: 24,
                            colorFilter: ColorFilter.mode(
                              AppTheme.fontLightPurple,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: AppTheme.smallGap),

                    // Calendar type selection (originally in header)
                    Text(
                      _getCalendarDisplayName(_selectedReservationType),
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w500,
                        fontSize: AppTheme.fontSizeSmall,
                        color: AppTheme.fontLightPurple,
                      ),
                    ),
                    const SizedBox(width: AppTheme.smallGap),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Tooltip(
                        message: "Schimba pe ${_getNextCalendarDisplayName()}",
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedReservationType = 
                                  _selectedReservationType == ReservationType.meeting 
                                  ? ReservationType.bureauDelete 
                                  : ReservationType.meeting;
                            });
                          },
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
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: AppTheme.smallGap),
        
        // Calendar container with days and slots
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(AppTheme.mediumGap),
            decoration: BoxDecoration(
              color: AppTheme.backgroundLightPurple,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Day headers - Ensure it has a fixed height of 24px
                SizedBox(
                  height: CalendarConstants.dayHeaderHeight,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: CalendarConstants.hourLabelWidth + AppTheme.mediumGap,
                    ),
                    child: Row(
                      children: List.generate(daysOfWeek.length, (index) {
                        return Expanded(
                          child: Text(
                            '${daysOfWeek[index]} ${weekDates[index]}',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w500,
                              fontSize: AppTheme.fontSizeSmall,
                              color: AppTheme.fontMediumPurple,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                
                const SizedBox(height: AppTheme.smallGap), // 8px gap from Figma
                
                // Calendar grid with hours and slots
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('reservations')
                        .where('dateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfWeek))
                        .where('dateTime', isLessThan: Timestamp.fromDate(endOfWeek))
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        print("Calendar Stream Error: ${snapshot.error}");
                        return const Center(child: Text('Eroare la incarcare calendar'));
                      }

                      final Map<String, Map<String, dynamic>> reservedSlotsMap = {};
                      final Map<String, String> reservedSlotsDocIds = {};
                      if (snapshot.hasData) {
                        for (var doc in snapshot.data!.docs) {
                          final data = doc.data() as Map<String, dynamic>;
                          
                          final type = data['type'] as String?;
                          final ReservationType? reservationType = type == 'meeting' 
                              ? ReservationType.meeting 
                              : (type == 'bureauDelete' ? ReservationType.bureauDelete : null);
                              
                          if (reservationType != _selectedReservationType) {
                            continue;
                          }
                          
                          final dateTime = (data['dateTime'] as Timestamp).toDate();
                          
                          final dayDifference = dateTime.difference(startOfWeek).inDays;
                          if (dayDifference < 0 || dayDifference > 4) continue;
                          final dayIndex = dayDifference;

                          final timeString = DateFormat('HH:mm').format(dateTime);
                          final hourIndex = hours.indexOf(timeString);
                          if (hourIndex == -1) continue;
                          
                          final slotKey = '$dayIndex-$hourIndex';
                          reservedSlotsMap[slotKey] = data;
                          reservedSlotsDocIds[slotKey] = doc.id;
                        }
                      }

                      return ScrollConfiguration(
                        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                        child: SingleChildScrollView(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start, 
                            children: [
                              // Hours column
                              // This column should effectively have 8px top padding before the first hour text.
                              // Each hour text is 24px high, followed by 56px gap.
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center, // Center text horizontally
                                children: [
                                  SizedBox(height: AppTheme.smallGap), // 8px top padding for the content of CalendarHours
                                  ...hours.expand((hour) {
                                    final isLastHour = hour == hours.last;
                                    return [
                                      Container(
                                        width: CalendarConstants.hourLabelWidth,
                                        height: CalendarConstants.dayHeaderHeight, // Hour text container height 24px
                                        alignment: Alignment.center,
                                        child: Text(
                                          hour,
                                          style: GoogleFonts.outfit(
                                            fontWeight: FontWeight.w500,
                                            fontSize: AppTheme.fontSizeSmall,
                                            color: AppTheme.fontMediumPurple,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      // Gap of 56px after each hour text, except the last one
                                      if (!isLastHour) const SizedBox(height: 56.0),
                                    ];
                                  }).toList(),
                                  // If a bottom padding of 8px is needed for CalendarHours, add it here.
                                  // Based on slot alignment, it might not be strictly necessary if total height matches slots.
                                  // For now, let total height be dynamic based on content.
                                ],
                              ),
                              
                              const SizedBox(width: AppTheme.mediumGap), // Gap between hours column and slots
                              
                              // Slots columns (one for each day)
                              Expanded(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: List.generate(daysOfWeek.length, (dayIndex) {
                                    // Each day column
                                    return Expanded(
                                      child: Container(
                                        width: CalendarConstants.slotColumnWidth,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(AppTheme.borderRadiusTiny),
                                        ),
                                        margin: EdgeInsets.only(right: dayIndex < daysOfWeek.length - 1 ? AppTheme.mediumGap : 0),
                                        child: Column(
                                          children: List.generate(hours.length, (hourIndex) {
                                            final slotKey = '$dayIndex-$hourIndex';
                                            final reservationData = reservedSlotsMap[slotKey];
                                            final docId = reservedSlotsDocIds[slotKey];
                                            final isReserved = reservationData != null;
                                        
                                            return Padding(
                                              padding: const EdgeInsets.only(bottom: CalendarConstants.slotGapVertical),
                                              child: SizedBox(
                                                height: CalendarConstants.slotHeight,
                                                width: double.infinity, 
                                                child: isReserved 
                                                  ? _buildReservedSlot(reservationData!, docId ?? slotKey)
                                                  : _buildAvailableSlot(dayIndex, hourIndex, _selectedReservationType), 
                                              ),
                                            );
                                          }),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReservedSlot(Map<String, dynamic> reservationData, String docId) {
    final consultantName = reservationData['consultantName'] ?? 'N/A';
    final clientName = reservationData['clientName'] ?? 'N/A';
    final consultantId = reservationData['consultantId'] as String?;
    final currentUserId = _auth.currentUser?.uid;
    final bool isOwner = consultantId != null && currentUserId == consultantId;
    
    final ReservationType calendarType = _selectedReservationType;

    return MouseRegion(
      cursor: isOwner ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: isOwner ? () => _showEditReservationDialog(reservationData, docId, calendarType) : null,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: CalendarConstants.slotPaddingHorizontal, 
            vertical: CalendarConstants.slotPaddingVertical
          ),
          decoration: BoxDecoration(
            color: AppTheme.backgroundDarkPurple,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
            boxShadow: [AppTheme.slotShadow],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                consultantName,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w600,
                  fontSize: AppTheme.fontSizeMedium,
                  color: AppTheme.fontDarkPurple,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                clientName,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w500,
                  fontSize: AppTheme.fontSizeSmall,
                  color: AppTheme.fontMediumPurple,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvailableSlot(int dayIndex, int hourIndex, ReservationType calendarType) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _showReservationDialog(dayIndex, hourIndex, calendarType),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: CalendarConstants.slotPaddingHorizontal, 
            vertical: CalendarConstants.slotPaddingVertical
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppTheme.backgroundDarkPurple, // Color from Figma for AvailableSlot border
              width: AppTheme.slotBorderThickness,
            ),
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
          ),
          child: Center(
            child: Text(
              'Creeaza intalnire',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w600,       // Figma: font-weight: 600
                fontSize: AppTheme.fontSizeMedium, // Figma: font-size: 17px
                color: AppTheme.fontMediumPurple,  // Figma: color: #886699
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  void _showReservationDialog(int dayIndex, int hourIndex, ReservationType calendarType) {
    final DateTime startOfWeek = _getStartOfWeekToDisplay(); 
    final selectedDate = startOfWeek.add(Duration(days: dayIndex));
    final selectedHourMinute = hours[hourIndex].split(':');
    final selectedDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      int.parse(selectedHourMinute[0]),
      int.parse(selectedHourMinute[1]),
    );

    _clientNameController.clear();

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.25),
      builder: (BuildContext context) {
        return CreateReservationDialog(
          clientNameController: _clientNameController,
          selectedDateTime: selectedDateTime,
          onSave: () {
                  final clientName = _clientNameController.text.trim();
                    _createReservation(selectedDateTime, clientName, calendarType);
                    Navigator.of(context).pop();
          }
        );
      },
    );
  }

  Future<void> _createReservation(DateTime dateTime, String clientName, ReservationType type) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final result = await _reservationService.createReservation(
        dateTime: dateTime,
        clientName: clientName,
        type: type,
      );

      Navigator.of(context).pop();

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Rezervare creata cu succes!"), backgroundColor: Colors.green)
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message']), backgroundColor: Colors.red)
        );
      }
    } catch (e) {
      Navigator.of(context).pop();
      print("Error creating reservation: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Eroare la crearea rezervarii: $e"), backgroundColor: Colors.red)
      );
    }
  }

  void _showEditReservationDialog(Map<String, dynamic> reservationData, String docId, ReservationType calendarType) {
    final initialClientName = reservationData['clientName'] as String? ?? '';
    final initialDateTime = (reservationData['dateTime'] as Timestamp).toDate();

    final clientNameController = TextEditingController(text: initialClientName);
    
    Future<List<String>> fetchAvailableTimeSlots(DateTime date, String excludeDocId) async {
      List<String> availableHours = [];
      try {
        final startOfDay = DateTime(date.year, date.month, date.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));
        
        Set<String> reservedTimes = {};
        
        QuerySnapshot reservations = await _firestore
            .collection('reservations')
            .where('dateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
            .where('dateTime', isLessThan: Timestamp.fromDate(endOfDay))
            .get();
            
        for (var doc in reservations.docs) {
          try {
            if (doc.id == excludeDocId) {
              continue; 
            }

            final data = doc.data() as Map<String, dynamic>;
            final type = data['type'] as String?;
            final ReservationType? reservationType = type == 'meeting' 
                ? ReservationType.meeting 
                : (type == 'bureauDelete' ? ReservationType.bureauDelete : null);
            
            if (reservationType != calendarType) {
              continue;
            }
            
            final timestamp = data['dateTime'] as Timestamp;
            final slotTime = DateFormat('HH:mm').format(timestamp.toDate());
            reservedTimes.add(slotTime);
          } catch (e) {
            print("Error processing a reservation document (${doc.id}): $e");
          }
        }
        
        availableHours = hours.where((hour) => !reservedTimes.contains(hour)).toList();
        
        String originalTimeSlot = DateFormat('HH:mm').format(initialDateTime);
        if (!availableHours.contains(originalTimeSlot)) {
          availableHours.add(originalTimeSlot);
          availableHours.sort();
        }
      } catch (e) {
        print("Error during fetchAvailableTimeSlots query/processing: $e");
        availableHours = [...hours];
      }
      
      return availableHours;
    }
    
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.25),
      builder: (BuildContext dialogContext) {
        return EditReservationDialog(
          reservationData: reservationData,
          docId: docId,
          clientNameController: clientNameController,
          initialDateTime: initialDateTime,
          onUpdate: _updateReservation,
          onDelete: _deleteReservation,
          fetchAvailableTimeSlots: fetchAvailableTimeSlots,
          calendarType: calendarType,
        );
      },
    );
  }

  Future<void> _updateReservation(String docId, String clientName, DateTime dateTime) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    
    try {
      final bool isAvailable = await _reservationService.isTimeSlotAvailable(
        dateTime, 
        excludeDocId: docId
      );
      
      if (!isAvailable) {
        if (context.mounted) Navigator.of(context).pop();
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Acest slot nu mai este disponibil.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      
      final result = await _reservationService.updateReservation(
        id: docId,
        clientName: clientName,
        dateTime: dateTime,
      );
      
      if (context.mounted) {
        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: result['success'] ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Eroare la actualizarea programarii: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteReservation(String docId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    
    try {
      final result = await _reservationService.deleteReservation(docId);
      
      if (context.mounted) {
        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: result['success'] ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Eroare la stergerea programarii: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
} 