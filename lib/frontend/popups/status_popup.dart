import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:broker_app/frontend/common/utils/safe_google_fonts.dart';
import 'package:broker_app/frontend/common/app_theme.dart';
import 'package:broker_app/frontend/common/components/headers/widget_header1.dart';
import 'package:broker_app/frontend/common/components/fields/dropdown_field1.dart';
import 'package:broker_app/frontend/common/components/fields/input_field1.dart';
import 'package:broker_app/frontend/common/components/fields/input_field3.dart';
import 'package:broker_app/frontend/common/components/buttons/flex_buttons1.dart';
import 'package:broker_app/backend/services/clients_service.dart';
import 'package:broker_app/backend/services/meeting_service.dart';
import 'package:broker_app/backend/services/xlsx_service.dart';
import 'package:broker_app/frontend/common/services/client_service.dart';

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

/// Popup pentru salvarea statusului discuției cu clientul
class ClientSavePopup extends StatefulWidget {
  /// Clientul pentru care se salvează statusul
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
  final ClientService _clientService = ClientService();
  final ExcelExportService _excelExportService = ExcelExportService();
  
  // Controllers pentru inputuri
  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  
  // State variables
  String? _selectedStatus;
  DateTime? _selectedDate;
  String? _selectedTimeSlot; // Pentru dropdown-ul de ore când statusul este "Acceptat"
  List<String> _availableTimeSlots = [];
  bool _isLoading = false;

  // Opțiunile pentru dropdown
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

  /// Generează sloturile de timp disponibile (similar cu meetingPopup)
  void _generateTimeSlots() {
    _availableTimeSlots.clear();
    for (int hour = 8; hour <= 18; hour++) {
      for (int minute = 0; minute < 60; minute += 30) {
        final timeString = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
        _availableTimeSlots.add(timeString);
      }
    }
  }

  /// Selectează data din calendar
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
          // Resetează ora când se schimbă data
          _timeController.clear();
          if (_selectedStatus == 'Acceptat') {
            _selectedTimeSlot = null;
          }
        });
      }
      
      // Încarcă orele disponibile pentru data selectată dacă statusul este "Acceptat"
      if (_selectedStatus == 'Acceptat') {
        await _loadAvailableTimeSlotsForDate();
      }
    }
  }

  /// Încarcă orele disponibile pentru data selectată
  Future<void> _loadAvailableTimeSlotsForDate() async {
    if (_selectedDate == null) return;

    try {
      // Folosește MeetingService pentru a obține orele disponibile
      final availableSlots = await _meetingService.getAvailableTimeSlots(_selectedDate!);
      
      if (mounted) {
        setState(() {
          _availableTimeSlots = availableSlots;
        });
      }
      
      // Afișează mesaj dacă nu sunt ore disponibile
      if (_availableTimeSlots.isEmpty) {
        _showError('Nu sunt ore disponibile în această dată');
      }
    } catch (e) {
      debugPrint('Eroare la încărcarea orelor disponibile: $e');
      _showError('Eroare la încărcarea orelor disponibile');
    }
  }

  /// Verifică dacă al doilea rând trebuie să fie vizibil
  bool get _shouldShowSecondRow {
    return _selectedStatus == 'Acceptat' || _selectedStatus == 'Amanat';
  }

  /// Generează textul pentru placeholder-ul datei (data curentă)
  String get _currentDateText {
    return DateFormat('dd/MM/yy').format(DateTime.now());
  }

  /// Generează textul pentru placeholder-ul orei (ora curentă)
  String get _currentTimeText {
    return DateFormat('HH:mm').format(DateTime.now());
  }

  /// Salvează statusul clientului
  Future<void> _saveClientStatus() async {
    // Validare
    if (_selectedStatus == null) {
      _showError("Selectează statusul discuției");
      return;
    }

    if (_shouldShowSecondRow) {
      if (_selectedDate == null) {
        _showError("Selectează o dată");
        return;
      }

      if (_selectedStatus == 'Amanat' && _timeController.text.trim().isEmpty) {
        _showError("Introduceti ora pentru amânare");
        return;
      }

      if (_selectedStatus == 'Acceptat' && (_selectedTimeSlot == null || _selectedTimeSlot!.trim().isEmpty)) {
        _showError("Selectați ora pentru întâlnire");
        return;
      }
    }

    if (mounted) {
      setState(() => _isLoading = true);
    }

    try {
      // Construiește data și ora finale dacă sunt necesare
      DateTime? finalDateTime;
      if (_shouldShowSecondRow && _selectedDate != null) {
        if (_selectedStatus == 'Amanat' && _timeController.text.trim().isNotEmpty) {
          // Pentru amânat, folosește ora introdusă manual
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
          // Pentru acceptat, folosește ora selectată din dropdown
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

      // Dacă statusul este "Acceptat", salvează întâlnirea în calendar
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
          _showError(result['message'] ?? 'Eroare la salvarea întâlnirii');
          return;
        }
        
        debugPrint('✅ Întâlnire salvată în calendar: ${widget.client.name} - $finalDateTime');
      }

      // Mută clientul în categoria corespunzătoare în funcție de status
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

      // Exportă datele în Excel după salvarea cu succes
      try {
        debugPrint('🔄 Începe exportul XLSX...');
        debugPrint('🔍 Debug: Serviciul Excel este inițializat: true');
        
        final filePath = await _excelExportService.exportAllClientsToXlsx();
        
        if (filePath != null) {
          debugPrint('✅ Export XLSX reușit: $filePath');
        } else {
          debugPrint('⚠️ Export XLSX nu a putut fi realizat (probabil nu există clienți)');
        }
      } catch (e, stackTrace) {
        debugPrint('❌ Eroare la exportul XLSX: $e');
        debugPrint('❌ Stack trace: $stackTrace');
        // Nu oprim procesul pentru că statusul a fost salvat cu succes
      }

      if (mounted) {
        Navigator.of(context).pop();
        if (widget.onSaved != null) {
          widget.onSaved!();
        }
      }
      
      String successMessage = "Statusul a fost salvat cu succes și datele au fost exportate în Excel";
      if (_selectedStatus == 'Acceptat' && finalDateTime != null) {
        successMessage = "Statusul a fost salvat, întâlnirea a fost programată și datele au fost exportate în Excel";
      } else if (_selectedStatus == 'Amanat') {
        successMessage = "Clientul a fost mutat în secțiunea Reveniri și datele au fost exportate în Excel";
      } else if (_selectedStatus == 'Refuzat') {
        successMessage = "Clientul a fost mutat în secțiunea Recente și datele au fost exportate în Excel";
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

  /// Afișează mesaj de eroare
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  /// Afișează mesaj de succes
  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 360, minHeight: 376),
        child: Container(
          width: 360,
          height: _shouldShowSecondRow ? 456 : 376, // Înălțime dinamică
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
              
              // Conținutul principal
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
                      // Primul rând - Dropdown pentru status
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
                              // Resetează data și ora când se schimbă statusul
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
                      
                      // Al doilea rând - Data și ora (condiționat)
                      if (_shouldShowSecondRow) ...[
                        Row(
                          children: [
                            // Câmpul pentru dată - folosind InputField3 cu iconița calendar
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
                            
                            // Câmpul pentru oră - diferit pentru Acceptat vs Amanat
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
                      
                      // Al treilea rând - Informații adiționale (permanent)
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
                                      style: SafeGoogleFonts.outfit(
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
                                  style: SafeGoogleFonts.outfit(
                                    color: AppTheme.elementColor3,
                                    fontSize: AppTheme.fontSizeMedium,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Introduceti informatii aditionale...',
                                    hintStyle: SafeGoogleFonts.outfit(
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
                textStyle: SafeGoogleFonts.outfit(
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

