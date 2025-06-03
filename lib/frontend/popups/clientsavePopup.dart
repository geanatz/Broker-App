import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:broker_app/frontend/common/appTheme.dart';
import 'package:broker_app/frontend/common/components/headers/widgetHeader1.dart';
import 'package:broker_app/frontend/common/components/fields/dropdownField1.dart';
import 'package:broker_app/frontend/common/components/fields/inputField3.dart';
import 'package:broker_app/frontend/common/components/buttons/flexButtons1.dart';
import 'package:broker_app/backend/models/client_model.dart';
import 'package:broker_app/backend/services/meetingService.dart';
import 'package:broker_app/frontend/common/services/client_service.dart';

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
  
  // Controllers pentru inputuri
  final TextEditingController _statusController = TextEditingController();
  
  // State variables
  String? _selectedStatus;
  DateTime? _selectedDate;
  String? _selectedTime;
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
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        // Resetează ora când se schimbă data și încarcă orele disponibile
        _selectedTime = null;
      });
      
      // Încarcă orele disponibile pentru data selectată
      await _loadAvailableTimeSlotsForDate();
    }
  }

  /// Încarcă orele disponibile pentru data selectată
  Future<void> _loadAvailableTimeSlotsForDate() async {
    if (_selectedDate == null) return;

    try {
      // Folosește MeetingService pentru a obține orele disponibile
      final availableSlots = await _meetingService.getAvailableTimeSlots(_selectedDate!);
      
      setState(() {
        _availableTimeSlots = availableSlots;
        // Selectează prima oră disponibilă automat
        if (_availableTimeSlots.isNotEmpty) {
          _selectedTime = _availableTimeSlots.first;
        } else {
          _selectedTime = null;
        }
      });
      
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

      if (_selectedTime == null) {
        _showError("Selectează o oră");
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      // Construiește data și ora finale dacă sunt necesare
      DateTime? finalDateTime;
      if (_shouldShowSecondRow && _selectedDate != null && _selectedTime != null) {
        final timeParts = _selectedTime!.split(':');
        finalDateTime = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          int.parse(timeParts[0]),
          int.parse(timeParts[1]),
        );
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

      Navigator.of(context).pop();
      if (widget.onSaved != null) {
        widget.onSaved!();
      }
      
      String successMessage = "Statusul a fost salvat cu succes";
      if (_selectedStatus == 'Acceptat' && finalDateTime != null) {
        successMessage = "Statusul a fost salvat și întâlnirea a fost programată în calendar";
      } else if (_selectedStatus == 'Amanat') {
        successMessage = "Clientul a fost mutat în secțiunea Reveniri";
      } else if (_selectedStatus == 'Refuzat') {
        successMessage = "Clientul a fost mutat în secțiunea Recente";
      }
      _showSuccess(successMessage);
    } catch (e) {
      debugPrint("Eroare la salvarea statusului: $e");
      _showError("Eroare la salvarea statusului");
    } finally {
      setState(() => _isLoading = false);
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
              WidgetHeader1(title: 'Status discutie - ${widget.client.name}'),
              
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
                        title: 'Status discutie',
                        value: _selectedStatus,
                        items: _statusOptions.map((status) => DropdownMenuItem<String>(
                          value: status,
                          child: Text(status),
                        )).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value;
                            // Resetează data și ora când se schimbă statusul
                            if (!_shouldShowSecondRow) {
                              _selectedDate = null;
                              _selectedTime = null;
                            }
                          });
                        },
                        hintText: 'Selecteaza statusul',
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Al doilea rând - Data și ora (condiționat)
                      if (_shouldShowSecondRow) ...[
                        Row(
                          children: [
                            // Câmpul pentru dată
                            Expanded(
                              child: InputField3(
                                title: _selectedStatus == 'Acceptat' ? 'Data intalnire' : 'Data amanare',
                                inputText: _selectedDate != null 
                                  ? DateFormat('dd/MM/yy').format(_selectedDate!)
                                  : 'zz/ll/aa',
                                trailingIcon: Icons.calendar_today,
                                onTap: _selectDate,
                              ),
                            ),
                            
                            const SizedBox(width: 8),
                            
                            // Câmpul pentru oră
                            Expanded(
                              child: DropdownField1<String>(
                                title: _selectedStatus == 'Acceptat' ? 'Ora intalnire' : 'Ora amanare',
                                value: _selectedTime,
                                items: _availableTimeSlots.map((time) => DropdownMenuItem<String>(
                                  value: time,
                                  child: Text(time),
                                )).toList(),
                                onChanged: _selectedDate != null ? (value) {
                                  setState(() {
                                    _selectedTime = value;
                                  });
                                } : null,
                                hintText: _selectedDate != null ? 'Selecteaza ora' : 'Blocat',
                                enabled: _selectedDate != null,
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
                                      style: GoogleFonts.outfit(
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
                                  style: GoogleFonts.outfit(
                                    color: AppTheme.elementColor3,
                                    fontSize: AppTheme.fontSizeMedium,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Introduceti informatii aditionale...',
                                    hintStyle: GoogleFonts.outfit(
                                      color: AppTheme.elementColor1,
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
              
              // Butonul de salvare
              FlexButtonSingle(
                text: _isLoading ? 'Se salveaza...' : 'Salveaza status',
                icon: Icons.save,
                onTap: _isLoading ? null : _saveClientStatus,
                borderRadius: AppTheme.borderRadiusMedium,
                buttonHeight: AppTheme.navButtonHeight,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 