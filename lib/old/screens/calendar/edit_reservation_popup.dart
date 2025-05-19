import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui';
import 'package:broker_app/frontend/common/appTheme.dart';
import 'package:broker_app/old/services/reservation_service.dart';

/// Dialog pentru editarea unei rezervari existente
class EditReservationDialog extends StatefulWidget {
  /// Date initiale ale rezervarii
  final Map<String, dynamic> reservationData;
  
  /// ID-ul documentului rezervarii
  final String docId;
  
  /// Controller pentru numele clientului
  final TextEditingController clientNameController;
  
  /// Data si ora initiala a rezervarii
  final DateTime initialDateTime;
  
  /// Functie pentru actualizarea rezervarii
  final Function(String, String, String, DateTime, ReservationType) onUpdate;
  
  /// Functie pentru stergerea rezervarii
  final Function(String) onDelete;
  
  /// Functie pentru verificarea disponibilitatii orei selectate
  final Future<List<String>> Function(DateTime, String) fetchAvailableTimeSlots;

  const EditReservationDialog({
    super.key,
    required this.reservationData,
    required this.docId,
    required this.clientNameController,
    required this.initialDateTime,
    required this.onUpdate,
    required this.onDelete,
    required this.fetchAvailableTimeSlots,
  });

  @override
  State<EditReservationDialog> createState() => _EditReservationDialogState();
}

class _EditReservationDialogState extends State<EditReservationDialog> {
  late DateTime _selectedDate;
  late String _selectedTime;
  final TextEditingController _phoneController = TextEditingController();
  ReservationType _selectedType = ReservationType.meeting;
  List<String> _availableHours = [];
  bool _isLoadingSlots = true;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDateTime;
    _selectedTime = DateFormat('HH:mm').format(widget.initialDateTime);
    
    // Initialize phone number if available
    final phoneNumber = widget.reservationData['phoneNumber'] as String? ?? '';
    _phoneController.text = phoneNumber;
    
    // Initialize reservation type
    final type = widget.reservationData['type'] as String?;
    _selectedType = type == 'bureauDelete' 
        ? ReservationType.bureauDelete 
        : ReservationType.meeting;
    
    // Fetch available time slots when dialog is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAvailableTimeSlots();
    });
  }
  
  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _fetchAvailableTimeSlots() async {
    if (!mounted) return;
    
    setState(() {
      _isLoadingSlots = true;
    });
    
    try {
      final availableHours = await widget.fetchAvailableTimeSlots(_selectedDate, widget.docId);
      
      if (mounted) {
        setState(() {
          _availableHours = availableHours;
          
          // Make sure selected time is in available hours
          String originalTimeSlot = DateFormat('HH:mm').format(widget.initialDateTime);
          if (_selectedTime != originalTimeSlot && !_availableHours.contains(_selectedTime)) {
            if (_availableHours.isNotEmpty) {
              _selectedTime = _availableHours.first;
              _updateSelectedDateTime();
            }
          }
          
          _isLoadingSlots = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingSlots = false;
        });
      }
    }
  }
  
  void _updateSelectedDateTime() {
    final timeParts = _selectedTime.split(':');
    _selectedDate = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          width: 320,
          height: 512,
          padding: const EdgeInsets.all(AppTheme.smallGap),
          decoration: BoxDecoration(
            color: AppTheme.popupBackground,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
            boxShadow: [AppTheme.widgetShadow],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header
              Container(
                width: 304,
                height: 24,
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.smallGap),
                alignment: Alignment.center,
                child: Text(
                  'Modifica programare',
                  style: AppTheme.headerTitleStyle,
                ),
              ),
              
              const SizedBox(height: AppTheme.smallGap),
              
              // Form Container
              Container(
                width: 304,
                height: 408,
                padding: const EdgeInsets.all(AppTheme.smallGap),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundLightPurple,
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Client Field
                    _buildFormField(
                      label: 'Client',
                      child: TextField(
                        controller: widget.clientNameController,
                        style: AppTheme.secondaryTitleStyle.copyWith(
                          color: AppTheme.fontDarkPurple,
                          fontSize: AppTheme.fontSizeMedium,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: _inputDecoration(hintText: 'Introdu numele clientului'),
                      ),
                    ),
                    
                    const SizedBox(height: AppTheme.smallGap),
                    
                    // Phone Number Field
                    _buildFormField(
                      label: 'Numar de telefon',
                      optionalText: '(optional)',
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: AppTheme.secondaryTitleStyle.copyWith(
                          color: AppTheme.fontDarkPurple,
                          fontSize: AppTheme.fontSizeMedium,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: _inputDecoration(hintText: 'Introdu numarul de telefon'),
                      ),
                    ),
                    
                    const SizedBox(height: AppTheme.smallGap),
                    
                    // Date Field
                    _buildFormField(
                      label: 'Data',
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () async {
                            final DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime.now().subtract(const Duration(days: 365)),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                              builder: (context, child) {
                                return Theme(
                                  data: ThemeData.light().copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary: AppTheme.fontLightPurple,
                                      onPrimary: Colors.white,
                                      surface: Colors.white,
                                      onSurface: AppTheme.fontMediumPurple,
                                    ),
                                    datePickerTheme: DatePickerThemeData(
                                      headerBackgroundColor: AppTheme.fontLightPurple,
                                      headerForegroundColor: Colors.white,
                                      backgroundColor: Colors.white, 
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                                      ),
                                    )
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            
                            if (pickedDate != null && mounted) {
                              setState(() {
                                _selectedDate = DateTime(
                                  pickedDate.year,
                                  pickedDate.month,
                                  pickedDate.day,
                                  _selectedDate.hour,
                                  _selectedDate.minute,
                                );
                              });
                              _fetchAvailableTimeSlots();
                            }
                          },
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppTheme.backgroundDarkPurple,
                              borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: AppTheme.smallGap),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  DateFormat('dd/MM/yyyy').format(_selectedDate),
                                  style: AppTheme.secondaryTitleStyle.copyWith(
                                    color: AppTheme.fontDarkPurple,
                                    fontSize: AppTheme.fontSizeMedium,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SvgPicture.asset(
                                  'assets/CalendarIcon.svg',
                                  width: AppTheme.iconSizeMedium,
                                  height: AppTheme.iconSizeMedium,
                                  colorFilter: ColorFilter.mode(
                                    AppTheme.fontDarkPurple,
                                    BlendMode.srcIn
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: AppTheme.smallGap),
                    
                    // Time Field
                    _buildFormField(
                      label: 'Ora',
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundDarkPurple,
                          borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                        ),
                        padding: const EdgeInsets.only(left: AppTheme.smallGap, right: AppTheme.smallGap),
                        child: _isLoadingSlots
                          ? const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppTheme.fontDarkPurple, strokeWidth: 2.5)))
                          : DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _availableHours.contains(_selectedTime) 
                                        ? _selectedTime 
                                        : (_availableHours.isNotEmpty ? _availableHours.first : null),
                                dropdownColor: AppTheme.backgroundDarkPurple,
                                icon: SvgPicture.asset(
                                    'assets/DropdownIcon.svg',
                                    width: AppTheme.iconSizeMedium,
                                    height: AppTheme.iconSizeMedium,
                                    colorFilter: ColorFilter.mode(
                                        AppTheme.fontDarkPurple,
                                        BlendMode.srcIn
                                    ),
                                ),
                                isExpanded: true,
                                style: AppTheme.secondaryTitleStyle.copyWith(
                                  color: AppTheme.fontDarkPurple,
                                  fontSize: AppTheme.fontSizeMedium,
                                  fontWeight: FontWeight.w500,
                                ),
                                items: _availableHours.map((String hour) =>
                                  DropdownMenuItem<String>(
                                    value: hour,
                                    child: Text(hour),
                                  )
                                ).toList(),
                                onChanged: (String? newValue) {
                                  if (newValue != null && mounted) {
                                    setState(() {
                                      _selectedTime = newValue;
                                      _updateSelectedDateTime();
                                    });
                                  }
                                },
                              ),
                            ),
                      ),
                    ),
                    
                    const SizedBox(height: AppTheme.smallGap),
                    
                    // Appointment Type Field
                    _buildFormField(
                      label: 'Tip programare',
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundDarkPurple,
                          borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                        ),
                        padding: const EdgeInsets.only(left: AppTheme.smallGap, right: AppTheme.smallGap),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<ReservationType>(
                            value: _selectedType,
                            dropdownColor: AppTheme.backgroundDarkPurple,
                            icon: SvgPicture.asset(
                                'assets/DropdownIcon.svg',
                                width: AppTheme.iconSizeMedium,
                                height: AppTheme.iconSizeMedium,
                                colorFilter: ColorFilter.mode(
                                    AppTheme.fontDarkPurple,
                                    BlendMode.srcIn
                                ),
                            ),
                            isExpanded: true,
                            style: AppTheme.secondaryTitleStyle.copyWith(
                              color: AppTheme.fontDarkPurple,
                              fontSize: AppTheme.fontSizeMedium,
                              fontWeight: FontWeight.w500,
                            ),
                            items: [
                              DropdownMenuItem(
                                value: ReservationType.meeting,
                                child: Text('Intalnire'),
                              ),
                              DropdownMenuItem(
                                value: ReservationType.bureauDelete,
                                child: Text('Stergere birou credit'),
                              ),
                            ],
                            onChanged: (ReservationType? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedType = newValue;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppTheme.smallGap),
              
              // Button Section
              SizedBox(
                width: 304,
                height: 48,
                child: Row(
                  children: [
                    // Delete Button
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundLightPurple,
                        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                              widget.onDelete(widget.docId);
                            },
                            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                            child: Center(
                              child: SvgPicture.asset(
                                'assets/DeleteIcon.svg',
                                width: AppTheme.iconSizeMedium,
                                height: AppTheme.iconSizeMedium,
                                colorFilter: ColorFilter.mode(
                                  AppTheme.fontMediumPurple,
                                  BlendMode.srcIn
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTheme.smallGap),
                    // Save Button
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundLightPurple,
                          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: InkWell(
                              onTap: _isLoadingSlots
                                ? null
                                : () {
                                    final String clientName = widget.clientNameController.text.trim();
                                    final String phoneNumber = _phoneController.text.trim();
                                    
                                    if (clientName.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Introduceți numele clientului.'),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                      return;
                                    }
                                    
                                    Navigator.of(context).pop();
                                    widget.onUpdate(
                                      widget.docId, 
                                      clientName, 
                                      phoneNumber,
                                      _selectedDate,
                                      _selectedType
                                    );
                                  },
                              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                              child: Center(
                                child: Text(
                                  'Salveaza',
                                  style: AppTheme.secondaryTitleStyle.copyWith(
                                    color: AppTheme.fontMediumPurple,
                                    fontSize: AppTheme.fontSizeMedium,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
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
    );
  }

  Widget _buildFormField({required String label, String? optionalText, required Widget child}) {
    return SizedBox(
      height: 72,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.smallGap),
            height: 24,
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: AppTheme.primaryTitleStyle.copyWith(
                    color: AppTheme.fontMediumPurple,
                    fontSize: AppTheme.fontSizeMedium,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (optionalText != null)
                  Text(
                    optionalText,
                    style: AppTheme.smallTextStyle.copyWith(
                      color: AppTheme.fontMediumPurple,
                      fontWeight: FontWeight.w500,
                      fontSize: AppTheme.fontSizeSmall,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(
            height: 48,
            child: child
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({required String hintText}) {
    return InputDecoration(
      border: InputBorder.none,
      hintText: hintText,
      hintStyle: AppTheme.secondaryTitleStyle.copyWith(
        color: AppTheme.fontDarkPurple.withOpacity(0.7),
        fontSize: AppTheme.fontSizeMedium,
        fontWeight: FontWeight.w500,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppTheme.smallGap,
        vertical: 14,
      ),
    );
  }
} 