import 'package:mat_finance/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mat_finance/backend/services/matcher_service.dart';
import 'package:mat_finance/backend/services/splash_service.dart';
import 'package:mat_finance/backend/services/llm_service.dart';
import 'package:mat_finance/backend/services/role_service.dart';
import 'package:mat_finance/backend/services/consultant_service.dart';
import '../components/headers/widget_header1.dart';

/// Area pentru setari care urmeaza exact design-ul specificat
/// Permite gestionarea Google Drive si alte setari
class SettingsArea extends StatefulWidget {
  const SettingsArea({super.key});

  @override
  State<SettingsArea> createState() => _SettingsAreaState();
}

class _SettingsAreaState extends State<SettingsArea> {
  late final MatcherService _matcherService;
  late final LLMService _llmService;
  late final ConsultantService _consultantService;

  int? _selectedColorIndex;
  bool _isLoading = false;
  Map<int, String?> _colorAvailability = {}; // colorIndex -> nume consultant sau null daca disponibila
  List<TradeRequest> _receivedTradeRequests = []; // trade requests primite
  List<TradeRequest> _sentTradeRequests = []; // trade requests trimise
  Map<int, bool> _pendingTradeRequests = {}; // colorIndex -> true daca exista cerere pending

  @override
  void initState() {
    super.initState();
    // Foloseste serviciile pre-incarcate din splash
    _matcherService = SplashService().matcherService;
    _llmService = SplashService().llmService;
    _consultantService = ConsultantService();

    // Asculta schimbarile de la servicii pentru actualizari in timp real
    _matcherService.addListener(_onMatcherServiceChanged);
    _llmService.addListener(_onLLMServiceChanged);

    // Asculta trade requests
    _consultantService.tradeRequestsStream.listen(_onTradeRequestsChanged);

    // Incarca cheia API existenta
    _loadApiKey();

    // Incarca culoarea curenta a consultantului
    _loadCurrentConsultantColor();

    // Incarca disponibilitatea culorilor
    _loadColorAvailability();

    // Incarca trade requests primite
    _loadReceivedTradeRequests();

    // Incarca trade requests trimise (pentru a identifica cele pending)
    _loadSentTradeRequests();
  }

  @override
  void dispose() {
    _matcherService.removeListener(_onMatcherServiceChanged);
    _llmService.removeListener(_onLLMServiceChanged);
    super.dispose();
  }

  /// Callback pentru schimbarile din MatcherService
  void _onMatcherServiceChanged() {
    if (mounted) {
      setState(() {
        // UI-ul se va actualiza automat datorita setState
      });
    }
  }

  /// Callback pentru schimbarile din LLMService
  void _onLLMServiceChanged() {
    if (mounted) {
      setState(() {
        // UI-ul se va actualiza automat datorita setState
      });
    }
  }

  /// Callback pentru trade requests
  void _onTradeRequestsChanged(List<TradeRequest> tradeRequests) {
    if (mounted) {
      setState(() {
        _receivedTradeRequests = tradeRequests;
      });
      // Reincarca trade requests trimise pentru a actualiza starea pending
      _loadSentTradeRequests();
    }
  }

  /// Incarca trade requests primite
  Future<void> _loadReceivedTradeRequests() async {
    try {
      final tradeRequests = await _consultantService.getReceivedTradeRequests();
      if (mounted) {
        setState(() {
          _receivedTradeRequests = tradeRequests;
        });
      }
      debugPrint('🎨 SETTINGS: Loaded ${_receivedTradeRequests.length} trade requests');
    } catch (e) {
      debugPrint('❌ SETTINGS: Error loading trade requests: $e');
    }
  }

  /// Incarca trade requests trimise de consultantul curent
  Future<void> _loadSentTradeRequests() async {
    try {
      final sentTradeRequests = await _consultantService.getSentTradeRequests();

      if (mounted) {
        setState(() {
          _sentTradeRequests = sentTradeRequests;
          // Actualizeaza pending trade requests din baza de date
          _pendingTradeRequests.clear();
          for (final request in sentTradeRequests) {
            _pendingTradeRequests[request.requestedColorIndex] = true;
          }
        });
      }

      debugPrint('🎨 SETTINGS: Loaded ${_sentTradeRequests.length} sent trade requests');
    } catch (e) {
      debugPrint('❌ SETTINGS: Error loading sent trade requests: $e');
      // In caz de eroare, initializam cu liste goale
      if (mounted) {
        setState(() {
          _sentTradeRequests = [];
          _pendingTradeRequests = {};
        });
      }
    }
  }



  /// Anuleaza un trade request trimis de consultantul curent
  Future<void> _cancelPendingTradeRequest(int colorIndex) async {
    if (_isLoading) return;

    // Gaseste trade request-ul pentru aceasta culoare
    final tradeRequest = _sentTradeRequests.firstWhere(
      (tr) => tr.requestedColorIndex == colorIndex,
      orElse: () => throw Exception('Trade request not found for color $colorIndex'),
    );

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _consultantService.cancelTradeRequest(tradeRequest.id);

      if (success && mounted) {
        // Reincarca trade requests trimise pentru a actualiza lista
        await _loadSentTradeRequests();
        debugPrint('🎨 SETTINGS: Trade request cancelled successfully for color $colorIndex');
      } else {
        if (mounted) {
          // Arata mesaj de eroare
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Eroare la anularea cererii de schimb'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ SETTINGS: Error cancelling trade request: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Accepta un trade request
  Future<void> _acceptTradeRequest(String tradeRequestId) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _consultantService.acceptTradeRequest(tradeRequestId);

      if (success && mounted) {
        // Reincarca trade requests trimise pentru a actualiza starea
        await _loadSentTradeRequests();

        // Reincarca datele
        await _loadCurrentConsultantColor();
        await _loadColorAvailability();
        await _loadReceivedTradeRequests();
      }
    } catch (e) {
      debugPrint('❌ SETTINGS: Error accepting trade request: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Refuza un trade request
  Future<void> _rejectTradeRequest(String tradeRequestId) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _consultantService.rejectTradeRequest(tradeRequestId);

      if (success && mounted) {
        // Reincarca trade requests trimise pentru a actualiza starea
        await _loadSentTradeRequests();

        await _loadReceivedTradeRequests();
      }
    } catch (e) {
      debugPrint('❌ SETTINGS: Error rejecting trade request: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Incarca cheia API din serviciu
  Future<void> _loadApiKey() async {
    // Cheia API se incarca automat in LLMService
    setState(() {
      // UI-ul se va actualiza automat
    });
  }

  /// Incarca culoarea curenta a consultantului
  Future<void> _loadCurrentConsultantColor() async {
    try {
      final colorIndex = await _consultantService.getCurrentConsultantColor();
      if (mounted) {
        setState(() {
          _selectedColorIndex = colorIndex;
        });
      }
    } catch (e) {
      debugPrint('❌ SETTINGS: Error loading consultant color: $e');
    }
  }

  /// Incarca disponibilitatea tuturor culorilor din echipa
  Future<void> _loadColorAvailability() async {
    try {
      final availability = <int, String?>{};

      // Verifica fiecare culoare din paleta (1-10)
      for (int colorIndex = 1; colorIndex <= 10; colorIndex++) {
        final takenBy = await _consultantService.checkColorAvailability(colorIndex);
        availability[colorIndex] = takenBy;
      }

      if (mounted) {
        setState(() {
          _colorAvailability = availability;
        });
      }

      debugPrint('🎨 SETTINGS: Color availability loaded: $_colorAvailability');
    } catch (e) {
      debugPrint('❌ SETTINGS: Error loading color availability: $e');
    }
  }

  /// Salveaza culoarea selectata de consultant
  Future<void> _saveConsultantColor(int colorIndex) async {
    if (_isLoading) return;

    final stopwatch = Stopwatch()..start();
    debugPrint('🎨 SETTINGS_COLORS: _saveConsultantColor - starting to save color index: $colorIndex');

    setState(() {
      _isLoading = true;
    });

    try {
      // Verifica daca culoarea este deja luata de alt consultant
      final takenBy = await _consultantService.checkColorAvailability(colorIndex);
      if (takenBy != null) {
        stopwatch.stop();
        debugPrint('❌ SETTINGS_COLORS: _saveConsultantColor - color already taken by: $takenBy, colorIndex: $colorIndex');

        // Culoarea este deja folosita - mesajul se afiseaza in UI

        setState(() {
          _isLoading = false;
        });
        return;
      }

      final success = await _consultantService.updateCurrentConsultantColor(colorIndex);
      stopwatch.stop();

      if (success && mounted) {
        setState(() {
          _selectedColorIndex = colorIndex;
        });

        // Reincarca disponibilitatea culorilor dupa salvare
        await _loadColorAvailability();

        debugPrint('🎨 SETTINGS_COLORS: _saveConsultantColor - completed successfully, timeMs=${stopwatch.elapsedMilliseconds}, colorIndex: $colorIndex');
      } else {
        debugPrint('❌ SETTINGS_COLORS: _saveConsultantColor - failed to save, timeMs=${stopwatch.elapsedMilliseconds}, colorIndex: $colorIndex');
      }
    } catch (e) {
      stopwatch.stop();
      debugPrint('❌ SETTINGS_COLORS: _saveConsultantColor - error: $e, timeMs=${stopwatch.elapsedMilliseconds}, colorIndex: $colorIndex');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.largeGap),
      decoration: BoxDecoration(
        gradient: AppTheme.areaColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: _buildSettingsContent(),
    );
  }

  /// Construieste continutul setarilor conform design-ului specificat
  Widget _buildSettingsContent() {
    final isSupervisor = RoleService().isSupervisor;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [


        // Indicator pentru supervisor
        if (isSupervisor)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppTheme.smallGap),
            margin: const EdgeInsets.only(bottom: AppTheme.smallGap),
            decoration: ShapeDecoration(
              color: AppTheme.elementColor3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.admin_panel_settings,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'SUPERVISOR MODE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: AppTheme.fontSizeMedium,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

        // Sectiunea pentru trade requests primite
        if (_receivedTradeRequests.isNotEmpty)
          _buildTradeRequestsSection(),

        if (_receivedTradeRequests.isNotEmpty)
          const SizedBox(height: AppTheme.mediumGap),

        // Sectiunea pentru selectarea culorilor consultantului
        _buildColorSelectionSection(),

        const SizedBox(height: AppTheme.mediumGap),
      ],
    );
  }

  /// Construieste butonul multifunctional pentru actiuni cu culori
  Widget _buildColorActionButton(int colorIndex, bool isSelected, bool isTaken, String? takenBy) {
    // Verifica daca exista o cerere de trade pending pentru aceasta culoare
    final hasPendingTrade = _pendingTradeRequests[colorIndex] == true;

    // Culoarea este luata de alt consultant - buton pentru trade sau cancel
    if (isTaken && !isSelected) {
      return IconButton(
        icon: SvgPicture.asset(
          hasPendingTrade ? 'assets/close_outlined.svg' : 'assets/trade_outlined.svg',
          width: 20,
          height: 20,
          colorFilter: ColorFilter.mode(AppTheme.elementColor3, BlendMode.srcIn),
        ),
        onPressed: _isLoading ? null : (hasPendingTrade
          ? () => _cancelPendingTradeRequest(colorIndex)
          : () => _requestColorTrade(colorIndex, takenBy!)),
        padding: EdgeInsets.zero,
        constraints: BoxConstraints(),
        tooltip: hasPendingTrade ? 'Anuleaza cerere' : 'Cerere de schimb',
      );
    }

    // Culoarea este selectata - afisam iconita de selectat
    if (isSelected) {
      return IconButton(
        icon: SvgPicture.asset(
          'assets/checkbox_outlined.svg',
          width: 20,
          height: 20,
          colorFilter: ColorFilter.mode(AppTheme.elementColor3, BlendMode.srcIn),
        ),
        onPressed: null, // Nu permitem deselectare
        padding: EdgeInsets.zero,
        constraints: BoxConstraints(),
        tooltip: 'Culoare selectata',
      );
    }

    // Culoarea este disponibila - buton pentru selectare
    return IconButton(
      icon: SvgPicture.asset(
        'assets/box_outlined.svg',
        width: 20,
        height: 20,
        colorFilter: ColorFilter.mode(AppTheme.elementColor3, BlendMode.srcIn),
      ),
      onPressed: _isLoading ? null : () => _saveConsultantColor(colorIndex),
      padding: EdgeInsets.zero,
      constraints: BoxConstraints(),
      tooltip: 'Selecteaza',
    );
  }

  /// Trimite cerere de schimb pentru o culoare luata de alt consultant
  Future<void> _requestColorTrade(int colorIndex, String targetConsultantName) async {
    if (_isLoading) return;

    try {
      // Obtine ID-ul consultantului target
      final targetId = await _consultantService.getConsultantIdByName(targetConsultantName);
      if (targetId == null) {
        // Nu s-a putut identifica consultantul - mesajul se afiseaza in UI
        return;
      }

      final success = await _consultantService.sendTradeRequest(colorIndex, targetId, targetConsultantName);

      if (success && mounted) {
        // Reincarca trade requests trimise pentru a actualiza lista
        await _loadSentTradeRequests();
        debugPrint('🎨 SETTINGS: Trade request sent for color $colorIndex, marked as pending');
      }
    } catch (e) {
      debugPrint('❌ SETTINGS: Error requesting color trade: $e');
    }
  }

  /// Construieste sectiunea pentru selectarea culorilor consultantului
  Widget _buildColorSelectionSection() {
    return Container(
      width: double.infinity, // Fill pe orizontala
      padding: const EdgeInsets.all(8),
      decoration: AppTheme.widgetDecorationWithoutShadow,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header - același ca în widgetul "Astăzi"
          WidgetHeader1(
            title: 'Culoarea consultantului',
            titleColor: AppTheme.elementColor1,
          ),
          const SizedBox(height: 8),

          // Grid cu cele 10 culori - 2 rânduri, 5 câte 5
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5, // 5 culori pe rând
              crossAxisSpacing: AppTheme.smallGap,
              mainAxisSpacing: 8,
              mainAxisExtent: 144, // înălțime fixă de 144 pixeli
            ),
            itemCount: 10,
            itemBuilder: (context, index) {
              final colorIndex = index + 1;
              final isSelected = _selectedColorIndex == colorIndex;
              final color = AppTheme.getConsultantColor(colorIndex);
              final strokeColor = AppTheme.getConsultantStrokeColor(colorIndex);
              final takenBy = _colorAvailability[colorIndex];
              final isTaken = takenBy != null;
              final colorName = AppTheme.getConsultantColorName(colorIndex);
              final colorDescription = AppTheme.getConsultantColorDescription(colorIndex);

              return Container(
                width: double.infinity,
                height: 144,
                padding: const EdgeInsets.only(top: 4, left: 4, right: 4, bottom: 12),
                decoration: ShapeDecoration(
                  color: color,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 4,
                      color: strokeColor,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    // Header cu status si buton
                    SizedBox(
                      width: double.infinity,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Status text
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            decoration: ShapeDecoration(
                              color: strokeColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Text(
                              isTaken ? takenBy : 'Disponibila',
                              style: GoogleFonts.outfit(
                                color: const Color(0xFF666666), // light-blue-text-3
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          // Buton multifunctional
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: ShapeDecoration(
                              color: strokeColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: _buildColorActionButton(colorIndex, isSelected, isTaken, takenBy),
                          ),
                        ],
                      ),
                    ),

                    // Sectiunea cu nume si descriere
                    Expanded(
                      child: SizedBox(
                        width: double.infinity,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 8,
                          children: [
                            Text(
                              colorName,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                color: AppTheme.elementColor3,
                                fontSize: 19,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              colorDescription,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                color: AppTheme.elementColor2,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Construieste sectiunea pentru trade requests primite
  Widget _buildTradeRequestsSection() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.mediumGap),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor2,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        boxShadow: AppTheme.standardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titlu sectiune
          Text(
            'Cereri de schimb primite',
            style: TextStyle(
              fontSize: AppTheme.fontSizeMedium,
              fontWeight: FontWeight.w600,
              color: AppTheme.elementColor2,
            ),
          ),
          const SizedBox(height: AppTheme.smallGap),

          // Lista trade requests
          ..._receivedTradeRequests.map((tradeRequest) {
            final colorName = AppTheme.getConsultantColorName(tradeRequest.requestedColorIndex);

            return Container(
              margin: const EdgeInsets.only(bottom: AppTheme.smallGap),
              padding: const EdgeInsets.all(AppTheme.smallGap),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor3,
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Informatii despre trade request
                  Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: AppTheme.getConsultantColor(tradeRequest.requestedColorIndex),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: AppTheme.smallGap),
                      Expanded(
                        child: Text(
                          '${tradeRequest.requesterName} vrea să schimbe pentru $colorName',
                          style: TextStyle(
                            fontSize: AppTheme.fontSizeSmall,
                            color: AppTheme.elementColor2,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.smallGap),

                  // Butoane pentru accept/refuz
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _isLoading ? null : () => _rejectTradeRequest(tradeRequest.id),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          backgroundColor: Colors.red.withValues(alpha: 0.1),
                        ),
                        child: Text(
                          'Refuza',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: AppTheme.fontSizeSmall,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppTheme.smallGap),
                      TextButton(
                        onPressed: _isLoading ? null : () => _acceptTradeRequest(tradeRequest.id),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          backgroundColor: Colors.green.withValues(alpha: 0.1),
                        ),
                        child: Text(
                          'Accepta',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: AppTheme.fontSizeSmall,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
