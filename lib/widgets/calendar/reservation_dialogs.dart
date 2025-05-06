import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import 'dart:ui';

/// Dialog pentru crearea unei noi rezervari
class CreateReservationDialog extends StatelessWidget {
  /// Controller pentru numele clientului
  final TextEditingController clientNameController;
  
  /// Functie callback pentru salvarea rezervarii
  final VoidCallback onSave;
  
  /// Data si ora selectata
  final DateTime selectedDateTime;

  const CreateReservationDialog({
    Key? key,
    required this.clientNameController,
    required this.onSave,
    required this.selectedDateTime,
  }) : super(key: key);

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
          height: 192,
          padding: const EdgeInsets.all(AppTheme.smallGap),
          decoration: BoxDecoration(
            color: const Color(0xDFDFDFDF),
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
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Creeaza programare',
                    style: AppTheme.primaryTitleStyle.copyWith(
                      color: AppTheme.fontLightPurple,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: AppTheme.smallGap),
              
              // Form Container
              Container(
                width: 304,
                height: 88,
                padding: const EdgeInsets.all(AppTheme.smallGap),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundLightPurple,
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Label
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppTheme.smallGap),
                      height: 24,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Nume client',
                        style: AppTheme.primaryTitleStyle.copyWith(
                          color: AppTheme.fontMediumPurple,
                        ),
                      ),
                    ),
                    
                    // Input field
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundDarkPurple,
                        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                      ),
                      child: TextField(
                        controller: clientNameController,
                        autofocus: true,
                        style: AppTheme.secondaryTitleStyle.copyWith(
                          color: AppTheme.fontDarkPurple,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Introdu numele clientului',
                          hintStyle: AppTheme.secondaryTitleStyle.copyWith(
                            color: AppTheme.fontDarkPurple.withOpacity(0.7),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppTheme.smallGap),
              
              // Button
              Container(
                width: 304,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.backgroundDarkPurple,
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: InkWell(
                      onTap: () {
                        final clientName = clientNameController.text.trim();
                        if (clientName.isNotEmpty) {
                          onSave();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Introdu numele clientului."),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                      child: Center(
                        child: Text(
                          'Salveaza',
                          style: AppTheme.secondaryTitleStyle.copyWith(
                            color: AppTheme.fontDarkPurple,
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
      ),
    );
  }
}

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
  final Function(String, String, DateTime) onUpdate;
  
  /// Functie pentru stergerea rezervarii
  final Function(String) onDelete;
  
  /// Functie pentru verificarea disponibilitatii orei selectate
  final Future<List<String>> Function(DateTime, String) fetchAvailableTimeSlots;
  
  /// Tipul de calendar (meeting sau bureauDelete)
  final dynamic calendarType;

  const EditReservationDialog({
    Key? key,
    required this.reservationData,
    required this.docId,
    required this.clientNameController,
    required this.initialDateTime,
    required this.onUpdate,
    required this.onDelete,
    required this.fetchAvailableTimeSlots,
    required this.calendarType,
  }) : super(key: key);

  @override
  State<EditReservationDialog> createState() => _EditReservationDialogState();
}

class _EditReservationDialogState extends State<EditReservationDialog> {
  late DateTime _selectedDate;
  late String _selectedTime;
  List<String> _availableHours = [];
  bool _isLoadingSlots = true;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDateTime;
    _selectedTime = DateFormat('HH:mm').format(widget.initialDateTime);
    
    // Fetch available time slots when dialog is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAvailableTimeSlots();
    });
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
          width: 352,
          height: 352,
          padding: const EdgeInsets.all(AppTheme.smallGap),
          decoration: BoxDecoration(
            color: const Color(0xDFDFDFDF),
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header
              Container(
                width: 336,
                height: 24,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.centerLeft,
                child: Text(
                  'Modifica programare',
                  style: AppTheme.primaryTitleStyle.copyWith(
                    color: AppTheme.fontLightPurple,
                  ),
                ),
              ),
              
              const SizedBox(height: AppTheme.smallGap),
              
              // Form Container
              Container(
                width: 336,
                height: 248,
                padding: const EdgeInsets.all(AppTheme.smallGap),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundLightPurple,
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Client Name Field
                    SizedBox(
                      width: 320,
                      height: 72,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppTheme.smallGap),
                            height: 24,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Nume client',
                              style: AppTheme.primaryTitleStyle.copyWith(
                                color: AppTheme.fontMediumPurple,
                              ),
                            ),
                          ),
                          Container(
                            height: 48,
                            width: 320,
                            decoration: BoxDecoration(
                              color: AppTheme.backgroundDarkPurple,
                              borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                            ),
                            child: TextField(
                              controller: widget.clientNameController,
                              textAlignVertical: TextAlignVertical.center,
                              style: AppTheme.secondaryTitleStyle.copyWith(
                                color: AppTheme.fontDarkPurple,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Introdu numele clientului',
                                hintStyle: AppTheme.secondaryTitleStyle.copyWith(
                                  color: AppTheme.fontDarkPurple.withOpacity(0.7),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: AppTheme.smallGap),
                    
                    // Date Field
                    SizedBox(
                      width: 320,
                      height: 72,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppTheme.smallGap),
                            height: 24,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Data',
                              style: AppTheme.primaryTitleStyle.copyWith(
                                color: AppTheme.fontMediumPurple,
                              ),
                            ),
                          ),
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () async {
                                final DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: _selectedDate,
                                  firstDate: DateTime.now().subtract(const Duration(days: 365)), // Allow past dates?
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
                                            borderRadius: BorderRadius.circular(16),
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
                                  // Trigger fetch for new date
                                  _fetchAvailableTimeSlots();
                                }
                              },
                              child: Container(
                                height: 48,
                                width: 320,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: AppTheme.backgroundDarkPurple,
                                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                                ),
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        DateFormat('dd/MM/yyyy').format(_selectedDate),
                                        style: AppTheme.secondaryTitleStyle.copyWith(
                                          color: AppTheme.fontDarkPurple,
                                        ),
                                      ),
                                    ),
                                    SvgPicture.asset(
                                      'assets/CalendarIcon.svg',
                                      width: 24,
                                      height: 24,
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
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: AppTheme.smallGap),
                    
                    // Time Field
                    SizedBox(
                      width: 320,
                      height: 72,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppTheme.smallGap),
                            height: 24,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Ora',
                              style: AppTheme.primaryTitleStyle.copyWith(
                                color: AppTheme.fontMediumPurple,
                              ),
                            ),
                          ),
                          Container(
                            height: 48,
                            width: 320,
                            decoration: BoxDecoration(
                              color: AppTheme.backgroundDarkPurple,
                              borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                            ),
                            child: _isLoadingSlots
                              ? Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: AppTheme.fontDarkPurple,
                                      strokeWidth: 2.5,
                                    ),
                                  ),
                                )
                              : DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _availableHours.contains(_selectedTime)
                                      ? _selectedTime
                                      : (_availableHours.isNotEmpty ? _availableHours.first : null),
                                    dropdownColor: AppTheme.backgroundDarkPurple,
                                    icon: Padding(
                                      padding: const EdgeInsets.only(right: 16.0),
                                      child: SvgPicture.asset(
                                        'assets/DropdownIcon.svg',
                                        width: 24,
                                        height: 24,
                                        colorFilter: ColorFilter.mode(
                                          AppTheme.fontDarkPurple,
                                          BlendMode.srcIn
                                        ),
                                      ),
                                    ),
                                    isExpanded: true,
                                    padding: const EdgeInsets.only(left: 16), // Adjust left padding
                                    style: AppTheme.secondaryTitleStyle.copyWith(
                                      color: AppTheme.fontDarkPurple,
                                    ),
                                    items: _availableHours.map((String hour) =>
                                      DropdownMenuItem<String>(
                                        value: hour,
                                        child: Text(hour),
                                      )
                                    ).toList(),
                                    onChanged: _isLoadingSlots
                                      ? null
                                      : (String? newValue) {
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
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppTheme.smallGap),
              
              // Button Section
              SizedBox(
                width: 336,
                height: 48,
                child: Row(
                  children: [
                    // Delete Button
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundDarkPurple,
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
                                width: 24,
                                height: 24,
                                colorFilter: ColorFilter.mode(
                                  AppTheme.fontDarkPurple,
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
                          color: AppTheme.backgroundDarkPurple,
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
                                    widget.onUpdate(widget.docId, clientName, _selectedDate);
                                  },
                              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                              child: Center(
                                child: Text(
                                  'Salveaza programare',
                                  style: AppTheme.secondaryTitleStyle.copyWith(
                                    color: AppTheme.fontDarkPurple,
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
} 