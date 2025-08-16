import 'package:mat_finance/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../backend/services/matcher_service.dart';
import '../../backend/services/splash_service.dart';
import '../components/headers/widget_header1.dart';
import '../components/fields/dropdown_field1.dart';
import '../popups/bank_popup.dart';
import '../components/dialog_utils.dart';
import 'package:intl/intl.dart';

/// Pane pentru afisarea recomandarilor de banci
/// 
/// Aceasta componenta afiseaza interfata pentru analiza criteriilor de creditare
/// si recomandarile de banci. Toata logica este gestionata in MatcherService.
class MatcherPane extends StatefulWidget {
  final Function? onClose;

  const MatcherPane({
    super.key,
    this.onClose,
  });

  @override
  State<MatcherPane> createState() => MatcherPaneState();
}

class MatcherPaneState extends State<MatcherPane> with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  // Service pentru logica matcher-ului
  late final MatcherService _matcherService;
  
  // Controllere pentru input-uri
  late final TextEditingController _ageController;
  late final TextEditingController _ficoController;
  
  // Tine evidenta bancii cu popup deschis pentru focused state
  
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    
    // Foloseste serviciul pre-incarcat din splash
    _matcherService = SplashService().matcherService;
    
    // Initializeaza controlerele si service-ul
    _ageController = _matcherService.ageController;
    _ficoController = _matcherService.ficoController;
    
    // Asculta la schimbarile din service
    _matcherService.addListener(_onMatcherServiceChanged);
    
    // Adauga listenere la controllere pentru actualizare automata
    _ageController.addListener(() => _matcherService.updateRecommendations());
    _ficoController.addListener(() => _matcherService.updateRecommendations());
    
    // Adauga observer pentru lifecycle
    WidgetsBinding.instance.addObserver(this);
    
    // Service-ul este deja initializat in splash, doar sincronizam datele
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Actualizeaza datele cand aplicatia revine in prim plan
      _refreshData();
    }
  }
  
  /// Actualizeaza datele (poate fi apelata manual)
  Future<void> _refreshData() async {
    try {
      await _matcherService.refreshClientData();
    } catch (e) {
      debugPrint('Error refreshing matcher data: $e');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _matcherService.removeListener(_onMatcherServiceChanged);
    super.dispose();
  }

  /// Callback pentru schimbarile din MatcherService
  void _onMatcherServiceChanged() {
    if (mounted) {
      // OPTIMIZARE: Foloseste addPostFrameCallback pentru a evita setState in timpul build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  /// Afiseaza popup-ul cu detaliile unei banci
  void _showBankDetailsPopup(BankCriteria bankCriteria) {
    // OPTIMIZARE: Foloseste addPostFrameCallback pentru a evita setState in timpul build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
        });
      }
    });
    
    showBlurredDialog(
      context: context,
      builder: (context) => BankPopup(
        bankCriteria: bankCriteria,
        matcherService: _matcherService,
      ),
    ).then((_) {
      // Reseteaza focused state cand se inchide popup-ul
      if (mounted) {
        setState(() {
        });
      }
    });
  }

  /// Construieste un camp de input custom
  Widget _buildInputField({
    required String title,
    required TextEditingController controller,
    required String placeholder,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 128),
      child: SizedBox(
        width: double.infinity,
        height: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title area
            Container(
              width: double.infinity,
              height: 21,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                title,
                style: AppTheme.safeOutfit(
                  color: AppTheme.elementColor2,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            // Input area
            Container(
              width: double.infinity,
              height: 48,
              decoration: ShapeDecoration(
                color: AppTheme.containerColor2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: TextField(
                controller: controller,
                keyboardType: keyboardType,
                inputFormatters: inputFormatters,
                style: AppTheme.safeOutfit(
                  color: AppTheme.elementColor3,
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                  border: InputBorder.none,
                  hintText: placeholder,
                  hintStyle: AppTheme.safeOutfit(
                    color: AppTheme.elementColor3,
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construieste dropdown-ul pentru selectia genului
  Widget _buildGenderSelection() {
    return DropdownField1<ClientGender>(
      title: 'Gen',
      value: _matcherService.gender,
      items: [
        DropdownMenuItem<ClientGender>(
          value: ClientGender.male,
          child: Text('Masculin'),
        ),
        DropdownMenuItem<ClientGender>(
          value: ClientGender.female,
          child: Text('Feminin'),
        ),
      ],
      onChanged: (ClientGender? newGender) {
        if (newGender != null) {
          _matcherService.updateGender(newGender);
        }
      },
      hintText: 'Selecteaza genul',
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    final uiData = _matcherService.uiData;
    final recommendations = uiData.recommendations;
    final errorMessage = uiData.errorMessage;
    
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(AppTheme.smallGap),
      decoration: ShapeDecoration(
        color: AppTheme.popupBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header using WidgetHeader1 component (same as calculatorPane)
          WidgetHeader1(
            title: 'Recomandare banca',
            titleColor: AppTheme.elementColor1,
          ),
          
          // Same spacing as calculatorPane
          const SizedBox(height: AppTheme.smallGap),
          
          // Content
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Form Container cu smallGap padding
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppTheme.smallGap),
                  decoration: ShapeDecoration(
                    color: AppTheme.containerColor1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Camp pentru gen
                      _buildGenderSelection(),
                      
                      const SizedBox(height: 8),
                      
                      // Camp pentru varsta
                      _buildInputField(
                        title: 'Varsta',
                        controller: _ageController,
                        placeholder: '0',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(3),
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Camp pentru FICO
                      _buildInputField(
                        title: 'Fico',
                        controller: _ficoController,
                        placeholder: '0',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(3),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: AppTheme.mediumGap),
                
                // Lista cu recomandari sau mesajul de eroare
                Expanded(
                  child: errorMessage != null
                      ? Align(
                          alignment: Alignment.topCenter,
                          child: Text(
                            errorMessage,
                            style: AppTheme.safeOutfit(
                              color: AppTheme.elementColor1,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : recommendations.isEmpty
                          ? Align(
                              alignment: Alignment.topCenter,
                              child: Text(
                                'Nu exista banci care sa indeplineasca criteriile clientului',
                                style: AppTheme.safeOutfit(
                                  color: AppTheme.elementColor1,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : Container(
                              width: double.infinity,
                              clipBehavior: Clip.antiAlias,
                              decoration: ShapeDecoration(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                                ),
                              ),
                              child: ListView.separated(
                                itemCount: recommendations.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 8),
                                itemBuilder: (context, index) {
                                  final recommendation = recommendations[index];
                                  final bankName = recommendation.bankCriteria.bankName;
                                  
                                  // Calculeaza sumele pentru fiecare tip
                                  final freshAmount = _matcherService.calculateFreshAmount(bankName);
                                  final refinantareAmount = _matcherService.calculateRefinantareAmount(bankName);
                                  final ordinPlataAmount = _matcherService.calculateOrdinPlataAmount(bankName);
                                  
                                  return GestureDetector(
                                    onTap: () => _showBankDetailsPopup(recommendation.bankCriteria),
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      decoration: ShapeDecoration(
                                        color: AppTheme.containerColor1,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            bankName,
                                            style: AppTheme.safeOutfit(
                                              color: AppTheme.elementColor2,
                                              fontSize: 17,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      'Fresh',
                                                      style: AppTheme.safeOutfit(
                                                        color: AppTheme.elementColor1,
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    NumberFormat('#,###').format(freshAmount),
                                                    style: AppTheme.safeOutfit(
                                                      color: AppTheme.elementColor1,
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 2),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      'Refinantare',
                                                      style: AppTheme.safeOutfit(
                                                        color: AppTheme.elementColor1,
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    NumberFormat('#,###').format(refinantareAmount),
                                                    style: AppTheme.safeOutfit(
                                                      color: AppTheme.elementColor1,
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              // Sectiunea Ordin de plata (doar pentru ING si BCR)
                                              if (bankName == 'ING' || bankName == 'BCR') ...[
                                                const SizedBox(height: 2),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        'Ordin de plata',
                                                        style: AppTheme.safeOutfit(
                                                          color: AppTheme.elementColor1,
                                                          fontSize: 15,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      NumberFormat('#,###').format(ordinPlataAmount),
                                                      style: AppTheme.safeOutfit(
                                                        color: AppTheme.elementColor1,
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Metoda publica pentru actualizarea datelor din exterior
  Future<void> refreshData() async {
    await _refreshData();
  }
}

