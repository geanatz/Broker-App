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
  final List<String> daysOfWeek = ['Luni', 'Marți', 'Miercuri', 'Joi', 'Vineri'];
  final List<String> hours = [
    '09:30', '10:00', '10:30', '11:00', '11:30', 
    '12:00', '12:30', '13:00', '13:30', '14:00', 
    '14:30', '15:00', '15:30', '16:00'
  ];

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

  // Helper pentru a obține numele afișat al calendarului în funcție de tip
  String _getCalendarDisplayName(ReservationType type) {
    switch (type) {
      case ReservationType.meeting:
        return 'Întâlniri cu clienții';
      case ReservationType.bureauDelete:
        return 'Ștergere birou credit';
    }
  }

  // Helper pentru a obține numele următorului tip de calendar (pentru tooltip buton)
  String _getNextCalendarDisplayName() {
    return _getCalendarDisplayName(
        _selectedReservationType == ReservationType.meeting 
        ? ReservationType.bureauDelete 
        : ReservationType.meeting);
  }
  
  List<String> _getCurrentWeekDates() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return List.generate(5, (index) {
      final date = monday.add(Duration(days: index));
      return '${date.day}';
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
            'Programările mele',
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

  /// Construiește widget-ul pentru calendar
  Widget _buildCalendarWidget() {
    final weekDates = _getCurrentWeekDates();
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeek = DateTime(monday.year, monday.month, monday.day);
    final endOfWeek = startOfWeek.add(const Duration(days: 5));
    
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
                Tooltip(
                  message: "Schimbă pe ${_getNextCalendarDisplayName()}",
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
                // Day labels row
                Padding(
                  padding: const EdgeInsets.only(
                    left: 64.0, // Space for hour labels + gap
                  ),
                  child: Row(
                    children: List.generate(daysOfWeek.length, (index) {
                      return Expanded(
                        child: Text(
                          '${daysOfWeek[index]} ${weekDates[index]}',
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
                        return const Center(child: Text('Eroare la încărcare calendar'));
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
                          
                          final dayIndex = dateTime.weekday - 1;
                          if (dayIndex < 0 || dayIndex > 4) continue;

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
                                    height: 64 + AppTheme.mediumGap, // Slot height + bottom gap
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
                                              padding: const EdgeInsets.only(bottom: AppTheme.mediumGap),
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
    
    // Determinăm tipul de calendar
    final ReservationType calendarType = _selectedReservationType;

    return GestureDetector(
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
    );
  }

  Widget _buildAvailableSlot(int dayIndex, int hourIndex, ReservationType calendarType) {
    return GestureDetector(
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
    );
  }

  void _showReservationDialog(int dayIndex, int hourIndex, ReservationType calendarType) {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final selectedDate = monday.add(Duration(days: dayIndex));
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
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            backgroundColor: Colors.white,
            title: Text(
              'Rezervare Slot',
              style: AppTheme.primaryTitleStyle,
            ),
            content: TextField(
              controller: _clientNameController,
              autofocus: true,
              style: TextStyle(color: AppTheme.fontDarkPurple),
              decoration: InputDecoration(
                labelText: 'Nume Client',
                labelStyle: TextStyle(color: AppTheme.fontMediumPurple),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.fontMediumPurple),
                  borderRadius: BorderRadius.circular(16),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.fontMediumPurple.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () {
                  final clientName = _clientNameController.text.trim();
                  if (clientName.isNotEmpty) {
                    _createReservation(selectedDateTime, clientName, calendarType);
                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Introduceți numele clientului."), 
                        backgroundColor: Colors.orange
                      )
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundDarkPurple,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Creează Rezervare',
                    style: TextStyle(
                      fontWeight: FontWeight.w600, 
                      color: AppTheme.fontDarkPurple
                    ),
                  ),
                ),
              ),
            ],
          ),
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
          const SnackBar(content: Text("Rezervare creată cu succes!"), backgroundColor: Colors.green)
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
        SnackBar(content: Text("Eroare la crearea rezervării: $e"), backgroundColor: Colors.red)
      );
    }
  }

  void _showEditReservationDialog(Map<String, dynamic> reservationData, String docId, ReservationType calendarType) {
    // Extract initial data
    final initialClientName = reservationData['clientName'] as String? ?? '';
    final initialDateTime = (reservationData['dateTime'] as Timestamp).toDate();

    // Controllers for fields
    final clientNameController = TextEditingController(text: initialClientName);
    
    // Variables for state within the dialog
    DateTime selectedDate = initialDateTime;
    String selectedTime = DateFormat('HH:mm').format(initialDateTime);
    List<String> availableHours = []; // Start empty, will be populated by fetch
    bool isLoadingSlots = true; // Start as true, fetch will set to false
    bool initialFetchTriggered = false; // Flag to ensure fetch runs only once initially
    
    // Function to fetch available time slots for the selected date
    Future<void> fetchAvailableTimeSlots(BuildContext dialogContext, DateTime date, String excludeDocId, StateSetter setStateCallback) async {
      // Ensure we only update state if the dialog is still mounted
      if (!dialogContext.mounted) {
        print("Fetch cancelled: Dialog context not mounted.");
        return;
      }
      
      // Set loading state immediately
      if (dialogContext.mounted) {
          setStateCallback(() {
              if (!isLoadingSlots) isLoadingSlots = true;
          });
      }
      
      List<String> finalAvailableHours = [];
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
        finalAvailableHours = hours.where((hour) => !reservedTimes.contains(hour)).toList();
        
        // Ensure the original time slot of the reservation being edited is always available
        String originalTimeSlot = DateFormat('HH:mm').format(initialDateTime);
        if (!finalAvailableHours.contains(originalTimeSlot)) {
          finalAvailableHours.add(originalTimeSlot);
          finalAvailableHours.sort(); // Keep sorted
        }

      } catch (e) {
        print("Error during fetchAvailableTimeSlots query/processing: $e");
        // Fallback: provide all hours if there was an error during fetch
        finalAvailableHours = [...hours];
      } finally {
        // Always ensure isLoadingSlots is set to false after attempt, only update state if mounted
        if (dialogContext.mounted) {
          setStateCallback(() {
            availableHours = finalAvailableHours;
            isLoadingSlots = false; // Explicitly set to false here
            
            // Adjust selectedTime ONLY if it's NOT the original slot AND it's not available
            String originalTimeSlot = DateFormat('HH:mm').format(initialDateTime);
            if (selectedTime != originalTimeSlot && !availableHours.contains(selectedTime)) {
               if (availableHours.isNotEmpty) {
                  selectedTime = availableHours.first; // Select first available
                  // Update selectedDate's time component accordingly
                  final timeParts = selectedTime.split(':');
                  selectedDate = DateTime(
                    selectedDate.year, selectedDate.month, selectedDate.day,
                    int.parse(timeParts[0]), int.parse(timeParts[1]),
                  );
               }
            }
          });
        }
      }
    }
    
    // Show the dialog
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.25),
      builder: (BuildContext dialogContext) {
        // StatefulBuilder to manage state inside the dialog
        return StatefulBuilder(
          builder: (stfContext, stfSetState) {
            // Trigger initial fetch
            if (!initialFetchTriggered) {
              initialFetchTriggered = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                fetchAvailableTimeSlots(dialogContext, selectedDate, docId, stfSetState);
              });
            }
            
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Dialog(
                insetPadding: EdgeInsets.zero,
                backgroundColor: Colors.transparent,
                child: Container(
                  width: 352,
                  height: 360,
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Header
                      Container(
                        width: 336,
                        height: 32,
                        padding: const EdgeInsets.only(left: 8),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Modifica programare',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                            color: AppTheme.fontLightPurple,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Form Container
                      Container(
                        width: 336,
                        height: 248,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundLightPurple,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // Client Name Field
                            SizedBox(
                              width: 320,
                              height: 72,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    height: 24,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Nume client',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600, 
                                        fontSize: 18, 
                                        color: AppTheme.fontMediumPurple
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 48,
                                    width: 320,
                                    decoration: BoxDecoration(
                                      color: AppTheme.backgroundDarkPurple, 
                                      borderRadius: BorderRadius.circular(16)
                                    ),
                                    child: TextField(
                                      controller: clientNameController,
                                      textAlignVertical: TextAlignVertical.center,
                                      style: TextStyle(
                                        fontSize: 18, 
                                        fontWeight: FontWeight.w500, 
                                        color: AppTheme.fontDarkPurple
                                      ),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'Introdu numele clientului',
                                        hintStyle: TextStyle(
                                          fontSize: 18, 
                                          fontWeight: FontWeight.w500, 
                                          color: AppTheme.fontDarkPurple.withOpacity(0.7)
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                        isDense: true,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 8),
                            
                            // Date Field
                            SizedBox(
                              width: 320,
                              height: 72,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    height: 24,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Data',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600, 
                                        fontSize: 18, 
                                        color: AppTheme.fontMediumPurple
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      final DateTime? pickedDate = await showDatePicker(
                                        context: context,
                                        initialDate: selectedDate,
                                        firstDate: DateTime.now(),
                                        lastDate: DateTime.now().add(const Duration(days: 365)),
                                        builder: (context, child) {
                                          return Theme(
                                            data: ThemeData.light().copyWith(
                                              colorScheme: ColorScheme.light(
                                                primary: AppTheme.fontLightPurple,
                                                onPrimary: Colors.white,
                                                surface: Colors.white,
                                                onSurface: AppTheme.fontMediumPurple,
                                              ),
                                            ),
                                            child: child!,
                                          );
                                        },
                                      );
                                      
                                      if (pickedDate != null) {
                                        if (stfContext.mounted) {
                                          stfSetState(() {
                                            selectedDate = DateTime(
                                              pickedDate.year, 
                                              pickedDate.month, 
                                              pickedDate.day, 
                                              selectedDate.hour, 
                                              selectedDate.minute
                                            );
                                          });
                                          // Trigger fetch for new date
                                          fetchAvailableTimeSlots(dialogContext, selectedDate, docId, stfSetState);
                                        }
                                      }
                                    },
                                    child: Container(
                                      height: 48,
                                      width: 320,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                                      decoration: BoxDecoration(
                                        color: AppTheme.backgroundDarkPurple, 
                                        borderRadius: BorderRadius.circular(16)
                                      ),
                                      alignment: Alignment.centerLeft,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              DateFormat('dd/MM/yyyy').format(selectedDate),
                                              style: TextStyle(
                                                fontSize: 18, 
                                                fontWeight: FontWeight.w500, 
                                                color: AppTheme.fontDarkPurple
                                              ),
                                            ),
                                          ),
                                          SvgPicture.asset(
                                            'assets/CalendarIcon.svg',
                                            width: 24,
                                            height: 24,
                                            colorFilter: ColorFilter.mode(
                                              AppTheme.fontDarkPurple,
                                              BlendMode.srcIn
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 8),
                            
                            // Time Field
                            SizedBox(
                              width: 320,
                              height: 72,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    height: 24,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Ora',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600, 
                                        fontSize: 18, 
                                        color: AppTheme.fontMediumPurple
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 48,
                                    width: 320,
                                    decoration: BoxDecoration(
                                      color: AppTheme.backgroundDarkPurple, 
                                      borderRadius: BorderRadius.circular(16)
                                    ),
                                    child: isLoadingSlots 
                                      ? Center(
                                          child: SizedBox(
                                            width: 20, 
                                            height: 20, 
                                            child: CircularProgressIndicator(
                                              color: AppTheme.fontDarkPurple, 
                                              strokeWidth: 2.5
                                            ),
                                          ),
                                        )
                                      : DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            value: availableHours.contains(selectedTime) 
                                              ? selectedTime 
                                              : (availableHours.isNotEmpty ? availableHours.first : null),
                                            dropdownColor: AppTheme.backgroundDarkPurple,
                                            icon: Icon(Icons.arrow_drop_down, color: AppTheme.fontDarkPurple),
                                            isExpanded: true,
                                            padding: const EdgeInsets.symmetric(horizontal: 16),
                                            style: TextStyle(
                                              fontSize: 18, 
                                              fontWeight: FontWeight.w500, 
                                              color: AppTheme.fontDarkPurple
                                            ),
                                            underline: const SizedBox.shrink(),
                                            items: availableHours.map((String hour) => 
                                              DropdownMenuItem<String>(
                                                value: hour, 
                                                child: Text(hour)
                                              )
                                            ).toList(),
                                            onChanged: isLoadingSlots 
                                              ? null 
                                              : (String? newValue) {
                                                  if (newValue != null) {
                                                    stfSetState(() {
                                                      selectedTime = newValue;
                                                      final timeParts = newValue.split(':');
                                                      selectedDate = DateTime(
                                                        selectedDate.year, 
                                                        selectedDate.month, 
                                                        selectedDate.day, 
                                                        int.parse(timeParts[0]), 
                                                        int.parse(timeParts[1])
                                                      );
                                                    });
                                                  }
                                                },
                                          ),
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Button Section
                      SizedBox(
                        width: 336,
                        height: 48,
                        child: Row(
                          children: [
                            // Delete Button
                            Container(
                              width: 48, 
                              height: 48, 
                              decoration: BoxDecoration(
                                color: AppTheme.backgroundDarkPurple, 
                                borderRadius: BorderRadius.circular(24)
                              ),
                              child: GestureDetector(
                                onTap: () async {
                                  // Close the edit dialog and delete
                                  if (dialogContext.mounted) {
                                    Navigator.of(dialogContext).pop();
                                  }
                                  // Call the delete function
                                  await _deleteReservation(docId);
                                },
                                child: Center(
                                  child: SvgPicture.asset(
                                    'assets/TrashIcon.svg',
                                    width: 24,
                                    height: 24,
                                    colorFilter: ColorFilter.mode(
                                      AppTheme.fontDarkPurple,
                                      BlendMode.srcIn
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Save Button
                            Expanded(
                              child: Container(
                                width: 280, 
                                height: 48, 
                                decoration: BoxDecoration(
                                  color: AppTheme.backgroundDarkPurple, 
                                  borderRadius: BorderRadius.circular(24)
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: isLoadingSlots 
                                      ? null 
                                      : () async {
                                          final String clientName = clientNameController.text.trim();
                                          if (clientName.isEmpty) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Introduceți numele clientului.'),
                                                backgroundColor: Colors.orange,
                                              ),
                                            );
                                            return;
                                          }
                                          
                                          bool isAvailable = await _reservationService.isTimeSlotAvailable(
                                            selectedDate, 
                                            excludeDocId: docId
                                          );
                                          
                                          if (isAvailable) {
                                            if (dialogContext.mounted) {
                                              Navigator.of(dialogContext).pop();
                                            }
                                            
                                            _updateReservation(docId, clientName, selectedDate);
                                          } else {
                                            if (stfContext.mounted) { 
                                              ScaffoldMessenger.of(stfContext).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Acest slot nu mai este disponibil.'),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          }
                                        },
                                    borderRadius: BorderRadius.circular(24),
                                    child: Center(
                                      child: Text(
                                        'Salveaza programare',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500, 
                                          fontSize: 18, 
                                          color: AppTheme.fontDarkPurple
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        );
      }
    );
  }

  Future<void> _updateReservation(String docId, String clientName, DateTime dateTime) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    
    try {
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
            content: Text('Eroare la actualizarea programării: $e'),
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
            content: Text('Eroare la ștergerea programării: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
} 