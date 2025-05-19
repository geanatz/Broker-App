import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';

import 'package:broker_app/frontend/common/appTheme.dart';
import 'package:broker_app/old/sidebar/sidebar_service.dart';
import 'package:broker_app/old/sidebar/sidebar_widget.dart';
import 'package:broker_app/old/widgets/common/panel_container.dart';
import 'package:broker_app/old/services/reservation_service.dart';
import 'package:broker_app/old/screens/calendar/create_reservation_popup.dart';
import 'package:broker_app/old/screens/calendar/edit_reservation_popup.dart';
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
  
  // Formatter pentru date
  late DateFormat dateFormatter = DateFormat('d MMM');
  
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
          SizedBox(
            width: 224,
            child: SidebarWidgetAdapter(
              consultantName: widget.consultantName,
              teamName: widget.teamName,
              currentScreen: NavigationScreen.calendar,
              onScreenChanged: widget.onScreenChanged,
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
          child: SidebarWidgetAdapter(
            consultantName: widget.consultantName,
            teamName: widget.teamName,
            currentScreen: NavigationScreen.calendar,
            onScreenChanged: widget.onScreenChanged,
          ),
        ),
      ],
    );
  }

  /// Construieste widget-ul pentru "Upcoming" (programari viitoare)
  Widget _buildUpcomingWidget() {
    final TextStyle headerStyle = GoogleFonts.outfit(
      fontSize: AppTheme.fontSizeLarge,
      fontWeight: FontWeight.w600,
      color: AppTheme.fontLightPurple,
    );
    final TextStyle secondaryStyle = const TextStyle(fontSize: AppTheme.fontSizeMedium, color: AppTheme.fontMediumPurple);

    final currentUserId = _auth.currentUser?.uid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.mediumGap),
          child: SizedBox(
            height: 24.0,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Intalnirile mele',
                style: headerStyle,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppTheme.smallGap),
        Expanded(
          child: currentUserId == null
              ? Center(child: Text("Utilizator neconectat", style: secondaryStyle))
              : UpcomingAppointmentsList(
                  userId: currentUserId, 
                  dateFormatter: dateFormatter,
                ),
        ),
      ],
    );
  }

  /// Construieste widget-ul pentru calendar
  Widget _buildCalendarWidget() {
    final DateTime startOfWeek = _getStartOfWeekToDisplay();
    final endOfWeek = startOfWeek.add(const Duration(days: 5)); 
    final List<String> weekDates = List.generate(5, (index) {
      final date = startOfWeek.add(Duration(days: index));
      return dateFormatter.format(date).split(' ').first; // Only day number
    });

    final String monthYearString = dateFormatter.format(startOfWeek).split(' ').length > 1 
                                  ? dateFormatter.format(startOfWeek).split(' ').sublist(1).join(' ') 
                                  : ''; // Month and potentially year
    final dateInterval = "${weekDates.first}-${weekDates.last} $monthYearString";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.smallGap),
          child: SizedBox(
            height: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: _navigateToPreviousWeek,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppTheme.smallGap),
                          child: SvgPicture.asset(
                            'assets/leftIcon.svg',
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
                    GestureDetector(
                      onTap: _navigateToCurrentWeek,
                      child: SizedBox(
                        width: 128,
                        child: Center(
                          child: Tooltip(
                            message: _currentWeekOffset != 0 ? "Revenire la săptămâna curentă" : "",
                            child: Text(
                              dateInterval.trim(),
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
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: _navigateToNextWeek,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppTheme.smallGap),
                          child: SvgPicture.asset(
                            'assets/rightIcon.svg',
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
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppTheme.smallGap),
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
                SizedBox(
                  height: CalendarConstants.dayHeaderHeight,
                  child: Padding(
                  padding: const EdgeInsets.only(
                      left: CalendarConstants.hourLabelWidth + AppTheme.mediumGap,
                  ),
                  child: Row(
                    children: List.generate(daysOfWeek.length, (index) {
                      final currentDate = startOfWeek.add(Duration(days: index));
                      return Expanded(
                        child: Text(
                          '${daysOfWeek[index]} ${currentDate.day}', // Display day name and day number
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
                const SizedBox(height: AppTheme.smallGap),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _reservationService.getReservationsForWeek(startOfWeek, endOfWeek), // Fetch all types
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
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const SizedBox(height: AppTheme.smallGap),
                                  ...hours.expand((hour) {
                                    final isLastHour = hour == hours.last;
                                    return [
                                      Container(
                                        width: CalendarConstants.hourLabelWidth,
                                        height: CalendarConstants.dayHeaderHeight,
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
                                      if (!isLastHour) const SizedBox(height: 56.0),
                                    ];
                                  }).toList(),
                                ],
                              ),
                              const SizedBox(width: AppTheme.mediumGap),
                              Expanded(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: List.generate(daysOfWeek.length, (dayIndex) {
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
                                                  : _buildAvailableSlot(dayIndex, hourIndex), 
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
    
    // Determine the type from the reservation data itself
    final String? typeString = reservationData['type'] as String?;
    final ReservationType reservationType = typeString == 'bureauDelete' 
                                        ? ReservationType.bureauDelete 
                                        : ReservationType.meeting;

    return MouseRegion(
      cursor: isOwner ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: isOwner ? () => _showEditReservationDialog(reservationData, docId) : null,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: CalendarConstants.slotPaddingHorizontal, 
            vertical: CalendarConstants.slotPaddingVertical
          ),
          decoration: BoxDecoration(
            color: AppTheme.backgroundDarkPurple, // Default color
            // You might want to change color based on reservationType if needed
            // color: reservationType == ReservationType.bureauDelete ? Colors.lightBlueAccent : AppTheme.backgroundDarkPurple,
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
              // Optionally, display the type if it's important for visual distinction
              // Text(
              //   reservationType == ReservationType.meeting ? 'Întâlnire' : 'Ștergere Birou',
              //   style: GoogleFonts.outfit(
              //     fontSize: AppTheme.fontSizeTiny,
              //     color: AppTheme.fontDarkPurple.withOpacity(0.7),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvailableSlot(int dayIndex, int hourIndex) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _showReservationDialog(dayIndex, hourIndex),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: CalendarConstants.slotPaddingHorizontal, 
            vertical: CalendarConstants.slotPaddingVertical
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppTheme.backgroundDarkPurple,
              width: AppTheme.slotBorderThickness,
            ),
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
          ),
          child: Center(
            child: Text(
              'Creeaza programare', // Changed from 'Creeaza intalnire'
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w600,
                fontSize: AppTheme.fontSizeMedium,
                color: AppTheme.fontMediumPurple,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  void _showReservationDialog(int dayIndex, int hourIndex) {
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
      barrierColor: Colors.black.withOpacity(0.25), // Standard blur
      builder: (BuildContext context) {
        return CreateReservationDialog(
          clientNameController: _clientNameController,
          selectedDateTime: selectedDateTime,
          onSave: (clientName, phoneNumber, type) {
            _createReservation(selectedDateTime, clientName, phoneNumber, type);
            Navigator.of(context).pop(); // Close dialog after save attempt
          }
        );
      },
    );
  }

  Future<void> _createReservation(DateTime dateTime, String clientName, String phoneNumber, ReservationType type) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final result = await _reservationService.createReservation(
        dateTime: dateTime,
        clientName: clientName,
        phoneNumber: phoneNumber,
        type: type,
      );

      Navigator.of(context).pop(); // Dismiss loading indicator

      if (mounted) { // Check if widget is still in the tree
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']), 
            backgroundColor: result['success'] ? Colors.green : Colors.red
          )
        );
      }
    } catch (e) {
      Navigator.of(context).pop(); // Dismiss loading indicator
      print("Error creating reservation: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Eroare la crearea rezervarii: $e"), backgroundColor: Colors.red)
        );
      }
    }
  }

  void _showEditReservationDialog(Map<String, dynamic> reservationData, String docId) {
    final initialClientName = reservationData['clientName'] as String? ?? '';
    final initialDateTime = (reservationData['dateTime'] as Timestamp).toDate();
    // final initialPhoneNumber = reservationData['phoneNumber'] as String? ?? ''; // Already handled in EditReservationDialog
    // final initialTypeString = reservationData['type'] as String?; // Already handled in EditReservationDialog
    // final initialType = initialTypeString == 'bureauDelete' ? ReservationType.bureauDelete : ReservationType.meeting;


    final clientNameController = TextEditingController(text: initialClientName);
    // final phoneController = TextEditingController(text: initialPhoneNumber);
    
    Future<List<String>> fetchAvailableTimeSlots(DateTime date, String excludeDocId) async {
      List<String> availableHoursList = []; // Renamed to avoid conflict
      try {
        final startOfDay = DateTime(date.year, date.month, date.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));
        
        Set<String> reservedTimes = {};
        
        // Use ReservationService instead of direct Firestore access
        final reservationsStream = _reservationService.getReservationsForWeek(startOfDay, endOfDay);
        final reservationsSnapshot = await reservationsStream.first;
            
        for (var doc in reservationsSnapshot.docs) {
          if (doc.id == excludeDocId) { // Don't count the current reservation being edited
            continue; 
          }
          final data = doc.data() as Map<String, dynamic>;
          final timestamp = data['dateTime'] as Timestamp;
          final slotTime = DateFormat('HH:mm').format(timestamp.toDate());
          reservedTimes.add(slotTime);
        }
        
        availableHoursList = hours.where((hour) => !reservedTimes.contains(hour)).toList();
        
        // Ensure the original slot of the reservation being edited is always available in the dropdown
        String originalTimeSlot = DateFormat('HH:mm').format(initialDateTime);
        if (!availableHoursList.contains(originalTimeSlot)) {
          availableHoursList.add(originalTimeSlot);
          availableHoursList.sort(); // Keep the list sorted
        }
      } catch (e) {
        print("Error during fetchAvailableTimeSlots query/processing: $e");
        // Fallback: return all hours, or the original slot if an error occurs
        availableHoursList = [...hours]; 
        String originalTimeSlot = DateFormat('HH:mm').format(initialDateTime);
         if (!availableHoursList.contains(originalTimeSlot)) {
          availableHoursList.add(originalTimeSlot);
          availableHoursList.sort();
        }
      }
      return availableHoursList;
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
          // phoneController: phoneController, // Pass phone controller
          initialDateTime: initialDateTime,
          // initialType: initialType, // Pass initial type
          onUpdate: _updateReservation,
          onDelete: _deleteReservation,
          fetchAvailableTimeSlots: fetchAvailableTimeSlots,
          // calendarType: calendarType, // Removed as it's no longer needed
        );
      },
    );
  }

  Future<void> _updateReservation(
    String docId, 
    String clientName, 
    String phoneNumber,
    DateTime dateTime,
    ReservationType type,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Check availability before updating
      final bool isAvailable = await _reservationService.isTimeSlotAvailable(
        dateTime, 
        excludeDocId: docId // Exclude the current reservation from the check
      );
      
      if (!isAvailable) {
        Navigator.of(context).pop(); // Dismiss loading
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Acest slot orar nu este disponibil pentru data și ora selectate.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final result = await _reservationService.updateReservation(
        id: docId,
        clientName: clientName,
        phoneNumber: phoneNumber,
        dateTime: dateTime,
        type: type,
      );

      Navigator.of(context).pop(); // Dismiss loading indicator

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']), 
            backgroundColor: result['success'] ? Colors.green : Colors.red
          )
        );
      }
    } catch (e) {
      Navigator.of(context).pop(); // Dismiss loading indicator
      print("Error updating reservation: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Eroare la actualizarea rezervării: $e"), backgroundColor: Colors.red)
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
      
      Navigator.of(context).pop(); // Dismiss loading

      if (mounted) { 
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: result['success'] ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.of(context).pop(); // Dismiss loading
      print('Error deleting reservation: $e');
      if (mounted) {
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