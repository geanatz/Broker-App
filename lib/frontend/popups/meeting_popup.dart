import 'package:mat_finance/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mat_finance/frontend/components/headers/widget_header1.dart';
import 'package:mat_finance/frontend/components/fields/input_field3.dart';
import 'package:mat_finance/frontend/components/fields/dropdown_field1.dart';
import 'package:mat_finance/frontend/components/buttons/flex_buttons1.dart';
import 'package:mat_finance/frontend/components/buttons/flex_buttons2.dart';
import 'package:mat_finance/backend/services/meeting_service.dart';
import 'package:mat_finance/backend/services/splash_service.dart';
import 'package:mat_finance/backend/services/clients_service.dart';
import 'package:mat_finance/backend/services/auth_service.dart';
import 'package:mat_finance/backend/services/firebase_service.dart';

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
  
  // Selectie client existent
  String? _selectedClientPhone;
  List<ClientModel> _clients = [];
  // Removed unused: original phone was used only by delete flow
  
  // State variables
  MeetingType _selectedType = MeetingType.meeting;
  DateTime? _selectedDate;
  String? _selectedTimeSlot; // Schimbat din controller la String pentru dropdown
  List<String> _availableTimeSlots = []; // Lista orelor disponibile
  bool _isLoading = false;

  // Pentru a sti daca suntem in modul editare
  bool get isEditMode => widget.meetingId != null;
  
  String get popupTitle => isEditMode ? 'Editeaza intalnire' : 'Creeaza intalnire';

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _initializeData() async {
    if (mounted) {
      setState(() => _isLoading = true);
    }

    // Incarca lista de clienti existenti din cache
    try {
      final cachedClients = await _splashService.getCachedClients();
      _clients = List.from(cachedClients);
      // sorteaza alfabetic pentru UX
      _clients.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    } catch (_) {}

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
      final phoneNumber = additionalData['phoneNumber'] ?? '';
      
      // Convert ActivityType to MeetingType
      final meetingType = targetMeeting.type == ClientActivityType.bureauDelete 
          ? MeetingType.bureauDelete 
          : MeetingType.meeting;

      _selectedClientPhone = phoneNumber.isNotEmpty ? phoneNumber : null;
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
      return;
    }

    if (_selectedTimeSlot == null || _selectedTimeSlot!.trim().isEmpty) {
      return;
    }

    // Validare client existent
    if (_selectedClientPhone == null || _selectedClientPhone!.isEmpty) {
      return;
    }

    // OPTIMIZARE: Set loading state imediat pentru feedback instant
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

      // OPTIMIZARE: Obtine datele consultantului in paralel cu alte operatii
      final authService = AuthService();
      final firebaseService = NewFirebaseService();
      
      // OPTIMIZARE: Operatii paralele pentru obtinerea datelor consultantului
      final consultantResults = await Future.wait([
        authService.getCurrentConsultantData(),
        firebaseService.getCurrentConsultantToken(),
      ]);
      
      final consultantData = consultantResults[0] as Map<String, dynamic>?;
      final consultantToken = consultantResults[1] as String?;
      
      final consultantName = consultantData?['name'] ?? 'Consultant necunoscut';
      
      // FIX: Validare pentru consultantToken
      if (consultantToken == null || consultantToken.isEmpty) {
        return;
      }

      // Obtine clientul selectat
      final selectedClient = _clients.firstWhere(
        (c) => c.phoneNumber == _selectedClientPhone,
        orElse: () => ClientModel(
          id: _selectedClientPhone!,
          name: '',
          phoneNumber1: _selectedClientPhone!,
          status: ClientStatus.normal,
          category: ClientCategory.apeluri,
          formData: const {},
        ),
      );
      if (selectedClient.name.trim().isEmpty) {
        return;
      }

      // Creeaza obiectul MeetingData
      final meetingData = MeetingData(
        clientName: selectedClient.name,
        phoneNumber: selectedClient.phoneNumber,
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
        
        // OPTIMIZARE: Inchide popup-ul imediat pentru feedback instant
        if (mounted) {
          // Safe close: only pop if this popup was pushed as a route
          WidgetsBinding.instance.addPostFrameCallback((_) {
            try {
              final nav = Navigator.of(context);
              if (nav.canPop()) {
                nav.pop();
              } else {
                debugPrint('MEETING_POPUP: cannot pop route, using onSaved callback only');
              }
            } catch (e) {
              debugPrint('MEETING_POPUP: error while popping route: $e');
            }
            if (widget.onSaved != null) {
              widget.onSaved!();
            }
          });
        }
        
        // OPTIMIZARE: Invalidare cache in background pentru actualizare rapida
        _invalidateCacheInBackground();
      } else {
        // silent
      }
    } catch (e) {
      debugPrint("❌ MEETING_POPUP: Exception in _saveMeeting: $e");
      debugPrint("❌ MEETING_POPUP: Stack trace: ${StackTrace.current}");
      // silent
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// OPTIMIZARE: Invalidare cache in background pentru performanta
  void _invalidateCacheInBackground() {
    // OPTIMIZARE: Executa in background pentru a nu bloca UI-ul
    Future.microtask(() async {
      try {
        await _splashService.invalidateAllMeetingCaches();
      } catch (e) {
        debugPrint('❌ MEETING_POPUP: Error invalidating cache in background: $e');
      }
    });
  }

  /// Delete meeting instantly (no confirmation) when editing
  Future<void> _onDeleteMeeting() async {
    if (!isEditMode || widget.meetingId == null) {
      return;
    }
    if (mounted) {
      setState(() => _isLoading = true);
    }
    try {
      final phoneNumber = _selectedClientPhone ?? '';
      final result = await _meetingService.deleteMeeting(widget.meetingId!, phoneNumber);
      if (result['success']) {
        _splashService.invalidateAllMeetingCaches();
        if (mounted) {
          Navigator.of(context).pop();
          widget.onSaved?.call();
        }
      }
    } catch (e) {
      debugPrint('❌ MEETING_POPUP: Exception in _onDeleteMeeting: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Delete flow handled elsewhere when editing; no delete button in create mode

  void _showError(String message) {}

  // Removed UI snackbars

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
          constraints: const BoxConstraints(minWidth: 296),
          child: Container(
            width: 360,
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
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppTheme.smallGap),
                  decoration: AppTheme.container1Decoration,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        // Selectie client existent
                        DropdownField1<String>(
                          title: "Client",
                          value: _selectedClientPhone,
                          items: _clients.map((client) {
                            final label = '${client.name} (${client.phoneNumber})';
                            return DropdownMenuItem<String>(
                              value: client.phoneNumber,
                              child: Text(label),
                            );
                          }).toList(),
                          onChanged: isEditMode ? null : (value) {
                            if (mounted) {
                              setState(() {
                                _selectedClientPhone = value;
                              });
                            }
                          },
                          hintText: "Selecteaza clientul",
                          enabled: _clients.isNotEmpty,
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
                                trailingIconPath: "assets/calendar_outlined.svg",
                                onTap: _selectDate,
                                inputBorderRadius: AppTheme.borderRadiusTiny,
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
                                dropdownBorderRadius: AppTheme.borderRadiusTiny,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                
                const SizedBox(height: AppTheme.smallGap),
                
                // Buttons – create: only save; edit: save + delete
                if (!isEditMode)
                  FlexButtonSingle(
                    text: "Salveaza",
                    iconPath: "assets/save_outlined.svg",
                    onTap: _saveMeeting,
                    borderRadius: AppTheme.borderRadiusSmall,
                    buttonHeight: 48.0,
                    textStyle: AppTheme.safeOutfit(
                      fontSize: AppTheme.fontSizeMedium,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                else
                  FlexButtonWithTrailingIcon(
                    primaryButtonText: "Salveaza",
                    primaryButtonIconPath: "assets/save_outlined.svg",
                    onPrimaryButtonTap: _saveMeeting,
                    trailingIconPath: "assets/delete_outlined.svg",
                    onTrailingIconTap: _onDeleteMeeting,
                    spacing: AppTheme.smallGap,
                    borderRadius: AppTheme.borderRadiusSmall,
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


