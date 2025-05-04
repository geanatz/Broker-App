import 'package:flutter/material.dart';
import '../../models/form_data.dart'; // Import data model
import '../../theme/app_theme.dart';
import '../common/dropdown_widget.dart';
import '../common/input_field_widget.dart';

/// Enum pentru diferitele tipuri de credite
enum CreditType {
  cardCumparaturi,
  nevoi,
  overdraft,
  ipotecar,
  primaCasa
}

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

  const CreditFormWidget({
    Key? key,
    required this.formData,
    required this.onChanged,
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
  final List<String> creditTypes = CreditType.values.map((type) => type.displayTitle).toList();

  // Lista tipuri de rate pentru dropdown
  final List<String> rateTypes = ['Fixa', 'Variabila', 'Euribor', 'IRCC', 'ROBOR'];

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
    widget.formData.isEmpty = !(_selectedBank != null && _selectedCreditType != null);

    // Notify parent widget
    widget.onChanged(widget.formData);
  }


  @override
  Widget build(BuildContext context) {
    // Styling from design (Form)
    return Container(
      padding: const EdgeInsets.all(16), // Padding from design
      decoration: BoxDecoration(
        color: const Color(0xFFCFC4D4), // Background from design
        borderRadius: BorderRadius.circular(24), // Radius from design
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFirstRow(),
          // Only show the second row if the form is not empty (bank and type selected)
          if (!widget.formData.isEmpty)
             Padding(
                padding: const EdgeInsets.only(top: 16), // Gap from design
                child: _buildSecondRow(),
            ),
        ],
      ),
    );
  }

  // Primul rand cu banca si tipul de credit
  Widget _buildFirstRow() {
    // Row styling from design
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start, // Align items to top
      children: [
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
              backgroundColor: const Color(0xFFC6ACD3), // Color from design
              textColor: const Color(0xFF7C568F), // Color from design
            ),
          ),
        ),
        const SizedBox(width: 16), // Gap from design
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
              backgroundColor: const Color(0xFFC6ACD3), // Color from design
              textColor: const Color(0xFF7C568F), // Color from design
            ),
          ),
        ),
      ],
    );
  }

  // Al doilea rand cu campuri specifice tipului de credit
  Widget _buildSecondRow() {
     // Row styling from design
     final specificFields = _getSpecificFieldsForCreditType();
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(specificFields.length, (index) {
          return Expanded(
            flex: specificFields[index]['flex'] ?? 1, // Default flex: 1
            child: Padding(
              padding: EdgeInsets.only(left: index == 0 ? 0 : 16), // Add gap between fields
              child: specificFields[index]['widget'],
            ),
          );
        }),
      );
  }

  // Helper to get fields based on credit type
  List<Map<String, dynamic>> _getSpecificFieldsForCreditType() {
     switch (_selectedCreditType) {
      case CreditType.cardCumparaturi:
      case CreditType.overdraft:
        return [
          {
            'widget': _buildFieldWithLabel(
              label: 'Sold',
              field: InputFieldWidget(
                controller: _soldController,
                hintText: '0',
                keyboardType: TextInputType.number,
                backgroundColor: const Color(0xFFC6ACD3),
                textColor: const Color(0xFF7C568F),
              ),
            ),
            'flex': 1
          },
           {
            'widget': _buildFieldWithLabel(
              label: 'Consumat',
              field: InputFieldWidget(
                controller: _consumatController,
                hintText: '0',
                keyboardType: TextInputType.number,
                backgroundColor: const Color(0xFFC6ACD3),
                textColor: const Color(0xFF7C568F),
              ),
            ),
            'flex': 1
          },
        ];
      case CreditType.nevoi:
        return [
          {
            'widget': _buildFieldWithLabel(
              label: 'Sold',
              field: InputFieldWidget(
                controller: _soldController,
                hintText: '0',
                keyboardType: TextInputType.number,
                backgroundColor: const Color(0xFFC6ACD3),
                textColor: const Color(0xFF7C568F),
              ),
            ),
            'flex': 1
          },
          {
            'widget': _buildFieldWithLabel(
              label: 'Rata',
              field: InputFieldWidget(
                controller: _rataController,
                hintText: '0',
                keyboardType: TextInputType.number,
                backgroundColor: const Color(0xFFC6ACD3),
                textColor: const Color(0xFF7C568F),
              ),
            ),
            'flex': 1
          },
          {
            'widget': _buildFieldWithLabel(
              label: 'Perioada',
              field: InputFieldWidget(
                controller: _perioadaController,
                hintText: '0 ani',
                backgroundColor: const Color(0xFFC6ACD3),
                textColor: const Color(0xFF7C568F),
              ),
            ),
            'flex': 0 // Let it take natural width or adjust flex
          },
        ];
      case CreditType.ipotecar:
      case CreditType.primaCasa:
        return [
           {
            'widget': _buildFieldWithLabel(
              label: 'Sold',
              field: InputFieldWidget(
                controller: _soldController,
                hintText: '0',
                keyboardType: TextInputType.number,
                backgroundColor: const Color(0xFFC6ACD3),
                textColor: const Color(0xFF7C568F),
              ),
            ),
            'flex': 1 // Adjust flex based on design proportions
          },
           {
            'widget': _buildFieldWithLabel(
              label: 'Rata',
              field: InputFieldWidget(
                controller: _rataController,
                hintText: '0',
                keyboardType: TextInputType.number,
                backgroundColor: const Color(0xFFC6ACD3),
                textColor: const Color(0xFF7C568F),
              ),
            ),
            'flex': 1 // Adjust flex
          },
          {
            'widget': _buildFieldWithLabel(
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
                backgroundColor: const Color(0xFFC6ACD3),
                textColor: const Color(0xFF7C568F),
              ),
            ),
            'flex': 1 // Adjust flex
          },
          {
            'widget': _buildFieldWithLabel(
              label: 'Perioada',
              field: InputFieldWidget(
                controller: _perioadaController,
                hintText: '0 ani',
                backgroundColor: const Color(0xFFC6ACD3),
                textColor: const Color(0xFF7C568F),
              ),
            ),
            'flex': 0 // Adjust flex
          },
        ];
      default:
        return [];
    }
  }


  // Helper pentru layout consistent camp+eticheta
  Widget _buildFieldWithLabel({
    required String label,
    required Widget field,
  }) {
    // Field styling from design
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8.0), // Padding from design
          child: Text(
            label,
            style: const TextStyle( // Style from design
              fontFamily: 'Outfit',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF886699), // Color from design
            ),
          ),
        ),
        SizedBox(
          height: 48, // Explicit height for the field container
          child: field,
        ),
      ],
    );
  }
} 