import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:ui';

import '../../theme/app_theme.dart';
import '../../widgets/navigation/sidebar_widget.dart';
import '../../widgets/navigation/navigation_widget.dart';
import '../../widgets/common/panel_container.dart';
import '../../services/reservation_service.dart';
import '../../widgets/calendar/reservation_dialogs.dart';
import 'calendar_widgets.dart';

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

    DateTime startOfWeek;
    // If it's Saturday (6) or Sunday (7)
    if (currentWeekday >= DateTime.saturday) {
      // Calculate days until next Monday
      final daysUntilNextMonday = 8 - currentWeekday;
      // Get next Monday's date
      final nextMonday = now.add(Duration(days: daysUntilNextMonday));
      // Set startOfWeek to the beginning of that Monday
      startOfWeek = DateTime(nextMonday.year, nextMonday.month, nextMonday.day);
    } else {
      // If it's Monday to Friday, get the current week's Monday
      final currentMonday = now.subtract(Duration(days: currentWeekday - 1));
      // Set startOfWeek to the beginning of that Monday
      startOfWeek = DateTime(currentMonday.year, currentMonday.month, currentMonday.day);
    }
    return startOfWeek;
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
          width: 1100, // Latimea panoului de calendar
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

  /// Construieste widget-ul pentru "Upcoming" (programari viitoare)
  Widget _buildUpcomingWidget() {
    final currentUserId = _auth.currentUser?.uid;

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
            'Programarile mele',
            style: AppTheme.headerTitleStyle,
          ),
        ),
        
        Expanded(
          child: currentUserId == null
              ? Center(child: Text(
                  "Utilizator neconectat", 
                  style: AppTheme.secondaryTitleStyle,
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
    // Get the correct start of the week (current or next)
    final DateTime startOfWeek = _getStartOfWeekToDisplay();
    // Calculate the end of that week (Friday end of day, for query purposes)
    final endOfWeek = startOfWeek.add(const Duration(days: 5)); 
    // Generate the day numbers for the header labels for the displayed week
    final List<String> weekDates = List.generate(5, (index) {
      return startOfWeek.add(Duration(days: index)).day.toString();
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with title and calendar type switch
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
                  _getCalendarDisplayName(_selectedReservationType),
                  style: AppTheme.subHeaderStyle,
                ),
                const SizedBox(width: AppTheme.defaultGap),
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
          ),
        ),
        
        // Calendar container
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(AppTheme.mediumGap),
            decoration: AppTheme.calendarContainerDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Day labels row - Uses the calculated weekDates
                Padding(
                  padding: const EdgeInsets.only(
                    left: 64.0, // Space for hour labels + gap
                  ),
                  child: Row(
                    children: List.generate(daysOfWeek.length, (index) {
                      return Expanded(
                        child: Text(
                          '${daysOfWeek[index]} ${weekDates[index]}', // Use updated weekDates
                          style: AppTheme.secondaryTitleStyle,
                          textAlign: TextAlign.center,
                        ),
                      );
                    }),
                  ),
                ),
                
                const SizedBox(height: AppTheme.defaultGap),
                
                // Calendar grid with slots
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    // Query uses the calculated startOfWeek and endOfWeek
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

                      // Process reservations data
                      final Map<String, Map<String, dynamic>> reservedSlotsMap = {};
                      final Map<String, String> reservedSlotsDocIds = {};
                      if (snapshot.hasData) {
                        for (var doc in snapshot.data!.docs) {
                          final data = doc.data() as Map<String, dynamic>;
                          
                          // Filter by reservation type
                          final type = data['type'] as String?;
                          final ReservationType? reservationType = type == 'meeting' 
                              ? ReservationType.meeting 
                              : (type == 'bureauDelete' ? ReservationType.bureauDelete : null);
                              
                          if (reservationType != _selectedReservationType) {
                            continue;
                          }
                          
                          final dateTime = (data['dateTime'] as Timestamp).toDate();
                          
                          // Calculate dayIndex relative to the startOfWeek being displayed
                          final dayDifference = dateTime.difference(startOfWeek).inDays;
                          // final dayIndex = dateTime.weekday - 1;
                          if (dayDifference < 0 || dayDifference > 4) continue; // Only show days within the displayed week
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
                              Column(
                                children: hours.map((hour) {
                                  return Container(
                                    width: AppTheme.hourLabelWidth,
                                    height: 40, // Match the slot height
                                    margin: const EdgeInsets.only(bottom: 40), // Match slot bottom padding
                                    alignment: Alignment.center,
                                    child: Text(
                                      hour,
                                      style: AppTheme.secondaryTitleStyle,
                                      textAlign: TextAlign.center,
                                    ),
                                  );
                                }).toList(),
                              ),
                              
                              const SizedBox(width: AppTheme.mediumGap),
                              
                              // Days columns with slots
                              Expanded(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: List.generate(daysOfWeek.length, (dayIndex) {
                                    return Expanded(
                                      child: Padding(
                                        // Add horizontal padding to the right of each column, except the last one
                                        padding: EdgeInsets.only(right: dayIndex < daysOfWeek.length - 1 ? AppTheme.mediumGap : 0),
                                        child: Column(
                                          children: List.generate(hours.length, (hourIndex) {
                                            final slotKey = '$dayIndex-$hourIndex';
                                            final reservationData = reservedSlotsMap[slotKey];
                                            final docId = reservedSlotsDocIds[slotKey];
                                            final isReserved = reservationData != null;
                                        
                                            return Padding(
                                              padding: const EdgeInsets.only(bottom: AppTheme.mediumGap), // Keep the gap between rows
                                              child: SizedBox(
                                                height: 64, // Fixed height
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
    
    // Determinam tipul de calendar
    final ReservationType calendarType = _selectedReservationType;

    return MouseRegion(
      cursor: isOwner ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        // Permite tap doar pentru proprietar
        onTap: isOwner ? () => _showEditReservationDialog(reservationData, docId, calendarType) : null,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
          decoration: BoxDecoration(
            color: AppTheme.slotReservedBackground,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
            boxShadow: [AppTheme.slotShadow],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                consultantName,
                style: AppTheme.primaryTitleStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                clientName,
                style: AppTheme.secondaryTitleStyle,
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
          decoration: BoxDecoration(
            border: Border.all(
              color: AppTheme.slotReservedBackground,
              width: AppTheme.slotBorderThickness,
            ),
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
          ),
          child: Center(
            child: Text(
              'Loc disponibil',
              style: AppTheme.secondaryTitleStyle.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showReservationDialog(int dayIndex, int hourIndex, ReservationType calendarType) {
    // Calculate the selected date based on the displayed startOfWeek
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

      Navigator.of(context).pop(); // Close loading dialog

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
      Navigator.of(context).pop(); // Close loading dialog
      print("Error creating reservation: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Eroare la crearea rezervarii: $e"), backgroundColor: Colors.red)
      );
    }
  }

  void _showEditReservationDialog(Map<String, dynamic> reservationData, String docId, ReservationType calendarType) {
    // Extract initial data
    final initialClientName = reservationData['clientName'] as String? ?? '';
    final initialDateTime = (reservationData['dateTime'] as Timestamp).toDate();

    // Controllers for fields
    final clientNameController = TextEditingController(text: initialClientName);
    
    // Function to fetch available time slots
    Future<List<String>> fetchAvailableTimeSlots(DateTime date, String excludeDocId) async {
      List<String> availableHours = [];
      try {
        // Get the start and end of the selected day
        final startOfDay = DateTime(date.year, date.month, date.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));
        
        Set<String> reservedTimes = {};
        
        // Query reservations safely
        QuerySnapshot reservations = await _firestore
            .collection('reservations')
            .where('dateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
            .where('dateTime', isLessThan: Timestamp.fromDate(endOfDay))
            .get();
            
        for (var doc in reservations.docs) {
          try {
            // Skip the current reservation
            if (doc.id == excludeDocId) {
              continue; 
            }

            // Skip reservations with different type
            final data = doc.data() as Map<String, dynamic>;
            final type = data['type'] as String?;
            final ReservationType? reservationType = type == 'meeting' 
                ? ReservationType.meeting 
                : (type == 'bureauDelete' ? ReservationType.bureauDelete : null);
            
            if (reservationType != calendarType) {
              continue;
            }
            
            // Add other reserved times
            final timestamp = data['dateTime'] as Timestamp;
            final slotTime = DateFormat('HH:mm').format(timestamp.toDate());
            reservedTimes.add(slotTime);
          } catch (e) {
            print("Error processing a reservation document (${doc.id}): $e");
          }
        }
        
        // Filter hours based on reserved times
        availableHours = hours.where((hour) => !reservedTimes.contains(hour)).toList();
        
        // Ensure the original time slot of the reservation being edited is always available
        String originalTimeSlot = DateFormat('HH:mm').format(initialDateTime);
        if (!availableHours.contains(originalTimeSlot)) {
          availableHours.add(originalTimeSlot);
          availableHours.sort(); // Keep sorted
        }
      } catch (e) {
        print("Error during fetchAvailableTimeSlots query/processing: $e");
        // Fallback: provide all hours if there was an error during fetch
        availableHours = [...hours];
      }
      
      return availableHours;
    }
    
    // Show the dialog
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
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    
    try {
      // Check if time slot is available before updating
      final bool isAvailable = await _reservationService.isTimeSlotAvailable(
        dateTime, 
        excludeDocId: docId
      );
      
      if (!isAvailable) {
        // Close loading indicator
        if (context.mounted) Navigator.of(context).pop();
        
        // Show error message
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
      
      // Perform the update
      final result = await _reservationService.updateReservation(
        id: docId,
        clientName: clientName,
        dateTime: dateTime,
      );
      
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        
        // Show result message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: result['success'] ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        
        // Show error message
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
        Navigator.of(context).pop(); // Close loading dialog
        
        // Show result message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: result['success'] ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        
        // Show error message
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