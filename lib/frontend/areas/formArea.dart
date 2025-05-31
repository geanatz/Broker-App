import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:broker_app/frontend/common/appTheme.dart';
import 'package:broker_app/backend/services/formService.dart';
import 'package:broker_app/frontend/common/services/client_service.dart';
import 'package:broker_app/frontend/common/models/client_model.dart';
import 'package:broker_app/frontend/common/components/headers/widgetHeader2.dart';
import 'package:broker_app/frontend/common/components/forms/form1.dart';
import 'package:broker_app/frontend/common/components/forms/form2.dart';
import 'package:broker_app/frontend/common/components/forms/formNew.dart';

/// Area pentru formulare care va fi afișată în cadrul ecranului principal.
/// Această componentă înlocuiește vechiul FormScreen păstrând funcționalitatea
/// dar fiind adaptată la noua structură a aplicației.
class FormArea extends StatefulWidget {
  const FormArea({super.key});

  @override
  State<FormArea> createState() => _FormAreaState();
}

class _FormAreaState extends State<FormArea> {
  // Services
  final FormService _formService = FormService();
  final ClientService _clientService = ClientService();
  
  // Text controllers pentru input fields
  final Map<String, TextEditingController> _textControllers = {};
  
  // Store the GLOBAL tap position for the context menu
  Offset _globalTapPosition = Offset.zero;
  
  // Previous client for handling client changes
  ClientModel? _previousClient;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  @override
  void dispose() {
    _disposeControllers();
    _formService.removeListener(_onFormServiceChanged);
    _clientService.removeListener(_onClientServiceChanged);
    super.dispose();
  }

  /// Inițializează serviciile
  Future<void> _initializeServices() async {
    await _formService.initialize();
    _formService.addListener(_onFormServiceChanged);
    _clientService.addListener(_onClientServiceChanged);
    _previousClient = _clientService.focusedClient;
    
    // Încarcă datele pentru clientul curent dacă există
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

  /// Callback pentru schimbările din FormService
  void _onFormServiceChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  /// Callback pentru schimbările din ClientService
  void _onClientServiceChanged() {
    _handleClientChange();
  }

  /// Gestionează schimbarea clientului
  Future<void> _handleClientChange() async {
    final currentClient = _clientService.focusedClient;
    
    // Salvează datele clientului anterior dacă există
    if (_previousClient != null && currentClient?.phoneNumber != _previousClient?.phoneNumber) {
      await _saveFormDataForClient(_previousClient!);
    }
    
    // Curăță controller-ele pentru noul client
    _disposeControllers();
    
    // Încarcă datele pentru noul client
    if (currentClient != null) {
      await _loadFormDataForCurrentClient();
    }
    
    // Actualizează referința clientului anterior
    _previousClient = currentClient;
    
    // Actualizează UI-ul
    if (mounted) {
      setState(() {});
    }
  }

  /// Încarcă datele formularului pentru clientul curent
  Future<void> _loadFormDataForCurrentClient() async {
    final currentClient = _clientService.focusedClient;
    if (currentClient != null) {
      await _formService.loadFormDataForClient(
        currentClient.phoneNumber,
        currentClient.phoneNumber,
      );
    }
  }

  /// Salvează datele formularului pentru un client specific
  Future<void> _saveFormDataForClient(ClientModel client) async {
    await _formService.saveFormDataForClient(
      client.phoneNumber,
      client.phoneNumber,
      client.name,
    );
  }

  /// Store GLOBAL tap position
  void _getTapPosition(TapDownDetails details) {
    setState(() {
      _globalTapPosition = details.globalPosition;
    });
  }

  /// Show context menu for form deletion
  void _showContextMenu(BuildContext context, int index, bool isCreditForm, bool isClient) async {
    final RenderObject? overlay = Overlay.of(context).context.findRenderObject();
    if (overlay == null) return;

    final String deleteLabel = isCreditForm ? 'Șterge credit' : 'Șterge venit';
    
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

  /// Obține controller-ul pentru un field specific
  TextEditingController _getController(String key) {
    if (!_textControllers.containsKey(key)) {
      _textControllers[key] = TextEditingController();
    }
    return _textControllers[key]!;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.smallGap),
      decoration: AppTheme.widgetDecoration,
      child: _buildFormContent(),
    );
  }

  /// Construiește conținutul formularului
  Widget _buildFormContent() {
    final focusedClient = _clientService.focusedClient;
    
    // Dacă nu există client focusat, afișează un placeholder
    if (focusedClient == null) {
      return _buildNoClientSelectedPlaceholder();
    }
    
    // Afișează formularele pentru client conform design-ului Figma
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: _buildCreditSection(focusedClient),
        ),
        const SizedBox(width: AppTheme.mediumGap),
        Expanded(
          child: _buildIncomeSection(focusedClient),
        ),
      ],
    );
  }

  /// Construiește placeholder-ul când nu există client selectat
  Widget _buildNoClientSelectedPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_outline,
            size: 64,
            color: AppTheme.elementColor2,
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
            'Selectați un client din panoul din stânga pentru a vedea formularul său',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppTheme.fontSizeMedium,
              color: AppTheme.elementColor1,
            ),
          ),
        ],
      ),
    );
  }

  /// Construiește secțiunea pentru credite
  Widget _buildCreditSection(ClientModel client) {
    final isShowingClient = _formService.isShowingClientLoanForm(client.phoneNumber);
    final forms = isShowingClient 
        ? _formService.getClientCreditForms(client.phoneNumber)
        : _formService.getCoborrowerCreditForms(client.phoneNumber);

    return Container(
      height: double.infinity,
      padding: const EdgeInsets.all(AppTheme.smallGap),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: AppTheme.popupBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        ),
        shadows: [AppTheme.widgetShadow],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header cu toggle
          WidgetHeader2(
            title: 'Credit',
            altText: isShowingClient ? 'Vezi codebitor' : 'Vezi client',
            onAltTextTap: () {
              _formService.toggleLoanFormType(client.phoneNumber);
            },
          ),
          
          const SizedBox(height: AppTheme.smallGap),
          
          // Lista de formulare de credit
          Expanded(
            child: _buildCreditFormsList(client, forms, isShowingClient),
          ),
        ],
      ),
    );
  }

  /// Construiește secțiunea pentru venituri
  Widget _buildIncomeSection(ClientModel client) {
    final isShowingClient = _formService.isShowingClientIncomeForm(client.phoneNumber);
    final forms = isShowingClient 
        ? _formService.getClientIncomeForms(client.phoneNumber)
        : _formService.getCoborrowerIncomeForms(client.phoneNumber);

    return Container(
      height: double.infinity,
      padding: const EdgeInsets.all(AppTheme.smallGap),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: AppTheme.popupBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        ),
        shadows: [AppTheme.widgetShadow],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header cu toggle
          WidgetHeader2(
            title: 'Venit',
            altText: isShowingClient ? 'Vezi codebitor' : 'Vezi client',
            onAltTextTap: () {
              _formService.toggleIncomeFormType(client.phoneNumber);
            },
          ),
          
          const SizedBox(height: AppTheme.smallGap),
          
          // Lista de formulare de venit
          Expanded(
            child: _buildIncomeFormsList(client, forms, isShowingClient),
          ),
        ],
      ),
    );
  }

  /// Construiește lista de formulare de credit
  Widget _buildCreditFormsList(ClientModel client, List<CreditFormModel> forms, bool isClient) {
    return SingleChildScrollView(
      child: Column(
        children: forms.asMap().entries.map((entry) {
          final index = entry.key;
          final form = entry.value;
          
          return GestureDetector(
            onTapDown: _getTapPosition,
            onLongPress: () => _showContextMenu(context, index, true, isClient),
            child: Container(
              margin: const EdgeInsets.only(bottom: AppTheme.smallGap),
              child: _buildCreditForm(client, form, index, isClient),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Construiește lista de formulare de venit
  Widget _buildIncomeFormsList(ClientModel client, List<IncomeFormModel> forms, bool isClient) {
    return SingleChildScrollView(
      child: Column(
        children: forms.asMap().entries.map((entry) {
          final index = entry.key;
          final form = entry.value;
          
          return GestureDetector(
            onTapDown: _getTapPosition,
            onLongPress: () => _showContextMenu(context, index, false, isClient),
            child: Container(
              margin: const EdgeInsets.only(bottom: AppTheme.smallGap),
              child: _buildIncomeForm(client, form, index, isClient),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Construiește un formular de credit individual
  Widget _buildCreditForm(ClientModel client, CreditFormModel form, int index, bool isClient) {
    // Determină ce tipuri de câmpuri să afișeze în funcție de tipul de credit
    final showConsumat = form.creditType == 'Card de cumparaturi' || form.creditType == 'Overdraft';
    final showRataAndPeriod = form.creditType == 'Nevoi personale' || 
                              form.creditType == 'Ipotecar' || 
                              form.creditType == 'Prima casa';

    if (showRataAndPeriod) {
      // Folosește Form2 pentru Nevoi personale, Ipotecar și Prima casa (5 câmpuri)
      return FormContainer2(
        titleR1F1: 'Banca',
        optionR1F1: form.bank,
        iconR1F1: Icons.expand_more,
        onTapR1F1: () => _showBankDropdown(client, index, true, isClient),
        
        titleR1F2: 'Tip credit',
        optionR1F2: form.creditType,
        iconR1F2: Icons.expand_more,
        onTapR1F2: () => _showCreditTypeDropdown(client, index, isClient),
        
        titleR2F1: 'Sold',
        textR2F1: form.sold,
        onTapR2F1: () => _showInputDialog(client, index, 'sold', form.sold, true, isClient),
        
        titleR2F2: 'Rata',
        textR2F2: form.rata,
        onTapR2F2: () => _showInputDialog(client, index, 'rata', form.rata, true, isClient),
        
        titleR2F3: 'Perioada',
        textR2F3: form.perioada,
        onTapR2F3: () => _showInputDialog(client, index, 'perioada', form.perioada, true, isClient),
      );
    } else {
      // Folosește Form1 pentru Card de cumparaturi și Overdraft (4 câmpuri)
      return FormContainer1(
        titleTL: 'Banca',
        optionTL: form.bank,
        iconTL: Icons.expand_more,
        onTapTL: () => _showBankDropdown(client, index, true, isClient),
        
        titleTR: 'Tip credit',
        optionTR: form.creditType,
        iconTR: Icons.expand_more,
        onTapTR: () => _showCreditTypeDropdown(client, index, isClient),
        
        titleBL: 'Sold',
        textBL: form.sold,
        onTapBL: () => _showInputDialog(client, index, 'sold', form.sold, true, isClient),
        
        titleBR: showConsumat ? 'Consumat' : 'Rata',
        textBR: showConsumat ? form.consumat : form.rata,
        onTapBR: () => _showInputDialog(
          client, 
          index, 
          showConsumat ? 'consumat' : 'rata', 
          showConsumat ? form.consumat : form.rata, 
          true, 
          isClient
        ),
      );
    }
  }

  /// Construiește un formular de venit individual
  Widget _buildIncomeForm(ClientModel client, IncomeFormModel form, int index, bool isClient) {
    // Folosește FormNew pentru venituri (2 câmpuri)
    return FormContainerNew(
      titleF1: 'Banca',
      optionF1: form.bank,
      iconF1: Icons.expand_more,
      onTapF1: () => _showBankDropdown(client, index, false, isClient),
      
      titleF2: 'Tip venit',
      optionF2: form.incomeType,
      iconF2: Icons.expand_more,
      onTapF2: () => _showIncomeTypeDropdown(client, index, isClient),
    );
  }

  /// Afișează dropdown pentru selectarea băncii
  void _showBankDropdown(ClientModel client, int index, bool isCreditForm, bool isClient) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.popupBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.borderRadiusLarge)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppTheme.mediumGap),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Selectează banca',
              style: TextStyle(
                fontSize: AppTheme.fontSizeLarge,
                fontWeight: FontWeight.w600,
                color: AppTheme.elementColor2,
              ),
            ),
            const SizedBox(height: AppTheme.mediumGap),
            ...FormService.banks.map((bank) => ListTile(
              title: Text(bank),
              onTap: () {
                Navigator.pop(context);
                _updateFormField(client, index, 'bank', bank, isCreditForm, isClient);
              },
            )),
          ],
        ),
      ),
    );
  }

  /// Afișează dropdown pentru selectarea tipului de credit
  void _showCreditTypeDropdown(ClientModel client, int index, bool isClient) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.popupBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.borderRadiusLarge)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppTheme.mediumGap),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Selectează tipul de credit',
              style: TextStyle(
                fontSize: AppTheme.fontSizeLarge,
                fontWeight: FontWeight.w600,
                color: AppTheme.elementColor2,
              ),
            ),
            const SizedBox(height: AppTheme.mediumGap),
            ...FormService.creditTypes.map((type) => ListTile(
              title: Text(type),
              onTap: () {
                Navigator.pop(context);
                _updateFormField(client, index, 'creditType', type, true, isClient);
              },
            )),
          ],
        ),
      ),
    );
  }

  /// Afișează dropdown pentru selectarea tipului de venit
  void _showIncomeTypeDropdown(ClientModel client, int index, bool isClient) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.popupBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.borderRadiusLarge)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppTheme.mediumGap),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Selectează tipul de venit',
              style: TextStyle(
                fontSize: AppTheme.fontSizeLarge,
                fontWeight: FontWeight.w600,
                color: AppTheme.elementColor2,
              ),
            ),
            const SizedBox(height: AppTheme.mediumGap),
            ...FormService.incomeTypes.map((type) => ListTile(
              title: Text(type),
              onTap: () {
                Navigator.pop(context);
                _updateFormField(client, index, 'incomeType', type, false, isClient);
              },
            )),
          ],
        ),
      ),
    );
  }

  /// Afișează dialog pentru introducerea textului
  void _showInputDialog(ClientModel client, int index, String field, String currentValue, bool isCreditForm, bool isClient) {
    final controller = TextEditingController(text: currentValue);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.popupBackground,
        title: Text(
          'Introduceți ${_getFieldDisplayName(field)}',
          style: TextStyle(color: AppTheme.elementColor2),
        ),
        content: TextField(
          controller: controller,
          keyboardType: _getKeyboardType(field),
          inputFormatters: _getInputFormatters(field),
          style: TextStyle(color: AppTheme.elementColor2),
          decoration: InputDecoration(
            hintText: 'Introduceți ${_getFieldDisplayName(field)}',
            hintStyle: TextStyle(color: AppTheme.elementColor1),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppTheme.containerColor2),
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppTheme.elementColor2),
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Anulează', style: TextStyle(color: AppTheme.elementColor1)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _updateFormField(client, index, field, controller.text, isCreditForm, isClient);
            },
            child: Text('Salvează', style: TextStyle(color: AppTheme.elementColor2)),
          ),
        ],
      ),
    );
  }

  /// Actualizează un câmp din formular
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
      }
    }
  }

  /// Obține numele de afișare pentru un câmp
  String _getFieldDisplayName(String field) {
    switch (field) {
      case 'sold':
        return 'soldul';
      case 'consumat':
        return 'suma consumată';
      case 'rata':
        return 'rata';
      case 'perioada':
        return 'perioada';
      case 'incomeAmount':
        return 'suma venitului';
      case 'vechime':
        return 'vechimea';
      default:
        return field;
    }
  }

  /// Obține tipul de tastatură pentru un câmp
  TextInputType _getKeyboardType(String field) {
    switch (field) {
      case 'sold':
      case 'consumat':
      case 'rata':
      case 'incomeAmount':
        return TextInputType.number;
      case 'perioada':
      case 'vechime':
        return TextInputType.text;
      default:
        return TextInputType.text;
    }
  }

  /// Obține formatările de input pentru un câmp
  List<TextInputFormatter> _getInputFormatters(String field) {
    switch (field) {
      case 'sold':
      case 'consumat':
      case 'rata':
      case 'incomeAmount':
        return [FilteringTextInputFormatter.digitsOnly];
      default:
        return [];
    }
  }
}
