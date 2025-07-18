import 'package:broker_app/app_theme.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:broker_app/backend/services/form_service.dart';
import 'package:broker_app/backend/services/splash_service.dart';
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
  const FormArea({super.key});

  @override
  State<FormArea> createState() => _FormAreaState();
}

class _FormAreaState extends State<FormArea> {
  // Services
  late final FormService _formService;
  late final ClientUIService _clientService;
  
  // Text controllers pentru input fields
  final Map<String, TextEditingController> _textControllers = {};
  
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

  @override
  void initState() {
    super.initState();
    app_log.PerformanceMonitor.startTimer('formAreaInit');
    _initializeServices();
    app_log.PerformanceMonitor.endTimer('formAreaInit');
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _disposeControllers();
    _formService.removeListener(_onFormServiceChanged);
    _clientService.removeListener(_onClientServiceChanged);
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
    
    // Incarca datele pentru clientul curent daca exista
    final currentClient = _clientService.focusedClient;
    if (currentClient != null) {
      await _loadFormDataForCurrentClient();
    }
  }

  /// Dispose all text controllers
  void _disposeControllers() {
    _textControllers.forEach((_, controller) => controller.dispose());
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
    // OPTIMIZARE: Folosește microtask pentru a evita blocking
    Future.microtask(() {
      _handleClientChange();
    });
  }

  /// Gestioneaza schimbarea clientului
  /// OPTIMIZAT: Cu loading instant și debouncing
  Future<void> _handleClientChange() async {
    final currentClient = _clientService.focusedClient;
    
    // OPTIMIZARE: Nu face nimic dacă clientul nu s-a schimbat
    if (currentClient?.phoneNumber == _previousClient?.phoneNumber) {
      return;
    }
    
    // Salveaza datele clientului anterior daca exista (doar pentru clienti reali)
    if (_previousClient != null && !_previousClient!.id.startsWith('temp_')) {
      // FIX: Verifică dacă clientul anterior încă există înainte de a salva datele
      final clientStillExists = _clientService.clients.any(
        (client) => client.phoneNumber == _previousClient!.phoneNumber
      );
      
      if (clientStillExists) {
        await _saveFormDataForClient(_previousClient!);
      } else {
        app_log.AppLogger.error('FORM', 'Skipping form save for deleted client: ${_previousClient!.phoneNumber}');
      }
    }
    
    // Curata controller-ele pentru noul client
    _disposeControllers();
    
    // OPTIMIZARE: Încarcă datele pentru noul client instant
    if (currentClient != null) {
      await _loadFormDataForCurrentClient();
    }
    
    // Actualizeaza referinta clientului anterior
    _previousClient = currentClient;
    
    // OPTIMIZARE: Actualizeaza UI-ul imediat pentru a afișa schimbarea
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  /// Incarca datele formularului pentru clientul curent
  /// OPTIMIZAT: Cu loading instant și cache
  Future<void> _loadFormDataForCurrentClient() async {
    app_log.PerformanceMonitor.startTimer('loadFormData');
    final currentClient = _clientService.focusedClient;
    if (currentClient != null) {
      try {
        // OPTIMIZARE: Nu încerca să încarci date pentru clienti temporari
        if (currentClient.id.startsWith('temp_')) {
          return;
        }
        
        // OPTIMIZARE: Încarcă datele instant din cache dacă sunt disponibile
        await _formService.loadFormDataForClient(
          currentClient.phoneNumber,
          currentClient.phoneNumber,
        );
        
        // Clear all controllers to force fresh data loading
        _disposeControllers();
        
        // OPTIMIZARE: Force refresh controllers after loading data cu delay
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              // This will trigger rebuild and sync controllers with loaded data
            });
          }
        });
      } catch (e) {
        app_log.AppLogger.error('FORM', 'Error loading form data', e);
      } finally {
        app_log.PerformanceMonitor.endTimer('loadFormData');
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
          // OPTIMIZARE: Log redus - doar pentru debugging când e necesar
          // debugPrint('Controller $key initialized with formatted value: "$formattedValue" (from model: "$cleanValue")');
        } else if (controllerNumericValue != cleanValue && cleanValue != '0') {
          // Only update if the numeric values are actually different and not just placeholder
          final formattedValue = _formatValueForDisplay(cleanValue, fieldType);
          controller.text = formattedValue;
          // OPTIMIZARE: Log redus - doar pentru debugging când e necesar
          // debugPrint('Controller $key updated to formatted value: "$formattedValue" (from model: "$cleanValue")');
        }
        // Don't update if only formatting differs (e.g., "12000" vs "12,000")
      } else {
        // For non-numeric fields, use exact comparison
        if (controller.text.isEmpty) {
          controller.text = cleanValue;
          // OPTIMIZARE: Log redus - doar pentru debugging când e necesar
          // debugPrint('Controller $key initialized with: "$cleanValue"');
        } else if (controller.text != cleanValue && cleanValue != '0') {
          controller.text = cleanValue;
          // OPTIMIZARE: Log redus - doar pentru debugging când e necesar
          // debugPrint('Controller $key updated to: "$cleanValue" (from model: "$modelValue")');
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
              } else {
                // debugPrint('Skipping save for field $field - value unchanged: "$cleanValue"');
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

  @override
  Widget build(BuildContext context) {
    final focusedClient = _clientService.focusedClient;
    
    // Verifica daca clientul focusat este temporar
    if (focusedClient != null && focusedClient.id.startsWith('temp_')) {
      return _buildTemporaryClientPlaceholder(focusedClient);
    }
    
    // Verifica daca nu exista client focusat
    if (focusedClient == null) {
      return _buildNoClientSelectedPlaceholder();
    }
    
    // Construieste formularul pentru clientul real
    return _buildFormContent(focusedClient);
  }

  /// Construieste continutul formularului conform design-ului din formArea.md
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
    
    // Afiseaza formularele pentru client conform design-ului exact din Figma
    return Row(
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
      child: ListView(
        children: allWidgets,
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
      child: ListView(
        children: allWidgets,
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
  }

  /// Actualizeaza un camp din formular
  void _updateFormField(ClientModel client, int index, String field, String value, bool isCreditForm, bool isClient) {
    if (isCreditForm) {
      final forms = isClient 
          ? _formService.getClientCreditForms(client.phoneNumber)
          : _formService.getCoborrowerCreditForms(client.phoneNumber);
      
      if (index < forms.length) {
        final form = forms[index];
        debugPrint('Original form values: bank=${form.bank}, sold=${form.sold}, rata=${form.rata}, perioada=${form.perioada}');
        
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
        
        debugPrint('Updated form values: bank=${updatedForm.bank}, sold=${updatedForm.sold}, rata=${updatedForm.rata}, perioada=${updatedForm.perioada}');
        
        _formService.updateCreditForm(client.phoneNumber, index, updatedForm, isClient: isClient);
        debugPrint('Credit form updated in FormService');
        
        // Automatically save to Firebase after updating the form field
        _autoSaveToFirebase(client);
      } else {
        debugPrint('ERROR: Index $index out of bounds for credit forms (length: ${forms.length})');
      }
    } else {
      final forms = isClient 
          ? _formService.getClientIncomeForms(client.phoneNumber)
          : _formService.getCoborrowerIncomeForms(client.phoneNumber);
      
      if (index < forms.length) {
        final form = forms[index];
        debugPrint('Original income form values: bank=${form.bank}, incomeAmount=${form.incomeAmount}, vechime=${form.vechime}');
        
        final updatedForm = IncomeFormModel(
          bank: field == 'bank' ? value : form.bank,
          incomeType: field == 'incomeType' ? value : form.incomeType,
          incomeAmount: field == 'incomeAmount' ? value : form.incomeAmount,
          vechime: field == 'vechime' ? value : form.vechime,
          isNew: form.isNew,
        );
        
        debugPrint('Updated income form values: bank=${updatedForm.bank}, incomeAmount=${updatedForm.incomeAmount}, vechime=${updatedForm.vechime}');
        
        _formService.updateIncomeForm(client.phoneNumber, index, updatedForm, isClient: isClient);
        debugPrint('Income form updated in FormService');
        
        // Automatically save to Firebase after updating the form field
        _autoSaveToFirebase(client);
      } else {
        debugPrint('ERROR: Index $index out of bounds for income forms (length: ${forms.length})');
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
    
    // Obtine lista de formulare si gaseste ultimul formular gol
    final forms = isClient 
        ? _formService.getClientCreditForms(client.phoneNumber)
        : _formService.getCoborrowerCreditForms(client.phoneNumber);
    
    debugPrint('DEBUG: Current forms count: ${forms.length}');
    
    // Gaseste ultimul formular gol pentru a-l actualiza
    int lastEmptyIndex = forms.length - 1;
    for (int i = forms.length - 1; i >= 0; i--) {
      if (forms[i].isEmpty) {
        lastEmptyIndex = i;
        break;
      }
    }
    
    debugPrint('DEBUG: Updating form at index: $lastEmptyIndex');
    
    // Actualizeaza ultimul formular gol cu datele noi
    _formService.updateCreditForm(
      client.phoneNumber, 
      lastEmptyIndex, 
      newForm, 
      isClient: isClient
    );
    
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
    
    // Obtine lista de formulare si gaseste ultimul formular gol
    final forms = isClient 
        ? _formService.getClientIncomeForms(client.phoneNumber)
        : _formService.getCoborrowerIncomeForms(client.phoneNumber);
    
    debugPrint('DEBUG: Current forms count: ${forms.length}');
    
    // Gaseste ultimul formular gol pentru a-l actualiza
    int lastEmptyIndex = forms.length - 1;
    for (int i = forms.length - 1; i >= 0; i--) {
      if (forms[i].isEmpty) {
        lastEmptyIndex = i;
        break;
      }
    }
    
    debugPrint('DEBUG: Updating form at index: $lastEmptyIndex');
    
    // Actualizeaza ultimul formular gol cu datele noi
    _formService.updateIncomeForm(
      client.phoneNumber, 
      lastEmptyIndex, 
      newForm, 
      isClient: isClient
    );
    
    // Automatically save to Firebase after creating new form
    _autoSaveToFirebase(client);
    
    // Reset selections to show a new clean FormNew
    _resetIncomeFormSelections();
    debugPrint('DEBUG: Income form selections reset');
  }
}
