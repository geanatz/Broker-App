import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  // Format pentru dată
  late DateFormat dateFormatter;
  
  @override
  void initState() {
    super.initState();
    // Inițializăm datele locale pentru română și creăm formatterul
    initializeDateFormatting('ro_RO', null).then((_) {
      setState(() {
        dateFormatter = DateFormat('d MMM', 'ro_RO');
      });
    });
  }
  
  // Demo data for upcoming meetings
  final List<Map<String, dynamic>> upcomingMeetings = [
    {
      'hour': '10:30',
      'date': '25 mar',
      'consultant': 'Ioan Dragomir',
      'client': 'Andrei Popescu',
    },
    {
      'hour': '13:00',
      'date': '25 mar',
      'consultant': 'Mihaela Vasile',
      'client': 'Maria Ionescu',
    },
    {
      'hour': '16:30',
      'date': '26 mar',
      'consultant': 'Ioan Dragomir',
      'client': 'Alexandru Popa',
    },
    {
      'hour': '09:00',
      'date': '27 mar',
      'consultant': 'Mihaela Vasile',
      'client': 'Elena David',
    },
    {
      'hour': '11:30',
      'date': '28 mar',
      'consultant': 'Ioan Dragomir',
      'client': 'Ionut Stan',
    },
  ];

  // Days of the week for calendar
  final List<String> daysOfWeek = ['Luni', 'Marți', 'Miercuri', 'Joi', 'Vineri'];
  
  // Generate current week dates
  List<String> _getCurrentWeekDates() {
    final now = DateTime.now();
    // Find Monday of this week
    final monday = now.subtract(Duration(days: now.weekday - 1));
    
    // Generate dates for Monday to Friday
    return List.generate(5, (index) {
      final date = monday.add(Duration(days: index));
      return '${date.day}'; // Just the day number
    });
  }
  
  // Hours for calendar (9:30 to 16:00) - Modificare #7
  final List<String> hours = [
    '09:30', '10:00', '10:30', '11:00', '11:30', 
    '12:00', '12:30', '13:00', '13:30', '14:00', 
    '14:30', '15:00', '15:30', '16:00'
  ];

  // Demo data for calendar slots
  // Format: day index, hour index, consultant name, client name
  final List<List<dynamic>> reservedSlots = [
    [0, 2, 'Ioan Dragomir', 'Cristian Munteanu'],
    [0, 6, 'Mihaela Vasile', 'Elena Georgescu'],
    [1, 3, 'Ioan Dragomir', 'Andrei Popescu'],
    [2, 8, 'Mihaela Vasile', 'Maria Ionescu'],
    [4, 10, 'Ioan Dragomir', 'Alexandru Popa'],
  ];

  // Formatarea datei într-un mod care nu folosește API-uri depreciate
  String _formatDate(DateTime date) {
    // Dacă formatterul nu e inițializat încă, afișăm un format simplu
    if (dateFormatter == null) {
      // Format simplu fără dependență de locale
      return '${date.day} ${_getMonthAbbr(date.month)}';
    }
    return dateFormatter.format(date);
  }
  
  // Abreviere manuală pentru luni (fallback)
  String _getMonthAbbr(int month) {
    const List<String> monthsRo = ['ian', 'feb', 'mar', 'apr', 'mai', 'iun', 'iul', 'aug', 'sep', 'oct', 'nov', 'dec'];
    return monthsRo[month - 1];
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
                    _buildSidebar(),
                  ],
                ),
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left column - Upcoming Widget
                  _buildUpcomingWidget(height: mainContentHeight),
                  
                  const SizedBox(width: 24),
                  
                  // Center column - Calendar Widget
                  _buildCalendarWidget(isExpanded: true),
                  
                  const SizedBox(width: 24),
                  
                  // Right column - Sidebar (User & Navigation)
                  _buildSidebar(height: mainContentHeight),
                ],
              ),
        ),
      ),
    );
  }

  // Left column - Upcoming Widget
  Widget _buildUpcomingWidget({required double height}) {
    return Container(
      width: 224,
      height: height,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2).withOpacity(0.5), // Modificare #3: Culoare corectă
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
          // Widget Header
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
          
          // Upcoming Meeting Fields
          Expanded(
            child: ListView.builder(
              itemCount: upcomingMeetings.length,
              itemBuilder: (context, index) {
                final meeting = upcomingMeetings[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: _buildMeetingField(meeting),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Meeting Field Item
  Widget _buildMeetingField(Map<String, dynamic> meeting) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: const Color(0xFFCFC4D4),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hour and Date
          Row(
            children: [
              Expanded(
                child: Text(
                  meeting['hour'],
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF886699),
                  ),
                ),
              ),
              Text(
                meeting['date'],
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
          
          // Consultant and Client
          Text(
            meeting['consultant'],
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6F4D80),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            meeting['client'],
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

  // Center column - Calendar Widget
  Widget _buildCalendarWidget({required bool isExpanded}) {
    // Get current week dates
    final weekDates = _getCurrentWeekDates();
    
    final calendarContainer = Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2).withOpacity(0.5), // Modificare #3: Culoare corectă
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          // Calendar Header
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
                  // Calendar Switch
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
          
          // Calendar Container
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
                  // Calendar Days - Modificare #2: Format zile "Luni 20"
                  Padding(
                    padding: const EdgeInsets.fromLTRB(64.0, 8.0, 0.0, 8.0),
                    child: Row(
                      children: List.generate(daysOfWeek.length, (index) {
                        return Expanded(
                          child: Text(
                            '${daysOfWeek[index]} ${weekDates[index]}', // Modificare #2: "Luni 20" format
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
                  
                  // Calendar Grid - Modificare #6: Restructurare pentru a corespunde designului Figma
                  Expanded(
                    child: ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                      child: SingleChildScrollView(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Hours Column
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
                            
                            // Day columns in a container
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: List.generate(daysOfWeek.length, (dayIndex) {
                                  return Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(right: dayIndex < daysOfWeek.length - 1 ? 16 : 0),
                                      child: Column(
                                        children: List.generate(hours.length, (hourIndex) {
                                          // Check if this slot is reserved
                                          bool isReserved = false;
                                          String consultant = '';
                                          String client = '';
                                          
                                          for (var slot in reservedSlots) {
                                            if (slot[0] == dayIndex && slot[1] == hourIndex) {
                                              isReserved = true;
                                              consultant = slot[2];
                                              client = slot[3];
                                              break;
                                            }
                                          }
                                          
                                          return Padding(
                                            padding: const EdgeInsets.only(bottom: 16.0),
                                            child: SizedBox(
                                              height: 64,
                                              // Modificare #8: Lățimi consistente pentru ambele tipuri de sloturi
                                              width: double.infinity, // Asigură lățime completă în cadrul coloanei
                                              child: isReserved 
                                                ? _buildReservedSlot(consultant, client)
                                                : _buildAvailableSlot(),
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
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    // Wrap with Expanded only if needed (in Row layout)
    return isExpanded ? Expanded(child: calendarContainer) : calendarContainer;
  }

  // Reserved Slot - Modificare #8: Asigură lățime consistentă
  Widget _buildReservedSlot(String consultant, String client) {
    return Container(
      width: double.infinity, // Asigură lățime completă
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
            consultant,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6F4D80),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            client,
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

  // Available Slot - Modificare #8: Asigură lățime consistentă
  Widget _buildAvailableSlot() {
    return Container(
      width: double.infinity, // Asigură lățime completă
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
    );
  }

  // Dropdown Button
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

  // Right column - Sidebar (User & Navigation)
  Widget _buildSidebar({double? height}) {
    return Container(
      width: 224,
      height: height,
      child: Column(
        children: [
          // User Widget
          _buildUserWidget(),
          
          const SizedBox(height: 16),
          
          // Navigation Bar - Let it take remaining space if height is provided
          height != null ? Expanded(child: _buildNavigationBar()) : _buildNavigationBar(),
        ],
      ),
    );
  }

  // User Widget - Modificări #1 și #4: Padding corectat la 8px
  Widget _buildUserWidget() {
    return Container(
      padding: const EdgeInsets.all(8.0), 
      decoration: BoxDecoration(
        color: const Color(0xF2F2F2F2).withOpacity(0.5),
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
          // About Consultant
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0), // Padding intern consistent
            child: Row(
              children: [
                // Consultant Avatar
                Container(
                  width: 56,
                  height: 56,
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC4B3CC),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: SvgPicture.asset(
                    'assets/UserIcon.svg',
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF886699),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // Consultant Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ioan Dragomir',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF886699),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Broker Team 1',
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
          
          // Call Progress
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0.0),
            child: Row(
              children: [
                // Loading Bar
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
                
                // Calls Count
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

  // Navigation Bar
  Widget _buildNavigationBar() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2).withOpacity(0.5), // Modificare #3: Culoare corectă
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
          // Widget Header
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
          
          // Navigation Buttons
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

  // Navigation Button
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
