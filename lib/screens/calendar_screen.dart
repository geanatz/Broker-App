import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'dart:ui';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateFormat dateFormatter;
  Map<String, dynamic>? _currentConsultantData;
  bool _isFetchingConsultantData = true;

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
    return Container(
      width: 224,
      height: height,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2).withOpacity(0.5),
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
              'In curand',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF9E8AA8),
              ),
            ),
          ),
          
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('reservations')
                  .orderBy('dateTime', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Eroare la încărcare întâlniri'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'Nicio întâlnire programată',
                       style: GoogleFonts.outfit(color: const Color(0xFF886699))
                    )
                  );
                }

                final now = DateTime.now();
                final meetings = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final meetingTime = (data['dateTime'] as Timestamp).toDate();
                  return meetingTime.isAfter(now);
                }).toList();

                meetings.sort((a, b) {
                   final timeA = (a.data() as Map<String, dynamic>)['dateTime'] as Timestamp;
                   final timeB = (b.data() as Map<String, dynamic>)['dateTime'] as Timestamp;
                   return timeA.compareTo(timeB);
                });

                if (meetings.isEmpty) {
                   return Center(
                    child: Text(
                      'Nicio întâlnire viitoare',
                       style: GoogleFonts.outfit(color: const Color(0xFF886699))
                    )
                  );
                }

                return ListView.builder(
                  itemCount: meetings.length,
              itemBuilder: (context, index) {
                    final doc = meetings[index];
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
        color: const Color(0xFFF2F2F2).withOpacity(0.5),
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
                  Text(
                    'Întâlniri cu clienții',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF9E8AA8),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildDropdownButton(),
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
                      stream: FirebaseFirestore.instance
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

                        final Map<String, Map<String, dynamic>> reservedSlotsMap = {};
                        if (snapshot.hasData) {
                          for (var doc in snapshot.data!.docs) {
                            final data = doc.data() as Map<String, dynamic>;
                            final dateTime = (data['dateTime'] as Timestamp).toDate();
                            
                            final dayIndex = dateTime.weekday - 1;
                            if (dayIndex < 0 || dayIndex > 4) continue;

                            final timeString = DateFormat('HH:mm').format(dateTime);
                            final hourIndex = hours.indexOf(timeString);
                            if (hourIndex == -1) continue;
                            
                            reservedSlotsMap['$dayIndex-$hourIndex'] = data;
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
                                              final isReserved = reservationData != null;
                                          
                                          return Padding(
                                            padding: const EdgeInsets.only(bottom: 16.0),
                                            child: SizedBox(
                                              height: 64,
                                                  width: double.infinity, 
                                              child: isReserved 
                                                    ? _buildReservedSlot(
                                                        reservationData?['consultantName'] ?? 'N/A', 
                                                        reservationData?['clientName'] ?? 'N/A'
                                                      )
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
      ),
    );

    return isExpanded ? Expanded(child: calendarContainer) : calendarContainer;
  }

  Widget _buildReservedSlot(String consultantName, String clientName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: const Color(0xFFC4B3CC),
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

 Widget _buildAvailableSlot(int dayIndex, int hourIndex) {
    return InkWell(
      onTap: () => _showReservationDialog(dayIndex, hourIndex),
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

 void _showReservationDialog(int dayIndex, int hourIndex) {
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
            backgroundColor: const Color(0xFFF2F2F2),
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
                    _createReservation(selectedDateTime, clientName);
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

 Future<void> _createReservation(DateTime dateTime, String clientName) async {
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
      await FirebaseFirestore.instance.collection('reservations').add({
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
      'assets/DropdownIcon.svg',
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
        color: const Color(0xFFF2F2F2).withOpacity(0.5),
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
        color: const Color(0xFFF2F2F2).withOpacity(0.5),
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
}
