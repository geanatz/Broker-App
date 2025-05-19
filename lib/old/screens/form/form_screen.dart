import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:broker_app/frontend/common/appTheme.dart';
import 'package:broker_app/old/sidebar/sidebar_service.dart';
import 'package:broker_app/old/sidebar/sidebar_widget.dart';
import 'package:broker_app/old/models/contact_data.dart';
import 'package:broker_app/old/services/contact_form_service.dart';
import 'package:broker_app/old/widgets/form/forms_container_widget.dart.dart' show FormsContainerWidget, FormContainerType;

/// Definirea temei de text pentru a asigura consistența fontului Outfit în întreaga aplicație
class TextStyles {
  static final TextStyle titleStyle = GoogleFonts.outfit(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );
  
  static final TextStyle subtitleStyle = GoogleFonts.outfit(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  static final TextStyle headerStyle = GoogleFonts.outfit(
    fontSize: 18,
    fontWeight: FontWeight.w600,  
  );
}

/// Ecranul pentru formularul de clienti
class FormScreen extends StatefulWidget {
  /// Numele consultantului
  final String consultantName;
  
  /// Numele echipei
  final String teamName;
  
  /// Callback pentru schimbarea ecranului
  final Function(NavigationScreen) onScreenChanged;

  const FormScreen({
    Key? key,
    required this.consultantName,
    required this.teamName,
    required this.onScreenChanged,
  }) : super(key: key);

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  // Panoul secundar selectat momentan
  SecondaryPanelType _selectedSecondaryPanel = SecondaryPanelType.calls;
  
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
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 1200;
    final mainContentHeight = screenSize.height - 48;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: AppTheme.appBackground,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.largeGap),
          child: isSmallScreen
            ? _buildSmallScreenLayout()
            : _buildLargeScreenLayout(mainContentHeight),
        ),
      ),
    );
  }

  /// Construieste layout-ul pentru ecrane mici (< 1200px)
  Widget _buildSmallScreenLayout() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 312,
            child: _buildSecondaryPanelContent(),
          ),
          const SizedBox(height: AppTheme.largeGap),
          _buildFormPanelContent(),
          const SizedBox(height: AppTheme.largeGap),
          Container(
             width: 224,
             child: SidebarWidgetAdapter(
               consultantName: widget.consultantName,
               teamName: widget.teamName,
               currentScreen: NavigationScreen.form,
               activeSecondaryPanel: _selectedSecondaryPanel,
               onScreenChanged: widget.onScreenChanged,
               onPanelChanged: (panelType) {
                 setState(() {
                   _selectedSecondaryPanel = panelType;
                 });
               },
             ),
           ),
        ],
      ),
    );
  }

  /// Construieste layout-ul pentru ecrane mari (>= 1200px)
  Widget _buildLargeScreenLayout(double contentHeight) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 312,
          height: contentHeight,
          child: _buildSecondaryPanelContent(),
        ),
        const SizedBox(width: AppTheme.largeGap),
        Expanded(
          child: SizedBox(
            height: contentHeight,
            child: _buildFormPanelContent(),
          ),
        ),
        const SizedBox(width: AppTheme.largeGap),
        SizedBox(
           width: 224,
           height: contentHeight,
           child: SidebarWidgetAdapter(
             consultantName: widget.consultantName,
             teamName: widget.teamName,
             currentScreen: NavigationScreen.form,
             activeSecondaryPanel: _selectedSecondaryPanel,
             onScreenChanged: widget.onScreenChanged,
             onPanelChanged: (panelType) {
               setState(() {
                 _selectedSecondaryPanel = panelType;
               });
             },
           ),
        ),
      ],
    );
  }

  /// Construieste continutul panoului secundar fara wrapper
  Widget _buildSecondaryPanelContent() {
    // This Column replaces the PanelContainer
    // The children will have their own background/styling
    return Column(
      children: [
        if (_selectedSecondaryPanel == SecondaryPanelType.calls)
          Expanded(child: _buildCallPanel())
        else if (_selectedSecondaryPanel == SecondaryPanelType.returns)
          Expanded(child: _buildReturnsPanel())
        else if (_selectedSecondaryPanel == SecondaryPanelType.calculator)
          Expanded(child: _buildCalculatorPanel())
        else if (_selectedSecondaryPanel == SecondaryPanelType.recommendation)
          Expanded(child: _buildRecommendationPanel()),
      ],
    );
  }

  /// Construieste continutul panoului de formulare fara wrapper
  Widget _buildFormPanelContent() {
    // Remove the export button and header section
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

  // ========== IMPLEMENTARILE PANOURILOR SECUNDARE ==========

  /// Construieste panoul pentru apeluri
  Widget _buildCallPanel() {
    // Use a layout builder to get the available height
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate appropriate heights based on available space
        final double availableHeight = constraints.maxHeight;
        
        // Define gap from design
        const double gap = AppTheme.largeGap; // 24px gap between widgets
        
        // Calculate height for each widget (equal split minus gap divided by 2)
        double widgetHeight = (availableHeight - gap) / 2;

        return Column(
          children: [
            SizedBox(
              height: widgetHeight,
              child: _buildNextCallsWidget(),
            ),
            const SizedBox(height: gap),
            SizedBox(
              height: widgetHeight,
              child: _buildPastCallsWidget(),
            ),
          ],
        );
      }
    );
  }

  /// Construieste widget-ul pentru apelurile urmatoare
  Widget _buildNextCallsWidget() {
    // Get contacts from service
    final upcomingContacts = _contactService.upcomingContacts;
    
    // Container styling from design (NextCallsWidget)
    return Container(
      padding: const EdgeInsets.all(AppTheme.smallGap), // 8px padding
      decoration: BoxDecoration(
        color: AppTheme.widgetBackground.withOpacity(0.5),
        boxShadow: [AppTheme.widgetShadow],
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge), // 32px
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.mediumGap), // 16px horizontal padding
            child: _buildWidgetHeader(
              title: 'Clienti', // Changed from "Apeluri" to "Clienti"
              count: upcomingContacts.length,
              color: AppTheme.elementColor1, // #8A9EA8
              countColor: AppTheme.elementColor1,
            ),
          ),
          const SizedBox(height: AppTheme.smallGap), // 8px gap
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: upcomingContacts.length,
              itemBuilder: (context, index) {
                final contact = upcomingContacts[index];
                final bool isSelected = _selectedContact?.id == contact.id;
                final bool isHovered = _hoveredContactId == contact.id;
                
                return _buildContactItem(
                  contactId: contact.id,
                  name: contact.name,
                  phone: contact.phone,
                  isSelected: isSelected,
                  isHovered: isHovered,
                  onHoverChanged: (isHovering) {
                    setState(() {
                      _hoveredContactId = isHovering ? contact.id : null;
                    });
                  },
                  onTap: () {
                    // Save data for previously selected contact before switching
                    if (_selectedContact != null && _selectedContact!.id != contact.id) {
                      _saveDataForContact();
                    }
                    setState(() {
                      _selectedContact = contact;
                    });
                  },
                  onCallTap: () {
                    // Save data for this contact
                    setState(() {
                      _selectedContact = contact;
                    });
                    _saveDataForContact();
                  },
                  backgroundColor: isSelected || isHovered 
                      ? AppTheme.containerColor2
                      : AppTheme.containerColor1,
                  nameColor: isSelected || isHovered 
                      ? AppTheme.elementColor3
                      : AppTheme.elementColor2,
                  phoneColor: isSelected || isHovered 
                      ? AppTheme.elementColor2
                      : AppTheme.elementColor1,
                  buttonColor: AppTheme.containerColor2,
                  buttonIconAsset: isSelected 
                      ? 'assets/doneIcon.svg'
                      : 'assets/viewIcon.svg',
                  buttonIconColor: AppTheme.elementColor3,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Construieste widget-ul pentru apelurile anterioare
  Widget _buildPastCallsWidget() {
    // Get contacts from service
    final recentContacts = _contactService.recentContacts;
    
    // Container styling from design (PastCallWidget)
    return Container(
      padding: const EdgeInsets.all(AppTheme.smallGap), // 8px padding
      decoration: BoxDecoration(
        color: AppTheme.widgetBackground.withOpacity(0.5),
        boxShadow: [AppTheme.widgetShadow],
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge), // 32px
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.mediumGap), // 16px horizontal padding
            child: _buildWidgetHeader(
              title: 'Recente',
              count: recentContacts.length,
              color: AppTheme.elementColor1, // #A88A8A
              countColor: AppTheme.elementColor1,
            ),
          ),
          const SizedBox(height: AppTheme.smallGap), // 8px gap
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: recentContacts.length,
              itemBuilder: (context, index) {
                final contact = recentContacts[index];
                final bool isSelected = _selectedContact?.id == contact.id;
                final bool isHovered = _hoveredContactId == contact.id;
                
                return _buildContactItem(
                  contactId: contact.id,
                  name: contact.name,
                  phone: contact.phone,
                  isSelected: isSelected,
                  isHovered: isHovered,
                  onHoverChanged: (isHovering) {
                    setState(() {
                      _hoveredContactId = isHovering ? contact.id : null;
                    });
                  },
                  onTap: () {
                    // Save data for previously selected contact before switching
                    if (_selectedContact != null && _selectedContact!.id != contact.id) {
                      _saveDataForContact();
                    }
                    setState(() {
                      _selectedContact = contact;
                    });
                  },
                  onCallTap: () {
                    // Save data for this contact
                    setState(() {
                      _selectedContact = contact;
                    });
                    _saveDataForContact();
                  },
                  backgroundColor: isSelected || isHovered 
                      ? AppTheme.containerColor2
                      : AppTheme.containerColor1,
                  nameColor: isSelected || isHovered 
                      ? AppTheme.elementColor3
                      : AppTheme.elementColor2,
                  phoneColor: isSelected || isHovered 
                      ? AppTheme.elementColor2
                      : AppTheme.elementColor1,
                  buttonColor: AppTheme.containerColor2,
                  buttonIconAsset: isSelected
                      ? 'assets/doneIcon.svg'
                      : 'assets/viewIcon.svg',
                  buttonIconColor: AppTheme.elementColor3,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Construieste un element de contact reutilizabil
  Widget _buildContactItem({
    required String contactId,
    required String name,
    required String phone,
    required VoidCallback onTap,
    required VoidCallback onCallTap,
    required Function(bool) onHoverChanged,
    required Color backgroundColor,
    required Color nameColor,
    required Color phoneColor,
    required Color buttonColor,
    required String buttonIconAsset,
    required Color buttonIconColor,
    bool isSelected = false,
    bool isHovered = false,
  }) {
    // Container styling from design (Contact) - Based on callsPanel.md specs
    return MouseRegion(
      onEnter: (_) => onHoverChanged(true),
      onExit: (_) => onHoverChanged(false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.only(bottom: AppTheme.smallGap), // 8px bottom margin
          padding: const EdgeInsets.all(AppTheme.smallGap), // 8px padding
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium), // 24px border radius
          ),
          child: Row(
            children: [
              // Contact Details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: AppTheme.smallGap), // 8px left padding
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyles.titleStyle.copyWith(
                          height: 1.28,
                          color: nameColor,
                          fontWeight: FontWeight.w600, // large font weight
                          fontSize: AppTheme.fontSizeMedium, // 17px as specified in callsPanel.md
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppTheme.tinyGap), // 4px gap
                      Text(
                        phone,
                        style: TextStyles.subtitleStyle.copyWith(
                          height: 1.25,
                          color: phoneColor,
                          fontWeight: FontWeight.w500, // medium font weight
                          fontSize: AppTheme.fontSizeSmall, // 15px as specified in callsPanel.md
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              // Call Button - Exactly as specified in callsPanel.md
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: onCallTap,
                  child: Container(
                    width: 48, // 48px width as specified
                    height: 48, // 48px height as specified
                    decoration: BoxDecoration(
                      color: buttonColor,
                      borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall), // 16px border radius
                    ),
                    // Center the icon without padding to ensure it appears at the correct 24px size
                    child: Center(
                      child: SvgPicture.asset(
                        buttonIconAsset,
                        width: 24, // Exactly 24px as specified
                        height: 24, // Exactly 24px as specified
                        colorFilter: ColorFilter.mode(buttonIconColor, BlendMode.srcIn),
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

  /// Construieste un header reutilizabil pentru widget-uri
  Widget _buildWidgetHeader({
    required String title,
    int? count,
    String? duration,
    required Color color,
    required Color countColor,
  }) {
    // Header uses specific height and padding from design
    return SizedBox(
      height: 24,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyles.titleStyle.copyWith(
              height: 1.28,
              color: color,
              fontWeight: FontWeight.w500, // medium font weight
              fontSize: AppTheme.fontSizeLarge, // 19px
            ),
          ),
          if (count != null)
            Text(
              count.toString(),
              style: TextStyles.subtitleStyle.copyWith(
                height: 1.25,
                color: countColor,
                fontWeight: FontWeight.w500, // medium font weight
                fontSize: AppTheme.fontSizeSmall, // 15px
              ),
            ),
          if (duration != null)
            Text(
              duration,
              style: TextStyles.subtitleStyle.copyWith(
                height: 1.25,
                color: countColor,
                fontWeight: FontWeight.w500, // medium font weight
                fontSize: AppTheme.fontSizeSmall, // 15px
              ),
            ),
        ],
      ),
    );
  }

  /// Construieste panoul pentru reveniri
  Widget _buildReturnsPanel() {
    // Placeholder - replace with actual implementation later
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
         color: const Color(0xFFFFFFFF).withOpacity(0.5),
         borderRadius: BorderRadius.circular(32),
         boxShadow: [AppTheme.widgetShadow],
      ),
      child: Text(
            'Panou Reveniri (în dezvoltare)',
            style: TextStyles.subtitleStyle.copyWith(
              color: const Color(0xFF927B9D),
            ),
          ),
    );
  }

  /// Construieste panoul pentru calculator
  Widget _buildCalculatorPanel() {
     // Placeholder - replace with actual implementation later
     return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
         color: const Color(0xFFFFFFFF).withOpacity(0.5),
         borderRadius: BorderRadius.circular(32),
         boxShadow: [AppTheme.widgetShadow],
      ),
      child: Text(
            'Panou Calculator (în dezvoltare)',
            style: TextStyles.subtitleStyle.copyWith(
              color: const Color(0xFF927B9D),
            ),
          ),
    );
  }

  /// Construieste panoul pentru recomandari
  Widget _buildRecommendationPanel() {
     // Placeholder - replace with actual implementation later
     return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
         color: const Color(0xFFFFFFFF).withOpacity(0.5),
         borderRadius: BorderRadius.circular(32),
         boxShadow: [AppTheme.widgetShadow],
      ),
      child: Text(
            'Panou Recomandări (în dezvoltare)',
            style: TextStyles.subtitleStyle.copyWith(
              color: const Color(0xFF927B9D),
            ),
          ),
    );
  }

  // ========== COMPONENTE PENTRU PANOUL DE FORMULARE ==========

  /// Construieste widget-ul pentru credite
  Widget _buildLoanWidget() {
    // Container styling from design (LoanWidget)
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF).withOpacity(0.5),
        borderRadius: BorderRadius.circular(32),
         boxShadow: [AppTheme.widgetShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: SizedBox(
              height: 24,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _showingClientLoanForm ? 'Credite client' : 'Credite codebitor',
                      style: TextStyles.titleStyle.copyWith(
                        color: const Color(0xFF927B9D),
                      ),
                    ),
                  ],
                ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: _buildLoansContainer(),
            ),
          ),
          _buildLoanToggleButtons(),
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
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF).withOpacity(0.5),
        borderRadius: BorderRadius.circular(32),
         boxShadow: [AppTheme.widgetShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
             padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: SizedBox(
              height: 24,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    _showingClientIncomeForm ? 'Venit client' : 'Venit codebitor',
                    style: TextStyles.titleStyle.copyWith(
                      color: const Color(0xFF927B9D),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
             child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: _buildIncomesContainer(),
            ),
          ),
          _buildIncomeToggleButtons(),
        ],
      ),
    );
  }

  /// Construieste containerul pentru lista de venituri
  Widget _buildIncomesContainer() {
     // Container for the scrollable list of forms
    return SingleChildScrollView(
      child: FormsContainerWidget(
        type: FormContainerType.income,
        isClientForm: _showingClientIncomeForm,
        contactId: _selectedContact?.id, // Pass the selected contact ID
      ),
    );
  }

  /// Construieste butoanele pentru comutarea intre client si codebitor pentru CREDITE
  Widget _buildLoanToggleButtons() {
    // Section styling from design
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildToggleButton(
            iconAsset: 'assets/userIcon.svg',
            isSelected: _showingClientLoanForm,
            onTap: () {
              setState(() {
                _showingClientLoanForm = true;
              });
            },
          ),
          _buildToggleButton(
            iconAsset: 'assets/groupIcon.svg',
            isSelected: !_showingClientLoanForm,
            onTap: () {
              setState(() {
                _showingClientLoanForm = false;
              });
            },
          ),
        ],
      ),
    );
  }
  
  /// Construieste butoanele pentru comutarea intre client si codebitor pentru VENITURI
  Widget _buildIncomeToggleButtons() {
    // Section styling from design
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildToggleButton(
            iconAsset: 'assets/userIcon.svg',
            isSelected: _showingClientIncomeForm,
            onTap: () {
              setState(() {
                _showingClientIncomeForm = true;
              });
            },
          ),
          _buildToggleButton(
            iconAsset: 'assets/groupIcon.svg',
            isSelected: !_showingClientIncomeForm,
            onTap: () {
              setState(() {
                _showingClientIncomeForm = false;
              });
            },
          ),
        ],
      ),
    );
  }

  /// Construieste un buton pentru comutare client/codebitor
  Widget _buildToggleButton({
    required String iconAsset,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    // Button styling from design
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFC6ACD3) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: SvgPicture.asset(
            iconAsset,
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              isSelected
                ? const Color(0xFF7C568F)
                : const Color(0xFF886699),
              BlendMode.srcIn
            ),
          ),
        ),
      ),
    );
  }

  /// Helper method to save data for the selected contact
  void _saveDataForContact() {
    if (_selectedContact == null) return;
    
    try {
      // Get current form data for both credit and income forms
      final creditForms = _contactService.getCreditForms(_selectedContact!.id);
      final incomeForms = _contactService.getIncomeForms(_selectedContact!.id);
      
      // Update any modified forms in the service
      for (var form in creditForms) {
        if (!form.isEmpty) {
          _contactService.updateCreditForm(_selectedContact!.id, form);
        }
      }
      
      for (var form in incomeForms) {
        if (!form.isEmpty) {
          _contactService.updateIncomeForm(_selectedContact!.id, form);
        }
      }
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Date salvate pentru ${_selectedContact!.name}',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
        ),
      );
      
      print('Salvat date pentru contactul: ${_selectedContact!.id}');
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Eroare la salvarea datelor: $e',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
      print('Eroare la salvarea datelor: $e');
    }
  }

  @override
  void didUpdateWidget(FormScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // If the selected contact changes, ensure forms are loaded with the correct data
    if (_selectedContact != null) {
      // This will trigger the FormsContainerWidget to load the appropriate data
      setState(() {});
    }
  }
} 