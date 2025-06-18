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
import 'package:broker_app/backend/services/xlsx_service.dart';


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
  final ExcelExportService _excelExportService = ExcelExportService();
  
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

  /// Incarca orele disponibile pentru data selectata
  Future<void> _loadAvailableTimeSlotsForDate() async {
    if (_selectedDate == null) return;

    try {
      // Foloseste MeetingService pentru a obtine orele disponibile
      final availableSlots = await _meetingService.getAvailableTimeSlots(_selectedDate!);
      
      if (mounted) {
        setState(() {
          _availableTimeSlots = availableSlots;
        });
      }
      
      // Afiseaza mesaj daca nu sunt ore disponibile
      if (_availableTimeSlots.isEmpty) {
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

  /// Genereaza textul pentru placeholder-ul datei (data curenta)
  String get _currentDateText {
    return DateFormat('dd/MM/yy').format(DateTime.now());
  }

  /// Genereaza textul pentru placeholder-ul orei (ora curenta)
  String get _currentTimeText {
    return DateFormat('HH:mm').format(DateTime.now());
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
        final meetingData = MeetingData(
          clientName: widget.client.name,
          phoneNumber: widget.client.phoneNumber,
          dateTime: finalDateTime,
          type: MeetingType.meeting,
          consultantId: '', // Va fi setat de service
          consultantName: '', // Va fi setat de service
        );

        final result = await _meetingService.createMeeting(meetingData);
        
        if (!result['success']) {
          _showError(result['message'] ?? 'Eroare la salvarea intalnirii');
          return;
        }
        
        debugPrint('✅ Intalnire salvata in calendar: ${widget.client.name} - $finalDateTime');
      }

      // Muta clientul in categoria corespunzatoare in functie de status
      switch (_selectedStatus) {
        case 'Acceptat':
          await _clientService.moveClientToRecente(
            widget.client.phoneNumber,
            additionalInfo: _statusController.text.isNotEmpty ? _statusController.text : null,
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

      // Salveaza doar acest client in Excel dupa salvarea cu succes
      try {
        debugPrint('🔄 Incepe salvarea clientului in XLSX...');
        
        // Obtine datele complete ale clientului folosind ClientsFirebaseService
        final clientsService = ClientsFirebaseService();
        final unifiedClient = await clientsService.getClient(widget.client.phoneNumber);
        
        if (unifiedClient != null) {
          final filePath = await _excelExportService.saveClientToXlsx(unifiedClient);
          
          if (filePath != null) {
            debugPrint('✅ Client salvat in XLSX: $filePath');
          } else {
            debugPrint('⚠️ Salvarea in XLSX nu a putut fi realizata');
          }
        } else {
          debugPrint('⚠️ Nu s-au putut obtine datele complete ale clientului pentru XLSX');
        }
      } catch (e, stackTrace) {
        debugPrint('❌ Eroare la salvarea clientului in XLSX: $e');
        debugPrint('❌ Stack trace: $stackTrace');
        // Nu oprim procesul pentru ca statusul a fost salvat cu succes
      }

      if (mounted) {
        Navigator.of(context).pop();
        if (widget.onSaved != null) {
          widget.onSaved!();
        }
      }
      
      String successMessage = "Statusul a fost salvat cu succes si datele au fost salvate in clienti.xlsx";
      if (_selectedStatus == 'Acceptat' && finalDateTime != null) {
        successMessage = "Statusul a fost salvat, intalnirea a fost programata si datele au fost salvate in clienti.xlsx";
      } else if (_selectedStatus == 'Amanat') {
        successMessage = "Clientul a fost mutat in sectiunea Reveniri si datele au fost salvate in clienti.xlsx";
      } else if (_selectedStatus == 'Refuzat') {
        successMessage = "Clientul a fost mutat in sectiunea Recente si datele au fost salvate in clienti.xlsx";
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
                              }
                            });
                          }
                        },
                        hintText: 'Selecteaza statusul',
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
                                  : _currentDateText,
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
                                      hintText: _currentTimeText,
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
                                      hintText: _selectedDate != null ? "00:00" : "Alege data",
                                      enabled: _selectedDate != null && _availableTimeSlots.isNotEmpty,
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

