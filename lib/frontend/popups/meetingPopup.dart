import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:broker_app/frontend/common/appTheme.dart';
import 'package:broker_app/frontend/common/components/headers/widgetHeader1.dart';
import 'package:broker_app/frontend/common/components/fields/inputField1.dart';
import 'package:broker_app/frontend/common/components/fields/dropdownField1.dart';
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
    Key? key,
    this.meetingId,
    this.initialDateTime,
    this.onSaved,
  }) : super(key: key);

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
  bool _isLoadingSlots = false;
  bool _isLoading = false;

  // Pentru a ști dacă suntem în modul editare
  bool get isEditMode => widget.meetingId != null;
  
  String get popupTitle => isEditMode ? 'Editează întâlnire' : 'Creează întâlnire';

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

    setState(() => _isLoadingSlots = true);

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
    } finally {
      setState(() => _isLoadingSlots = false);
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
    if (_clientNameController.text.trim().isEmpty) {
      _showError("Numele clientului este obligatoriu");
      return;
    }

    if (_selectedDate == null) {
      _showError("Selectează o dată");
      return;
    }

    if (_selectedTime == null) {
      _showError("Selectează o oră");
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
        clientName: _clientNameController.text.trim(),
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
    if (_selectedDate == null) return "Selectează data";
    return DateFormat('dd/MM/yyyy').format(_selectedDate!);
  }

  String get _selectedTypeText {
    switch (_selectedType) {
      case MeetingType.meeting:
        return "Întâlnire";
      case MeetingType.bureauDelete:
        return "Ștergere birou credit";
    }
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
                        // Nume client (optional)
                        InputField1(
                          title: "Nume client",
                          inputText: _clientNameController.text.isEmpty 
                              ? "Introduceți numele" 
                              : _clientNameController.text,
                          onTap: () => _showTextInputDialog(
                            title: "Nume client",
                            controller: _clientNameController,
                            hintText: "Introduceți numele clientului",
                          ),
                        ),
                        
                        const SizedBox(height: AppTheme.smallGap),
                        
                        // Telefon (optional) - cu indicator "optional"
                        _buildOptionalInputField(
                          title: "Telefon",
                          optionalText: "(optional)",
                          inputText: _phoneController.text.isEmpty 
                              ? "Introduceți telefonul" 
                              : _phoneController.text,
                          onTap: () => _showTextInputDialog(
                            title: "Număr telefon",
                            controller: _phoneController,
                            hintText: "Introduceți numărul de telefon",
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                        
                        const SizedBox(height: AppTheme.smallGap),
                        
                        // Tip întâlnire (dropdown)
                        DropdownField1(
                          title: "Tip întâlnire",
                          selectedOption: _selectedTypeText,
                          onTap: _showTypeSelection,
                        ),
                        
                        const SizedBox(height: AppTheme.smallGap),
                        
                        // Row cu Data și Ora
                        Row(
                          children: [
                            // Data
                            Expanded(
                              child: InputField1(
                                title: "Data",
                                inputText: _selectedDateText,
                                onTap: _selectDate,
                              ),
                            ),
                            
                            const SizedBox(width: AppTheme.smallGap),
                            
                            // Ora
                            Expanded(
                              child: DropdownField1(
                                title: "Ora",
                                selectedOption: _selectedTime ?? "Selectează ora",
                                onTap: _selectedDate != null ? _showTimeSelection : null,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: AppTheme.smallGap),
                
                // Buton salvare
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: TextButton(
                    onPressed: _saveMeeting,
                    style: TextButton.styleFrom(
                      backgroundColor: AppTheme.containerColor1,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.mediumGap,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isEditMode ? "Actualizează" : "Salvează",
                          style: TextStyle(
                            color: AppTheme.elementColor2,
                            fontSize: AppTheme.fontSizeMedium,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Outfit',
                          ),
                        ),
                        const SizedBox(width: AppTheme.smallGap),
                        Icon(
                          Icons.save,
                          color: AppTheme.elementColor2,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionalInputField({
    required String title,
    required String optionalText,
    required String inputText,
    required VoidCallback onTap,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 128),
      child: SizedBox(
        width: double.infinity,
        height: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 21,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: AppTheme.elementColor2,
                        fontSize: AppTheme.fontSizeMedium,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Outfit',
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppTheme.smallGap),
                  Text(
                    optionalText,
                    style: TextStyle(
                      color: AppTheme.elementColor1,
                      fontSize: AppTheme.fontSizeSmall,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Outfit',
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
              child: Container(
                width: double.infinity,
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.mediumGap),
                decoration: BoxDecoration(
                  color: AppTheme.containerColor2,
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        inputText,
                        style: TextStyle(
                          color: AppTheme.elementColor3,
                          fontSize: AppTheme.fontSizeMedium,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Outfit',
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
              Text("Se încarcă..."),
            ],
          ),
        ),
      ),
    );
  }

  void _showTextInputDialog({
    required String title,
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final tempController = TextEditingController(text: controller.text);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: tempController,
          keyboardType: keyboardType,
          decoration: InputDecoration(hintText: hintText),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Anulează"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                controller.text = tempController.text;
              });
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showTypeSelection() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Selectează tipul întâlnirii"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text("Întâlnire"),
              onTap: () {
                setState(() => _selectedType = MeetingType.meeting);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("Ștergere birou credit"),
              onTap: () {
                setState(() => _selectedType = MeetingType.bureauDelete);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showTimeSelection() {
    if (_availableTimeSlots.isEmpty) {
      _showError("Nu există ore disponibile pentru această dată");
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Selectează ora"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _availableTimeSlots.length,
            itemBuilder: (context, index) {
              final timeSlot = _availableTimeSlots[index];
              return ListTile(
                title: Text(timeSlot),
                onTap: () {
                  setState(() => _selectedTime = timeSlot);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
