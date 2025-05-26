import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:broker_app/frontend/common/appTheme.dart';
import 'package:broker_app/old/models/contact_data.dart';
import 'package:broker_app/old/services/contact_form_service.dart';
import 'package:broker_app/frontend/common/components/forms/form1.dart';
import 'package:broker_app/frontend/common/components/forms/form2.dart';
import 'package:broker_app/frontend/common/components/forms/form3.dart';
import 'package:broker_app/frontend/common/components/forms/formNew.dart';
import 'package:intl/intl.dart';

/// Definirea temei de text pentru a asigura consistenta fontului Outfit in intreaga aplicatie
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

/// Model pentru stocarea datelor de credit
class CreditFormModel {
  String bank;
  String creditType;
  String sold;
  String consumat;
  String rateType;
  String rata;
  String perioada;
  bool isNew; // Adaugam un flag pentru formularele noi

  CreditFormModel({
    this.bank = 'Selecteaza banca',
    this.creditType = 'Selecteaza tipul',
    this.sold = '',
    this.consumat = '',
    this.rateType = 'Selecteaza tipul',
    this.rata = '',
    this.perioada = '',
    this.isNew = true, // Implicit, un formular nou este marcat ca "nou"
  });
  
  // Verifica daca formularul are suficiente informatii pentru a nu mai fi considerat "nou"
  bool hasMinimumInfo() {
    return bank != 'Selecteaza banca' && creditType != 'Selecteaza tipul';
  }
}

/// Model pentru stocarea datelor de venit
class IncomeFormModel {
  String bank;
  String incomeType;
  String incomeAmount;
  String vechime;
  bool isNew; // Adaugam un flag pentru formularele noi

  IncomeFormModel({
    this.bank = 'Selecteaza banca',
    this.incomeType = 'Selecteaza tipul',
    this.incomeAmount = '',
    this.vechime = '',
    this.isNew = true, // Implicit, un formular nou este marcat ca "nou"
  });
  
  // Verifica daca formularul are suficiente informatii pentru a nu mai fi considerat "nou"
  bool hasMinimumInfo() {
    return bank != 'Selecteaza banca' && incomeType != 'Selecteaza tipul';
  }
}

/// Area pentru formulare care va fi afisata in cadrul ecranului principal.
/// Aceasta componenta inlocuieste vechiul FormScreen pastrand functionalitatea
/// dar fiind adaptata la noua structura a aplicatiei.
class FormArea extends StatefulWidget {
  const FormArea({Key? key}) : super(key: key);

  @override
  State<FormArea> createState() => _FormAreaState();
}

class _FormAreaState extends State<FormArea> {
  // Controleaza daca se afiseaza formularul pentru client sau pentru codebitor
  bool _showingClientLoanForm = true;
  bool _showingClientIncomeForm = true;
  
  // Serviciul pentru gestionarea contactelor si formularelor
  final ContactFormService _contactService = ContactFormService();
  
  // Contactul selectat curent (pentru completarea formularelor)
  ContactData? _selectedContact;
  
  // Hover state for contacts
  String? _hoveredContactId;
  
  // Flag pentru a arata daca procesul de export este in desfasurare
  bool _isExporting = false;

  // Date pentru formularele clientului si codebitorului
  final List<CreditFormModel> _clientCreditForms = [CreditFormModel()];
  final List<CreditFormModel> _coborrowerCreditForms = [CreditFormModel()];
  final List<IncomeFormModel> _clientIncomeForms = [IncomeFormModel()];
  final List<IncomeFormModel> _coborrowerIncomeForms = [IncomeFormModel()];

  // Controller-e pentru input fields
  final Map<String, TextEditingController> _creditTextControllers = {};
  final Map<String, TextEditingController> _incomeTextControllers = {};

  // Optiuni pentru dropdown-uri
  final List<String> _banks = [
    'Alpha Bank',
    'Raiffeisen Bank',
    'BRD',
    'BCR',
    'ING Bank',
    'Banca Transilvania',
    'CEC Bank',
    'OTP Bank',
  ];

  final List<String> _creditTypes = [
    'Card de cumparaturi',
    'Nevoi personale',
    'Overdraft',
    'Ipotecar',
    'Prima casa',
  ];

  final List<String> _rateTypes = [
    'Fixa',
    'Variabila',
    'Euribor',
    'IRCC',
    'ROBOR',
  ];

  final List<String> _incomeTypes = [
    'Salariu',
    'PFA',
    'Dividende',
    'Chirie',
    'Pensie',
    'Alte venituri',
  ];

  // Store the GLOBAL tap position for the context menu
  Offset _globalTapPosition = Offset.zero;
  
  // Store GLOBAL tap position
  void _getTapPosition(TapDownDetails details) {
    setState(() {
      _globalTapPosition = details.globalPosition;
    });
  }

  @override
  void initState() {
    super.initState();
    // Initialize demo data using the service
    _contactService.initializeDemoData();
  }

  @override
  void dispose() {
    // Dispose all text controllers
    _creditTextControllers.forEach((_, controller) => controller.dispose());
    _incomeTextControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  /// Helper function to format numbers with commas automatically
  void _formatNumberWithCommas(TextEditingController controller, String value) {
    if (value.isEmpty) {
      controller.value = TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    } else {
      try {
        // Remove existing commas and parse
        final numericValue = value.replaceAll(',', '');
        final parts = numericValue.split('.');
        final intPart = parts[0];
        final decPart = parts.length > 1 ? parts[1] : '';
        
        // Format integer part with commas
        final formattedInt = NumberFormat('#,###').format(int.parse(intPart));
        final newText = decPart.isNotEmpty ? '$formattedInt.$decPart' : formattedInt;
        
        controller.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: newText.length),
        );
      } catch (e) {
        // Handle parsing errors - keep original value
      }
    }
  }

  /// Export data to Excel
  Future<void> _exportToExcel() async {
    setState(() {
      _isExporting = true;
    });
    
    try {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      final success = await _contactService.exportToExcel();
      
      if (!mounted) return;
      
      if (success) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              'Date exportate cu succes!',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        scaffoldMessenger.showSnackBar(
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
      if (!mounted) return;
      
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
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
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
        const SizedBox(width: AppTheme.mediumGap),
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
    // Get the current list of forms based on whether we're showing client or co-borrower
    final formsList = _showingClientLoanForm ? _clientCreditForms : _coborrowerCreditForms;
    
    return SingleChildScrollView(
      child: Column(
        children: [
          for (int i = 0; i < formsList.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTapDown: _getTapPosition,
                onLongPress: () => _showCreditFormContextMenu(context, i, formsList),
                child: _buildCreditForm(i, formsList),
              ),
            ),
        ],
      ),
    );
  }

  /// Afiseaza meniul contextual pentru un formular de credit
  void _showCreditFormContextMenu(BuildContext context, int index, List<CreditFormModel> formsList) {
    if (formsList.length <= 1) {
      // Nu permitem stergerea ultimului formular
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Nu se poate sterge ultimul formular.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppTheme.elementColor1,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    
    final RenderObject? overlay = Overlay.of(context).context.findRenderObject();
    if (overlay == null) return;
    
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        _globalTapPosition.dx,
        _globalTapPosition.dy,
        overlay.paintBounds.size.width - _globalTapPosition.dx,
        overlay.paintBounds.size.height - _globalTapPosition.dy,
      ),
      items: [
        PopupMenuItem(
          value: 'delete',
          child: Text(
            'Sterge credit',
            style: TextStyles.subtitleStyle.copyWith(
              color: AppTheme.elementColor3,
            ),
          ),
        ),
      ],
    ).then((value) {
      if (value == 'delete') {
        setState(() {
          formsList.removeAt(index);
        });
      }
    });
  }

  /// Construieste un formular de credit
  Widget _buildCreditForm(int index, List<CreditFormModel> formsList) {
    final form = formsList[index];
    final formPrefix = _showingClientLoanForm ? 'client' : 'codebitor';
    
    // Check the credit type to determine which form to show
    if (form.creditType == 'Card de cumparaturi' || form.creditType == 'Overdraft') {
      // For credit cards and overdraft, show Form1
      return FormContainer1(
        titleTL: 'Banca',
        optionTL: form.bank,
        iconTL: Icons.expand_more,
        onTapTL: null,
        child1TL: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildBankDropdown(index, formsList),
        ),
        
        titleTR: 'Tip credit',
        optionTR: form.creditType,
        iconTR: Icons.expand_more,
        onTapTR: null,
        child1TR: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildCreditTypeDropdown(index, formsList),
        ),
        
        titleBL: 'Sold',
        textBL: form.sold,
        onTapBL: null,
        child1: TextField(
          controller: _getCreditTextController(index, formPrefix, 'sold', form.sold),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d,\.]')),
          ],
          style: GoogleFonts.outfit(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: AppTheme.elementColor3,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            hintText: 'Introduceti soldul',
            hintStyle: GoogleFonts.outfit(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: AppTheme.elementColor3,
            ),
          ),
          onChanged: (value) {
            final controller = _getCreditTextController(index, formPrefix, 'sold', form.sold);
            _formatNumberWithCommas(controller, value);
            setState(() {
              form.sold = controller.text;
            });
          },
        ),
        
        titleBR: 'Consumat',
        textBR: form.consumat,
        onTapBR: null,
        child2: TextField(
          controller: _getCreditTextController(index, formPrefix, 'consumat', form.consumat),
          style: GoogleFonts.outfit(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: AppTheme.elementColor3,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            hintText: 'Introduceti suma consumata',
            hintStyle: GoogleFonts.outfit(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: AppTheme.elementColor3,
            ),
          ),
          onChanged: (value) {
            setState(() {
              form.consumat = value;
              _checkAndAddNewCreditForm();
            });
          },
        ),
        
        fieldHeaderTextColor: AppTheme.elementColor2,
        fieldValueTextColor: AppTheme.elementColor3,
        fieldIconColor: AppTheme.elementColor1,
        fieldContentContainerColor: AppTheme.containerColor2,
      );
    } else if (form.creditType == 'Nevoi personale') {
      // For personal needs loans, show Form2
      return FormContainer2(
        titleR1F1: 'Banca',
        optionR1F1: form.bank,
        iconR1F1: Icons.expand_more,
        onTapR1F1: null,
        child1R1F1: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildBankDropdown(index, formsList),
        ),
        
        titleR1F2: 'Tip credit',
        optionR1F2: form.creditType,
        iconR1F2: Icons.expand_more,
        onTapR1F2: null,
        child1R1F2: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildCreditTypeDropdown(index, formsList),
        ),
        
        titleR2F1: 'Sold',
        textR2F1: form.sold,
        onTapR2F1: null,
        child1: TextField(
          controller: _getCreditTextController(index, formPrefix, 'sold', form.sold),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d,\.]')),
          ],
          style: GoogleFonts.outfit(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: AppTheme.elementColor3,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            hintText: 'Introduceti soldul',
            hintStyle: GoogleFonts.outfit(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: AppTheme.elementColor3,
            ),
          ),
          onChanged: (value) {
            final controller = _getCreditTextController(index, formPrefix, 'sold', form.sold);
            _formatNumberWithCommas(controller, value);
            setState(() {
              form.sold = controller.text;
            });
          },
        ),
        
        titleR2F2: 'Rata',
        textR2F2: form.rata,
        onTapR2F2: null,
        child2: TextField(
          controller: _getCreditTextController(index, formPrefix, 'rata', form.rata),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d,\.]')),
          ],
          style: GoogleFonts.outfit(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: AppTheme.elementColor3,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            hintText: 'Introduceti rata',
            hintStyle: GoogleFonts.outfit(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: AppTheme.elementColor3,
            ),
          ),
          onChanged: (value) {
            final controller = _getCreditTextController(index, formPrefix, 'rata', form.rata);
            _formatNumberWithCommas(controller, value);
            setState(() {
              form.rata = controller.text;
            });
          },
        ),
        
        titleR2F3: 'Perioada',
        textR2F3: form.perioada,
        onTapR2F3: null,
        child3: TextField(
          controller: _getCreditTextController(index, formPrefix, 'perioada', form.perioada),
          style: GoogleFonts.outfit(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: AppTheme.elementColor3,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            hintText: 'Introduceti perioada',
            hintStyle: GoogleFonts.outfit(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: AppTheme.elementColor3,
            ),
          ),
          onChanged: (value) {
            setState(() {
              form.perioada = value;
              _checkAndAddNewCreditForm();
            });
          },
        ),
        
        fieldHeaderTextColor: AppTheme.elementColor2,
        fieldValueTextColor: AppTheme.elementColor3,
        fieldIconColor: AppTheme.elementColor1,
        fieldContentContainerColor: AppTheme.containerColor2,
      );
    } else if (form.creditType == 'Ipotecar' || form.creditType == 'Prima casa') {
      // For mortgage loans, create a custom layout that matches the Figma design
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.containerColor1,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            // First row: Bank and Credit Type
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          'Banca',
                          style: GoogleFonts.outfit(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.elementColor2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppTheme.containerColor2,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: _buildBankDropdown(index, formsList),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          'Tip credit',
                          style: GoogleFonts.outfit(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.elementColor2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppTheme.containerColor2,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: _buildCreditTypeDropdown(index, formsList),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Second row: Sold, Tip rata, Rata, Perioada
            Row(
              children: [
                // Sold field
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          'Sold',
                          style: GoogleFonts.outfit(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.elementColor2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.containerColor2,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextField(
                          controller: _getCreditTextController(index, formPrefix, 'sold', form.sold),
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[\d,\.]')),
                          ],
                          style: GoogleFonts.outfit(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.elementColor3,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                            hintText: 'Sold',
                            hintStyle: GoogleFonts.outfit(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.elementColor3,
                            ),
                          ),
                          onChanged: (value) {
                            final controller = _getCreditTextController(index, formPrefix, 'sold', form.sold);
                            _formatNumberWithCommas(controller, value);
                            setState(() {
                              form.sold = controller.text;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Tip rata field
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          'Tip rata',
                          style: GoogleFonts.outfit(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.elementColor2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppTheme.containerColor2,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: _buildRateTypeDropdown(index, formsList),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Rata field
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          'Rata',
                          style: GoogleFonts.outfit(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.elementColor2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.containerColor2,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextField(
                          controller: _getCreditTextController(index, formPrefix, 'rata', form.rata),
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[\d,\.]')),
                          ],
                          style: GoogleFonts.outfit(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.elementColor3,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                            hintText: 'Rata',
                            hintStyle: GoogleFonts.outfit(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.elementColor3,
                            ),
                          ),
                          onChanged: (value) {
                            final controller = _getCreditTextController(index, formPrefix, 'rata', form.rata);
                            _formatNumberWithCommas(controller, value);
                            setState(() {
                              form.rata = controller.text;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Perioada field
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          'Perioada',
                          style: GoogleFonts.outfit(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.elementColor2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.containerColor2,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextField(
                          controller: _getCreditTextController(index, formPrefix, 'perioada', form.perioada),
                          style: GoogleFonts.outfit(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.elementColor3,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                            hintText: 'Perioada',
                            hintStyle: GoogleFonts.outfit(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.elementColor3,
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              form.perioada = value;
                              _checkAndAddNewCreditForm();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      // Default form for selecting bank and credit type
      return FormContainerNew(
        titleF1: 'Banca',
        optionF1: form.bank,
        iconF1: Icons.expand_more,
        onTapF1: null,
        child1F1: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildBankDropdown(index, formsList),
        ),
        
        titleF2: 'Tip credit',
        optionF2: form.creditType,
        iconF2: Icons.expand_more,
        onTapF2: null,
        child1F2: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildCreditTypeDropdown(index, formsList),
        ),
        
        fieldHeaderTextColor: AppTheme.elementColor2,
        fieldValueTextColor: AppTheme.elementColor3,
        fieldIconColor: AppTheme.elementColor1,
        fieldContentContainerColor: AppTheme.containerColor2,
      );
    }
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
    // Get the current list of forms based on whether we're showing client or co-borrower
    final formsList = _showingClientIncomeForm ? _clientIncomeForms : _coborrowerIncomeForms;
    
    return SingleChildScrollView(
      child: Column(
        children: [
          for (int i = 0; i < formsList.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTapDown: _getTapPosition,
                onLongPress: () => _showIncomeFormContextMenu(context, i, formsList),
                child: _buildIncomeForm(i, formsList),
              ),
            ),
        ],
      ),
    );
  }

  /// Afiseaza meniul contextual pentru un formular de venit
  void _showIncomeFormContextMenu(BuildContext context, int index, List<IncomeFormModel> formsList) {
    if (formsList.length <= 1) {
      // Nu permitem stergerea ultimului formular
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Nu se poate sterge ultimul formular.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppTheme.elementColor1,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    
    final RenderObject? overlay = Overlay.of(context).context.findRenderObject();
    if (overlay == null) return;
    
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        _globalTapPosition.dx,
        _globalTapPosition.dy,
        overlay.paintBounds.size.width - _globalTapPosition.dx,
        overlay.paintBounds.size.height - _globalTapPosition.dy,
      ),
      items: [
        PopupMenuItem(
          value: 'delete',
          child: Text(
            'Sterge venit',
            style: TextStyles.subtitleStyle.copyWith(
              color: AppTheme.elementColor3,
            ),
          ),
        ),
      ],
    ).then((value) {
      if (value == 'delete') {
        setState(() {
          formsList.removeAt(index);
        });
      }
    });
  }

  /// Construieste un formular de venit
  Widget _buildIncomeForm(int index, List<IncomeFormModel> formsList) {
    final form = formsList[index];
    final formPrefix = _showingClientIncomeForm ? 'client' : 'codebitor';
    
    return FormContainer1(
      titleTL: 'Banca',
      optionTL: form.bank,
      iconTL: Icons.expand_more,
      onTapTL: null,
      child1TL: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: _buildBankDropdownForIncome(index, formsList),
      ),
      
      titleTR: 'Tip venit',
      optionTR: form.incomeType,
      iconTR: Icons.expand_more,
      onTapTR: null,
      child1TR: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: _buildIncomeTypeDropdown(index, formsList),
      ),
      
      titleBL: 'Venit',
      textBL: form.incomeAmount,
      onTapBL: null,
      child1: TextField(
        controller: _getIncomeTextController(index, formPrefix, 'amount', form.incomeAmount),
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[\d,\.]')),
        ],
        style: GoogleFonts.outfit(
          fontSize: 17,
          fontWeight: FontWeight.w500,
          color: AppTheme.elementColor3,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          hintText: 'Introduceti venitul',
          hintStyle: GoogleFonts.outfit(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: AppTheme.elementColor3,
          ),
        ),
        onChanged: (value) {
          final controller = _getIncomeTextController(index, formPrefix, 'amount', form.incomeAmount);
          _formatNumberWithCommas(controller, value);
          setState(() {
            form.incomeAmount = controller.text;
          });
        },
      ),
      
      titleBR: 'Vechime',
      textBR: form.vechime,
      onTapBR: null,
      child2: TextField(
        controller: _getIncomeTextController(index, formPrefix, 'vechime', form.vechime),
        style: GoogleFonts.outfit(
          fontSize: 17,
          fontWeight: FontWeight.w500,
          color: AppTheme.elementColor3,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          hintText: 'Introduceti vechimea',
          hintStyle: GoogleFonts.outfit(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: AppTheme.elementColor3,
          ),
        ),
        onChanged: (value) {
          setState(() {
            form.vechime = value;
            _checkAndAddNewIncomeForm();
          });
        },
      ),
      
      fieldHeaderTextColor: AppTheme.elementColor2,
      fieldValueTextColor: AppTheme.elementColor3,
      fieldIconColor: AppTheme.elementColor1,
      fieldContentContainerColor: AppTheme.containerColor2,
    );
  }

  /// Afiseaza un dialog pentru selectarea bancii
  void _showBankPicker(int index, List<CreditFormModel> formsList) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('Selecteaza banca', style: TextStyles.headerStyle),
        children: _banks.map((bank) => SimpleDialogOption(
          onPressed: () {
            setState(() {
              formsList[index].bank = bank;
              _checkAndAddNewCreditForm();
            });
            Navigator.pop(context);
          },
          child: Text(bank, style: TextStyles.subtitleStyle),
        )).toList(),
      ),
    );
  }

  /// Afiseaza un dialog pentru selectarea bancii pentru venit
  void _showBankPickerForIncome(int index, List<IncomeFormModel> formsList) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('Selecteaza banca', style: TextStyles.headerStyle),
        children: _banks.map((bank) => SimpleDialogOption(
          onPressed: () {
            setState(() {
              formsList[index].bank = bank;
              _checkAndAddNewIncomeForm();
            });
            Navigator.pop(context);
          },
          child: Text(bank, style: TextStyles.subtitleStyle),
        )).toList(),
      ),
    );
  }

  /// Afiseaza un dialog pentru selectarea tipului de credit
  void _showCreditTypePicker(int index, List<CreditFormModel> formsList) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('Selecteaza tipul de credit', style: TextStyles.headerStyle),
        children: _creditTypes.map((type) => SimpleDialogOption(
          onPressed: () {
            setState(() {
              formsList[index].creditType = type;
              _checkAndAddNewCreditForm();
            });
            Navigator.pop(context);
          },
          child: Text(type, style: TextStyles.subtitleStyle),
        )).toList(),
      ),
    );
  }

  /// Afiseaza un dialog pentru selectarea tipului de rata
  void _showRateTypePicker(int index, List<CreditFormModel> formsList) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('Selecteaza tipul de rata', style: TextStyles.headerStyle),
        children: _rateTypes.map((type) => SimpleDialogOption(
          onPressed: () {
            setState(() {
              formsList[index].rateType = type;
            });
            Navigator.pop(context);
          },
          child: Text(type, style: TextStyles.subtitleStyle),
        )).toList(),
      ),
    );
  }

  /// Afiseaza un dialog pentru selectarea tipului de venit
  void _showIncomeTypePicker(int index, List<IncomeFormModel> formsList) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('Selecteaza tipul de venit', style: TextStyles.headerStyle),
        children: _incomeTypes.map((type) => SimpleDialogOption(
          onPressed: () {
            setState(() {
              formsList[index].incomeType = type;
            });
            Navigator.pop(context);
          },
          child: Text(type, style: TextStyles.subtitleStyle),
        )).toList(),
      ),
    );
  }

  /// Obtine sau creeaza un TextEditingController pentru un camp specific
  TextEditingController _getCreditTextController(int index, String formType, String fieldName, String initialValue) {
    final String key = 'credit_${formType}_${index}_$fieldName';
    if (!_creditTextControllers.containsKey(key)) {
      _creditTextControllers[key] = TextEditingController(text: initialValue);
    } else if (_creditTextControllers[key]!.text != initialValue) {
      _creditTextControllers[key]!.text = initialValue;
    }
    return _creditTextControllers[key]!;
  }

  /// Obtine sau creeaza un TextEditingController pentru un camp de venit specific
  TextEditingController _getIncomeTextController(int index, String formType, String fieldName, String initialValue) {
    final String key = 'income_${formType}_${index}_$fieldName';
    if (!_incomeTextControllers.containsKey(key)) {
      _incomeTextControllers[key] = TextEditingController(text: initialValue);
    } else if (_incomeTextControllers[key]!.text != initialValue) {
      _incomeTextControllers[key]!.text = initialValue;
    }
    return _incomeTextControllers[key]!;
  }

  /// Verifica si adauga un nou formular daca este necesar
  void _checkAndAddNewCreditForm() {
    final formsList = _showingClientLoanForm ? _clientCreditForms : _coborrowerCreditForms;
    
    // Verifica daca ultimul formular nu mai este considerat "nou"
    if (formsList.isNotEmpty && formsList.last.hasMinimumInfo()) {
      setState(() {
        formsList.last.isNew = false; // Marcheaza formularul ca fiind completat
        formsList.add(CreditFormModel()); // Adauga un nou formular gol
      });
    }
  }

  /// Verifica si adauga un nou formular de venit daca este necesar
  void _checkAndAddNewIncomeForm() {
    final formsList = _showingClientIncomeForm ? _clientIncomeForms : _coborrowerIncomeForms;
    
    // Verifica daca ultimul formular nu mai este considerat "nou"
    if (formsList.isNotEmpty && formsList.last.hasMinimumInfo()) {
      setState(() {
        formsList.last.isNew = false; // Marcheaza formularul ca fiind completat
        formsList.add(IncomeFormModel()); // Adauga un nou formular gol
      });
    }
  }

  // Functie pentru crearea unui dropdown pentru banca
  Widget _buildBankDropdown(int index, List<CreditFormModel> formsList) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        isExpanded: true,
        value: formsList[index].bank != 'Selecteaza banca' ? formsList[index].bank : null,
        hint: Text(
          'Selecteaza banca',
          style: GoogleFonts.outfit(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: AppTheme.elementColor3,
          ),
        ),
        style: GoogleFonts.outfit(
          fontSize: 17,
          fontWeight: FontWeight.w500,
          color: AppTheme.elementColor3,
        ),
        dropdownColor: AppTheme.containerColor2,
        icon: Icon(
          Icons.expand_more,
          color: AppTheme.elementColor3,
        ),
        items: _banks.map((String bank) {
          return DropdownMenuItem<String>(
            value: bank,
            child: Text(bank),
          );
        }).toList(),
        onChanged: (String? value) {
          if (value != null) {
            setState(() {
              formsList[index].bank = value;
              _checkAndAddNewCreditForm();
            });
          }
        },
      ),
    );
  }

  // Functie pentru crearea unui dropdown pentru banca (pentru venituri)
  Widget _buildBankDropdownForIncome(int index, List<IncomeFormModel> formsList) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        isExpanded: true,
        value: formsList[index].bank != 'Selecteaza banca' ? formsList[index].bank : null,
        hint: Text(
          'Selecteaza banca',
          style: GoogleFonts.outfit(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: AppTheme.elementColor3,
          ),
        ),
        style: GoogleFonts.outfit(
          fontSize: 17,
          fontWeight: FontWeight.w500,
          color: AppTheme.elementColor3,
        ),
        dropdownColor: AppTheme.containerColor2,
        icon: Icon(
          Icons.expand_more,
          color: AppTheme.elementColor3,
        ),
        items: _banks.map((String bank) {
          return DropdownMenuItem<String>(
            value: bank,
            child: Text(bank),
          );
        }).toList(),
        onChanged: (String? value) {
          if (value != null) {
            setState(() {
              formsList[index].bank = value;
              _checkAndAddNewIncomeForm();
            });
          }
        },
      ),
    );
  }

  // Functie pentru crearea unui dropdown pentru tipul de credit
  Widget _buildCreditTypeDropdown(int index, List<CreditFormModel> formsList) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        isExpanded: true,
        value: formsList[index].creditType != 'Selecteaza tipul' ? formsList[index].creditType : null,
        hint: Text(
          'Selecteaza tipul',
          style: GoogleFonts.outfit(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: AppTheme.elementColor3,
          ),
        ),
        style: GoogleFonts.outfit(
          fontSize: 17,
          fontWeight: FontWeight.w500,
          color: AppTheme.elementColor3,
        ),
        dropdownColor: AppTheme.containerColor2,
        icon: Icon(
          Icons.expand_more,
          color: AppTheme.elementColor3,
        ),
        items: _creditTypes.map((String type) {
          return DropdownMenuItem<String>(
            value: type,
            child: Text(type),
          );
        }).toList(),
        onChanged: (String? value) {
          if (value != null) {
            setState(() {
              formsList[index].creditType = value;
              _checkAndAddNewCreditForm();
            });
          }
        },
      ),
    );
  }

  // Functie pentru crearea unui dropdown pentru tipul de venit
  Widget _buildIncomeTypeDropdown(int index, List<IncomeFormModel> formsList) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        isExpanded: true,
        value: formsList[index].incomeType != 'Selecteaza tipul' ? formsList[index].incomeType : null,
        hint: Text(
          'Selecteaza tipul',
          style: GoogleFonts.outfit(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: AppTheme.elementColor3,
          ),
        ),
        style: GoogleFonts.outfit(
          fontSize: 17,
          fontWeight: FontWeight.w500,
          color: AppTheme.elementColor3,
        ),
        dropdownColor: AppTheme.containerColor2,
        icon: Icon(
          Icons.expand_more,
          color: AppTheme.elementColor3,
        ),
        items: _incomeTypes.map((String type) {
          return DropdownMenuItem<String>(
            value: type,
            child: Text(type),
          );
        }).toList(),
        onChanged: (String? value) {
          if (value != null) {
            setState(() {
              formsList[index].incomeType = value;
              _checkAndAddNewIncomeForm();
            });
          }
        },
      ),
    );
  }

  // Functie pentru crearea unui dropdown pentru tipul de rata
  Widget _buildRateTypeDropdown(int index, List<CreditFormModel> formsList) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        isExpanded: true,
        value: formsList[index].rateType != 'Selecteaza tipul' ? formsList[index].rateType : null,
        hint: Text(
          'Selecteaza tipul',
          style: GoogleFonts.outfit(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: AppTheme.elementColor3,
          ),
        ),
        style: GoogleFonts.outfit(
          fontSize: 17,
          fontWeight: FontWeight.w500,
          color: AppTheme.elementColor3,
        ),
        dropdownColor: AppTheme.containerColor2,
        icon: Icon(
          Icons.expand_more,
          color: AppTheme.elementColor3,
        ),
        items: _rateTypes.map((String type) {
          return DropdownMenuItem<String>(
            value: type,
            child: Text(type),
          );
        }).toList(),
        onChanged: (String? value) {
          if (value != null) {
            setState(() {
              formsList[index].rateType = value;
              _checkAndAddNewCreditForm();
            });
          }
        },
      ),
    );
  }
}

