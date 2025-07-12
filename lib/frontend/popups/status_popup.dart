import 'package:broker_app/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:broker_app/frontend/components/headers/widget_header1.dart';
import 'package:broker_app/frontend/components/fields/dropdown_field1.dart';
import 'package:broker_app/frontend/components/fields/input_field1.dart';
import 'package:broker_app/frontend/components/fields/input_field3.dart';
import 'package:broker_app/frontend/components/buttons/flex_buttons1.dart';
import 'package:broker_app/backend/services/clients_service.dart';
import 'package:broker_app/backend/services/meeting_service.dart';
import 'package:broker_app/backend/services/auth_service.dart';
import 'package:broker_app/backend/services/splash_service.dart';
import 'package:broker_app/backend/services/sheets_service.dart';
import 'package:broker_app/backend/services/form_service.dart';
import 'package:broker_app/backend/services/firebase_service.dart';


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

/// Popup pentru salvarea statusului discutiei cu clientul
class ClientSavePopup extends StatefulWidget {
  /// Clientul pentru care se salveaza statusul
  final ClientModel client;
  
  /// Callback pentru salvare cu succes
  final VoidCallback? onSaved;

  const ClientSavePopup({
    super.key,
    required this.client,
    this.onSaved,
  });

  @override
  State<ClientSavePopup> createState() => _ClientSavePopupState();
}

class _ClientSavePopupState extends State<ClientSavePopup> {
  // Services
  final MeetingService _meetingService = MeetingService();
  final ClientUIService _clientService = ClientUIService();
  
  // Controllers pentru inputuri
  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  
  // State variables
  String? _selectedStatus;
  DateTime? _selectedDate;
  String? _selectedTimeSlot; // Pentru dropdown-ul de ore cand statusul este "Acceptat"
  List<String> _availableTimeSlots = [];
  bool _isLoading = false;

  // Optiunile pentru dropdown
  final List<String> _statusOptions = ['Acceptat', 'Amanat', 'Refuzat'];

  @override
  void initState() {
    super.initState();
    _generateTimeSlots();
    _initializeExistingStatus();
  }

  /// Initializeaza status-ul existent pentru editare
  void _initializeExistingStatus() {
    if (widget.client.discussionStatus != null && widget.client.discussionStatus!.isNotEmpty) {
      _selectedStatus = widget.client.discussionStatus;
      
      // Incarca informatiile aditionale daca exista
      if (widget.client.additionalInfo != null && widget.client.additionalInfo!.isNotEmpty) {
        _statusController.text = widget.client.additionalInfo!;
      }
      
      // IMPORTANT: Daca are data programata, incarca-o INDIFERENT de status
      if (widget.client.scheduledDateTime != null) {
        _selectedDate = DateTime(
          widget.client.scheduledDateTime!.year,
          widget.client.scheduledDateTime!.month,
          widget.client.scheduledDateTime!.day,
        );
        
        // Pentru amanat, incarca ora in timeController
        if (_selectedStatus == 'Amanat') {
          _timeController.text = DateFormat('HH:mm').format(widget.client.scheduledDateTime!);
        }
        
        // Pentru acceptat, incarca ora ca selectedTimeSlot si pregateste orele disponibile
        if (_selectedStatus == 'Acceptat') {
          _selectedTimeSlot = DateFormat('HH:mm').format(widget.client.scheduledDateTime!);
          
          // IMPORTANT: Adaugă ora existentă în lista disponibilă IMEDIAT pentru a fi afișată în UI
          if (_selectedTimeSlot != null && !_availableTimeSlots.contains(_selectedTimeSlot!)) {
            _availableTimeSlots.add(_selectedTimeSlot!);
            _availableTimeSlots.sort();
          }
          
          // Incarca orele disponibile pentru data selectata pentru completarea listei
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _loadAvailableTimeSlotsForDate();
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _statusController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  /// Genereaza sloturile de timp disponibile (similar cu meetingPopup)
  void _generateTimeSlots() {
    _availableTimeSlots.clear();
    for (int hour = 8; hour <= 18; hour++) {
      for (int minute = 0; minute < 60; minute += 30) {
        final timeString = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
        _availableTimeSlots.add(timeString);
      }
    }
  }

  /// Selecteaza data din calendar
  Future<void> _selectDate() async {
    final now = DateTime.now();
    
    // Functie helper pentru a gasi urmatoarea zi lucratoare
    DateTime getNextWorkday(DateTime date) {
      while (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
        date = date.add(const Duration(days: 1));
      }
      return date;
    }
    
    // Asigura-te ca initialDate este o zi lucratoare
    DateTime initialDate;
    if (_selectedDate != null && _selectedDate!.isAfter(now)) {
      initialDate = getNextWorkday(_selectedDate!);
    } else {
      initialDate = getNextWorkday(now);
    }
    
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
          _timeController.clear();
          if (_selectedStatus == 'Acceptat') {
            _selectedTimeSlot = null;
          }
        });
      }
      
      // Incarca orele disponibile pentru data selectata daca statusul este "Acceptat"
      if (_selectedStatus == 'Acceptat') {
        await _loadAvailableTimeSlotsForDate();
      }
    }
  }

  /// Seteaza data si ora implicita in functie de tipul de status
  Future<void> _setDefaultDateTimeForStatus(String? status) async {
    if (status == null) return;
    
    // Setting default date/time for status
    
    if (status == 'Acceptat') {
      // Pentru Acceptat, foloseste cea mai apropiata data valida din calendar
      await _setNextAvailableDateTime();
    } else if (status == 'Amanat') {
      // Pentru Amanat, foloseste data si ora curenta
      final now = DateTime.now();
      final currentTime = DateFormat('HH:mm').format(now);
      
      if (mounted) {
        setState(() {
          _selectedDate = now;
          _timeController.text = currentTime;
          _selectedTimeSlot = null; // Nu e relevant pentru amanat
        });
      }
      
      // Set current date/time for Amanat
    }
    // Pentru Refuzat nu setam nimic (nu are campuri de data/ora)
  }

  /// Seteaza automat cea mai apropiata data si ora valida pentru programare
  Future<void> _setNextAvailableDateTime() async {
    try {
      // Searching for next available date/time
      
      // Cauta urmatoarea zi lucratoare disponibila (maxim 30 de zile in viitor)
      DateTime currentDate = DateTime.now();
      DateTime? availableDate;
      String? availableTime;
      
      for (int i = 0; i < 30; i++) {
        final testDate = currentDate.add(Duration(days: i));
        
        // Verifica daca este zi lucratoare
        if (testDate.weekday == DateTime.saturday || testDate.weekday == DateTime.sunday) {
          continue;
        }
        
        // Obtine orele disponibile pentru aceasta data
        final availableSlots = await _meetingService.getAvailableTimeSlots(testDate);
        
        if (availableSlots.isNotEmpty) {
          availableDate = testDate;
          availableTime = availableSlots.first; // Prima ora disponibila
          // Found available slot
          break;
        }
      }
      
      // Seteaza datele gasite
      if (availableDate != null) {
        if (mounted) {
          setState(() {
            _selectedDate = availableDate;
            _selectedTimeSlot = availableTime;
            _availableTimeSlots = [availableTime!]; // Va fi actualizat cand se incarca toate orele
            
            // Pre-completeaza si timpul pentru amanare cu acelasi timp
            _timeController.text = availableTime;
          });
        }
        
        // Incarca toate orele disponibile pentru data selectata
        await _loadAvailableTimeSlotsForDate();
        
        // Auto-completed with next available slot
              }
      } catch (e) {
        debugPrint('❌ STATUS_POPUP: Error setting next available date/time: $e');
    }
  }

  /// Incarca orele disponibile pentru data selectata
  Future<void> _loadAvailableTimeSlotsForDate() async {
    if (_selectedDate == null) return;

    try {
      // Foloseste MeetingService pentru a obtine orele disponibile
      final availableSlots = await _meetingService.getAvailableTimeSlots(_selectedDate!);
      
      if (mounted) {
        setState(() {
          _availableTimeSlots = availableSlots;
          
          // Daca se incarca pentru prima data din edit mode si timeSlot-ul selectat nu e disponibil,
          // adauga-l la lista pentru a permite editarea
          if (_selectedTimeSlot != null && !_availableTimeSlots.contains(_selectedTimeSlot)) {
            _availableTimeSlots.add(_selectedTimeSlot!);
            _availableTimeSlots.sort(); // Sorteaza lista din nou
          }
        });
      }
      
      // Afiseaza mesaj daca nu sunt ore disponibile (dar nu pentru edit mode)
      if (_availableTimeSlots.isEmpty && _selectedTimeSlot == null) {
        _showError('Nu sunt ore disponibile in aceasta data');
      }
    } catch (e) {
      debugPrint('Eroare la incarcarea orelor disponibile: $e');
      _showError('Eroare la incarcarea orelor disponibile');
    }
  }

  /// Verifica daca al doilea rand trebuie sa fie vizibil
  bool get _shouldShowSecondRow {
    return _selectedStatus == 'Acceptat' || _selectedStatus == 'Amanat';
  }



  /// Salveaza statusul clientului
  Future<void> _saveClientStatus() async {
    // Validare
    if (_selectedStatus == null) {
      _showError("Selecteaza statusul discutiei");
      return;
    }

    if (_shouldShowSecondRow) {
      if (_selectedDate == null) {
        _showError("Selecteaza o data");
        return;
      }

      if (_selectedStatus == 'Amanat' && _timeController.text.trim().isEmpty) {
        _showError("Introduceti ora pentru amanare");
        return;
      }

      if (_selectedStatus == 'Acceptat' && (_selectedTimeSlot == null || _selectedTimeSlot!.trim().isEmpty)) {
        _showError("Selectati ora pentru intalnire");
        return;
      }
    }

    if (mounted) {
      setState(() => _isLoading = true);
    }

    try {
      // Construieste data si ora finale daca sunt necesare
      DateTime? finalDateTime;
      if (_shouldShowSecondRow && _selectedDate != null) {
        if (_selectedStatus == 'Amanat' && _timeController.text.trim().isNotEmpty) {
          // Pentru amanat, foloseste ora introdusa manual
          final timeParts = _timeController.text.trim().split(':');
          if (timeParts.length == 2) {
            finalDateTime = DateTime(
              _selectedDate!.year,
              _selectedDate!.month,
              _selectedDate!.day,
              int.parse(timeParts[0]),
              int.parse(timeParts[1]),
            );
          }
        } else if (_selectedStatus == 'Acceptat' && _selectedTimeSlot != null) {
          // Pentru acceptat, foloseste ora selectata din dropdown
          final timeParts = _selectedTimeSlot!.split(':');
          if (timeParts.length == 2) {
            finalDateTime = DateTime(
              _selectedDate!.year,
              _selectedDate!.month,
              _selectedDate!.day,
              int.parse(timeParts[0]),
              int.parse(timeParts[1]),
            );
          }
        }
      }

      // Daca statusul este "Acceptat", salveaza intalnirea in calendar
      if (_selectedStatus == 'Acceptat' && finalDateTime != null) {
        debugPrint('🔍 STATUS_POPUP: Creating meeting for accepted client');
        
        // Obtine numele consultantului curent
        final authService = AuthService();
        final consultantData = await authService.getCurrentConsultantData();
        debugPrint('🔍 STATUS_POPUP: consultantData = $consultantData');
        final consultantName = consultantData?['name'] ?? 'Consultant necunoscut';
        debugPrint('🔍 STATUS_POPUP: consultantName = "$consultantName"');
        
        // FIX: Obtine consultantToken-ul curent cu validare
        final firebaseService = NewFirebaseService();
        final consultantToken = await firebaseService.getCurrentConsultantToken();
        debugPrint('🔍 STATUS_POPUP: consultantToken = "$consultantToken"');
        
        // FIX: Validare pentru consultantToken
        if (consultantToken == null || consultantToken.isEmpty) {
          debugPrint('❌ STATUS_POPUP: consultantToken is null or empty');
          _showError("Eroare: Nu s-a putut obtine token-ul consultantului");
          return;
        }
        
        debugPrint('🔍 STATUS_POPUP: Creating MeetingData object');
        final meetingData = MeetingData(
          clientName: widget.client.name,
          phoneNumber: widget.client.phoneNumber,
          dateTime: finalDateTime,
          type: MeetingType.meeting,
          consultantToken: consultantToken,
          consultantName: consultantName,
        );
        debugPrint('🔍 STATUS_POPUP: MeetingData created successfully');

        debugPrint('🔍 STATUS_POPUP: Calling meeting service');
        final result = await _meetingService.createMeeting(meetingData);
        debugPrint('🔍 STATUS_POPUP: Meeting service result = $result');
        
        if (!result['success']) {
                  final errorMessage = result['message'] ?? 'Eroare la salvarea intalnirii';
        debugPrint('❌ STATUS_POPUP: Meeting creation failed: $errorMessage');
        _showError(errorMessage);
          return;
        }
        
        debugPrint('✅ STATUS_POPUP: Intalnire salvata in calendar: ${widget.client.name} - $finalDateTime');
        
        // IMPORTANT: Invalidează cache-ul pentru a afișa imediat întâlnirea în calendar
        try {
          final splashService = SplashService();
          await splashService.invalidateMeetingsCacheAndRefresh();
                  // Cache invalidated after meeting save
      } catch (e) {
        debugPrint('❌ STATUS_POPUP: Error invalidating cache: $e');
        }

      }

      // Muta clientul in categoria corespunzatoare in functie de status
      switch (_selectedStatus) {
        case 'Acceptat':
          await _clientService.moveClientToRecente(
            widget.client.phoneNumber,
            additionalInfo: _statusController.text.isNotEmpty ? _statusController.text : null,
            scheduledDateTime: finalDateTime, // IMPORTANT: Transmite data și ora întâlnirii
          );
          break;
          
        case 'Amanat':
          if (finalDateTime != null) {
            await _clientService.moveClientToReveniri(
              widget.client.phoneNumber,
              scheduledDateTime: finalDateTime,
              additionalInfo: _statusController.text.isNotEmpty ? _statusController.text : null,
            );
          }
          break;
          
        case 'Refuzat':
          await _clientService.moveClientToRecenteRefuzat(
            widget.client.phoneNumber,
            additionalInfo: _statusController.text.isNotEmpty ? _statusController.text : null,
          );
          break;
      }

      debugPrint('✅ Client mutat cu succes: ${widget.client.name} - Status: $_selectedStatus');

      // Salveaza client in Excel prin Google Drive dupa salvarea cu succes
      try {
        // IMPORTANT: Actualizeaza clientul cu statusul nou si informatiile aditionale
        final updatedClient = widget.client.copyWith(
          discussionStatus: _selectedStatus,
          additionalInfo: _statusController.text.isNotEmpty ? _statusController.text : null,
          scheduledDateTime: finalDateTime,
        );
        
        // Obtine datele de formular din FormService si le ataseaza la client
        final formService = FormService();
        final clientFormData = formService.prepareDataForExport();
        final clientData = clientFormData[widget.client.phoneNumber];
        
        // Ataseaza datele de formular la client
        final clientWithFormData = updatedClient.copyWith(
          formData: clientData,
        );
        
        final googleDriveService = GoogleDriveService();
        final saveResult = await googleDriveService.saveClientToXlsx(clientWithFormData);
        
        if (saveResult != null) {
          // A fost o eroare la salvare
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Avertizare: $saveResult'),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        }
      } catch (e) {
        debugPrint('❌ STATUS_POPUP: Error saving to Google Drive: $e');
        // Nu oprim procesul pentru ca statusul a fost salvat cu succes
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Avertizare: Eroare la salvarea în Google Drive Excel'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }

      if (mounted) {
        Navigator.of(context).pop();
        if (widget.onSaved != null) {
          widget.onSaved!();
        }
      }
      
      String successMessage = "Statusul a fost salvat cu succes si datele au fost salvate in Google Sheets";
      if (_selectedStatus == 'Acceptat' && finalDateTime != null) {
        successMessage = "Statusul a fost salvat, intalnirea a fost programata si datele au fost salvate in Google Sheets";
      } else if (_selectedStatus == 'Amanat') {
        successMessage = "Clientul a fost mutat in sectiunea Reveniri si datele au fost salvate in Google Sheets";
      } else if (_selectedStatus == 'Refuzat') {
        successMessage = "Clientul a fost mutat in sectiunea Recente si datele au fost salvate in Google Sheets";
      }
      _showSuccess(successMessage);
    } catch (e) {
      debugPrint("Eroare la salvarea statusului: $e");
      if (mounted) {
        _showError("Eroare la salvarea statusului");
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Afiseaza mesaj de eroare
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

  /// Afiseaza mesaj de succes
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 360, minHeight: 376),
        child: Container(
          width: 360,
          height: _shouldShowSecondRow ? 456 : 376, // Inaltime dinamica
          padding: const EdgeInsets.all(8),
          decoration: ShapeDecoration(
            color: AppTheme.popupBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const WidgetHeader1(title: 'Status client'),
              
              const SizedBox(height: 8),
              
              // Continutul principal
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: ShapeDecoration(
                    color: AppTheme.containerColor1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Primul rand - Dropdown pentru status
                      DropdownField1<String>(
                        title: 'Status',
                        value: _selectedStatus,
                        items: _statusOptions.map((status) => DropdownMenuItem<String>(
                          value: status,
                          child: Text(status),
                        )).toList(),
                        onChanged: (value) {
                          if (mounted) {
                            setState(() {
                              _selectedStatus = value;
                              // Reseteaza data si ora cand se schimba statusul
                              if (!_shouldShowSecondRow) {
                                _selectedDate = null;
                                _timeController.clear();
                                _selectedTimeSlot = null;
                              } else {
                                // Seteaza automat data si ora in functie de tipul de status
                                _setDefaultDateTimeForStatus(value);
                              }
                            });
                          }
                        },
                        hintText: 'Selecteaza status',
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Al doilea rand - Data si ora (conditionat)
                      if (_shouldShowSecondRow) ...[
                        Row(
                          children: [
                            // Campul pentru data - folosind InputField3 cu iconita calendar
                            Expanded(
                              child: InputField3(
                                title: _selectedStatus == 'Acceptat' ? 'Data intalnire' : 'Data amanare',
                                inputText: _selectedDate != null 
                                  ? DateFormat('dd/MM/yy').format(_selectedDate!)
                                  : '',
                                trailingIconPath: "assets/calendarIcon.svg",
                                onTap: _selectDate,
                              ),
                            ),
                            
                            const SizedBox(width: 8),
                            
                            // Campul pentru ora - diferit pentru Acceptat vs Amanat
                            Expanded(
                              child: _selectedStatus == 'Amanat'
                                  ? InputField1(
                                      title: 'Ora amanare',
                                      controller: _timeController,
                                      hintText: null,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        TimeInputFormatter(),
                                      ],
                                    )
                                  : DropdownField1<String>(
                                      title: 'Ora intalnire',
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
                                      hintText: null,
                                      enabled: _selectedDate != null,
                                    ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 8),
                      ],
                      
                      // Al treilea rand - Informatii aditionale (permanent)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              height: 21,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Informatii aditionale',
                                      style: AppTheme.safeOutfit(
                                        color: AppTheme.elementColor2,
                                        fontSize: AppTheme.fontSizeMedium,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 4),
                            
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: ShapeDecoration(
                                  color: AppTheme.containerColor2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                                  ),
                                ),
                                child: TextField(
                                  controller: _statusController,
                                  maxLines: null,
                                  expands: true,
                                  textAlignVertical: TextAlignVertical.top,
                                  style: AppTheme.safeOutfit(
                                    color: AppTheme.elementColor3,
                                    fontSize: AppTheme.fontSizeMedium,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Introduceti informatii aditionale...',
                                    hintStyle: AppTheme.safeOutfit(
                                      color: AppTheme.elementColor3,
                                      fontSize: AppTheme.fontSizeMedium,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
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
              
              const SizedBox(height: 8),
              
              // Butonul de salvare - folosind FlexButtonSingle cu saveIcon
              FlexButtonSingle(
                text: _isLoading ? 'Se salveaza...' : 'Salveaza status',
                iconPath: "assets/saveIcon.svg",
                onTap: _isLoading ? null : _saveClientStatus,
                borderRadius: AppTheme.borderRadiusMedium,
                buttonHeight: AppTheme.navButtonHeight,
                textStyle: AppTheme.safeOutfit(
                  fontSize: AppTheme.fontSizeMedium,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.elementColor2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 

