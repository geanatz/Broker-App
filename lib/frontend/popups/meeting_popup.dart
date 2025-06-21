import 'package:broker_app/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:broker_app/frontend/components/headers/widget_header1.dart';
import 'package:broker_app/frontend/components/fields/input_field1.dart';
import 'package:broker_app/frontend/components/fields/input_field3.dart';
import 'package:broker_app/frontend/components/fields/dropdown_field1.dart';
import 'package:broker_app/frontend/components/buttons/flex_buttons2.dart';
import 'package:broker_app/backend/services/meeting_service.dart';
import 'package:broker_app/backend/services/splash_service.dart';
import 'package:broker_app/backend/services/clients_service.dart';
import 'package:broker_app/backend/services/auth_service.dart';

/// Custom TextInputFormatter for automatic colon insertion in time format
class TimeInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    
    // Remove any existing colons to start fresh
    final digitsOnly = text.replaceAll(':', '');
    
    // Limit to 4 digits maximum (HHMM)
    if (digitsOnly.length > 4) {
      return oldValue;
    }
    
    String formattedText = digitsOnly;
    int cursorPosition = newValue.selection.end;
    
    // Add colon after 2 digits
    if (digitsOnly.length >= 2) {
      formattedText = '${digitsOnly.substring(0, 2)}:${digitsOnly.substring(2)}';
      
      // Adjust cursor position if we added a colon
      if (digitsOnly.length == 2 && oldValue.text.length == 1) {
        cursorPosition = 3; // Position after the colon
      } else if (digitsOnly.length > 2) {
        cursorPosition = formattedText.length;
      }
    }
    
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }
}

/// Popup combinat pentru crearea si editarea intalnirilor
class MeetingPopup extends StatefulWidget {
  /// ID-ul intalnirii pentru editare (null pentru creare noua)
  final String? meetingId;
  
  /// Data si ora initiala (pentru creare noua sau editare)
  final DateTime? initialDateTime;
  
  /// Callback pentru salvare cu succes
  final VoidCallback? onSaved;

  const MeetingPopup({
    super.key,
    this.meetingId,
    this.initialDateTime,
    this.onSaved,
  });

  @override
  State<MeetingPopup> createState() => _MeetingPopupState();
}

class _MeetingPopupState extends State<MeetingPopup> {
  final MeetingService _meetingService = MeetingService();
  final SplashService _splashService = SplashService();
  
  // Controllers pentru inputuri
  final TextEditingController _clientNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  
  // State variables
  MeetingType _selectedType = MeetingType.meeting;
  DateTime? _selectedDate;
  String? _selectedTimeSlot; // Schimbat din controller la String pentru dropdown
  List<String> _availableTimeSlots = []; // Lista orelor disponibile
  bool _isLoading = false;

  // Pentru a sti daca suntem in modul editare
  bool get isEditMode => widget.meetingId != null;
  
  String get popupTitle => isEditMode ? 'Editeaza intalnire' : 'Creaza intalnire';

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _clientNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    if (mounted) {
      setState(() => _isLoading = true);
    }

    if (isEditMode) {
      // Modul editare - incarca datele intalnirii existente din cache
      await _loadExistingMeetingFromCache();
    } else {
      // Modul creare - foloseste data initiala daca este furnizata
      if (widget.initialDateTime != null) {
        _selectedDate = widget.initialDateTime;
        _selectedTimeSlot = DateFormat('HH:mm').format(widget.initialDateTime!);
        // Incarca orele disponibile pentru data initiala din cache
        await _loadAvailableTimeSlotsFromCache();
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadExistingMeetingFromCache() async {
    if (widget.meetingId == null) return;

    try {
      // Cauta intalnirea in cache-ul din SplashService
      final cachedMeetings = await _splashService.getCachedMeetings();
      final targetMeeting = cachedMeetings.firstWhere(
        (meeting) => meeting.id == widget.meetingId,
        orElse: () => throw Exception('Meeting not found in cache'),
      );

      // Extrage datele din additionalData
      final additionalData = targetMeeting.additionalData ?? {};
      final clientName = additionalData['clientName'] ?? 'Client nedefinit';
      final phoneNumber = additionalData['phoneNumber'] ?? '';
      
      // Convert ActivityType to MeetingType
      final meetingType = targetMeeting.type == ClientActivityType.bureauDelete 
          ? MeetingType.bureauDelete 
          : MeetingType.meeting;

      _clientNameController.text = clientName;
      _phoneController.text = phoneNumber;
      _selectedType = meetingType;
      _selectedDate = targetMeeting.dateTime;
      _selectedTimeSlot = DateFormat('HH:mm').format(targetMeeting.dateTime);
      
      // Incarca orele disponibile pentru data existenta din cache
      await _loadAvailableTimeSlotsFromCache();
    } catch (e) {
      debugPrint("Eroare la incarcarea intalnirii din cache: $e");
      _showError("Eroare la incarcarea datelor intalnirii din cache");
    }
  }

  Future<void> _loadAvailableTimeSlotsFromCache() async {
    if (_selectedDate == null) return;

    try {
      // Foloseste SplashService cache pentru a obtine orele disponibile instant
      final availableSlots = await _splashService.getAvailableTimeSlots(
        _selectedDate!, 
        excludeId: widget.meetingId // Exclude current meeting when editing
      );
      
      if (mounted) {
        setState(() {
          _availableTimeSlots = availableSlots;
        
          // In edit mode, ensure the current time slot is always available
          if (isEditMode && _selectedTimeSlot != null && !_availableTimeSlots.contains(_selectedTimeSlot)) {
            _availableTimeSlots.add(_selectedTimeSlot!);
            // Sort the list to keep it in chronological order
            _availableTimeSlots.sort((a, b) {
              final timeA = a.split(':');
              final timeB = b.split(':');
              final hourA = int.parse(timeA[0]);
              final minuteA = int.parse(timeA[1]);
              final hourB = int.parse(timeB[0]);
              final minuteB = int.parse(timeB[1]);
              
              if (hourA != hourB) {
                return hourA.compareTo(hourB);
              }
              return minuteA.compareTo(minuteB);
            });
          }
          
          // For create mode, reset selection if time slot is not available
          if (!isEditMode && _selectedTimeSlot != null && !_availableTimeSlots.contains(_selectedTimeSlot)) {
            _selectedTimeSlot = null;
          }
        });
      }
      
      // Afiseaza mesaj daca nu sunt ore disponibile (only for create mode)
      if (!isEditMode && _availableTimeSlots.isEmpty) {
        _showError('Nu sunt ore disponibile in aceasta data');
      }
    } catch (e) {
      debugPrint('Eroare la incarcarea orelor disponibile din cache: $e');
      _showError('Eroare la incarcarea orelor disponibile din cache');
    }
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final initialDate = _selectedDate != null && _selectedDate!.isAfter(now) 
        ? _selectedDate! 
        : now;
    
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      locale: const Locale('ro', 'RO'),
      selectableDayPredicate: (DateTime date) {
        // Exclude weekends (Saturday = 6, Sunday = 7)
        return date.weekday != DateTime.saturday && date.weekday != DateTime.sunday;
      },
    );

    if (picked != null && picked != _selectedDate) {
      if (mounted) {
        setState(() {
          _selectedDate = picked;
          // Reseteaza ora cand se schimba data
          _selectedTimeSlot = null;
        });
      }
      
      // Incarca orele disponibile pentru noua data
      await _loadAvailableTimeSlotsFromCache();
    }
  }

  Future<void> _saveMeeting() async {
    // Validare
    if (_selectedDate == null) {
      _showError("Selecteaza o data");
      return;
    }

    if (_selectedTimeSlot == null || _selectedTimeSlot!.trim().isEmpty) {
      _showError("Selecteaza o ora");
      return;
    }

    if (mounted) {
      setState(() => _isLoading = true);
    }

    try {
      // Construieste data si ora finale
      final timeParts = _selectedTimeSlot!.trim().split(':');
      final finalDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );

      // Obtine datele consultantului curent
      final authService = AuthService();
      final consultantData = await authService.getCurrentConsultantData();
      final consultantName = consultantData?['name'] ?? 'Consultant necunoscut';
      final consultantToken = consultantData?['token'] ?? '';

      // Creeaza obiectul MeetingData
      final meetingData = MeetingData(
        clientName: _clientNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        dateTime: finalDateTime,
        type: _selectedType,
        consultantToken: consultantToken,
        consultantName: consultantName,
      );

      Map<String, dynamic> result;
      if (isEditMode) {
        result = await _meetingService.updateMeeting(widget.meetingId!, meetingData);
      } else {
        result = await _meetingService.createMeeting(meetingData);
      }

      if (result['success']) {
        // FIX: Invalidează și reîncarcă imediat cache-urile pentru actualizare instantanee
        await _splashService.invalidateAllMeetingCaches();
        
        if (mounted) {
          Navigator.of(context).pop();
          if (widget.onSaved != null) {
            widget.onSaved!();
          }
          _showSuccess(result['message']);
        }
      } else {
        if (mounted) {
          _showError(result['message']);
        }
      }
    } catch (e) {
      debugPrint("Eroare la salvarea intalnirii: $e");
      if (mounted) {
        _showError("Eroare la salvarea intalnirii");
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteMeeting() async {
    if (!isEditMode || widget.meetingId == null) {
      debugPrint("Delete meeting called but not in edit mode or no meeting ID");
      return;
    }

    debugPrint("Delete meeting called for ID: ${widget.meetingId}");

    // Afiseaza dialog de confirmare
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmare stergere'),
        content: const Text('Esti sigur ca vrei sa stergi aceasta intalnire?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Anuleaza'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sterge'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) {
      debugPrint("Delete cancelled by user");
      return;
    }

    if (mounted) {
      setState(() => _isLoading = true);
    }

    try {
      debugPrint("Attempting to delete meeting with ID: ${widget.meetingId}");
      final result = await _meetingService.deleteMeeting(widget.meetingId!);
      
      debugPrint("Delete result: $result");
      
      if (result['success']) {
        // FIX: Invalidează și reîncarcă imediat cache-urile pentru actualizare instantanee
        await _splashService.invalidateAllMeetingCaches();
        
        if (mounted) {
          Navigator.of(context).pop();
          if (widget.onSaved != null) {
            widget.onSaved!();
          }
          _showSuccess(result['message']);
        }
      } else {
        if (mounted) {
          _showError(result['message']);
        }
      }
    } catch (e) {
      debugPrint("Eroare la stergerea intalnirii: $e");
      if (mounted) {
        _showError("Eroare la stergerea intalnirii");
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSuccess(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  String get _selectedDateText {
    if (_selectedDate == null) return "Selecteaza data";
    return DateFormat('dd/MM/yy').format(_selectedDate!);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingDialog();
    }

    return Center(
      child: Material(
        color: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 296, minHeight: 352),
          child: Container(
            width: 360,
            height: 432,
            padding: const EdgeInsets.all(AppTheme.smallGap),
            decoration: AppTheme.popupDecoration,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                WidgetHeader1(
                  title: popupTitle,
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.mediumGap),
                ),
                
                const SizedBox(height: AppTheme.smallGap),
                
                // Form Container
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppTheme.smallGap),
                    decoration: AppTheme.container1Decoration,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nume client
                        InputField1(
                          title: "Nume client",
                          controller: _clientNameController,
                          hintText: "Introduceti numele",
                        ),
                        
                        const SizedBox(height: AppTheme.smallGap),
                        
                        // Telefon (optional)
                        InputField1(
                          title: "Telefon",
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          hintText: "Introduceti telefonul",
                        ),
                        
                        const SizedBox(height: AppTheme.smallGap),
                        
                        // Tip intalnire (dropdown)
                        DropdownField1<MeetingType>(
                          title: "Tip intalnire",
                          value: _selectedType,
                          items: MeetingType.values.map((type) {
                            return DropdownMenuItem<MeetingType>(
                              value: type,
                              child: Text(
                                type == MeetingType.meeting ? "Intalnire" : "Stergere birou credit",
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null && mounted) {
                              setState(() {
                                _selectedType = value;
                              });
                            }
                          },
                        ),
                        
                        const SizedBox(height: AppTheme.smallGap),
                        
                        // Row cu Data si Ora
                        Row(
                          children: [
                            // Data - using InputField3 with calendar icon
                            Expanded(
                              child: InputField3(
                                title: "Data",
                                inputText: _selectedDateText,
                                trailingIconPath: "assets/calendarIcon.svg",
                                onTap: _selectDate,
                              ),
                            ),
                            
                            const SizedBox(width: AppTheme.smallGap),
                            
                            // Ora - using DropdownField1 for time slot selection
                            Expanded(
                              child: DropdownField1<String>(
                                title: "Ora",
                                value: _selectedTimeSlot,
                                items: _availableTimeSlots.map((timeSlot) {
                                  return DropdownMenuItem<String>(
                                    value: timeSlot,
                                    child: Text(timeSlot),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (mounted) {
                                    setState(() {
                                      _selectedTimeSlot = value;
                                    });
                                  }
                                },
                                hintText: "Selecteaza ora",
                                enabled: _selectedDate != null && _availableTimeSlots.isNotEmpty,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: AppTheme.smallGap),
                
                // Buttons - flexButtons2 with save and delete
                FlexButtonWithTrailingIcon(
                  primaryButtonText: "Salveaza",
                  primaryButtonIconPath: "assets/saveIcon.svg",
                  onPrimaryButtonTap: _saveMeeting,
                  trailingIconPath: "assets/deleteIcon.svg",
                  onTrailingIconTap: () {
                    debugPrint("Delete button tapped. isEditMode: $isEditMode, meetingId: ${widget.meetingId}");
                    if (isEditMode) {
                      _deleteMeeting();
                    } else {
                      _showError("Nu poti sterge o intalnire care nu exista inca");
                    }
                  },
                  spacing: AppTheme.smallGap,
                  borderRadius: AppTheme.borderRadiusMedium,
                  buttonHeight: 48.0,
                  primaryButtonTextStyle: AppTheme.safeOutfit(
                    fontSize: AppTheme.fontSizeMedium,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingDialog() {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 200,
          height: 100,
          padding: const EdgeInsets.all(AppTheme.mediumGap),
          decoration: AppTheme.popupDecoration,
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: AppTheme.smallGap),
              Text("Se incarca..."),
            ],
          ),
        ),
      ),
    );
  }
}

