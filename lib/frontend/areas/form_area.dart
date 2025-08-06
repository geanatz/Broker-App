import 'dart:async';
import 'package:flutter/material.dart';
import 'package:broker_app/app_theme.dart';
import 'package:broker_app/utils/smooth_scroll_behavior.dart';
import 'package:broker_app/backend/services/form_service.dart';
import 'package:broker_app/backend/services/splash_service.dart';
import 'package:broker_app/backend/services/sidebar_service.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:broker_app/backend/services/clients_service.dart';
import 'package:broker_app/frontend/components/forms/form1.dart';
import 'package:broker_app/frontend/components/forms/form3.dart';
import 'package:broker_app/frontend/components/forms/form_new.dart';
import 'package:broker_app/frontend/components/headers/widget_header2.dart';
import 'package:intl/intl.dart';
import '../../backend/services/app_logger.dart' as app_log;

/// Area pentru formulare care va fi afisata in cadrul ecranului principal.
/// Aceasta componenta inlocuieste vechiul FormScreen pastrand functionalitatea
/// dar fiind adaptata la noua structura a aplicatiei.
class FormArea extends StatefulWidget {
  /// Callback pentru navigarea la clients_pane
  final VoidCallback? onNavigateToClients;
  /// Indica daca clients_pane este vizibil
  final bool isClientsPaneVisible;
  
  const FormArea({
    super.key,
    this.onNavigateToClients,
    this.isClientsPaneVisible = false,
  });

  @override
  State<FormArea> createState() => _FormAreaState();
}

class _FormAreaState extends State<FormArea> {
  // Services
  late final FormService _formService;
  late final ClientUIService _clientService;
  
  // Text controllers pentru input fields
  final Map<String, TextEditingController> _textControllers = {};
  
  // ScrollController pentru smooth scrolling
  final ScrollController _creditScrollController = ScrollController();
  final ScrollController _incomeScrollController = ScrollController();
  
  // Debounce timer for saving controller values
  Timer? _saveTimer;
  
  // Store the GLOBAL tap position for the context menu
  Offset _globalTapPosition = Offset.zero;
  
  // Previous client for handling client changes
  ClientModel? _previousClient;

  // State for FormNew selections - separate for credit and income
  String? _newCreditFormSelectedBank;
  String? _newCreditFormSelectedType;
  String? _newIncomeFormSelectedBank;
  String? _newIncomeFormSelectedType;
  
  // TYPING GUARD: Track which controllers are currently being typed in
  final Set<String> _typingControllers = {};
  final Map<String, Timer> _typingTimers = {};
  
  // FIX: Removed debouncing for immediate response
  
  // OPTIMIZATION: Loading state for immediate feedback
  bool _isLoadingFormData = false;
  String? _loadingClientId;
  
  // OPTIMIZATION: Precision timing for performance profiling
  DateTime? _clientSelectionStartTime;

  // OPTIMIZATION: Flag to prevent redundant client change operations
  bool _isPerformingClientChange = false;

  // Debounce timer for client changes
  Timer? _clientChangeTimer;

  @override
  void initState() {
    super.initState();
    app_log.PerformanceMonitor.startTimer('formAreaInit');
    _initializeServices();
    app_log.PerformanceMonitor.endTimer('formAreaInit');
  }

  @override
  void dispose() {
    // Cleanup controllers
    _disposeControllers();
    
    // Cleanup timers
    _saveTimer?.cancel();
    _clientChangeTimer?.cancel();
    
    // Cleanup scroll controllers
    _creditScrollController.dispose();
    _incomeScrollController.dispose();
    
    // Remove listeners
    _clientService.removeListener(_onClientServiceChanged);
    _formService.removeListener(_onFormServiceChanged);
    
    super.dispose();
  }

  /// Initializeaza serviciile
  Future<void> _initializeServices() async {
    // Foloseste serviciile pre-incarcate din splash
    _formService = SplashService().formService;
    _clientService = SplashService().clientUIService;
    
    _formService.addListener(_onFormServiceChanged);
    _clientService.addListener(_onClientServiceChanged);
    _previousClient = _clientService.focusedClient;
    
    // FIX: Check if there's already a focused client at initialization
    final currentClient = _clientService.focusedClient;
    if (currentClient != null) {
      debugPrint('🔄 FORM: Found focused client at initialization: ${currentClient.phoneNumber}');
      await _loadFormDataForCurrentClient();
    } else {
      debugPrint('🔄 FORM: No focused client at initialization');
    }
  }

  /// Dispose all text controllers
  void _disposeControllers() {
    _textControllers.forEach((key, controller) {
      controller.dispose();
    });
    _textControllers.clear();
  }

  /// Clear controllers for specific client type and form type to prevent data sharing
  void _clearControllersForClientType(String clientPhone, String clientType, String formType) {
    final keysToRemove = <String>[];
    
    _textControllers.forEach((key, controller) {
      if (key.startsWith('${clientPhone}_${clientType}_${formType}_')) {
        keysToRemove.add(key);
      }
    });
    
    for (final key in keysToRemove) {
      _textControllers[key]?.dispose();
      _textControllers.remove(key);
    }
    
    // FIX: Also clear typing state for these controllers
    _typingControllers.removeWhere((key) => key.startsWith('${clientPhone}_${clientType}_${formType}_'));
    _typingTimers.removeWhere((key, timer) {
      if (key.startsWith('${clientPhone}_${clientType}_${formType}_')) {
        timer.cancel();
        return true;
      }
      return false;
    });
    
    debugPrint('🔧 FORM_AREA: Cleared ${keysToRemove.length} controllers for $clientPhone $clientType $formType');
  }

  /// Callback pentru schimbarile din FormService
  void _onFormServiceChanged() {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  /// Callback pentru schimbarile din ClientService
  void _onClientServiceChanged() {
    // FIX: Improved client change handling with debouncing
    _handleClientChange();
  }

  /// FIX: Ultra-fast client change handling with minimal debouncing
  void _handleClientChange() {
    try {
      final currentClient = _clientService.focusedClient;
      
      // FIX: Log focus state before processing
      _clientService.logFocusState('FORM_BEFORE_CHANGE');
      
      // OPTIMIZATION: Minimal debounce for ultra-fast response
      if (_clientChangeTimer?.isActive == true) {
        _clientChangeTimer!.cancel();
      }
      
      _clientChangeTimer = Timer(const Duration(milliseconds: 10), () {
        // OPTIMIZATION: Only process if client actually changed
        // FIX: Ignore temporary client updates (when phone number changes during editing)
        final isTemporaryClientUpdate = currentClient?.id.startsWith('temp_') == true && 
                                       _previousClient?.id.startsWith('temp_') == true &&
                                       _previousClient?.phoneNumber != currentClient?.phoneNumber;
        
        // FIX: Detect focus restoration from cache (when previous is null but current is not)
        final isFocusRestorationFromCache = _previousClient == null && currentClient != null;
        
        if (_previousClient?.phoneNumber != currentClient?.phoneNumber && !isTemporaryClientUpdate) {
          debugPrint('🔄 FORM: Client changed - Previous: ${_previousClient?.phoneNumber ?? 'none'}, Current: ${currentClient?.phoneNumber ?? 'none'}');
          _performClientChange(currentClient);
        } else if (isFocusRestorationFromCache) {
          debugPrint('🔄 FORM: Focus restored from cache - Current: ${currentClient.phoneNumber}');
          _performClientChange(currentClient);
        } else if (isTemporaryClientUpdate) {
          debugPrint('🔄 FORM: Temporary client update - ignoring form reset');
        }
      });
    } catch (e) {
      app_log.AppLogger.error('FORM', 'Error in client change', e);
    }
  }

  /// FIX: Improved client change execution with aggressive optimization
  Future<void> _performClientChange(ClientModel? currentClient) async {
    // OPTIMIZATION: Prevent redundant operations
    if (_isPerformingClientChange) {
      debugPrint('⚡ FORM: Skipping redundant client change operation');
      return;
    }
    
    try {
      _isPerformingClientChange = true;
      
      // FIX: Log focus state at start of client change
      _clientService.logFocusState('FORM_CLIENT_CHANGE_START');
      
      // OPTIMIZATION: Start precision timing
      _clientSelectionStartTime = DateTime.now();
      debugPrint('⚡ FORM: Processing client change - Previous: ${_previousClient?.phoneNumber ?? 'none'}, Current: ${currentClient?.phoneNumber ?? 'none'}');
      
      // OPTIMIZATION: Set loading state immediately for instant feedback
      if (mounted) {
        setState(() {
          _isLoadingFormData = true;
          _loadingClientId = currentClient?.phoneNumber;
        });
      }
      
      // OPTIMIZATION: Only save if client actually changed
      if (_previousClient != null && 
          _previousClient!.phoneNumber != currentClient?.phoneNumber &&
          !_previousClient!.id.startsWith('temp_')) {
        final clientStillExists = _clientService.clients.any(
          (client) => client.phoneNumber == _previousClient!.phoneNumber
        );
        
        if (clientStillExists) {
          debugPrint('⚡ FORM: Saving form data for previous client: ${_previousClient!.phoneNumber}');
          await _saveFormDataForClient(_previousClient!);
        } else {
          debugPrint('⚡ FORM: Previous client no longer exists, skipping save');
        }
      }
      
      // OPTIMIZATION: Only clear controllers if client actually changed
      if (_previousClient?.phoneNumber != currentClient?.phoneNumber) {
        debugPrint('⚡ FORM: Clearing controllers for client change');
        _disposeControllers();
        
        // FIX: Clear form data cache for previous client to prevent data persistence
        if (_previousClient != null) {
          _formService.clearFormDataCacheForClient(_previousClient!.phoneNumber);
          debugPrint('🔧 FORM_AREA: Cleared form data cache for previous client ${_previousClient!.phoneNumber}');
        }
        
        // FIX: Also clear typing state and timers for all controllers
        _typingControllers.clear();
        _typingTimers.forEach((key, timer) {
          timer.cancel();
        });
        _typingTimers.clear();
      }
      
      // OPTIMIZATION: Only load form data if client changed and is not temporary
      if (currentClient != null && 
          !currentClient.id.startsWith('temp_') &&
          _previousClient?.phoneNumber != currentClient.phoneNumber) {
        debugPrint('⚡ FORM: Loading form data for new client: ${currentClient.phoneNumber}');
        await _loadFormDataForCurrentClient();
      } else if (currentClient?.id.startsWith('temp_') == true) {
        debugPrint('⚡ FORM: Skipping form data load for temporary client');
      }
      
      // Update previous client reference
      _previousClient = currentClient;
      
      // FIX: Log focus state after client change
      _clientService.logFocusState('FORM_CLIENT_CHANGE_END');
      
      // OPTIMIZATION: Clear loading state and update UI
      if (mounted) {
        setState(() {
          _isLoadingFormData = false;
          _loadingClientId = null;
        });
        
        // OPTIMIZATION: Log total time from selection to render
        if (_clientSelectionStartTime != null) {
          final totalTime = DateTime.now().difference(_clientSelectionStartTime!).inMilliseconds;
          debugPrint('⚡ FORM: Total client selection time: ${totalTime}ms');
        }
      }
    } catch (e) {
      app_log.AppLogger.error('FORM', 'Error in client change', e);
      
      // OPTIMIZATION: Clear loading state on error
      if (mounted) {
        setState(() {
          _isLoadingFormData = false;
          _loadingClientId = null;
        });
      }
    } finally {
      _isPerformingClientChange = false;
    }
  }

  /// OPTIMIZATION: Advanced form rendering with strategic splash screens
  Future<void> _loadFormDataForCurrentClient() async {
    final currentClient = _clientService.focusedClient;
    if (currentClient == null || currentClient.id.startsWith('temp_')) {
      return;
    }
    
    try {

      
      app_log.PerformanceMonitor.startTimer('loadFormData');
      
      // OPTIMIZATION: Immediate form initialization with strategic splash
      if (!_formService.hasFormDataForClient(currentClient.phoneNumber)) {

        
        _formService.initializeEmptyFormsForClient(currentClient.phoneNumber);
        
        if (mounted) {
          setState(() {});
        }
        
        
      }
      
      // OPTIMIZATION: Strategic splash screen for perceived performance
      if (!_formService.hasCachedDataForClient(currentClient.phoneNumber)) {

        if (mounted) {
          setState(() {
            _isLoadingFormData = true;
            _loadingClientId = currentClient.phoneNumber;
          });
        }
      }
      
      // FIX: Force load form data with enhanced caching
      await _formService.loadFormDataForClient(
        currentClient.phoneNumber,
        currentClient.phoneNumber,
      );
      
      
      
      // FIX: Clear controllers to ensure fresh data loading
      _disposeControllers();
      
      // FIX: Force UI update after data loading
      if (mounted) {
        setState(() {
          _isLoadingFormData = false;
          _loadingClientId = null;
        });
      }
      
      app_log.PerformanceMonitor.endTimer('loadFormData');
    } catch (e) {
      app_log.AppLogger.error('FORM', 'Error loading form data', e);
      
      // OPTIMIZATION: Clear loading state on error
      if (mounted) {
        setState(() {
          _isLoadingFormData = false;
          _loadingClientId = null;
        });
      }
    }
  }

  /// Salveaza datele formularului pentru un client specific
  Future<void> _saveFormDataForClient(ClientModel client) async {
    await _formService.saveFormDataForClient(
      client.phoneNumber,
      client.phoneNumber,
      client.name,
    );
  }

  /// Store GLOBAL tap position
  void _getTapPosition(TapDownDetails details) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _globalTapPosition = details.globalPosition;
        });
      }
    });
  }

  /// Show context menu for form deletion
  void _showContextMenu(BuildContext context, int index, bool isCreditForm, bool isClient) async {
    final RenderObject? overlay = Overlay.of(context).context.findRenderObject();
    if (overlay == null) return;

    final String deleteLabel = isCreditForm ? 'Sterge credit' : 'Sterge venit';
    
    final result = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(_globalTapPosition.dx, _globalTapPosition.dy, 0, 0),
        Rect.fromLTWH(0, 0, overlay.paintBounds.size.width, overlay.paintBounds.size.height),
      ),
      items: [
        PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, color: AppTheme.elementColor1),
              const SizedBox(width: 8),
              Text(deleteLabel, style: TextStyle(color: AppTheme.elementColor1)),
            ],
          ),
        ),
      ],
    );

    if (result == 'delete') {
      final currentClient = _clientService.focusedClient;
      if (currentClient != null) {
        // FIX: Clear controllers for the deleted form to prevent data persistence
        final clientType = isClient ? 'client' : 'coborrower';
        final formType = isCreditForm ? 'credit' : 'income';
        
        // FIX: Clear all controllers for this client and form type to prevent data persistence
        _clearControllersForClientType(currentClient.phoneNumber, clientType, formType);
        
        // FIX: Also clear any remaining controllers that might have old data
        final keysToRemove = <String>[];
        _textControllers.forEach((key, controller) {
          if (key.contains('${currentClient.phoneNumber}_${clientType}_$formType')) {
            keysToRemove.add(key);
          }
        });
        
        for (final key in keysToRemove) {
          _textControllers[key]?.dispose();
          _textControllers.remove(key);
        }
        
        debugPrint('🔧 FORM_AREA: Cleared controllers for client ${currentClient.phoneNumber}, type $clientType, form $formType after deletion');
        
        if (isCreditForm) {
          _formService.removeCreditForm(currentClient.phoneNumber, index, isClient: isClient);
        } else {
          _formService.removeIncomeForm(currentClient.phoneNumber, index, isClient: isClient);
        }
      }
    }
  }

  /// Extrage doar valoarea numerica din campurile care pot contine "luni"
  String _extractNumericValue(String value, String fieldType) {
    // Pentru campurile perioada si vechime, returnam valoarea exact cum este
    // pentru a permite formatul ani/luni (ex: 1/4, 2/7, 5/2)
    if (fieldType == 'perioada' || fieldType == 'vechime') {
      return value;
    }
    // Pentru toate celelalte campuri, returneaza valoarea exact cum este
    // pentru a nu interfera cu transformarea K si formatarea cu virgule
    return value;
  }

  /// Obtine controller-ul pentru un field specific
  TextEditingController _getController(String key) {
    if (!_textControllers.containsKey(key)) {
      _textControllers[key] = TextEditingController();
    }
    return _textControllers[key]!;
  }

  /// Formateaza o valoare numerica cu virgule pentru afisare
  String _formatValueForDisplay(String value, String fieldType) {
    // Aplica formatarea cu virgule doar pentru campurile numerice
    if (fieldType == 'sold' || fieldType == 'rata' || fieldType == 'consumat' || fieldType == 'incomeAmount') {
      if (value.isNotEmpty && value != '0') {
        try {
          // Remove existing commas if any
          final cleanValue = value.replaceAll(',', '');
          
          // Parse as integer and format with commas
          final numericValue = int.tryParse(cleanValue);
          if (numericValue != null && numericValue > 0) {
            // Format with commas using NumberFormat
            final formatter = NumberFormat('#,###');
            return formatter.format(numericValue);
          }
        } catch (e) {
          app_log.AppLogger.error('FORM', 'Error formatting value for display', e);
        }
      }
    }
    
    // For non-numeric fields or invalid values, return as-is
    return value;
  }

  /// Seteaza textul controller-ului doar daca este necesar
  /// Aceasta previne suprascrierea valorilor introduse de utilizator
  TextEditingController _getControllerWithText(String key, String modelValue) {
    final controller = _getController(key);
    
    // Extrage tipul de camp din key pentru a determina daca trebuie sa extracem doar valoarea numerica
    // New format: phoneNumber_clientType_formType_index_field
    final parts = key.split('_');
    final fieldType = parts.length >= 5 ? parts[4] : '';
    final cleanValue = _extractNumericValue(modelValue, fieldType);
    
    // FIX: Clear controller if it has old data and model value is empty
    // But only if user is not currently typing to prevent interference
    if (controller.text.isNotEmpty && cleanValue.isEmpty && !_typingControllers.contains(key)) {
      controller.clear();
      debugPrint('🔧 FORM_AREA: Cleared controller $key with old data');
    }
    
    // TYPING GUARD: Don't update controller if user is currently typing
    if (_typingControllers.contains(key)) {
      return controller;
    }
    
    // Check if we should update the controller
    // For numeric fields, compare the numeric values (without commas) to avoid formatting conflicts
    if (cleanValue.isNotEmpty) {
      if (fieldType == 'sold' || fieldType == 'rata' || fieldType == 'consumat' || fieldType == 'incomeAmount') {
        // For numeric fields, compare values without commas
        final controllerNumericValue = controller.text.replaceAll(',', '');
        if (controller.text.isEmpty) {
          // Controller is empty, set initial value with proper formatting
          final formattedValue = _formatValueForDisplay(cleanValue, fieldType);
          controller.text = formattedValue;
        } else if (controllerNumericValue != cleanValue && cleanValue != '0') {
          // Only update if the numeric values are actually different and not just placeholder
          final formattedValue = _formatValueForDisplay(cleanValue, fieldType);
          controller.text = formattedValue;
        }
        // Don't update if only formatting differs (e.g., "12000" vs "12,000")
      } else {
        // For non-numeric fields, use exact comparison
        if (controller.text.isEmpty) {
          controller.text = cleanValue;
        } else if (controller.text != cleanValue && cleanValue != '0') {
          controller.text = cleanValue;
        }
      }
    }
    
    // Adauga listener pentru a salva modificarile automat
    controller.addListener(() {
      _saveControllerValueToModel(key, controller.text);
    });
    
    return controller;
  }

  /// Salveaza valoarea din controller inapoi in model
  void _saveControllerValueToModel(String key, String value) {
    // Parse key to extract field type for logging
    key.split('_');
    
    // TYPING GUARD: Set typing state when user starts typing
    _typingControllers.add(key);
    
    // Clear typing state after a delay (longer than the save timer)
    _typingTimers[key]?.cancel();
    _typingTimers[key] = Timer(Duration(milliseconds: 500), () {
      _typingControllers.remove(key);
      _typingTimers.remove(key);
    });
    
    // Cancel the previous timer if it exists
    _saveTimer?.cancel();
    
    // Set a shorter timer to save after a brief delay (reduced from 500ms to 200ms)
    _saveTimer = Timer(Duration(milliseconds: 200), () {
      // Parse key to extract client, client type, form type, index, and field
      // New format: phoneNumber_clientType_formType_index_field
      final parts = key.split('_');
      if (parts.length >= 5) {
        final clientPhone = parts[0];
        final clientType = parts[1]; // 'client' or 'coborrower'
        final formType = parts[2]; // 'credit' or 'income'
        final indexStr = parts[3];
        final field = parts[4];
        
        final index = int.tryParse(indexStr);
        if (index != null) {
          final client = _clientService.focusedClient;
          if (client != null && client.phoneNumber == clientPhone) {
            final isCreditForm = formType == 'credit';
            final isClient = clientType == 'client';
            
            if (mounted) {
                              // Process value based on field type
                String cleanValue = value;
                if (field == 'sold' || field == 'rata' || field == 'consumat' || field == 'incomeAmount') {
                  // Remove commas for numeric fields
                  cleanValue = value.replaceAll(',', '');
              } else if (field == 'perioada' || field == 'vechime') {
                // Keep original format for period and seniority fields (allows "year/month" format)
                cleanValue = value;
              }
              
              // Check if the value actually changed before saving
              bool shouldSave = false;
              
              if (isCreditForm) {
                final forms = isClient 
                    ? _formService.getClientCreditForms(clientPhone)
                    : _formService.getCoborrowerCreditForms(clientPhone);
                
                if (index < forms.length) {
                  final currentValue = _getCurrentFieldValue(forms[index], field, true);
                  shouldSave = currentValue != cleanValue;
                }
              } else {
                final forms = isClient 
                    ? _formService.getClientIncomeForms(clientPhone)
                    : _formService.getCoborrowerIncomeForms(clientPhone);
                
                if (index < forms.length) {
                  final currentValue = _getCurrentFieldValue(forms[index], field, false);
                  shouldSave = currentValue != cleanValue;
                }
              }
              
              if (shouldSave) {
                _updateFormField(client, index, field, cleanValue, isCreditForm, isClient);
                
                // Automatically save to Firebase after updating the form field
                _autoSaveToFirebase(client);
              }
            }
          }
        }
      }
    });
  }

  /// Helper method to get current field value from a form model
  String _getCurrentFieldValue(dynamic form, String field, bool isCreditForm) {
    if (isCreditForm) {
      final creditForm = form as CreditFormModel;
      switch (field) {
        case 'bank': return creditForm.bank;
        case 'creditType': return creditForm.creditType;
        case 'sold': return creditForm.sold;
        case 'rata': return creditForm.rata;
        case 'consumat': return creditForm.consumat;
        case 'rateType': return creditForm.rateType;
        case 'perioada': return creditForm.perioada;
        default: return '';
      }
    } else {
      final incomeForm = form as IncomeFormModel;
      switch (field) {
        case 'bank': return incomeForm.bank;
        case 'incomeType': return incomeForm.incomeType;
        case 'incomeAmount': return incomeForm.incomeAmount;
        case 'vechime': return incomeForm.vechime;
        default: return '';
      }
    }
  }

  /// Automatically saves form data to Firebase for the given client
  Future<void> _autoSaveToFirebase(ClientModel client) async {
    try {
      final success = await _formService.saveFormDataForClient(
        client.phoneNumber,
        client.phoneNumber,
        client.name,
      );
      
      if (!success) {
        app_log.AppLogger.error('FORM', 'Failed to auto-save form data', null);
      }
    } catch (e) {
      app_log.AppLogger.error('FORM', 'Error auto-saving form data', e);
    }
  }

  /// FIX: Force refresh form data for current client
  Future<void> forceRefreshFormData() async {
    final currentClient = _clientService.focusedClient;
    if (currentClient != null && !currentClient.id.startsWith('temp_')) {
      await _formService.forceRefreshFormData(
        currentClient.phoneNumber,
        currentClient.phoneNumber,
      );
      
      // Clear controllers to force fresh data loading
      _disposeControllers();
      
      // Force UI update
      if (mounted) {
        setState(() {});
      }
    }
  }

  /// FIX: Ensure form area reflects current focus state
  void _ensureFocusStateConsistency() {
    final currentFocusedClient = _clientService.focusedClient;
    
    
    if (currentFocusedClient != null) {
      // Validate that the focused client is properly set in the list
      final focusedInList = _clientService.clients.any((client) => 
          client.phoneNumber == currentFocusedClient.phoneNumber && 
          client.status == ClientStatus.focused);
      
      if (!focusedInList) {

        _clientService.fixFocusStateInconsistencies();
      }
    }
    
    
  }

  @override
  Widget build(BuildContext context) {
    // FIX: Log focus state during build
    _clientService.logFocusState('FORM_BUILD');
    
    // FIX: Ensure focus consistency when area is shown
    _ensureFocusStateConsistency();
    
    final focusedClient = _clientService.focusedClient;
    
    // FIX: Better handling of empty states
    if (focusedClient == null) {
      return _buildNoClientSelectedPlaceholder();
    }
    
    // FIX: Better handling of temporary clients
    if (focusedClient.id.startsWith('temp_')) {
      return _buildTemporaryClientPlaceholder(focusedClient);
    }
    
    // OPTIMIZATION: Show loading state only for very brief periods
    if (_isLoadingFormData && _loadingClientId == focusedClient.phoneNumber) {
      return _buildOptimizedLoadingPlaceholder(focusedClient);
    }
    
    // OPTIMIZATION: Always show form content - data will load in background
    return _buildFormContent(focusedClient);
  }

  /// OPTIMIZATION: Advanced form rendering with performance profiling
  Widget _buildFormContent(ClientModel client) {
    
    
    final focusedClient = _clientService.focusedClient;
    
    // Daca nu exista client focusat, afiseaza un placeholder
    if (focusedClient == null) {
      return _buildNoClientSelectedPlaceholder();
    }
    
    // Daca este un client temporar, afiseaza un placeholder special
    if (focusedClient.id.startsWith('temp_')) {
      return _buildTemporaryClientPlaceholder(focusedClient);
    }
    
    // OPTIMIZATION: Check form data availability for strategic rendering
    _formService.hasFormDataForClient(client.phoneNumber);
    _formService.hasCachedDataForClient(client.phoneNumber);
    
    
    
    // Afiseaza formularele pentru client conform design-ului exact din Figma
    final formContent = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: _buildCreditSection(client),
        ),
        const SizedBox(width: AppTheme.mediumGap),
        Expanded(
          child: _buildIncomeSection(client),
        ),
      ],
    );
    
    
    
    return formContent;
  }

  /// Construieste placeholder-ul pentru client temporar
  Widget _buildTemporaryClientPlaceholder(ClientModel client) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(AppTheme.largeGap),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: AppTheme.popupBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
        ),
        shadows: [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 15,
            offset: Offset(0, 0),
            spreadRadius: 0,
          )
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/addIcon.svg',
              width: 64,
              height: 64,
              colorFilter: ColorFilter.mode(
                AppTheme.elementColor2,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: AppTheme.mediumGap),
            Text(
              'Client nou',
              style: TextStyle(
                fontSize: AppTheme.fontSizeLarge,
                fontWeight: FontWeight.w600,
                color: AppTheme.elementColor2,
              ),
            ),
            const SizedBox(height: AppTheme.smallGap),
            Text(
              'Completeaza datele clientului in popup-ul de clienti',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppTheme.fontSizeMedium,
                color: AppTheme.elementColor1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construieste placeholder-ul cand nu exista client selectat
  Widget _buildNoClientSelectedPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(AppTheme.largeGap),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: AppTheme.popupBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
        ),
        shadows: [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 15,
            offset: Offset(0, 0),
            spreadRadius: 0,
          )
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/userIcon.svg',
              width: 64,
              height: 64,
              colorFilter: ColorFilter.mode(
                AppTheme.elementColor2,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: AppTheme.mediumGap),
            Text(
              'Niciun client selectat',
              style: TextStyle(
                fontSize: AppTheme.fontSizeLarge,
                fontWeight: FontWeight.w600,
                color: AppTheme.elementColor2,
              ),
            ),
            const SizedBox(height: AppTheme.smallGap),
            Text(
              'Selectati un client din panoul de clienti pentru a vedea formularul clientului',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppTheme.fontSizeMedium,
                color: AppTheme.elementColor1,
              ),
            ),
            if (!widget.isClientsPaneVisible) ...[
              const SizedBox(height: AppTheme.mediumGap),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    // Navighează la clients_pane
                    widget.onNavigateToClients?.call();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.containerColor1,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Vezi clienti',
                      style: AppTheme.safeOutfit(
                        color: AppTheme.elementColor2,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }


  /// OPTIMIZATION: Build optimized loading placeholder with refined splash screen
  Widget _buildOptimizedLoadingPlaceholder(ClientModel client) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(AppTheme.largeGap),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: AppTheme.popupBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
        ),
        shadows: [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 15,
            offset: Offset(0, 0),
            spreadRadius: 0,
          )
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // OPTIMIZATION: Animated loading indicator for better perceived performance
            SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.elementColor1),
              ),
            ),
            const SizedBox(height: AppTheme.mediumGap),
            Text(
              'Se incarca formularul...',
              style: TextStyle(
                fontSize: AppTheme.fontSizeLarge,
                fontWeight: FontWeight.w600,
                color: AppTheme.elementColor2,
              ),
            ),
            const SizedBox(height: AppTheme.smallGap),
            Text(
              'Client: ${client.name}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppTheme.fontSizeMedium,
                color: AppTheme.elementColor1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construieste sectiunea pentru credite conform design-ului exact din formArea.md
  Widget _buildCreditSection(ClientModel client) {
    final isShowingClient = _formService.isShowingClientLoanForm(client.phoneNumber);
    final forms = isShowingClient 
        ? _formService.getClientCreditForms(client.phoneNumber)
        : _formService.getCoborrowerCreditForms(client.phoneNumber);

    return Container(
      height: double.infinity,
      padding: const EdgeInsets.all(8),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: AppTheme.popupBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
        ),
        shadows: [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 15,
            offset: Offset(0, 0),
            spreadRadius: 0,
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header cu toggle conform design-ului
          WidgetHeader2(
            title: 'Credit',
            altText: isShowingClient ? 'Vezi codebitor' : 'Vezi client',
            onAltTextTap: () {
              debugPrint('🔄 FORM: Credit toggle button pressed');
              debugPrint('🔄 FORM: Current isShowingClient: $isShowingClient');
              debugPrint('🔄 FORM: Client phone: ${client.phoneNumber}');
              
              // Clear controllers for the current view before switching
              final newClientType = isShowingClient ? 'coborrower' : 'client';
              debugPrint('🔄 FORM: Clearing controllers for clientType: $newClientType');
              _clearControllersForClientType(client.phoneNumber, newClientType, 'credit');
              
              debugPrint('🔄 FORM: Calling toggleLoanFormType for: ${client.phoneNumber}');
              _formService.toggleLoanFormType(client.phoneNumber);
              debugPrint('🔄 FORM: toggleLoanFormType completed');
            },
          ),
          
          const SizedBox(height: 8),
          
          // Lista de formulare de credit
          Expanded(
            child: _buildCreditFormsList(client, forms, isShowingClient),
          ),
        ],
      ),
    );
  }

  /// Construieste sectiunea pentru venituri conform design-ului exact din formArea.md
  Widget _buildIncomeSection(ClientModel client) {
    final isShowingClient = _formService.isShowingClientIncomeForm(client.phoneNumber);
    final forms = isShowingClient 
        ? _formService.getClientIncomeForms(client.phoneNumber)
        : _formService.getCoborrowerIncomeForms(client.phoneNumber);

    return Container(
      height: double.infinity,
      padding: const EdgeInsets.all(8),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: AppTheme.popupBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
        ),
        shadows: [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 15,
            offset: Offset(0, 0),
            spreadRadius: 0,
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header cu toggle conform design-ului
          WidgetHeader2(
            title: 'Venit',
            altText: isShowingClient ? 'Vezi codebitor' : 'Vezi client',
            onAltTextTap: () {
              debugPrint('🔄 FORM: Income toggle button pressed');
              debugPrint('🔄 FORM: Current isShowingClient: $isShowingClient');
              debugPrint('🔄 FORM: Client phone: ${client.phoneNumber}');
              
              // Clear controllers for the current view before switching
              final newClientType = isShowingClient ? 'coborrower' : 'client';
              debugPrint('🔄 FORM: Clearing controllers for clientType: $newClientType');
              _clearControllersForClientType(client.phoneNumber, newClientType, 'income');
              
              debugPrint('🔄 FORM: Calling toggleIncomeFormType for: ${client.phoneNumber}');
              _formService.toggleIncomeFormType(client.phoneNumber);
              debugPrint('🔄 FORM: toggleIncomeFormType completed');
            },
          ),
          
          const SizedBox(height: 8),
          
          // Lista de formulare de venit
          Expanded(
            child: _buildIncomeFormsList(client, forms, isShowingClient),
          ),
        ],
      ),
    );
  }

  /// Construieste lista de formulare de credit folosind componentele specificate
  Widget _buildCreditFormsList(ClientModel client, List<CreditFormModel> forms, bool isClient) {
    
    // Filtreaza doar formularele care au date (nu sunt goale)
    final nonEmptyForms = forms.where((form) => !form.isEmpty).toList();
    
    // Pregateste toate widget-urile pentru lista
    final List<Widget> allWidgets = [
      // Formulare existente (doar cele cu date)
      ...nonEmptyForms.asMap().entries.map((entry) {
        final form = entry.value;
        // Gaseste indexul real in lista originala
        final realIndex = forms.indexOf(form);
        
        return GestureDetector(
          onTapDown: _getTapPosition,
          onLongPress: () => _showContextMenu(context, realIndex, true, isClient),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: _buildCreditForm(client, form, realIndex, isClient),
          ),
        );
      }),
      
      // Formular nou (FormNew) pentru adaugare - intotdeauna afisat
      FormNew(
        key: ValueKey('credit_form_new_${_newCreditFormSelectedBank}_$_newCreditFormSelectedType'),
        titleF1: 'Banca',
        valueF1: _newCreditFormSelectedBank,
        itemsF1: FormService.creditBanks.map((bank) => DropdownMenuItem<String>(
          value: bank,
          child: Text(bank),
        )).toList(),
        onChangedF1: (value) {
          setState(() {
            _newCreditFormSelectedBank = value;
            debugPrint('DEBUG: Credit bank selected: $value');
          });
          // Check if both fields are completed and transform if needed
          if (value != null && _newCreditFormSelectedType != null) {
            debugPrint('DEBUG: Both credit fields completed, transforming...');
            Future.microtask(() {
              _transformCreditFormNew(client, value, _newCreditFormSelectedType!, isClient);
            });
          }
        },
        hintTextF1: 'Selecteaza',
        
        titleF2: 'Tip credit',
        valueF2: _newCreditFormSelectedType,
        itemsF2: FormService.creditTypes.map((type) => DropdownMenuItem<String>(
          value: type,
          child: Text(type),
        )).toList(),
        onChangedF2: (value) {
          setState(() {
            _newCreditFormSelectedType = value;
            debugPrint('DEBUG: Credit type selected: $value');
          });
          // Check if both fields are completed and transform if needed
          if (value != null && _newCreditFormSelectedBank != null) {
            debugPrint('DEBUG: Both credit fields completed, transforming...');
            Future.microtask(() {
              _transformCreditFormNew(client, _newCreditFormSelectedBank!, value, isClient);
            });
          }
        },
        hintTextF2: 'Selecteaza',
      ),
    ];
    
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      child: SmoothScrollWrapper(
        controller: _creditScrollController,
        scrollSpeed: 100.0,
        animationDuration: const Duration(milliseconds: 250),
        child: ListView(
          controller: _creditScrollController,
          physics: const NeverScrollableScrollPhysics(),
          children: allWidgets,
        ),
      ),
    );
  }

  /// Construieste lista de formulare de venit folosind componentele specificate
  Widget _buildIncomeFormsList(ClientModel client, List<IncomeFormModel> forms, bool isClient) {
    
    // Filtreaza doar formularele care au date (nu sunt goale)
    final nonEmptyForms = forms.where((form) => !form.isEmpty).toList();
    
    // Pregateste toate widget-urile pentru lista
    final List<Widget> allWidgets = [
      // Formulare existente (doar cele cu date)
      ...nonEmptyForms.asMap().entries.map((entry) {
        final form = entry.value;
        // Gaseste indexul real in lista originala
        final realIndex = forms.indexOf(form);
        
        return GestureDetector(
          onTapDown: _getTapPosition,
          onLongPress: () => _showContextMenu(context, realIndex, false, isClient),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: _buildIncomeForm(client, form, realIndex, isClient),
          ),
        );
      }),
      
      // Formular nou (FormNew) pentru adaugare - intotdeauna afisat
      FormNew(
        key: ValueKey('income_form_new_${_newIncomeFormSelectedBank}_$_newIncomeFormSelectedType'),
        titleF1: 'Banca',
        valueF1: _newIncomeFormSelectedBank,
        itemsF1: FormService.incomeBanks.map((bank) => DropdownMenuItem<String>(
          value: bank,
          child: Text(bank),
        )).toList(),
        onChangedF1: (value) {
          setState(() {
            _newIncomeFormSelectedBank = value;
            debugPrint('DEBUG: Income bank selected: $value');
          });
          // Check if both fields are completed and transform if needed
          if (value != null && _newIncomeFormSelectedType != null) {
            debugPrint('DEBUG: Both income fields completed, transforming...');
            Future.microtask(() {
              _transformIncomeFormNew(client, value, _newIncomeFormSelectedType!, isClient);
            });
          }
        },
        hintTextF1: 'Selecteaza',
        
        titleF2: 'Tip venit',
        valueF2: _newIncomeFormSelectedType,
        itemsF2: FormService.incomeTypes.map((type) => DropdownMenuItem<String>(
          value: type,
          child: Text(type),
        )).toList(),
        onChangedF2: (value) {
          setState(() {
            _newIncomeFormSelectedType = value;
            debugPrint('DEBUG: Income type selected: $value');
          });
          // Check if both fields are completed and transform if needed
          if (value != null && _newIncomeFormSelectedBank != null) {
            debugPrint('DEBUG: Both income fields completed, transforming...');
            Future.microtask(() {
              _transformIncomeFormNew(client, _newIncomeFormSelectedBank!, value, isClient);
            });
          }
        },
        hintTextF2: 'Selecteaza',
      ),
    ];
    
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      child: SmoothScrollWrapper(
        controller: _incomeScrollController,
        scrollSpeed: 100.0,
        animationDuration: const Duration(milliseconds: 250),
        child: ListView(
          controller: _incomeScrollController,
          physics: const NeverScrollableScrollPhysics(),
          children: allWidgets,
        ),
      ),
    );
  }

  /// Construieste un formular de credit individual folosind componentele specificate
  Widget _buildCreditForm(ClientModel client, CreditFormModel form, int index, bool isClient) {
    // Determina ce tipuri de campuri sa afiseze in functie de tipul de credit
    final showConsumat = form.creditType == 'Card cumparaturi' || form.creditType == 'Overdraft';
    final showSoldRata = form.creditType == 'Nevoi personale';
    final showIpotecarFields = form.creditType == 'Ipotecar' || form.creditType == 'Prima casa';

    if (showIpotecarFields) {
      // Foloseste Form3 pentru Ipotecar si Prima casa (2+4 campuri: Banca, Tip credit in primul rand; Sold, Rata, Perioada, Tip Rata in al doilea rand)
      return Form3(
        titleR1F1: 'Banca',
        valueR1F1: (form.bank.isEmpty || form.bank == 'Selecteaza' || form.bank == 'Selecteaza banca') ? null : form.bank,
        itemsR1F1: FormService.creditBanks.map((bank) => DropdownMenuItem<String>(
          value: bank,
          child: Text(bank),
        )).toList(),
        onChangedR1F1: (value) {
          if (value != null) {
            _updateFormField(client, index, 'bank', value, true, isClient);
          }
        },
        hintTextR1F1: 'Selecteaza',
        
        titleR1F2: 'Tip credit',
        valueR1F2: (form.creditType.isEmpty || form.creditType == 'Selecteaza' || form.creditType == 'Selecteaza tipul') ? null : form.creditType,
        itemsR1F2: FormService.creditTypes.map((type) => DropdownMenuItem<String>(
          value: type,
          child: Text(type),
        )).toList(),
        onChangedR1F2: (value) {
          if (value != null) {
            _updateFormField(client, index, 'creditType', value, true, isClient);
          }
        },
        hintTextR1F2: 'Selecteaza',
        
        titleR2F1: 'Sold',
        controllerR2F1: _getControllerWithText('${client.phoneNumber}_${isClient ? 'client' : 'coborrower'}_credit_${index}_sold', form.sold),
        hintTextR2F1: '0',
        keyboardTypeR2F1: TextInputType.number,
        
        titleR2F2: 'Rata',
        controllerR2F2: _getControllerWithText('${client.phoneNumber}_${isClient ? 'client' : 'coborrower'}_credit_${index}_rata', form.rata),
        hintTextR2F2: '0',
        keyboardTypeR2F2: TextInputType.number,
        
        titleR2F3: 'Perioada',
        controllerR2F3: _getControllerWithText('${client.phoneNumber}_${isClient ? 'client' : 'coborrower'}_credit_${index}_perioada', form.perioada),
        hintTextR2F3: '0/0',
        keyboardTypeR2F3: TextInputType.text,
        suffixTextColorR2F3: AppTheme.elementColor2,
        
        titleR2F4: 'Tip rata',
        valueR2F4: (form.rateType.isEmpty || form.rateType == 'Selecteaza' || form.rateType == 'Selecteaza tipul') ? null : form.rateType,
        itemsR2F4: ['IRCC', 'Euribor', 'Variabila', 'Fixa'].map((type) => DropdownMenuItem<String>(
          value: type,
          child: Text(type),
        )).toList(),
        onChangedR2F4: (value) {
          if (value != null) {
            _updateFormField(client, index, 'rateType', value, true, isClient);
          }
        },
        hintTextR2F4: 'Selecteaza',
        
        onClose: () => _formService.removeCreditForm(client.phoneNumber, index, isClient: isClient),
      );
    } else if (showSoldRata) {
      // Foloseste Form1 pentru Nevoi personale (4 campuri: Sold si Rata)
      return Form1(
        titleR1F1: 'Banca',
        valueR1F1: (form.bank.isEmpty || form.bank == 'Selecteaza' || form.bank == 'Selecteaza banca') ? null : form.bank,
        itemsR1F1: FormService.creditBanks.map((bank) => DropdownMenuItem<String>(
          value: bank,
          child: Text(bank),
        )).toList(),
        onChangedR1F1: (value) {
          if (value != null) {
            _updateFormField(client, index, 'bank', value, true, isClient);
          }
        },
        hintTextR1F1: 'Selecteaza',
        
        titleR1F2: 'Tip credit',
        valueR1F2: (form.creditType.isEmpty || form.creditType == 'Selecteaza' || form.creditType == 'Selecteaza tipul') ? null : form.creditType,
        itemsR1F2: FormService.creditTypes.map((type) => DropdownMenuItem<String>(
          value: type,
          child: Text(type),
        )).toList(),
        onChangedR1F2: (value) {
          if (value != null) {
            _updateFormField(client, index, 'creditType', value, true, isClient);
          }
        },
        hintTextR1F2: 'Selecteaza',
        
        titleR2F1: 'Sold',
        controllerR2F1: _getControllerWithText('${client.phoneNumber}_${isClient ? 'client' : 'coborrower'}_credit_${index}_sold', form.sold),
        hintTextR2F1: '0',
        keyboardTypeR2F1: TextInputType.number,
        
        titleR2F2: 'Rata',
        controllerR2F2: _getControllerWithText('${client.phoneNumber}_${isClient ? 'client' : 'coborrower'}_credit_${index}_rata', form.rata),
        hintTextR2F2: '0',
        keyboardTypeR2F2: TextInputType.number,
        
        onClose: () => _formService.removeCreditForm(client.phoneNumber, index, isClient: isClient),
      );
    } else {
      // Foloseste Form1 pentru Card cumparaturi si Overdraft (4 campuri)
      return Form1(
        titleR1F1: 'Banca',
        valueR1F1: (form.bank.isEmpty || form.bank == 'Selecteaza' || form.bank == 'Selecteaza banca') ? null : form.bank,
        itemsR1F1: FormService.creditBanks.map((bank) => DropdownMenuItem<String>(
          value: bank,
          child: Text(bank),
        )).toList(),
        onChangedR1F1: (value) {
          if (value != null) {
            _updateFormField(client, index, 'bank', value, true, isClient);
          }
        },
        hintTextR1F1: 'Selecteaza',
        
        titleR1F2: 'Tip credit',
        valueR1F2: (form.creditType.isEmpty || form.creditType == 'Selecteaza' || form.creditType == 'Selecteaza tipul') ? null : form.creditType,
        itemsR1F2: FormService.creditTypes.map((type) => DropdownMenuItem<String>(
          value: type,
          child: Text(type),
        )).toList(),
        onChangedR1F2: (value) {
          if (value != null) {
            _updateFormField(client, index, 'creditType', value, true, isClient);
          }
        },
        hintTextR1F2: 'Selecteaza',
        
        titleR2F1: showConsumat ? 'Plafon' : 'Sold',
        controllerR2F1: _getControllerWithText('${client.phoneNumber}_${isClient ? 'client' : 'coborrower'}_credit_${index}_sold', form.sold),
        hintTextR2F1: '0',
        keyboardTypeR2F1: TextInputType.number,
        
        titleR2F2: showConsumat ? 'Consumat' : 'Rata',
        controllerR2F2: _getControllerWithText('${client.phoneNumber}_${isClient ? 'client' : 'coborrower'}_credit_${index}_${showConsumat ? 'consumat' : 'rata'}', showConsumat ? form.consumat : form.rata),
        hintTextR2F2: showConsumat ? '0' : '0',
        keyboardTypeR2F2: TextInputType.number,
        
        onClose: () => _formService.removeCreditForm(client.phoneNumber, index, isClient: isClient),
      );
    }
  }

  /// Construieste un formular de venit individual folosind componentele specificate
  Widget _buildIncomeForm(ClientModel client, IncomeFormModel form, int index, bool isClient) {
    // Foloseste Form1 pentru venituri (4 campuri: 2x2)
    return Form1(
      titleR1F1: 'Banca',
      valueR1F1: (form.bank.isEmpty || form.bank == 'Selecteaza' || form.bank == 'Selecteaza banca') ? null : form.bank,
      itemsR1F1: FormService.incomeBanks.map((bank) => DropdownMenuItem<String>(
        value: bank,
        child: Text(bank),
      )).toList(),
      onChangedR1F1: (value) {
        if (value != null) {
          _updateFormField(client, index, 'bank', value, false, isClient);
        }
      },
      hintTextR1F1: 'Selecteaza',
      
      titleR1F2: 'Tip venit',
      valueR1F2: (form.incomeType.isEmpty || form.incomeType == 'Selecteaza' || form.incomeType == 'Selecteaza tipul') ? null : form.incomeType,
      itemsR1F2: FormService.incomeTypes.map((type) => DropdownMenuItem<String>(
        value: type,
        child: Text(type),
      )).toList(),
      onChangedR1F2: (value) {
        if (value != null) {
          _updateFormField(client, index, 'incomeType', value, false, isClient);
        }
      },
      hintTextR1F2: 'Selecteaza',
      
      titleR2F1: 'Suma venit',
      controllerR2F1: _getControllerWithText('${client.phoneNumber}_${isClient ? 'client' : 'coborrower'}_income_${index}_incomeAmount', form.incomeAmount),
      hintTextR2F1: '0',
      keyboardTypeR2F1: TextInputType.number,
      
      titleR2F2: 'Vechime',
      controllerR2F2: _getControllerWithText('${client.phoneNumber}_${isClient ? 'client' : 'coborrower'}_income_${index}_vechime', form.vechime),
      hintTextR2F2: '0/0',
      keyboardTypeR2F2: TextInputType.text,
      
      onClose: () => _formService.removeIncomeForm(client.phoneNumber, index, isClient: isClient),
    );
  }

  /// Reset credit form selections
  void _resetCreditFormSelections() {
    debugPrint('DEBUG: Resetting credit form selections');
    if (mounted) {
      setState(() {
        _newCreditFormSelectedBank = null;
        _newCreditFormSelectedType = null;
        debugPrint('DEBUG: Credit selections reset to null');
      });
    }
    
    // FIX: Also clear any remaining controllers that might have old data
    final currentClient = _clientService.focusedClient;
    if (currentClient != null) {
      _clearControllersForClientType(currentClient.phoneNumber, 'client', 'credit');
      _clearControllersForClientType(currentClient.phoneNumber, 'coborrower', 'credit');
    }
  }

  /// Reset income form selections
  void _resetIncomeFormSelections() {
    debugPrint('DEBUG: Resetting income form selections');
    if (mounted) {
      setState(() {
        _newIncomeFormSelectedBank = null;
        _newIncomeFormSelectedType = null;
        debugPrint('DEBUG: Income selections reset to null');
      });
    }
    
    // FIX: Also clear any remaining controllers that might have old data
    final currentClient = _clientService.focusedClient;
    if (currentClient != null) {
      _clearControllersForClientType(currentClient.phoneNumber, 'client', 'income');
      _clearControllersForClientType(currentClient.phoneNumber, 'coborrower', 'income');
    }
  }

  /// Actualizeaza un camp din formular
  void _updateFormField(ClientModel client, int index, String field, String value, bool isCreditForm, bool isClient) {
    if (isCreditForm) {
      final forms = isClient 
          ? _formService.getClientCreditForms(client.phoneNumber)
          : _formService.getCoborrowerCreditForms(client.phoneNumber);
      
      if (index < forms.length) {
        final form = forms[index];
        
        final updatedForm = CreditFormModel(
          bank: field == 'bank' ? value : form.bank,
          creditType: field == 'creditType' ? value : form.creditType,
          sold: field == 'sold' ? value : form.sold,
          consumat: field == 'consumat' ? value : form.consumat,
          rateType: field == 'rateType' ? value : form.rateType,
          rata: field == 'rata' ? value : form.rata,
          perioada: field == 'perioada' ? value : form.perioada,
          isNew: form.isNew,
        );
        
        _formService.updateCreditForm(client.phoneNumber, index, updatedForm, isClient: isClient);
        
        // Automatically save to Firebase after updating the form field
        _autoSaveToFirebase(client);
      }
    } else {
      final forms = isClient 
          ? _formService.getClientIncomeForms(client.phoneNumber)
          : _formService.getCoborrowerIncomeForms(client.phoneNumber);
      
      if (index < forms.length) {
        final form = forms[index];
        
        final updatedForm = IncomeFormModel(
          bank: field == 'bank' ? value : form.bank,
          incomeType: field == 'incomeType' ? value : form.incomeType,
          incomeAmount: field == 'incomeAmount' ? value : form.incomeAmount,
          vechime: field == 'vechime' ? value : form.vechime,
          isNew: form.isNew,
        );
        
        _formService.updateIncomeForm(client.phoneNumber, index, updatedForm, isClient: isClient);
        
        // Automatically save to Firebase after updating the form field
        _autoSaveToFirebase(client);
      }
    }
  }

  /// Transform credit form new based on selected bank and credit type
  void _transformCreditFormNew(ClientModel client, String bank, String creditType, bool isClient) {
    debugPrint('DEBUG: Transforming credit form - Bank: $bank, Type: $creditType, IsClient: $isClient');
    
    // Creeaza un formular nou cu datele selectate
    final newForm = CreditFormModel(
      bank: bank,
      creditType: creditType,
    );
    
    // FIX: Create a completely new form list with only the new form
    _formService.createNewCreditForm(client.phoneNumber, newForm, isClient: isClient);
    
    debugPrint('DEBUG: Created new credit form with clean state');
    
    // Automatically save to Firebase after creating new form
    _autoSaveToFirebase(client);
    
    // Reset selections to show a new clean FormNew
    _resetCreditFormSelections();
    debugPrint('DEBUG: Credit form selections reset');
  }

  /// Transform income form new based on selected bank and income type
  void _transformIncomeFormNew(ClientModel client, String bank, String incomeType, bool isClient) {
    debugPrint('DEBUG: Transforming income form - Bank: $bank, Type: $incomeType, IsClient: $isClient');
    
    // Creeaza un formular nou cu datele selectate
    final newForm = IncomeFormModel(
      bank: bank,
      incomeType: incomeType,
    );
    
    // FIX: Create a completely new form list with only the new form
    _formService.createNewIncomeForm(client.phoneNumber, newForm, isClient: isClient);
    
    debugPrint('DEBUG: Created new income form with clean state');
    
    // Automatically save to Firebase after creating new form
    _autoSaveToFirebase(client);
    
    // Reset selections to show a new clean FormNew
    _resetIncomeFormSelections();
    debugPrint('DEBUG: Income form selections reset');
  }
}
