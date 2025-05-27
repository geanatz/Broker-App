import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

import 'package:broker_app/frontend/common/appTheme.dart';

import 'package:broker_app/frontend/popups/meetingPopup.dart';
import 'package:broker_app/backend/services/calendarService.dart';
import 'package:broker_app/frontend/common/components/texts/text2.dart';

// Import the required components
import 'package:broker_app/frontend/common/components/headers/widgetHeader6.dart';
import 'package:broker_app/frontend/common/components/items/outlinedItem6.dart';
import 'package:broker_app/frontend/common/components/items/darkItem4.dart';

/// Area pentru calendar care va fi afișată în cadrul ecranului principal.
/// Această componentă respectă strict designul din Figma și folosește o abordare simplă pentru stabilitate.
class CalendarArea extends StatefulWidget {
  /// Callback pentru refresh meetingsPane când se salvează întâlniri
  final VoidCallback? onMeetingSaved;
  
  const CalendarArea({super.key, this.onMeetingSaved});

  @override
  State<CalendarArea> createState() => CalendarAreaState();
}

class CalendarAreaState extends State<CalendarArea> {
  // Services
  final CalendarService _calendarService = CalendarService();
  
  // Firebase references
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Calendar state
  int _currentWeekOffset = 0;
  bool _isInitialized = false;
  bool _isLoading = false;
  
  // Data cache pentru meetings
  List<QueryDocumentSnapshot> _cachedMeetings = [];
  Timer? _refreshTimer;
  
  // Highlight functionality
  String? _highlightedMeetingId;
  Timer? _highlightTimer;

  @override
  void initState() {
    super.initState();
    _initializeCalendar();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _highlightTimer?.cancel();
    super.dispose();
  }

  /// Inițializează serviciul de calendar
  Future<void> _initializeCalendar() async {
    try {
      await _calendarService.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        // Load initial data and start periodic refresh
        _loadMeetingsForCurrentWeek();
        _startPeriodicRefresh();
      }
    } catch (e) {
      debugPrint('Calendar initialization error: $e');
      if (mounted) {
        setState(() {
          _isInitialized = true; // Show calendar even with init errors
        });
      }
    }
  }

  /// Start periodic refresh to avoid blocking streams (disabled - refresh only when needed)
  void _startPeriodicRefresh() {
    _refreshTimer?.cancel();
    // Removed automatic refresh - will only refresh when explicitly needed
  }

  /// Load meetings for current week using one-time fetch instead of stream
  Future<void> _loadMeetingsForCurrentWeek() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final DateTime startOfWeek = _calendarService.getStartOfWeekToDisplay(_currentWeekOffset);
      final DateTime endOfWeek = _calendarService.getEndOfWeekToDisplay(_currentWeekOffset);
      
      // Use get() instead of snapshots() to avoid streaming issues
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('meetings')
          .where('dateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfWeek))
          .where('dateTime', isLessThan: Timestamp.fromDate(endOfWeek))
          .get()
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              debugPrint('Firestore query timeout');
              throw TimeoutException('Query timeout', const Duration(seconds: 5));
            },
          );

      if (mounted) {
        setState(() {
          _cachedMeetings = snapshot.docs;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading meetings: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Keep existing cache on error
        });
      }
    }
  }

  // Navigate to previous week
  void _navigateToPreviousWeek() {
    setState(() {
      _currentWeekOffset--;
    });
    _loadMeetingsForCurrentWeek();
  }
  
  // Navigate to next week
  void _navigateToNextWeek() {
    setState(() {
      _currentWeekOffset++;
    });
    _loadMeetingsForCurrentWeek();
  }

  // Navigate to current week
  void _navigateToCurrentWeek() {
    setState(() {
      _currentWeekOffset = 0;
    });
    _loadMeetingsForCurrentWeek();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return _buildLoadingContainer();
    }
    
    return _buildCalendarWidget();
  }

  /// Construiește containerul de loading
  Widget _buildLoadingContainer() {
    return Container(
      width: double.infinity,
      height: 600,
      padding: const EdgeInsets.all(8),
      decoration: ShapeDecoration(
        color: AppTheme.widgetBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppTheme.elementColor1,
              strokeWidth: 2,
            ),
            const SizedBox(height: 16),
            Text2(
              text: 'Inițializare calendar...',
              color: AppTheme.elementColor2,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ],
        ),
      ),
    );
  }

  /// Construiește widget-ul principal pentru calendar conform designului Figma
  Widget _buildCalendarWidget() {
    final String dateInterval = _calendarService.getDateInterval(_currentWeekOffset);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: ShapeDecoration(
        color: AppTheme.widgetBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header cu navigation conform Figma folosind WidgetHeader6
          WidgetHeader6(
            title: 'Calendar',
            dateText: dateInterval,
            prevDateIcon: Icons.chevron_left,
            nextDateIcon: Icons.chevron_right,
            onPrevDateTap: _navigateToPreviousWeek,
            onNextDateTap: _navigateToNextWeek,
            onDateTextTap: _currentWeekOffset != 0 ? _navigateToCurrentWeek : null,
            titleColor: AppTheme.elementColor1,
            dateTextColor: _currentWeekOffset != 0 
                ? AppTheme.elementColor2 
                : AppTheme.elementColor1,
            dateNavIconColor: AppTheme.elementColor1,
          ),
          
          const SizedBox(height: 8),
          
          // Containerul principal cu calendar
          Expanded(
            child: _buildCalendarContainer(),
          ),
        ],
      ),
    );
  }

  /// Construiește containerul principal cu calendar
  Widget _buildCalendarContainer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: AppTheme.containerColor1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Header cu zilele săptămânii
          _buildWeekDaysHeader(),
          
          const SizedBox(height: 8),
          
          // Grid-ul cu orele și sloturile
          Expanded(
            child: _buildCalendarGrid(),
          ),
        ],
      ),
    );
  }

  /// Construiește header-ul cu zilele săptămânii conform Figma
  Widget _buildWeekDaysHeader() {
    final List<String> weekDates = _calendarService.getWeekDates(_currentWeekOffset);
    
    return Container(
      width: double.infinity,
      height: 21,
      child: Row(
        children: [
          // Spațiu pentru coloana cu orele
          const SizedBox(width: 56),
          
          // Zilele săptămânii folosind Text2
          ...List.generate(CalendarService.daysPerWeek, (index) {
            return Expanded(
              child: Container(
                height: 21,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                alignment: Alignment.center,
                child: Text2(
                  text: '${CalendarService.workingDays[index]} ${weekDates[index]}',
                  color: AppTheme.elementColor2,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Construiește grid-ul cu orele și sloturile (fără StreamBuilder)
  Widget _buildCalendarGrid() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppTheme.elementColor1,
              strokeWidth: 2,
            ),
            const SizedBox(height: 8),
            Text2(
              text: 'Se încarcă calendarul...',
              color: AppTheme.elementColor2,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ],
        ),
      );
    }

    final Map<String, Map<String, dynamic>> meetingsMap = {};
    final Map<String, String> meetingsDocIds = {};
    
    // Process cached meetings
    for (var doc in _cachedMeetings) {
      try {
        final data = doc.data() as Map<String, dynamic>;
        final dateTime = (data['dateTime'] as Timestamp).toDate();
        
        final dayIndex = _calendarService.getDayIndexForDate(dateTime, _currentWeekOffset);
        final hourIndex = _calendarService.getHourIndexForDateTime(dateTime);
        
        if (dayIndex != null && hourIndex != -1) {
          final slotKey = _calendarService.generateSlotKey(dayIndex, hourIndex);
          meetingsMap[slotKey] = data;
          meetingsDocIds[slotKey] = doc.id;
        }
      } catch (e) {
        debugPrint('Error processing meeting document ${doc.id}: $e');
        continue;
      }
    }

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        children: _buildHourRows(meetingsMap, meetingsDocIds),
      ),
    );
  }

  /// Construiește rândurile pentru fiecare oră
  List<Widget> _buildHourRows(
    Map<String, Map<String, dynamic>> meetingsMap,
    Map<String, String> meetingsDocIds,
  ) {
    return List.generate(CalendarService.workingHours.length, (hourIndex) {
      final hour = CalendarService.workingHours[hourIndex];
      final isLastHour = hourIndex == CalendarService.workingHours.length - 1;
      
      return Column(
        children: [
          Container(
            width: double.infinity,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Coloana cu ora folosind Text2
                Container(
                  width: 48,
                  height: 64,
                  padding: const EdgeInsets.only(top: 8),
                  alignment: Alignment.topCenter,
                  child: Text2(
                    text: hour,
                    color: AppTheme.elementColor2,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Sloturile pentru fiecare zi
                ...List.generate(CalendarService.daysPerWeek, (dayIndex) {
                  final slotKey = _calendarService.generateSlotKey(dayIndex, hourIndex);
                  final meetingData = meetingsMap[slotKey];
                  final docId = meetingsDocIds[slotKey];
                  final isMeeting = meetingData != null;
                  final isLastSlot = dayIndex == CalendarService.daysPerWeek - 1;
                  
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: isLastSlot ? 0 : 8),
                      child: isMeeting 
                          ? _buildMeetingSlot(meetingData!, docId!)
                          : _buildAvailableSlot(dayIndex, hourIndex),
                    ),
                  );
                }),
              ],
            ),
          ),
          if (!isLastHour) const SizedBox(height: 16),
        ],
      );
    });
  }

  /// Construiește un slot rezervat conform designului folosind DarkItem4
  Widget _buildMeetingSlot(Map<String, dynamic> meetingData, String docId) {
    final consultantName = meetingData['consultantName'] ?? 'N/A';
    final clientName = meetingData['clientName'] ?? 'N/A';
    final consultantId = meetingData['consultantId'] as String?;
    final currentUserId = _auth.currentUser?.uid;
    final bool isOwner = consultantId != null && currentUserId == consultantId;
    final bool isHighlighted = _highlightedMeetingId == docId;

    // Calculate background color with highlight effect
    Color backgroundColor = AppTheme.containerColor2;
    if (isHighlighted) {
      // Add 20% white overlay for highlight effect
      backgroundColor = Color.lerp(backgroundColor, Colors.white, 0.2) ?? backgroundColor;
    }

    return MouseRegion(
      cursor: isOwner ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: DarkItem4(
        title: consultantName,
        description: clientName,
        onTap: isOwner ? () => _showEditMeetingDialog(meetingData, docId) : null,
        backgroundColor: backgroundColor,
        titleColor: AppTheme.elementColor3,
        descriptionColor: AppTheme.elementColor2,
      ),
    );
  }

  /// Construiește un slot liber conform designului folosind OutlinedItem6
  Widget _buildAvailableSlot(int dayIndex, int hourIndex) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: OutlinedItem6(
        title: 'Slot liber',
        svgAsset: 'assets/addIcon.svg',
        onTap: () => _showCreateMeetingDialog(dayIndex, hourIndex),
        mainBorderColor: AppTheme.containerColor2,
        mainBorderWidth: 4.0,
        titleColor: AppTheme.elementColor2,
        iconColor: AppTheme.elementColor2,
      ),
    );
  }

  /// Afișează dialogul pentru crearea unei întâlniri noi
  void _showCreateMeetingDialog(int dayIndex, int hourIndex) {
    try {
      final DateTime selectedDateTime = _calendarService.buildDateTimeFromIndices(
        _currentWeekOffset, 
        dayIndex, 
        hourIndex
      );

      showDialog(
        context: context,
        barrierDismissible: true,
        barrierColor: Colors.black.withValues(alpha: 0.25),
        builder: (BuildContext context) {
          return MeetingPopup(
            initialDateTime: selectedDateTime,
            onSaved: () {
              if (mounted) {
                _loadMeetingsForCurrentWeek(); // Refresh calendar data
                // Also refresh meetings pane
                widget.onMeetingSaved?.call();
              }
            },
          );
        },
      );
    } catch (e) {
      debugPrint('Error showing create meeting dialog: $e');
    }
  }

  /// Afișează dialogul pentru editarea unei întâlniri existente
  void _showEditMeetingDialog(Map<String, dynamic> meetingData, String docId) {
    try {
      showDialog(
        context: context,
        barrierDismissible: true,
        barrierColor: Colors.black.withValues(alpha: 0.25),
        builder: (BuildContext context) {
          return MeetingPopup(
            meetingId: docId,
            onSaved: () {
              if (mounted) {
                _loadMeetingsForCurrentWeek(); // Refresh calendar data
                // Also refresh meetings pane
                widget.onMeetingSaved?.call();
              }
            },
          );
        },
      );
    } catch (e) {
      debugPrint('Error showing edit meeting dialog: $e');
    }
  }

  /// Navigates to a specific meeting and highlights it
  void navigateToMeeting(String meetingId) {
    debugPrint('Navigate to meeting: $meetingId');
    
    // Find the meeting in cached data to determine which week it's in
    QueryDocumentSnapshot? targetMeeting;
    for (var meeting in _cachedMeetings) {
      if (meeting.id == meetingId) {
        targetMeeting = meeting;
        break;
      }
    }
    
    if (targetMeeting != null) {
      // Get meeting date to calculate week offset
      final meetingData = targetMeeting.data() as Map<String, dynamic>;
      final meetingDateTime = (meetingData['dateTime'] as Timestamp).toDate();
      
      // Calculate what week offset this meeting is in
      final weekDifference = _calendarService.getWeekOffsetForDate(meetingDateTime);
      
      // Navigate to the correct week if needed
      if (weekDifference != _currentWeekOffset) {
        setState(() {
          _currentWeekOffset = weekDifference;
        });
        _loadMeetingsForCurrentWeek();
      }
      
      // Highlight the meeting
      _highlightMeeting(meetingId);
    } else {
      // Meeting not in current cache, try to load fresh data
      _loadMeetingsForCurrentWeek().then((_) {
        // Try again after loading
        for (var meeting in _cachedMeetings) {
          if (meeting.id == meetingId) {
            _highlightMeeting(meetingId);
            break;
          }
        }
      });
    }
  }
  
  /// Highlights a meeting for 1 second
  void _highlightMeeting(String meetingId) {
    setState(() {
      _highlightedMeetingId = meetingId;
    });
    
    // Remove highlight after 1 second
    _highlightTimer?.cancel();
    _highlightTimer = Timer(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _highlightedMeetingId = null;
        });
      }
    });
  }
}
