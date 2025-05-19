import 'package:flutter/material.dart';
import 'package:broker_app/old/models/form_data.dart'; // Import data model
import 'package:broker_app/frontend/common/appTheme.dart';
import 'package:broker_app/old/widgets/common/dropdown_widget.dart';
import 'package:broker_app/old/widgets/common/input_field_widget.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Enum pentru diferitele tipuri de credite
enum CreditType { cardCumparaturi, nevoi, overdraft, ipotecar, primaCasa }

/// Extinde String pentru a obtine titluri pentru dropdown
extension CreditTypeExtension on CreditType {
  String get displayTitle {
    switch (this) {
      case CreditType.cardCumparaturi:
        return 'Card de cumparaturi';
      case CreditType.nevoi:
        return 'Nevoi personale';
      case CreditType.overdraft:
        return 'Overdraft';
      case CreditType.ipotecar:
        return 'Ipotecar';
      case CreditType.primaCasa:
        return 'Prima casa';
    }
  }
}

/// Widget pentru un formular de credit
class CreditFormWidget extends StatefulWidget {
  final CreditFormData formData;
  final Function(CreditFormData) onChanged;
  final String? contactId;

  const CreditFormWidget({
    Key? key,
    required this.formData,
    required this.onChanged,
    this.contactId,
  }) : super(key: key);

  @override
  State<CreditFormWidget> createState() => _CreditFormWidgetState();
}

class _CreditFormWidgetState extends State<CreditFormWidget> {
  // Controllers initialized in initState
  late TextEditingController _soldController;
  late TextEditingController _consumatController;
  late TextEditingController _rataController;
  late TextEditingController _perioadaController;

  // Local state derived from formData
  String? _selectedBank;
  CreditType? _selectedCreditType;
  String? _selectedRateType;

  // Lista de banci pentru dropdown
  final List<String> banks = [
    'Alpha Bank',
    'Raiffeisen Bank',
    'BRD',
    'BCR',
    'ING Bank',
    'Banca Transilvania',
    'CEC Bank',
    'OTP Bank',
    // Adauga alte banci aici...
  ];

  // Lista tipuri de credite pentru dropdown
  final List<String> creditTypes =
      CreditType.values.map((type) => type.displayTitle).toList();

  // Lista tipuri de rate pentru dropdown
  final List<String> rateTypes = [
    'Fixa',
    'Variabila',
    'Euribor',
    'IRCC',
    'ROBOR',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize local state and controllers from formData
    _selectedBank = widget.formData.selectedBank;
    _selectedCreditType = widget.formData.selectedCreditType;
    _selectedRateType = widget.formData.selectedRateType;

    _soldController = TextEditingController(text: widget.formData.sold);
    _consumatController = TextEditingController(text: widget.formData.consumat);
    _rataController = TextEditingController(text: widget.formData.rata);
    _perioadaController = TextEditingController(text: widget.formData.perioada);

    // Add listeners to controllers to update formData
    _soldController.addListener(_handleFieldChange);
    _consumatController.addListener(_handleFieldChange);
    _rataController.addListener(_handleFieldChange);
    _perioadaController.addListener(_handleFieldChange);
  }

  @override
  void didUpdateWidget(CreditFormWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update local state if formData changes externally (e.g., reset)
    if (widget.formData.id != oldWidget.formData.id) {
      _updateLocalStateFromFormData();
    }
  }

  void _updateLocalStateFromFormData() {
    _selectedBank = widget.formData.selectedBank;
    _selectedCreditType = widget.formData.selectedCreditType;
    _selectedRateType = widget.formData.selectedRateType;

    // Avoid cursor jumping by only updating if text differs
    if (_soldController.text != widget.formData.sold) {
      _soldController.text = widget.formData.sold;
    }
    if (_consumatController.text != widget.formData.consumat) {
      _consumatController.text = widget.formData.consumat;
    }
    if (_rataController.text != widget.formData.rata) {
      _rataController.text = widget.formData.rata;
    }
    if (_perioadaController.text != widget.formData.perioada) {
      _perioadaController.text = widget.formData.perioada;
    }
  }

  @override
  void dispose() {
    // Remove listeners and dispose controllers
    _soldController.removeListener(_handleFieldChange);
    _consumatController.removeListener(_handleFieldChange);
    _rataController.removeListener(_handleFieldChange);
    _perioadaController.removeListener(_handleFieldChange);

    _soldController.dispose();
    _consumatController.dispose();
    _rataController.dispose();
    _perioadaController.dispose();
    super.dispose();
  }

  // Update the central formData object whenever a field changes
  void _handleFieldChange() {
    widget.formData.sold = _soldController.text;
    widget.formData.consumat = _consumatController.text;
    widget.formData.rata = _rataController.text;
    widget.formData.perioada = _perioadaController.text;
    widget.formData.selectedBank = _selectedBank;
    widget.formData.selectedCreditType = _selectedCreditType;
    widget.formData.selectedRateType = _selectedRateType;

    // Update isEmpty based on whether bank and type are selected
    final bool wasEmpty = widget.formData.isEmpty;
    widget.formData.isEmpty = !widget.formData.isFilled();

    // Debug
    print(
      "Credit form updated: wasEmpty=$wasEmpty, isEmpty=${widget.formData.isEmpty}, bank=${widget.formData.selectedBank}, type=${widget.formData.selectedCreditType}",
    );

    // Notify parent widget
    widget.onChanged(widget.formData);
  }

  @override
  Widget build(BuildContext context) {
    // Styling from design (Form)
    return Container(
      // width: 624, // REMOVED Fixed width from Figma - Let parent decide width
      padding: const EdgeInsets.all(8), // Changed from 16 to 8
      decoration: BoxDecoration(
        color: AppTheme.containerColor1, // Background from design
        borderRadius: BorderRadius.circular(24), // Radius from design
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // SizedBox( // REMOVED fixed width SizedBox
          //   width: 592, // Inner width from Figma spec
          //   child: _buildFirstRow(),
          // ),
          _buildFirstRow(), // Use Row directly
          // Only show the second row if the form is not empty (bank and type selected)
          if (!widget.formData.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16), // Gap from design
              // child: SizedBox( // REMOVED fixed width SizedBox
              //   width: 592, // Inner width from Figma spec
              //   child: _buildSecondRow(),
              // ),
              child: _buildSecondRow(), // Use Row directly
            ),
        ],
      ),
    );
  }

  // Primul rand cu banca si tipul de credit
  Widget _buildFirstRow() {
    // Row styling from design - Use Expanded for flexible width
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start, // Align items to top
      children: [
        // Expanded( // Replace SizedBox with Expanded - Already Expanded, just remove explicit width
        //   child: _buildFieldWithLabel(
        Expanded(
          child: _buildFieldWithLabel(
            label: 'Banca',
            field: DropdownWidget(
              items: banks,
              value: _selectedBank,
              hintText: 'Selecteaza banca',
              onChanged: (value) {
                setState(() {
                  _selectedBank = value;
                });
                _handleFieldChange(); // Update formData
              },
              backgroundColor: AppTheme.containerColor2, // Color from design
              textColor: AppTheme.elementColor2, // Color from design
            ),
          ),
        ),
        const SizedBox(width: 8), // Gap from design
        // Expanded( // Replace SizedBox with Expanded - Already Expanded, just remove explicit width
        //   child: _buildFieldWithLabel(
        Expanded(
          child: _buildFieldWithLabel(
            label: 'Tip credit',
            field: DropdownWidget(
              items: creditTypes,
              value: _selectedCreditType?.displayTitle,
              hintText: 'Selecteaza credit',
              onChanged: (value) {
                setState(() {
                  _selectedCreditType = CreditType.values.firstWhere(
                    (type) => type.displayTitle == value,
                    // Provide a default or handle null case appropriately
                    orElse: () => CreditType.cardCumparaturi,
                  );
                });
                _handleFieldChange(); // Update formData
              },
              backgroundColor: AppTheme.containerColor2, // Color from design
              textColor: AppTheme.elementColor2, // Color from design
            ),
          ),
        ),
      ],
    );
  }

  // Al doilea rand cu campuri specifice tipului de credit
  Widget _buildSecondRow() {
    // Get the specific fields for this credit type
    final List<Widget> specificFields = _getSpecificFieldsForCreditType();

    // Create a Row with Expanded children and gaps
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List<Widget>.generate(specificFields.length * 2 - 1, (index) {
        if (index.isEven) {
          // It's a field - wrap in Expanded
          return Expanded(child: specificFields[index ~/ 2]);
        } else {
          // It's a gap
          return const SizedBox(width: 16);
        }
      }),
      // children: specificFields.asMap().entries.map((entry) {
      //   int index = entry.key;
      //   Widget widget = entry.value;

      //   return Padding(
      //     padding: EdgeInsets.only(left: index == 0 ? 0 : 16), // 16px gap from design
      //     child: widget,
      //   );
      // }).toList(),
    );
  }

  // Helper to get fields based on credit type
  List<Widget> _getSpecificFieldsForCreditType() {
    switch (_selectedCreditType) {
      case CreditType.cardCumparaturi:
      case CreditType.overdraft:
        return [
          // SizedBox( // Remove SizedBox wrapper, Expanded is handled in _buildSecondRow
          //   width: 288, // From Figma (592px - 16px) / 2
          //   child:
          _buildFieldWithLabel(
            label: 'Sold',
            field: InputFieldWidget(
              controller: _soldController,
              hintText: '0',
              keyboardType: TextInputType.number,
              backgroundColor: AppTheme.containerColor2,
              textColor: AppTheme.elementColor2,
            ),
          ),
          // ),
          // SizedBox(
          //   width: 288, // From Figma (592px - 16px) / 2
          //   child:
          _buildFieldWithLabel(
            label: 'Consumat',
            field: InputFieldWidget(
              controller: _consumatController,
              hintText: '0',
              keyboardType: TextInputType.number,
              backgroundColor: AppTheme.containerColor2,
              textColor: AppTheme.elementColor2,
            ),
          ),
          // ),
        ];
      case CreditType.nevoi:
        // 3 fields
        // final fieldWidth = (592 - 32) / 3; // REMOVE calculation, use Expanded
        return [
          // SizedBox(
          //   width: fieldWidth,
          //   child:
          _buildFieldWithLabel(
            label: 'Sold',
            field: InputFieldWidget(
              controller: _soldController,
              hintText: '0',
              keyboardType: TextInputType.number,
              backgroundColor: AppTheme.containerColor2,
              textColor: AppTheme.elementColor2,
            ),
          ),
          // ),
          // SizedBox(
          //   width: fieldWidth,
          //   child:
          _buildFieldWithLabel(
            label: 'Rata',
            field: InputFieldWidget(
              controller: _rataController,
              hintText: '0',
              keyboardType: TextInputType.number,
              backgroundColor: AppTheme.containerColor2,
              textColor: AppTheme.elementColor2,
            ),
          ),
          // ),
          // SizedBox(
          //   width: fieldWidth,
          //   child:
          // _buildPerioadaField(width: fieldWidth), // Revert to standard field
          _buildFieldWithLabel(
            label: 'Perioada',
            field: InputFieldWidget(
              controller: _perioadaController,
              hintText: '0 ani',
              backgroundColor: AppTheme.containerColor2,
              textColor: AppTheme.elementColor2,
            ),
          ),
          // ),
        ];
      case CreditType.ipotecar:
      case CreditType.primaCasa:
        // 4 fields
        // final fieldWidth = (592 - (3 * 16)) / 4; // REMOVE calculation, use Expanded
        return [
          // SizedBox(
          //   width: fieldWidth, // Adjusted width to prevent overflow
          //   child:
          _buildFieldWithLabel(
            label: 'Sold',
            field: InputFieldWidget(
              controller: _soldController,
              hintText: '0',
              keyboardType: TextInputType.number,
              backgroundColor: AppTheme.containerColor2,
              textColor: AppTheme.elementColor2,
            ),
          ),
          // ),
          // SizedBox(
          //   width: fieldWidth, // Adjusted width to prevent overflow
          //   child:
          _buildFieldWithLabel(
            label: 'Rata',
            field: InputFieldWidget(
              controller: _rataController,
              hintText: '0',
              keyboardType: TextInputType.number,
              backgroundColor: AppTheme.containerColor2,
              textColor: AppTheme.elementColor2,
            ),
          ),
          // ),
          // SizedBox(
          //   width: fieldWidth, // Adjusted width to prevent overflow
          //   child:
          // _buildTipRataField(width: fieldWidth), // Revert to standard field
          _buildFieldWithLabel(
            label: 'Tip rata',
            field: DropdownWidget(
              items: rateTypes,
              value: _selectedRateType,
              hintText: 'Tip',
              onChanged: (value) {
                setState(() {
                  _selectedRateType = value;
                });
                _handleFieldChange();
              },
              backgroundColor: AppTheme.containerColor2,
              textColor: AppTheme.elementColor2,
            ),
          ),
          // ),
          // SizedBox(
          //   width: fieldWidth, // Adjusted width to prevent overflow
          //   child:
          _buildFieldWithLabel(
            label: 'Perioada',
            field: InputFieldWidget(
              controller: _perioadaController,
              hintText: '0 ani',
              backgroundColor: AppTheme.containerColor2,
              textColor: AppTheme.elementColor2,
            ),
          ),
          // ),
        ];
      default:
        return [];
    }
  }

  // Widget pentru etichetă și câmp
  Widget _buildFieldWithLabel({
    required String label,
    required Widget field,
    String? altText,
  }) {
    // Field styling from design
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: AppTheme.elementColor2,
                  fontSize: 17,
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (altText != null)
                Text(
                  altText,
                  style: TextStyle(
                    color: AppTheme.elementColor2,
                    fontSize: 15,
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(
          height: 4,
        ), // Changed from default 8 to 4 to match design
        field,
      ],
    );
  }

  // Custom override to precisely match the Figma design for Perioada field
  Widget _buildPerioadaField({double? width}) {
    return _buildFieldWithLabel(
      label: 'Perioada',
      field: Container(
        height: 48,
        width: width ?? 136, // Use provided width or default to 136
        decoration: BoxDecoration(
          color: AppTheme.containerColor1,
          borderRadius: BorderRadius.circular(16),
          // Removed box shadow as requested
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.centerLeft,
        child: TextField(
          controller: _perioadaController,
          style: AppTheme.primaryTitleStyle.copyWith(
            color: AppTheme.elementColor2,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: '0 ani',
            hintStyle: AppTheme.primaryTitleStyle.copyWith(
              color: AppTheme.elementColor2, // Full opacity
              fontWeight: FontWeight.w500,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }

  // Custom override to precisely match the Figma design for Tip rata field
  Widget _buildTipRataField({double? width}) {
    return _buildFieldWithLabel(
      label: 'Tip rata',
      field: Container(
        height: 48,
        width: width ?? 136, // Use provided width or default to 136
        decoration: BoxDecoration(
          color: AppTheme.containerColor2,
          borderRadius: BorderRadius.circular(16),
          // Removed box shadow as requested
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedRateType,
            icon: SvgPicture.asset(
              'assets/DropdownIcon.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                AppTheme.elementColor2,
                BlendMode.srcIn,
              ),
            ),
            isExpanded: true,
            dropdownColor: AppTheme.containerColor2,
            hint: Text(
              'Tip',
              style: AppTheme.primaryTitleStyle.copyWith(
                color: AppTheme.elementColor2, // Full opacity
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            style: AppTheme.primaryTitleStyle.copyWith(
              color: AppTheme.elementColor2,
              fontWeight: FontWeight.w500,
            ),
            items:
                rateTypes.map<DropdownMenuItem<String>>((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedRateType = value;
              });
              _handleFieldChange();
            },
          ),
        ),
      ),
    );
  }
}
