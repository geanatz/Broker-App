import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:broker_app/frontend/common/appTheme.dart';
import 'package:broker_app/frontend/common/components/headers/widgetHeader1.dart';
import 'package:broker_app/frontend/common/components/fields/inputField1.dart';
import 'package:broker_app/frontend/common/components/fields/dropdownField1.dart';
import 'package:broker_app/frontend/common/components/buttons/flexButtons2Svg.dart';
import 'package:broker_app/backend/services/meetingService.dart';

/// Popup combinat pentru crearea și editarea întâlnirilor
class MeetingPopup extends StatefulWidget {
  /// ID-ul întâlnirii pentru editare (null pentru creare nouă)
  final String? meetingId;
  
  /// Data și ora inițială (pentru creare nouă sau editare)
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
  
  // Controllers pentru inputuri
  final TextEditingController _clientNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  
  // State variables
  MeetingType _selectedType = MeetingType.meeting;
  DateTime? _selectedDate;
  String? _selectedTime;
  List<String> _availableTimeSlots = [];
  bool _isLoading = false;

  // Pentru a ști dacă suntem în modul editare
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
    setState(() => _isLoading = true);

    if (isEditMode) {
      // Modul editare - încarcă datele întâlnirii existente
      await _loadExistingMeeting();
    } else {
      // Modul creare - folosește data inițială dacă este furnizată
      if (widget.initialDateTime != null) {
        _selectedDate = widget.initialDateTime;
        _selectedTime = DateFormat('HH:mm').format(widget.initialDateTime!);
        await _loadAvailableTimeSlots();
      }
    }

    setState(() => _isLoading = false);
  }

  Future<void> _loadExistingMeeting() async {
    if (widget.meetingId == null) return;

    try {
      final meetingData = await _meetingService.getMeeting(widget.meetingId!);
      if (meetingData != null) {
        _clientNameController.text = meetingData.clientName;
        _phoneController.text = meetingData.phoneNumber;
        _selectedType = meetingData.type;
        _selectedDate = meetingData.dateTime;
        _selectedTime = DateFormat('HH:mm').format(meetingData.dateTime);
        
        await _loadAvailableTimeSlots();
      }
    } catch (e) {
      debugPrint("Eroare la încărcarea întâlnirii: $e");
      _showError("Eroare la încărcarea datelor întâlnirii");
    }
  }

  Future<void> _loadAvailableTimeSlots() async {
    if (_selectedDate == null) return;

    try {
      final slots = await _meetingService.getAvailableTimeSlots(
        _selectedDate!, 
        excludeId: widget.meetingId,
      );
      
      setState(() {
        _availableTimeSlots = slots;
        
        // Dacă slotul selectat nu este disponibil, resetează-l
        if (_selectedTime != null && !_availableTimeSlots.contains(_selectedTime)) {
          _selectedTime = null;
        }
        
        // Dacă nu avem un slot selectat și există sloturi disponibile, selectează primul
        if (_selectedTime == null && _availableTimeSlots.isNotEmpty) {
          _selectedTime = _availableTimeSlots.first;
        }
      });
    } catch (e) {
      debugPrint("Eroare la încărcarea sloturilor: $e");
      _showError("Eroare la încărcarea orelor disponibile");
    }
  }

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
        _selectedTime = null; // Resetează ora când se schimbă data
      });
      await _loadAvailableTimeSlots();
    }
  }

  Future<void> _saveMeeting() async {
    // Validare
    if (_selectedDate == null) {
      _showError("Selecteaza o data");
      return;
    }

    if (_selectedTime == null) {
      _showError("Selecteaza o ora");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Construiește data și ora finale
      final timeParts = _selectedTime!.split(':');
      final finalDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );

      // Creează obiectul MeetingData
      final meetingData = MeetingData(
        clientName: _clientNameController.text.trim().isEmpty ? 'Client nedefinit' : _clientNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        dateTime: finalDateTime,
        type: _selectedType,
        consultantId: '', // Va fi setat de service
        consultantName: '', // Va fi setat de service
      );

      Map<String, dynamic> result;
      if (isEditMode) {
        result = await _meetingService.updateMeeting(widget.meetingId!, meetingData);
      } else {
        result = await _meetingService.createMeeting(meetingData);
      }

      if (result['success']) {
        Navigator.of(context).pop();
        if (widget.onSaved != null) {
          widget.onSaved!();
        }
        _showSuccess(result['message']);
      } else {
        _showError(result['message']);
      }
    } catch (e) {
      debugPrint("Eroare la salvarea întâlnirii: $e");
      _showError("Eroare la salvarea întâlnirii");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteMeeting() async {
    if (!isEditMode || widget.meetingId == null) return;

    setState(() => _isLoading = true);

    try {
      final result = await _meetingService.deleteMeeting(widget.meetingId!);
      
      if (result['success']) {
        Navigator.of(context).pop();
        if (widget.onSaved != null) {
          widget.onSaved!();
        }
        _showSuccess(result['message']);
      } else {
        _showError(result['message']);
      }
    } catch (e) {
      debugPrint("Eroare la ștergerea întâlnirii: $e");
      _showError("Eroare la ștergerea întâlnirii");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  String get _selectedDateText {
    if (_selectedDate == null) return "Selecteaza data";
    return DateFormat('dd/MM/yyyy').format(_selectedDate!);
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
                            if (value != null) {
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
                            // Data - using GestureDetector for date picker
                            Expanded(
                              child: GestureDetector(
                                onTap: _selectDate,
                                child: Container(
                                  height: 72,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 21,
                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                        child: Text(
                                          "Data",
                                          style: GoogleFonts.outfit(
                                            color: AppTheme.elementColor2,
                                            fontSize: AppTheme.fontSizeMedium,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Container(
                                        height: 48,
                                        padding: const EdgeInsets.symmetric(horizontal: AppTheme.mediumGap, vertical: 15),
                                        decoration: BoxDecoration(
                                          color: AppTheme.containerColor2,
                                          borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                _selectedDateText,
                                                style: GoogleFonts.outfit(
                                                  color: AppTheme.elementColor3,
                                                  fontSize: AppTheme.fontSizeMedium,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            Icon(
                                              Icons.calendar_today,
                                              color: AppTheme.elementColor3,
                                              size: 24,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            
                            const SizedBox(width: AppTheme.smallGap),
                            
                            // Ora
                            Expanded(
                              child: DropdownField1<String>(
                                title: "Ora",
                                value: _selectedTime,
                                items: _availableTimeSlots.map((timeSlot) {
                                  return DropdownMenuItem<String>(
                                    value: timeSlot,
                                    child: Text(timeSlot),
                                  );
                                }).toList(),
                                onChanged: _selectedDate != null ? (value) {
                                  if (value != null) {
                                    setState(() {
                                      _selectedTime = value;
                                    });
                                  }
                                } : null,
                                hintText: "Selecteaza ora",
                                enabled: _selectedDate != null,
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
                FlexButtonWithTrailingIconSvg(
                  primaryButtonText: "Salveaza",
                  primaryButtonIconPath: "assets/saveIcon.svg",
                  onPrimaryButtonTap: _saveMeeting,
                  trailingIconPath: "assets/deleteIcon.svg",
                  onTrailingIconTap: isEditMode ? _deleteMeeting : null,
                  spacing: AppTheme.smallGap,
                  buttonBackgroundColor: AppTheme.containerColor1,
                  textColor: AppTheme.elementColor2,
                  iconColor: AppTheme.elementColor2,
                  borderRadius: AppTheme.borderRadiusMedium,
                  buttonHeight: 48.0,
                  primaryButtonTextStyle: GoogleFonts.outfit(
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
