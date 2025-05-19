import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui';
import 'package:broker_app/frontend/common/appTheme.dart';
import 'package:broker_app/old/services/reservation_service.dart';

/// Dialog pentru crearea unei noi rezervari
class CreateReservationDialog extends StatefulWidget {
  /// Controller pentru numele clientului
  final TextEditingController clientNameController;
  
  /// Functie callback pentru salvarea rezervarii
  final Function(String, String, ReservationType) onSave;
  
  /// Data si ora selectata
  final DateTime selectedDateTime;

  const CreateReservationDialog({
    Key? key,
    required this.clientNameController,
    required this.onSave,
    required this.selectedDateTime,
  }) : super(key: key);

  @override
  State<CreateReservationDialog> createState() => _CreateReservationDialogState();
}

class _CreateReservationDialogState extends State<CreateReservationDialog> {
  final TextEditingController _phoneController = TextEditingController();
  ReservationType _selectedType = ReservationType.meeting;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
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
          height: 352,
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
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.smallGap),
                alignment: Alignment.centerLeft,
                child: Text(
                  'Creeaza programare',
                  style: AppTheme.primaryTitleStyle.copyWith(
                    color: AppTheme.fontLightPurple,
                    fontSize: AppTheme.fontSizeLarge,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              
              const SizedBox(height: AppTheme.smallGap),
              
              // Form Container
              Container(
                width: 304,
                height: 248,
                padding: const EdgeInsets.all(AppTheme.smallGap),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundLightPurple,
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Client Field
                    SizedBox(
                      height: 72,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppTheme.smallGap),
                            height: 24,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Client',
                              style: AppTheme.primaryTitleStyle.copyWith(
                                color: AppTheme.fontMediumPurple,
                              ),
                            ),
                          ),
                          Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppTheme.backgroundDarkPurple,
                              borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                            ),
                            child: TextField(
                              controller: widget.clientNameController,
                              autofocus: true,
                              style: AppTheme.secondaryTitleStyle.copyWith(
                                color: AppTheme.fontDarkPurple,
                                fontSize: AppTheme.fontSizeMedium,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Introdu numele clientului',
                                hintStyle: AppTheme.secondaryTitleStyle.copyWith(
                                  color: AppTheme.fontDarkPurple.withOpacity(0.7),
                                  fontSize: AppTheme.fontSizeMedium,
                                  fontWeight: FontWeight.w500,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: AppTheme.smallGap,
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: AppTheme.smallGap),
                    
                    // Phone Number Field
                    SizedBox(
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
                                  'Numar de telefon',
                                  style: AppTheme.primaryTitleStyle.copyWith(
                                    color: AppTheme.fontMediumPurple,
                                  ),
                                ),
                                Text(
                                  '(optional)',
                                  style: AppTheme.smallTextStyle.copyWith(
                                    color: AppTheme.fontMediumPurple,
                                    fontWeight: FontWeight.w500,
                                    fontSize: AppTheme.fontSizeSmall,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppTheme.backgroundDarkPurple,
                              borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                            ),
                            child: TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              style: AppTheme.secondaryTitleStyle.copyWith(
                                color: AppTheme.fontDarkPurple,
                                fontSize: AppTheme.fontSizeMedium,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Introdu numarul de telefon',
                                hintStyle: AppTheme.secondaryTitleStyle.copyWith(
                                  color: AppTheme.fontDarkPurple.withOpacity(0.7),
                                  fontSize: AppTheme.fontSizeMedium,
                                  fontWeight: FontWeight.w500,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: AppTheme.smallGap,
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: AppTheme.smallGap),
                    
                    // Appointment Type Field
                    SizedBox(
                      height: 72,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppTheme.smallGap),
                            height: 24,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Tip programare',
                              style: AppTheme.primaryTitleStyle.copyWith(
                                color: AppTheme.fontMediumPurple,
                              ),
                            ),
                          ),
                          Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppTheme.backgroundDarkPurple,
                              borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<ReservationType>(
                                value: _selectedType,
                                dropdownColor: AppTheme.backgroundDarkPurple,
                                icon: Padding(
                                  padding: const EdgeInsets.only(right: AppTheme.smallGap),
                                  child: SvgPicture.asset(
                                    'assets/expandIcon.svg',
                                    width: 24,
                                    height: 24,
                                    colorFilter: ColorFilter.mode(
                                      AppTheme.fontDarkPurple,
                                      BlendMode.srcIn
                                    ),
                                  ),
                                ),
                                isExpanded: true,
                                padding: const EdgeInsets.only(left: AppTheme.smallGap),
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
                        ],
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
                  color: AppTheme.backgroundLightPurple,
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: InkWell(
                      onTap: () {
                        final clientName = widget.clientNameController.text.trim();
                        final phoneNumber = _phoneController.text.trim();
                        
                        if (clientName.isNotEmpty) {
                          widget.onSave(clientName, phoneNumber, _selectedType);
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
            ],
          ),
        ),
      ),
    );
  }
} 