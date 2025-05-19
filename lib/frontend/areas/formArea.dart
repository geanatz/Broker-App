import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:broker_app/frontend/common/appTheme.dart';
import 'package:broker_app/old/sidebar/sidebar_service.dart';
import 'package:broker_app/old/models/contact_data.dart';
import 'package:broker_app/old/services/contact_form_service.dart';
import 'package:broker_app/old/widgets/form/forms_container_widget.dart.dart' show FormsContainerWidget, FormContainerType;
import 'package:broker_app/old/widgets/common/panel_container.dart';

/// Definirea temei de text pentru a asigura consistența fontului Outfit în întreaga aplicație
class TextStyles {
  static final TextStyle titleStyle = GoogleFonts.outfit(
    fontSize: 19,
    fontWeight: FontWeight.w600,
  );
  
  static final TextStyle subtitleStyle = GoogleFonts.outfit(
    fontSize: 17,
    fontWeight: FontWeight.w500,
  );

  static final TextStyle headerStyle = GoogleFonts.outfit(
    fontSize: 19,
    fontWeight: FontWeight.w600,  
  );
  
  static final TextStyle toggleStyle = GoogleFonts.outfit(
    fontSize: 17,
    fontWeight: FontWeight.w500,
  );
}

/// Area pentru formulare care va fi afișată în cadrul ecranului principal.
/// Această componentă înlocuiește vechiul FormScreen păstrând funcționalitatea
/// dar fiind adaptată la noua structură a aplicației.
class FormArea extends StatefulWidget {
  const FormArea({Key? key}) : super(key: key);

  @override
  State<FormArea> createState() => _FormAreaState();
}

class _FormAreaState extends State<FormArea> {
  // Controleaza daca se afiseaza formularul pentru client sau pentru codebitor
  bool _showingClientLoanForm = true;
  bool _showingClientIncomeForm = true;
  
  // Serviciul pentru gestionarea contactelor și formularelor
  final ContactFormService _contactService = ContactFormService();
  
  // Contactul selectat curent (pentru completarea formularelor)
  ContactData? _selectedContact;
  
  // Hover state for contacts
  String? _hoveredContactId;
  
  // Flag pentru a arăta dacă procesul de export este în desfășurare
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    // Initialize demo data using the service
    _contactService.initializeDemoData();
  }

  /// Export data to Excel
  Future<void> _exportToExcel() async {
    setState(() {
      _isExporting = true;
    });
    
    try {
      final success = await _contactService.exportToExcel();
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Date exportate cu succes!',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Eroare la exportarea datelor.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Eroare: $e',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildFormPanelContent();
  }

  /// Construieste continutul panoului de formulare
  Widget _buildFormPanelContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: _buildLoanWidget(),
        ),
        const SizedBox(width: AppTheme.largeGap),
        Expanded(
          flex: 1,
          child: _buildIncomeWidget(),
        ),
      ],
    );
  }

  /// Construieste widget-ul pentru credite
  Widget _buildLoanWidget() {
    // Container styling from design (LoanWidget)
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: AppTheme.widgetDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 24,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        'Credit',
                        style: TextStyles.titleStyle.copyWith(
                          color: AppTheme.elementColor1,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _showingClientLoanForm = !_showingClientLoanForm;
                        });
                      },
                      child: Text(
                        _showingClientLoanForm ? 'Vezi codebitor' : 'Vezi client',
                        style: TextStyles.toggleStyle.copyWith(
                          color: AppTheme.elementColor1,
                        ),
                      ),
                    ),
                  ],
                ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _buildLoansContainer(),
          ),
        ],
      ),
    );
  }

  /// Construieste containerul pentru lista de credite
  Widget _buildLoansContainer() {
    // Container for the scrollable list of forms
    return SingleChildScrollView(
      child: FormsContainerWidget(
        type: FormContainerType.credit,
        isClientForm: _showingClientLoanForm,
        contactId: _selectedContact?.id, // Pass the selected contact ID
      ),
    );
  }

  /// Construieste widget-ul pentru venituri
  Widget _buildIncomeWidget() {
    // Container styling from design (IncomeWidget)
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: AppTheme.widgetDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 24,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        'Venituri',
                        style: TextStyles.titleStyle.copyWith(
                          color: AppTheme.elementColor1,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _showingClientIncomeForm = !_showingClientIncomeForm;
                        });
                      },
                      child: Text(
                        _showingClientIncomeForm ? 'Vezi codebitor' : 'Vezi client',
                        style: TextStyles.toggleStyle.copyWith(
                          color: AppTheme.elementColor1,
                        ),
                      ),
                    ),
                  ],
                ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _buildIncomeContainer(),
          ),
        ],
      ),
    );
  }

  /// Construieste containerul pentru lista de venituri
  Widget _buildIncomeContainer() {
    // Container for the scrollable list of forms
    return SingleChildScrollView(
      child: FormsContainerWidget(
        type: FormContainerType.income,
        isClientForm: _showingClientIncomeForm,
        contactId: _selectedContact?.id, // Pass the selected contact ID
      ),
    );
  }
}

