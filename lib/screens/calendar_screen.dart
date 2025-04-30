import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'dart:ui';
import 'dart:async'; // Import async for StreamGroup
import 'package:async/async.dart'; // Import for StreamGroup

// Define enum for calendar types
enum CalendarType {
  meetings,       // Întâlniri cu clienții
  creditBureau    // Stergere birou de credit
}

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateFormat dateFormatter;
  Map<String, dynamic>? _currentConsultantData;
  bool _isFetchingConsultantData = true;
  CalendarType _selectedCalendarType = CalendarType.meetings; // Default calendar type

  final TextEditingController _clientNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchConsultantData(); 

    initializeDateFormatting('ro_RO', null).then((_) {
      if (mounted) {
        setState(() {
          dateFormatter = DateFormat('d MMM', 'ro_RO');
        });
      }
    });
  }

  Future<void> _fetchConsultantData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print("Error: _fetchConsultantData called but currentUser is null!");
      // Schedule sign out after the frame
      WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (mounted) { // Check mount status again inside callback
             await FirebaseAuth.instance.signOut();
             // Setting state might not be strictly needed here as AuthWrapper handles UI change
             // setState(() { _isFetchingConsultantData = false; _currentConsultantData = null; });
          }
      });
      if(mounted) {
        setState(() { _isFetchingConsultantData = false; _currentConsultantData = null; });
      }
      return;
    }

    // Ensure initial state update happens before async gap
    if (mounted) {
      setState(() { _isFetchingConsultantData = true; });
    }

    print("Fetching consultant data for user: ${currentUser.uid}");
    try {
      DocumentSnapshot consultantDoc = await FirebaseFirestore.instance
          .collection('consultants')
          .doc(currentUser.uid)
          .get();
      
      // Check mount status AFTER the await
      if (!mounted) return;

      print("Consultant document exists: ${consultantDoc.exists}");
      if (consultantDoc.exists) {
          print("Consultant data fetched: ${consultantDoc.data()}");
          setState(() {
            _currentConsultantData = consultantDoc.data() as Map<String, dynamic>?;
            _isFetchingConsultantData = false;
          });
      } else {
          print("Consultant document does not exist. Scheduling sign out.");
          // Schedule sign out after the frame
          WidgetsBinding.instance.addPostFrameCallback((_) async {
             if (mounted) { // Check mount status again inside callback
                 await FirebaseAuth.instance.signOut();
                 // Setting state might not be strictly needed here as AuthWrapper handles UI change
                 // setState(() { _isFetchingConsultantData = false; _currentConsultantData = null; });
             }
          });
          setState(() {
             _currentConsultantData = null;
             _isFetchingConsultantData = false;
          });
        }
      
    } catch (e) {
      print("Error fetching consultant data for user ${currentUser.uid}: $e. Scheduling sign out.");
      // Check mount status AFTER the await/catch
      if (mounted) {
        // Schedule sign out after the frame
        WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (mounted) { // Check mount status again inside callback
               await FirebaseAuth.instance.signOut();
               // Setting state might not be strictly needed here as AuthWrapper handles UI change
               // setState(() { _isFetchingConsultantData = false; _currentConsultantData = null; });
            }
        });
        setState(() {
          _currentConsultantData = null;
          _isFetchingConsultantData = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _clientNameController.dispose();
    super.dispose();
  }

  final List<String> daysOfWeek = ['Luni', 'Marți', 'Miercuri', 'Joi', 'Vineri'];
  
  List<String> _getCurrentWeekDates() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return List.generate(5, (index) {
      final date = monday.add(Duration(days: index));
      return '${date.day}';
    });
  }
  
  final List<String> hours = [
    '09:30', '10:00', '10:30', '11:00', '11:30', 
    '12:00', '12:30', '13:00', '13:30', '14:00', 
    '14:30', '15:00', '15:30', '16:00'
  ];

  String _formatDate(DateTime date) {
    if (dateFormatter == null) {
      return '${date.day} ${_getMonthAbbr(date.month)}';
    }
    return dateFormatter.format(date);
  }
  
  String _getMonthAbbr(int month) {
    const List<String> monthsRo = ['ian', 'feb', 'mar', 'apr', 'mai', 'iun', 'iul', 'aug', 'sep', 'oct', 'nov', 'dec'];
    return monthsRo[month - 1];
  }

  // Helper to get the Firestore collection name based on type
  String _getCollectionName(CalendarType type) {
    switch (type) {
      case CalendarType.meetings:
        return 'reservations';
      case CalendarType.creditBureau:
        return 'creditBureauAppointments'; // Choose a name for the new collection
    }
  }

  // Helper to get the display name for the calendar type
  String _getCalendarDisplayName(CalendarType type) {
    switch (type) {
      case CalendarType.meetings:
        return 'Întâlniri cu clienții';
      case CalendarType.creditBureau:
        return 'Ștergere birou credit';
    }
  }

  // Helper to get the display name for the NEXT calendar type (for button tooltip)
  String _getNextCalendarDisplayName() {
    return _getCalendarDisplayName(
        _selectedCalendarType == CalendarType.meetings 
        ? CalendarType.creditBureau 
        : CalendarType.meetings);
  }

  @override
  Widget build(BuildContext context) {
    if (_isFetchingConsultantData) {
        return const Scaffold(
            body: Center(child: CircularProgressIndicator(key: ValueKey("consultant_data_loading")))
        );
    }

    if (_currentConsultantData == null) {
        return const Scaffold(
          body: Center(child: Text("Eroare la încărcarea datelor consultantului."))
        );
    }
    
    if (dateFormatter == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(key: ValueKey("date_formatter_loading")))
      );
    }

    return Scaffold(
      body: _buildCalendarUI(context, _currentConsultantData!),
    );
  }

 Widget _buildCalendarUI(BuildContext context, Map<String, dynamic> consultantData) {
   final screenSize = MediaQuery.of(context).size;
   final isSmallScreen = screenSize.width < 1200;
   final mainContentHeight = screenSize.height - 48;

   return Container(
     width: double.infinity,
     height: double.infinity,
     decoration: const BoxDecoration(
       gradient: LinearGradient(
         begin: Alignment.topLeft,
         end: Alignment.bottomRight,
         colors: [Color(0xFFA4B8C2), Color(0xFFC2A4A4)],
         stops: [0.0, 1.0],
       ),
     ),
     child: Padding(
       padding: const EdgeInsets.all(24.0),
       child: isSmallScreen 
         ? SingleChildScrollView(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.stretch,
               children: [
                 _buildUpcomingWidget(height: 300),
                 const SizedBox(height: 24),
                 _buildCalendarWidget(isExpanded: false),
                 const SizedBox(height: 24),
                 _buildSidebar(consultantData: consultantData),
               ],
             ),
           )
         : Row(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               _buildUpcomingWidget(height: mainContentHeight),
               const SizedBox(width: 24),
               _buildCalendarWidget(isExpanded: true),
               const SizedBox(width: 24),
               _buildSidebar(height: mainContentHeight, consultantData: consultantData),
             ],
           ),
     ),
   );
 }

  Widget _buildUpcomingWidget({required double height}) {
    final now = DateTime.now();
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    // If user is not logged in, don't attempt to query
    if (currentUserId == null) {
      return Container(
        width: 224,
        height: height,
        padding: const EdgeInsets.all(8.0),
         decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF).withOpacity(0.5), // Use the background from theme/design
          borderRadius: BorderRadius.circular(32),
           boxShadow: [
             BoxShadow( color: Colors.black.withOpacity(0.1), blurRadius: 15, ),
          ],
        ),
        child: Center(child: Text("Utilizator neconectat", style: GoogleFonts.outfit(color: const Color(0xFF886699)))),
      );
    }

    return Container(
      width: 224,
      height: height,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF).withOpacity(0.5),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 8.0),
            child: Text(
              'Programările mele', // Changed title
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF9E8AA8),
              ),
            ),
          ),
          
          Expanded(
            // Revert to simple StreamBuilder for user's meetings only
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection(_getCollectionName(CalendarType.meetings)) // Always use meetings collection
                  .where('consultantId', isEqualTo: currentUserId) // Filter by current user ID
                  .where('dateTime', isGreaterThan: Timestamp.fromDate(now)) // Filter future events
                  .orderBy('dateTime', descending: false) // Order chronologically
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  print("Upcoming User Meetings Error: ${snapshot.error}");
                  return const Center(child: Text('Eroare la încărcare'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'Nicio programare viitoare',
                      style: GoogleFonts.outfit(color: const Color(0xFF886699))
                    )
                  );
                }

                final userMeetings = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: userMeetings.length,
                  itemBuilder: (context, index) {
                    final doc = userMeetings[index];
                    final meetingData = doc.data() as Map<String, dynamic>;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: _buildMeetingField(meetingData), 
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

 Widget _buildMeetingField(Map<String, dynamic> meetingData) {
    if (dateFormatter == null) {
      return const SizedBox.shrink();
    }

    final dateTime = (meetingData['dateTime'] as Timestamp).toDate();
    final hourString = DateFormat('HH:mm').format(dateTime);
    final dateString = dateFormatter.format(dateTime);
    final consultantName = meetingData['consultantName'] ?? 'N/A';
    final clientName = meetingData['clientName'] ?? 'N/A';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: const Color(0xFFCFC4D4),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  hourString,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF886699),
                  ),
                ),
              ),
              Text(
                dateString,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF886699),
                ),
                textAlign: TextAlign.right,
              ),
            ],
          ),
          
          const SizedBox(height: 4),
          
          Text(
            consultantName,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6F4D80),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            clientName,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF886699),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarWidget({required bool isExpanded}) {
    final weekDates = _getCurrentWeekDates();
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeek = DateTime(monday.year, monday.month, monday.day);
    final endOfWeek = startOfWeek.add(const Duration(days: 5));
    
    final calendarContainer = Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF).withOpacity(0.5),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SizedBox(
              height: 24,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Calendar',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF9E8AA8),
                      ),
                    ),
                  ),
                  // Display current calendar name
                  Text(
                    _getCalendarDisplayName(_selectedCalendarType),
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF9E8AA8),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Swap button
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
                      borderRadius: BorderRadius.circular(12), // Make ripple effect circular
                      child: SvgPicture.asset(
                        'assets/SwapIcon.svg', // Use the correct SVG asset
                        width: 24,
                        height: 24,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFF9E8AA8),
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
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: const Color(0xFFCFC4D4),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(64.0, 8.0, 0.0, 8.0),
                    child: Row(
                      children: List.generate(daysOfWeek.length, (index) {
                        return Expanded(
                          child: Text(
                            '${daysOfWeek[index]} ${weekDates[index]}',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF886699),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }),
                    ),
                  ),
                  
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      // Use helper to get collection name based on state
                      stream: FirebaseFirestore.instance
                          .collection(_getCollectionName(_selectedCalendarType))
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

                        final Map<String, Map<String, dynamic>> reservedSlotsMap = {};
                        final Map<String, String> reservedSlotsDocIds = {}; // Store doc IDs
                        if (snapshot.hasData) {
                          for (var doc in snapshot.data!.docs) {
                            final data = doc.data() as Map<String, dynamic>;
                            final dateTime = (data['dateTime'] as Timestamp).toDate();
                            
                            final dayIndex = dateTime.weekday - 1;
                            if (dayIndex < 0 || dayIndex > 4) continue;

                            final timeString = DateFormat('HH:mm').format(dateTime);
                            final hourIndex = hours.indexOf(timeString);
                            if (hourIndex == -1) continue;
                            
                            final slotKey = '$dayIndex-$hourIndex';
                            reservedSlotsMap[slotKey] = data;
                            reservedSlotsDocIds[slotKey] = doc.id; // Store the document ID
                          }
                        }

                        return ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                      child: SingleChildScrollView(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 48,
                              child: Column(
                                children: hours.map((hour) {
                                  return SizedBox(
                                    height: 80.0,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        hour,
                                        style: GoogleFonts.outfit(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF886699),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            
                            const SizedBox(width: 16),
                            
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: List.generate(daysOfWeek.length, (dayIndex) {
                                  return Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(right: dayIndex < daysOfWeek.length - 1 ? 16 : 0),
                                      child: Column(
                                        children: List.generate(hours.length, (hourIndex) {
                                              final slotKey = '$dayIndex-$hourIndex';
                                              final reservationData = reservedSlotsMap[slotKey];
                                              final docId = reservedSlotsDocIds[slotKey]; // Get the stored doc ID
                                              final isReserved = reservationData != null;
                                          
                                          return Padding(
                                            padding: const EdgeInsets.only(bottom: 16.0),
                                            child: SizedBox(
                                              height: 64,
                                                  width: double.infinity, 
                                              child: isReserved 
                                                    ? _buildReservedSlot(reservationData, docId ?? slotKey)
                                                    : _buildAvailableSlot(dayIndex, hourIndex, _selectedCalendarType), 
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
      ),
    );

    return isExpanded ? Expanded(child: calendarContainer) : calendarContainer;
  }

  Widget _buildReservedSlot(Map<String, dynamic> reservationData, String docId) {
    final consultantName = reservationData['consultantName'] ?? 'N/A';
    final clientName = reservationData['clientName'] ?? 'N/A';
    final consultantId = reservationData['consultantId'] as String?;
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final bool isOwner = consultantId != null && currentUserId == consultantId;
    
    // Determine the calendar type based on the current state
    // This assumes the slot being built belongs to the currently selected calendar
    // A more robust approach might involve storing the type in the reservation data itself
    final CalendarType calendarType = _selectedCalendarType;

    return InkWell(
      // Only allow tap if the current user is the owner
      onTap: isOwner ? () => _showEditReservationDialog(reservationData, docId, calendarType) : null,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: const Color(0xFFC4B3CC), // Background color for reserved slot
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              consultantName,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6F4D80), // Darker text color
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              clientName,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF886699), // Lighter text color
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

 Widget _buildAvailableSlot(int dayIndex, int hourIndex, CalendarType calendarType) {
    return InkWell(
      // Pass calendar type to the reservation dialog
      onTap: () => _showReservationDialog(dayIndex, hourIndex, calendarType),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFFC4B3CC),
          width: 4,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          'Loc disponibil',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF886699),
            ),
          ),
        ),
      ),
    );
  }

 void _showReservationDialog(int dayIndex, int hourIndex, CalendarType calendarType) {
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
            backgroundColor: const Color(0xFFFFFFFF),
            title: Text(
              'Rezervare Slot',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6F4D80),
              ),
            ),
            content: TextField(
              controller: _clientNameController,
              autofocus: true,
              style: GoogleFonts.outfit(color: const Color(0xFF6F4D80)),
              decoration: InputDecoration(
                labelText: 'Nume Client',
                labelStyle: GoogleFonts.outfit(color: const Color(0xFF886699)),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFF886699)),
                  borderRadius: BorderRadius.circular(16),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: const Color(0xFF886699).withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            actions: [
              TextButton(
                child: Text(
                  'Creează Rezervare',
                  style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w600, color: const Color(0xFF6F4D80)),
                ),
                onPressed: () {
                  final clientName = _clientNameController.text.trim();
                  if (clientName.isNotEmpty && _currentConsultantData != null) {
                    // Pass calendar type to create reservation
                    _createReservation(selectedDateTime, clientName, calendarType);
                    Navigator.of(context).pop();
                  } else {
                    print("Client name is empty or consultant data missing.");
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Introduceți numele clientului."), backgroundColor: Colors.orange)
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

 Future<void> _createReservation(DateTime dateTime, String clientName, CalendarType calendarType) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || _currentConsultantData == null) {
      print("Cannot create reservation: User not logged in or consultant data missing.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Eroare: Utilizator neconectat sau date consultant lipsă."), backgroundColor: Colors.red)
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await FirebaseFirestore.instance
          .collection(_getCollectionName(calendarType)) // Use correct collection
          .add({
        'consultantId': currentUser.uid,
        'consultantName': _currentConsultantData?['name'] ?? 'N/A',
        'clientName': clientName,
        'dateTime': Timestamp.fromDate(dateTime),
        'createdAt': FieldValue.serverTimestamp(),
      });

      Navigator.of(context).pop();
      print("Reservation created successfully for $clientName at $dateTime");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Rezervare creată cu succes!"), backgroundColor: Colors.green)
      );

    } catch (e) {
      Navigator.of(context).pop();
      print("Error creating reservation: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Eroare la crearea rezervării: $e"), backgroundColor: Colors.red)
      );
    }
  }

  Widget _buildDropdownButton() {
    return SvgPicture.asset(
      'assets/SwapIcon.svg',
      width: 24,
      height: 24,
      colorFilter: const ColorFilter.mode(
        Color(0xFF9E8AA8),
        BlendMode.srcIn,
      ),
    );
  }

 Widget _buildSidebar({double? height, required Map<String, dynamic> consultantData}) {
    return Container(
      width: 224,
      height: height,
      child: Column(
        children: [
          _buildUserWidget(consultantData: consultantData),
          
          const SizedBox(height: 16),
          
          height != null ? Expanded(child: _buildNavigationBar()) : _buildNavigationBar(),
        ],
      ),
    );
  }

 Widget _buildUserWidget({required Map<String, dynamic> consultantData}) {
    return Container(
      padding: const EdgeInsets.all(8.0), 
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF).withOpacity(0.5),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                     padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC4B3CC),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: SvgPicture.asset(
                    'assets/UserIcon.svg',
                           width: 24,
                           height: 24,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF886699),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                
                const SizedBox(width: 8),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          consultantData['name'] ?? 'N/A',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF886699),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                          consultantData['team'] ?? 'N/A',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF9E8AA8),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 16,
                    decoration: BoxDecoration(
                      color: const Color(0xFFC4B3CC),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: 0.473,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF9E8AA8),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              bottomLeft: Radius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 8),
                
                SizedBox(
                  width: 20,
                  child: Text(
                    '44',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF886699),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationBar() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF).withOpacity(0.5),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
            child: SizedBox(
              height: 24,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Navigație',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF9E8AA8),
                      ),
                    ),
                  ),
                  SvgPicture.asset(
                    'assets/DropdownIcon.svg',
                    width: 24,
                    height: 24,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF9E8AA8),
                      BlendMode.srcIn,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          _buildNavigationButton(
            'Formular clienți',
            'assets/FormIcon.svg',
            const Color(0xFFCFC4D4),
            const Color(0xFF886699),
            onTap: () { /* TODO: Implement navigation */ },
          ),
          
          const SizedBox(height: 8),
          
          _buildNavigationButton(
            'Calendar',
            'assets/CalendarIcon.svg',
            const Color(0xFFC4B3CC),
            const Color(0xFF6F4D80),
            isActive: true,
            onTap: () { /* Already here */ },
          ),
          
          const SizedBox(height: 8),
          
          _buildNavigationButton(
            'Statistici',
            'assets/StatisticsIcon.svg',
            const Color(0xFFCFC4D4),
            const Color(0xFF886699),
            onTap: () { /* TODO: Implement navigation */ },
          ),
          
          const SizedBox(height: 8),
          
          _buildNavigationButton(
            'Setări',
            'assets/SettingsIcon.svg',
            const Color(0xFFCFC4D4),
            const Color(0xFF886699),
            onTap: () { /* TODO: Implement navigation */ },
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButton(String text, String iconPath, Color bgColor, Color textColor, {bool isActive = false, VoidCallback? onTap}) {
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: isActive ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              SvgPicture.asset(
                iconPath,
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  textColor,
                  BlendMode.srcIn,
                ),
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: Text(
                  text,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Modify Edit Dialog to accept and use CalendarType
  void _showEditReservationDialog(Map<String, dynamic> reservationData, String docId, CalendarType calendarType) {
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
    Future<void> fetchAvailableTimeSlots(BuildContext dialogContext, DateTime date, String excludeDocId, String collectionName, StateSetter setStateCallback) async {
      print("Fetching slots for $date from $collectionName, excluding $excludeDocId");
      // Ensure we only update state if the dialog is still mounted
      if (!dialogContext.mounted) {
        print("Fetch cancelled: Dialog context not mounted.");
        return;
      }
      
      // Set loading state immediately
      // Check mount again before calling setStateCallback
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
        QuerySnapshot reservations = await FirebaseFirestore.instance
            .collection(collectionName)
            .where('dateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
            .where('dateTime', isLessThan: Timestamp.fromDate(endOfDay))
            .get();
        print("Found ${reservations.docs.length} reservations for the day.");
            
        for (var doc in reservations.docs) {
          try {
            // Determine the ID to exclude based on format
            String? reservationDocIdToCompare = doc.id;
            DateTime? excludeSlotDateTime;
            
            // Complex logic to handle both slot key and direct docId for exclusion
            bool isCurrentReservation = false;
            if (excludeDocId.contains('-')) {
              final parts = excludeDocId.split('-');
                if (parts.length == 2) {
                  final dayIndex = int.parse(parts[0]);
                  final hourIndex = int.parse(parts[1]);
                  final now = DateTime.now();
                  final monday = now.subtract(Duration(days: now.weekday - 1));
                  final excludeDate = monday.add(Duration(days: dayIndex));
                  final excludeHourMin = hours[hourIndex].split(':');
                  excludeSlotDateTime = DateTime(
                    excludeDate.year, excludeDate.month, excludeDate.day,
                    int.parse(excludeHourMin[0]), int.parse(excludeHourMin[1])
                  );
                  final data = doc.data() as Map<String, dynamic>;
                  final timestamp = data['dateTime'] as Timestamp;
                  final reservationTime = timestamp.toDate();
                   if (reservationTime.year == excludeSlotDateTime.year &&
                        reservationTime.month == excludeSlotDateTime.month &&
                        reservationTime.day == excludeSlotDateTime.day &&
                        reservationTime.hour == excludeSlotDateTime.hour &&
                        reservationTime.minute == excludeSlotDateTime.minute) {
                      isCurrentReservation = true;
                  }
                }
            } else if (doc.id == excludeDocId) {
               isCurrentReservation = true;
            }

            // If it's the one being edited, skip adding its time to reservedTimes
            if (isCurrentReservation) {
              print("Skipping current reservation: ${doc.id}");
              continue; 
            }
            
            // Add other reserved times
            final data = doc.data() as Map<String, dynamic>;
            final timestamp = data['dateTime'] as Timestamp;
            final slotTime = DateFormat('HH:mm').format(timestamp.toDate());
            reservedTimes.add(slotTime);
          } catch (e) {
            print("Error processing a reservation document (${doc.id}): $e");
          }
        }
        print("Reserved times found: $reservedTimes");
        
        // Filter hours based on reserved times
        finalAvailableHours = hours.where((hour) => !reservedTimes.contains(hour)).toList();
        print("Initially available hours: $finalAvailableHours");
        
        // Ensure the original time slot of the reservation being edited is always available
        String originalTimeSlot = DateFormat('HH:mm').format(initialDateTime);
        if (!finalAvailableHours.contains(originalTimeSlot)) {
          print("Adding original slot $originalTimeSlot back to list.");
          finalAvailableHours.add(originalTimeSlot);
          finalAvailableHours.sort(); // Keep sorted
        }
        print("Final available hours: $finalAvailableHours");

      } catch (e) {
        print("Error during fetchAvailableTimeSlots query/processing: $e");
        // Fallback: provide all hours if there was an error during fetch
        finalAvailableHours = [...hours];
      } finally {
        print("Fetch complete. Setting state. isLoadingSlots will be false.");
        // Always ensure isLoadingSlots is set to false after attempt, only update state if mounted
        if (dialogContext.mounted) {
          setStateCallback(() {
            availableHours = finalAvailableHours;
            isLoadingSlots = false; // Explicitly set to false here
            
            // Adjust selectedTime ONLY if it's NOT the original slot AND it's not available
            String originalTimeSlot = DateFormat('HH:mm').format(initialDateTime);
            if (selectedTime != originalTimeSlot && !availableHours.contains(selectedTime)) {
               print("Selected time $selectedTime is no longer available. Resetting...");
               if (availableHours.isNotEmpty) {
                  selectedTime = availableHours.first; // Select first available
                  print("New selected time: $selectedTime");
                  // Update selectedDate's time component accordingly
                  final timeParts = selectedTime.split(':');
                  selectedDate = DateTime(
                    selectedDate.year, selectedDate.month, selectedDate.day,
                    int.parse(timeParts[0]), int.parse(timeParts[1]),
                  );
               } else {
                  print("Warning: No available time slots found, cannot reset selectedTime.");
                  // Consider disabling dropdown or showing message
               }
            } else {
              print("Selected time $selectedTime is still available or is the original slot.");
            }
          });
        } else {
           print("Dialog context was not mounted in finally block.");
        }
      }
    }
    
    // Show the dialog
    showDialog(
        context: context, // Use the original context here
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.25),
        builder: (BuildContext dialogContext) { // New context for the builder
          // StatefulBuilder to manage state inside the dialog
          return StatefulBuilder(
              builder: (stfContext, stfSetState) {
              // Trigger initial fetch using WidgetsBinding
              // We need a way to track if it has been done for this dialog instance
              // Use a simple boolean flag within this scope
              if (!initialFetchTriggered) {
                  initialFetchTriggered = true;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                  // Pass the correct context and setState
                  fetchAvailableTimeSlots(dialogContext, selectedDate, docId, _getCollectionName(calendarType), stfSetState);
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
                      color: const Color(0xFFFFFFFF).withOpacity(0.75),
                      borderRadius: BorderRadius.circular(32),
                      ),
                      child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                          // Header (aligns with EditReservationHeader and Title CSS)
                          Container(
                              width: 336, // width: 336px
                              height: 32,
                              padding: const EdgeInsets.only(left: 8), // padding: 0px 0px 0px 8px
                              alignment: Alignment.centerLeft, // Align text left within its container
                              child: Text(
                                  'Modifica programare',
                                  style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 20,
                                      color: const Color(0xFF9E8AA8),
                                  ),
                              ),
                          ),
                          
                          const SizedBox(height: 8), // gap: 8px
                          
                          // Form Container
                          Container(
                              width: 336,
                              height: 248,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                              color: const Color(0xFFCFC4D4),
                              borderRadius: BorderRadius.circular(24),
                              ),
                              child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                  // Client Name Field
                                  Container(
                                      width: 320,
                                      height: 72,
                                      child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                              Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                                  height: 24,
                                                  alignment: Alignment.centerLeft,
                                                  child: Text('Nume client', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 18, color: const Color(0xFF886699)))
                                              ),
                                              Container(
                                                  height: 48,
                                                  width: 320,
                                                  decoration: BoxDecoration(color: const Color(0xFFC5B0CF), borderRadius: BorderRadius.circular(16)),
                                                  child: TextField(
                                                      controller: clientNameController,
                                                      textAlignVertical: TextAlignVertical.center,
                                                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w500, color: const Color(0xFF6F4D80)),
                                                      decoration: InputDecoration(
                                                          border: InputBorder.none,
                                                          hintText: 'Introdu numele clientului',
                                                          hintStyle: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w500, color: const Color(0xFF6F4D80).withOpacity(0.7)),
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
                                  Container(
                                      width: 320,
                                      height: 72,
                                      child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                              Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                                  height: 24,
                                                  alignment: Alignment.centerLeft,
                                                  child: Text('Data', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 18, color: const Color(0xFF886699)))
                                              ),
                                              InkWell(
                                                  onTap: () async {
                                                      final DateTime? pickedDate = await showDatePicker(
                                                        context: context,
                                                        initialDate: selectedDate,
                                                        firstDate: DateTime.now(),
                                                        lastDate: DateTime.now().add(const Duration(days: 365)),
                                                        builder: (context, child) {
                                                          return Theme(
                                                            data: ThemeData.light().copyWith(
                                                              colorScheme: const ColorScheme.light(
                                                                primary: Color(0xFF9E8AA8),
                                                                onPrimary: Colors.white,
                                                                surface: Color(0xFFFFFFFF),
                                                                onSurface: Color(0xFF886699),
                                                              ),
                                                            ),
                                                            child: child!,
                                                          );
                                                        },
                                                      );
                                                      
                                                      if (pickedDate != null) {
                                                          if (stfContext.mounted) {
                                                              stfSetState(() {
                                                                  selectedDate = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, selectedDate.hour, selectedDate.minute);
                                                              });
                                                              // Trigger fetch for new date
                                                              fetchAvailableTimeSlots(dialogContext, selectedDate, docId, _getCollectionName(calendarType), stfSetState);
                                                          }
                                                      }
                                                  },
                                                  child: Container(
                                                      height: 48,
                                                      width: 320,
                                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                                                      decoration: BoxDecoration(color: const Color(0xFFC5B0CF), borderRadius: BorderRadius.circular(16)),
                                                      alignment: Alignment.centerLeft,
                                                      child: Row(
                                                          children: [
                                                              Expanded(child: Text(DateFormat('dd/MM/yyyy').format(selectedDate), style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w500, color: const Color(0xFF6F4D80)))),
                                                              SvgPicture.asset('assets/CalendarIcon.svg', width: 24, height: 24, colorFilter: const ColorFilter.mode(Color(0xFF6F4D80), BlendMode.srcIn)),
                                                          ],
                                                      ),
                                                  ),
                                              ),
                                          ],
                                      ),
                                  ),
                                  
                                  const SizedBox(height: 8),
                                  
                                  // Time Field
                                  Container(
                                      width: 320,
                                      height: 72,
                                      child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                              Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                                  height: 24,
                                                  alignment: Alignment.centerLeft,
                                                  child: Text('Ora', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 18, color: const Color(0xFF886699)))
                                              ),
                                              Container(
                                                  height: 48,
                                                  width: 320,
                                                  decoration: BoxDecoration(color: const Color(0xFFC5B0CF), borderRadius: BorderRadius.circular(16)),
                                                  child: isLoadingSlots 
                                                      ? const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Color(0xFF6F4D80), strokeWidth: 2.5)))
                                                      : DropdownButtonHideUnderline(
                                                      child: DropdownButton<String>(
                                                          value: availableHours.contains(selectedTime) ? selectedTime : (availableHours.isNotEmpty ? availableHours.first : null),
                                                          dropdownColor: const Color(0xFFC5B0CF),
                                                          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF6F4D80)),
                                                          isExpanded: true,
                                                          padding: const EdgeInsets.symmetric(horizontal: 16),
                                                          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w500, color: const Color(0xFF6F4D80)),
                                                          underline: const SizedBox.shrink(),
                                                          items: availableHours.map((String hour) => DropdownMenuItem<String>(value: hour, child: Text(hour))).toList(),
                                                          onChanged: isLoadingSlots ? null : (String? newValue) {
                                                              if (newValue != null) {
                                                                  stfSetState(() {
                                                                      selectedTime = newValue;
                                                                      final timeParts = newValue.split(':');
                                                                      selectedDate = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, int.parse(timeParts[0]), int.parse(timeParts[1]));
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
                          Container(
                              width: 336,
                              height: 48,
                              child: Row(
                                  children: [
                                      // Delete Button
                                      Container(
                                          width: 48, height: 48, decoration: BoxDecoration(color: const Color(0xFFC5B0CF), borderRadius: BorderRadius.circular(24)),
                                          child: Material(color: Colors.transparent, child: InkWell(
                                            onTap: () async {
                                              // Directly close the edit dialog and delete
                                              if (dialogContext.mounted) {
                                                   Navigator.of(dialogContext).pop(); // Close edit dialog
                                              }
                                              // Call the delete function
                                              await _deleteReservation(docId, _getCollectionName(calendarType));
                                            },
                                            borderRadius: BorderRadius.circular(24),
                                            child: Center(child: SvgPicture.asset('assets/TrashIcon.svg', width: 24, height: 24, colorFilter: const ColorFilter.mode(Color(0xFF6F4D80), BlendMode.srcIn)))))
                                      ),
                                      const SizedBox(width: 8),
                                      // Save Button
                                      Expanded(
                                          child: Container(
                                              width: 280, height: 48, decoration: BoxDecoration(color: const Color(0xFFC5B0CF), borderRadius: BorderRadius.circular(24)),
                                              child: Material(
                                                  color: Colors.transparent,
                                                  child: InkWell(
                                                    onTap: isLoadingSlots ? null : () async {
                                                      print("Save button tapped.");
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
                                                      
                                                      print("Checking availability for $selectedDate (excluding $docId)");
                                                      bool isAvailable = await _isTimeSlotAvailable(selectedDate, docId, _getCollectionName(calendarType));
                                                      print("Slot available: $isAvailable");
                                                      
                                                      if (isAvailable) {
                                                        if (dialogContext.mounted) {
                                                          Navigator.of(dialogContext).pop();
                                                        }
                                                        
                                                        _updateReservation(
                                                          docId,
                                                          clientName,
                                                          selectedDate,
                                                          _getCollectionName(calendarType)
                                                        );
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
                                                    child: Center(child: Text('Salveaza programare', style: GoogleFonts.outfit(fontWeight: FontWeight.w500, fontSize: 18, color: const Color(0xFF6F4D80)), textAlign: TextAlign.center))))
                                          )
                                      ),
                                  ],
                              ),
                          ),
                      ],
                      ),
                  ),
                  ),
              );
              });
        });
  }

  // Modify helper methods to accept collection name
  Future<bool> _isTimeSlotAvailable(DateTime dateTime, String excludeDocId, String collectionName) async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
    final formattedTime = DateFormat('HH:mm').format(dateTime);
    
    // Create a range for the exact date/time
    final startOfDay = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final timestamp = Timestamp.fromDate(dateTime);
    
    try {
      // Query reservations for this exact date/time
      QuerySnapshot reservations = await FirebaseFirestore.instance
          .collection(collectionName)
          .where('dateTime', isEqualTo: timestamp)
          .get();
      
      // If no reservations or the only one is the current one (excludeDocId), the slot is available
      if (reservations.docs.isEmpty) {
        return true;
      }
      
      // Check if the only reservation is the one we're editing
      if (reservations.docs.length == 1) {
        // If excludeDocId is in format dayIndex-hourIndex, we need to get the actual document ID
        if (excludeDocId.contains('-')) {
          // Extract day and hour indices
          final dayHourParts = excludeDocId.split('-');
          if (dayHourParts.length == 2) {
            final dayIndex = int.parse(dayHourParts[0]);
            final hourIndex = int.parse(dayHourParts[1]);
            
            // Calculate the DateTime for this slot
            final now = DateTime.now();
            final monday = now.subtract(Duration(days: now.weekday - 1));
            final slotDate = monday.add(Duration(days: dayIndex));
            final slotHour = hours[hourIndex].split(':');
            
            final slotDateTime = DateTime(
              slotDate.year, slotDate.month, slotDate.day,
              int.parse(slotHour[0]), int.parse(slotHour[1])
            );
            
            // Compare timestamp of the reservation with our slot
            final reservationTimestamp = (reservations.docs.first.data() as Map<String, dynamic>)['dateTime'] as Timestamp;
            final reservationDateTime = reservationTimestamp.toDate();
            
            // If the times match (same minute), this is our reservation
            if (reservationDateTime.year == slotDateTime.year &&
                reservationDateTime.month == slotDateTime.month &&
                reservationDateTime.day == slotDateTime.day &&
                reservationDateTime.hour == slotDateTime.hour &&
                reservationDateTime.minute == slotDateTime.minute) {
              return true;
            }
          }
        } else if (reservations.docs.first.id == excludeDocId) {
          // Direct document ID comparison
          return true;
        }
      }
      
      // If we got here, the slot is taken by someone else
      return false;
    } catch (e) {
      print("Error checking time slot availability: $e");
      return false;
    }
  }

  // Modify update function to accept collection name
  Future<void> _updateReservation(String docId, String clientName, DateTime dateTime, String collectionName) async {
    print("_updateReservation called for $collectionName with docId: $docId");
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    
    try {
      String? actualDocId = await _resolveDocId(docId, collectionName);
      if (actualDocId == null) throw Exception("Failed to resolve document ID");
      
      await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(actualDocId)
          .update({
            'clientName': clientName,
            'dateTime': Timestamp.fromDate(dateTime),
            'updatedAt': FieldValue.serverTimestamp(),
          });
      
      print("Reservation updated successfully: $actualDocId");
      
      // Close the loading dialog (make sure we're on the main thread)
      if (context.mounted) {
        Navigator.of(context).pop();
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Programare actualizată cu succes!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Log the error
      print("Error updating reservation: $e");
      
      // Close the loading dialog if it's showing
      if (context.mounted) {
        Navigator.of(context).pop();
        
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

  // Modify delete function to accept collection name
  Future<void> _deleteReservation(String docId, String collectionName) async {
    print("_deleteReservation called for $collectionName with docId: $docId");
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    
    try {
      String? actualDocId = await _resolveDocId(docId, collectionName);
      if (actualDocId == null) throw Exception("Failed to resolve document ID");
      
      await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(actualDocId)
          .delete();
      
      print("Reservation deleted successfully: $actualDocId");
      
      // Close the loading dialog (make sure we're on the main thread)
      if (context.mounted) {
        Navigator.of(context).pop();
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Programare ștearsă cu succes!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Log the error
      print("Error deleting reservation: $e");
      
      // Close the loading dialog if it's showing
      if (context.mounted) {
        Navigator.of(context).pop();
        
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

  // NEW Helper method to resolve docId (slot key or actual ID) reliably
  Future<String?> _resolveDocId(String docIdOrSlotKey, String collectionName) async {
     if (!docIdOrSlotKey.contains('-')) {
       // It's already (presumably) a document ID
       return docIdOrSlotKey;
     }
     
     // It's a slot key, resolve it
     try {
       final parts = docIdOrSlotKey.split('-');
       if (parts.length != 2) return null;
       final dayIndex = int.parse(parts[0]);
       final hourIndex = int.parse(parts[1]);

       final now = DateTime.now();
       final monday = now.subtract(Duration(days: now.weekday - 1));
       final slotDate = monday.add(Duration(days: dayIndex));
       final slotHour = hours[hourIndex].split(':');
       final slotDateTime = DateTime(
           slotDate.year, slotDate.month, slotDate.day,
           int.parse(slotHour[0]), int.parse(slotHour[1])
       );
       final slotTimestamp = Timestamp.fromDate(slotDateTime);

       QuerySnapshot query = await FirebaseFirestore.instance
           .collection(collectionName)
           .where('dateTime', isEqualTo: slotTimestamp)
           .limit(1)
           .get();
           
       if (query.docs.isNotEmpty) {
         return query.docs.first.id;
       } else {
         print("Warning: No document found for slot key $docIdOrSlotKey in $collectionName");
         return null;
       }
     } catch (e) {
       print("Error resolving slot key $docIdOrSlotKey: $e");
       return null;
     }
  }
}
