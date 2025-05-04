import 'package:flutter/material.dart';
import '../../models/form_data.dart'; // Import data model
import '../../theme/app_theme.dart';
import '../common/dropdown_widget.dart';
import '../common/input_field_widget.dart';

/// Enum pentru diferitele tipuri de venituri
enum IncomeType {
  salariu,
  pensie,
  chirie,
  dividende,
  altele
}

/// Extinde String pentru a obtine titluri pentru dropdown
extension IncomeTypeExtension on IncomeType {
  String get displayTitle {
    switch (this) {
      case IncomeType.salariu:
        return 'Salariu';
      case IncomeType.pensie:
        return 'Pensie';
      case IncomeType.chirie:
        return 'Chirie';
      case IncomeType.dividende:
        return 'Dividende';
      case IncomeType.altele:
        return 'Altele';
    }
  }
}

/// Widget pentru un formular de venit
class IncomeFormWidget extends StatefulWidget {
  final IncomeFormData formData;
  final Function(IncomeFormData) onChanged;

  const IncomeFormWidget({
    Key? key,
    required this.formData,
    required this.onChanged,
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
  final List<String> incomeTypes = IncomeType.values.map((type) => type.displayTitle).toList();

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
    widget.formData.isEmpty = !(_selectedBank != null && _selectedIncomeType != null);

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
     // Row styling from design
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
              backgroundColor: const Color(0xFFC6ACD3), // Color from design
              textColor: const Color(0xFF7C568F), // Color from design
            ),
          ),
        ),
        const SizedBox(width: 16), // Gap from design
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
              backgroundColor: const Color(0xFFC6ACD3), // Color from design
              textColor: const Color(0xFF7C568F), // Color from design
            ),
          ),
        ),
      ],
    );
  }

  // Al doilea rand cu campuri specifice tipului de venit
  Widget _buildSecondRow() {
     // Row styling from design
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildFieldWithLabel(
            label: 'Suma', // Changed from Sold to Suma
            field: InputFieldWidget(
              controller: _incomeController,
              hintText: '0',
              keyboardType: TextInputType.number,
              backgroundColor: const Color(0xFFC6ACD3), // Color from design
              textColor: const Color(0xFF7C568F), // Color from design
            ),
          ),
        ),
        const SizedBox(width: 16), // Gap from design
        Expanded(
          child: _buildFieldWithLabel(
            label: 'Vechime',
            field: InputFieldWidget(
              controller: _vechimeController,
              hintText: '0 ani',
               backgroundColor: const Color(0xFFC6ACD3), // Color from design
              textColor: const Color(0xFF7C568F), // Color from design
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
          height: 48, // Explicit height for field container
          child: field
        ),
      ],
    );
  }
} 