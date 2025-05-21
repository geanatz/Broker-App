import 'package:flutter/material.dart';
import 'package:broker_app/old/models/form_data.dart'; // Import data model
import 'package:broker_app/frontend/common/appTheme.dart';
import 'package:broker_app/old/widgets/common/dropdown_widget.dart';
import 'package:broker_app/old/widgets/common/input_field_widget.dart';

/// Enum pentru diferitele tipuri de venituri
enum IncomeType { salariu, pensie, indemnizatie }

/// Extinde String pentru a obtine titluri pentru dropdown
extension IncomeTypeExtension on IncomeType {
  String get displayTitle {
    switch (this) {
      case IncomeType.salariu:
        return 'Salariu';
      case IncomeType.pensie:
        return 'Pensie';
      case IncomeType.indemnizatie:
        return 'Indemnizatie';
    }
  }
}

/// Widget pentru un formular de venit
class IncomeFormWidget extends StatefulWidget {
  final IncomeFormData formData;
  final Function(IncomeFormData) onChanged;
  final String? contactId;

  const IncomeFormWidget({
    Key? key,
    required this.formData,
    required this.onChanged,
    this.contactId,
  }) : super(key: key);

  @override
  State<IncomeFormWidget> createState() => _IncomeFormWidgetState();
}

class _IncomeFormWidgetState extends State<IncomeFormWidget> {
  // Controllers initialized in initState
  late TextEditingController _incomeController;
  late TextEditingController _vechimeController;

  // Local state derived from formData
  String? _selectedBank;
  IncomeType? _selectedIncomeType;

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

  // Lista tipuri de venituri pentru dropdown
  final List<String> incomeTypes =
      IncomeType.values.map((type) => type.displayTitle).toList();

  @override
  void initState() {
    super.initState();
    // Initialize local state and controllers from formData
    _selectedBank = widget.formData.selectedBank;
    _selectedIncomeType = widget.formData.selectedIncomeType;

    _incomeController = TextEditingController(text: widget.formData.income);
    _vechimeController = TextEditingController(text: widget.formData.vechime);

    // Add listeners to controllers to update formData
    _incomeController.addListener(_handleFieldChange);
    _vechimeController.addListener(_handleFieldChange);
  }

  @override
  void didUpdateWidget(IncomeFormWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update local state if formData changes externally
    if (widget.formData.id != oldWidget.formData.id) {
      _updateLocalStateFromFormData();
    }
  }

  void _updateLocalStateFromFormData() {
    _selectedBank = widget.formData.selectedBank;
    _selectedIncomeType = widget.formData.selectedIncomeType;

    if (_incomeController.text != widget.formData.income) {
      _incomeController.text = widget.formData.income;
    }
    if (_vechimeController.text != widget.formData.vechime) {
      _vechimeController.text = widget.formData.vechime;
    }
  }

  @override
  void dispose() {
    // Remove listeners and dispose controllers
    _incomeController.removeListener(_handleFieldChange);
    _vechimeController.removeListener(_handleFieldChange);

    _incomeController.dispose();
    _vechimeController.dispose();
    super.dispose();
  }

  // Update the central formData object whenever a field changes
  void _handleFieldChange() {
    widget.formData.income = _incomeController.text;
    widget.formData.vechime = _vechimeController.text;
    widget.formData.selectedBank = _selectedBank;
    widget.formData.selectedIncomeType = _selectedIncomeType;

    // Update isEmpty based on whether bank and type are selected
    final bool wasEmpty = widget.formData.isEmpty;
    widget.formData.isEmpty = !widget.formData.isFilled();

    // Debug
    debugPrint(
      "Income form updated: wasEmpty=$wasEmpty, isEmpty=${widget.formData.isEmpty}, bank=${widget.formData.selectedBank}, type=${widget.formData.selectedIncomeType}",
    );

    // Notify parent widget
    widget.onChanged(widget.formData);
  }


  @override
  Widget build(BuildContext context) {
    // Styling from design (Form)
    return Container(
      padding: const EdgeInsets.all(8), // Changed from 16 to 8
      decoration: BoxDecoration(
        color: AppTheme.containerColor1, // Background from design
        borderRadius: BorderRadius.circular(24), // Radius from design
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFirstRow(),
          // Only show the second row if the form is not empty
          if (!widget.formData.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16), // Gap from design
              child: _buildSecondRow(),
            ),
        ],
      ),
    );
  }

  // Primul rand cu banca si tipul de venit
  Widget _buildFirstRow() {
    // Row styling from design - Use Expanded for flexible width
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
                _handleFieldChange();
              },
              backgroundColor: AppTheme.containerColor2, // Color from design
              textColor: AppTheme.elementColor3, // Color from design
            ),
          ),
        ),
        const SizedBox(width: 8), // Gap from design
        Expanded(
          child: _buildFieldWithLabel(
            label: 'Tip venit',
            field: DropdownWidget(
              items: incomeTypes,
              value: _selectedIncomeType?.displayTitle,
              hintText: 'Selecteaza venit',
              onChanged: (value) {
                setState(() {
                  _selectedIncomeType = IncomeType.values.firstWhere(
                    (type) => type.displayTitle == value,
                    orElse: () => IncomeType.salariu, // Default or handle null
                  );
                });
                _handleFieldChange();
              },
              backgroundColor: AppTheme.containerColor2, // Color from design
              textColor: AppTheme.elementColor3, // Color from design
            ),
          ),
        ),
      ],
    );
  }

  // Al doilea rand cu campuri specifice tipului de venit
  Widget _buildSecondRow() {
    // Row styling from design - Use Expanded instead of fixed width calculation
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildFieldWithLabel(
            label: 'Suma',
            field: InputFieldWidget(
              controller: _incomeController,
              hintText: '0',
              keyboardType: TextInputType.number,
              backgroundColor: AppTheme.containerColor2,
              textColor: AppTheme.elementColor3,
            ),
          ),
        ),
        const SizedBox(width: 8), // Gap from design
        Expanded(
          child: _buildFieldWithLabel(
            label: 'Vechime',
            field: InputFieldWidget(
              controller: _vechimeController,
              hintText: '0 ani',
              backgroundColor: AppTheme.containerColor2,
              textColor: AppTheme.elementColor3,
            ),
          ),
        ),
      ],
    );
  }

  // Helper pentru layout consistent camp+eticheta
  Widget _buildFieldWithLabel({
    required String label,
    required Widget field,
    String? altText,
  }) {
    return Column(
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
                    color: AppTheme.elementColor1,
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
}
