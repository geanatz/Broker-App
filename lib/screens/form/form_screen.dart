import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../sidebar/navigation_config.dart';
import '../../sidebar/user_widget.dart';
import '../../sidebar/navigation_widget.dart';
import '../../sidebar/user_config.dart';
import '../../widgets/form/forms_container_widget.dart' show FormsContainerWidget, FormContainerType;

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

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 1200;
    final mainContentHeight = screenSize.height - 48;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppTheme.appBackgroundGradient,
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
             child: Column(
               children: [
                 UserWidget(
                   consultantName: widget.consultantName,
                   teamName: widget.teamName,
                   progress: 0.0,
                   callCount: 0,
                 ),
                 const SizedBox(height: AppTheme.mediumGap),
                 NavigationWidget(
                   currentScreen: NavigationScreen.form,
                   onScreenChanged: widget.onScreenChanged,
                   activeSecondaryPanel: _selectedSecondaryPanel,
                   onPanelChanged: (panelType) {
                     setState(() {
                       _selectedSecondaryPanel = panelType;
                     });
                   },
                 ),
               ],
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
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.stretch,
             children: [
                UserWidget(
                  consultantName: widget.consultantName,
                  teamName: widget.teamName,
                  progress: 0.0,
                  callCount: 0,
                ),
                const SizedBox(height: AppTheme.mediumGap),
                Expanded(
                  child: NavigationWidget(
                    currentScreen: NavigationScreen.form,
                    onScreenChanged: widget.onScreenChanged,
                    activeSecondaryPanel: _selectedSecondaryPanel,
                    onPanelChanged: (panelType) {
                      setState(() {
                        _selectedSecondaryPanel = panelType;
                      });
                    },
                  ),
                ),
             ],
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
    // This Row replaces the PanelContainer
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
        
        // Define gaps from design
        const double gap = 16.0;
        
        // Calculate heights ensuring they don't exceed available space minus gaps
        double nextCallsHeight = 440;
        double ongoingCallHeight = 120;
        double pastCallsHeight = availableHeight - nextCallsHeight - ongoingCallHeight - (2 * gap); 
        pastCallsHeight = pastCallsHeight.clamp(100.0, double.infinity); // Minimum height

        // Recalculate if total exceeds available, prioritizing PastCalls height
        double totalHeight = nextCallsHeight + ongoingCallHeight + pastCallsHeight + (2 * gap);
        if (totalHeight > availableHeight) {
          double excess = totalHeight - availableHeight;
          // Reduce NextCalls and OngoingCall proportionally, maintaining minimums
          double reducibleHeight = nextCallsHeight + ongoingCallHeight;
          if (reducibleHeight > 280) { // Ensure minimums (200 + 80)
             double reductionFactor = (reducibleHeight - excess) / reducibleHeight;
             reductionFactor = reductionFactor.clamp(0.0, 1.0); 
             nextCallsHeight = (nextCallsHeight * reductionFactor).clamp(300.0, 440.0); // Min 300
             ongoingCallHeight = (ongoingCallHeight * reductionFactor).clamp(80.0, 120.0); // Min 80
             pastCallsHeight = availableHeight - nextCallsHeight - ongoingCallHeight - (2 * gap);
          } else {
             // Fallback if not enough space for minimums (unlikely with clamp above)
             nextCallsHeight = 300.0;
             ongoingCallHeight = 80.0;
             pastCallsHeight = (availableHeight - 380 - (2 * gap)).clamp(100.0, double.infinity);
          }

        }


        return Column(
          children: [
            SizedBox(
              height: nextCallsHeight,
              child: _buildNextCallsWidget(),
            ),
            const SizedBox(height: gap),
            SizedBox(
              height: ongoingCallHeight,
              child: _buildOngoingCallWidget(),
            ),
            const SizedBox(height: gap),
            Expanded(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: pastCallsHeight),
                 child: _buildPastCallsWidget(),
               ),
            ),
          ],
        );
      }
    );
  }

  /// Construieste widget-ul pentru apelurile urmatoare
  Widget _buildNextCallsWidget() {
    // Container styling from design (NextCallsWidget)
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF).withOpacity(0.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 0),
          )
        ],
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _buildWidgetHeader(
              title: 'Apeluri urmatoare',
              count: 3,
              color: const Color(0xFF8A9EA8),
              countColor: const Color(0xFF8A9EA8),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: 3,
              itemBuilder: (context, index) {
                return _buildContactItem(
                  name: 'Contact name ${index + 1}',
                  phone: '0712 345 678',
                  onTap: () {
                    // Actiune pentru apelare
                  },
                  backgroundColor: const Color(0xFFC4CFD4),
                  nameColor: const Color(0xFF4D6F80),
                  phoneColor: const Color(0xFF668899),
                  buttonColor: const Color(0xFFACC6D3),
                  buttonIconAsset: 'assets/CallIcon.svg',
                  buttonIconColor: const Color(0xFF4D6F80),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Construieste widget-ul pentru apelul in desfasurare
  Widget _buildOngoingCallWidget() {
    // Container styling from design (OngoingCallWidget)
     return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF).withOpacity(0.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 0),
          )
        ],
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
             padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _buildWidgetHeader(
              title: 'Apel in desfasurare',
              duration: '01:49',
              color: const Color(0xFF927B9D),
              countColor: const Color(0xFF927B9D),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _buildContactItem(
              name: 'Contact name 4',
              phone: '0712 345 678',
              onTap: () {
                // Actiune pentru speech
              },
              backgroundColor: const Color(0xFFCFC4D4),
              nameColor: const Color(0xFF7C568F),
              phoneColor: const Color(0xFF886699),
              buttonColor: const Color(0xFFC6ACD3),
              buttonIconAsset: 'assets/SpeechIcon.svg',
              buttonIconColor: const Color(0xFF7C568F),
              addMargin: false,
            ),
          ),
        ],
      ),
    );
  }

  /// Construieste widget-ul pentru apelurile anterioare
  Widget _buildPastCallsWidget() {
    // Container styling from design (PastCallWidget)
     return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF).withOpacity(0.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 0),
          )
        ],
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
           Padding(
             padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _buildWidgetHeader(
              title: 'Apeluri anterioare',
              count: 6,
              color: const Color(0xFFA88A8A),
              countColor: const Color(0xFFA88A8A),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: 6,
              itemBuilder: (context, index) {
                return _buildContactItem(
                  name: 'Contact name ${index + 5}',
                  phone: '0712 345 678',
                  onTap: () {
                    // Actiune pentru reapelare
                  },
                  backgroundColor: const Color(0xFFD4C4C4),
                  nameColor: const Color(0xFF804D4D),
                  phoneColor: const Color(0xFF996666),
                  buttonColor: const Color(0xFFD3ACAC),
                  buttonIconAsset: 'assets/CallIcon.svg',
                  buttonIconColor: const Color(0xFF804D4D),
                  rotateIcon: true,
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
    required String name,
    required String phone,
    required VoidCallback onTap,
    required Color backgroundColor,
    required Color nameColor,
    required Color phoneColor,
    required Color buttonColor,
    required String buttonIconAsset,
    required Color buttonIconColor,
    bool rotateIcon = false,
    bool addMargin = true,
  }) {
    // Container styling from design (Contact)
    return Container(
      margin: EdgeInsets.only(bottom: addMargin ? 8.0 : 0.0),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyles.titleStyle.copyWith(
                      height: 1.28,
                      color: nameColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    phone,
                    style: TextStyles.subtitleStyle.copyWith(
                      height: 1.25,
                      color: phoneColor,
                    ),
                     maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                width: 56,
                height: 56,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: buttonColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Transform.rotate(
                  angle: rotateIcon ? (135 * 3.14159 / 180) : 0,
                  child: SvgPicture.asset(
                    buttonIconAsset,
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(buttonIconColor, BlendMode.srcIn),
                  ),
                ),
              ),
            ),
          ),
        ],
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
            ),
          ),
          if (count != null)
            Text(
              count.toString(),
              style: TextStyles.subtitleStyle.copyWith(
                height: 1.25,
                color: countColor,
              ),
            ),
          if (duration != null)
            Text(
              duration,
               style: TextStyles.subtitleStyle.copyWith(
                height: 1.25,
                color: countColor,
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
            iconAsset: 'assets/UserIcon.svg',
            isSelected: _showingClientLoanForm,
            onTap: () {
              setState(() {
                _showingClientLoanForm = true;
              });
            },
          ),
          _buildToggleButton(
            iconAsset: 'assets/CodebitorIcon.svg',
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
            iconAsset: 'assets/UserIcon.svg',
            isSelected: _showingClientIncomeForm,
            onTap: () {
              setState(() {
                _showingClientIncomeForm = true;
              });
            },
          ),
          _buildToggleButton(
            iconAsset: 'assets/CodebitorIcon.svg',
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
} 