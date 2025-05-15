import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart'; // Import for gesture recognizer
import 'package:broker_app/old/models/form_data.dart'; // Import data models
import 'package:broker_app/old/theme/app_theme.dart';
import 'package:broker_app/old/services/contact_form_service.dart'; // Import ContactFormService
import 'package:broker_app/old/widgets/form/credit_form_widget.dart';
import 'package:broker_app/old/widgets/form/income_form_widget.dart';

/// Enum pentru a diferentia tipurile de containere
enum FormContainerType {
  credit,
  income
}

/// Widget care gestioneaza multiple formulare de credit sau venit
class FormsContainerWidget extends StatefulWidget {
  /// Tipul de formular (credit sau venit)
  final FormContainerType type;

  /// Daca se afiseaza formulare pentru client sau codebitor
  final bool isClientForm;
  
  /// ID-ul contactului asociat cu aceste formulare
  final String? contactId;

  const FormsContainerWidget({
    Key? key,
    required this.type,
    required this.isClientForm,
    this.contactId,
  }) : super(key: key);

  @override
  State<FormsContainerWidget> createState() => _FormsContainerWidgetState();
}

class _FormsContainerWidgetState extends State<FormsContainerWidget> {
  // Lista de modele de date pentru formulare
  // Initializata cu un formular gol
  late List<BaseFormData> _formDataList;

  // Service pentru gestionarea contactelor și formularelor
  final ContactFormService _contactService = ContactFormService();

  // GlobalKey to access ScaffoldMessenger for SnackBar or other context needs
  final GlobalKey _containerKey = GlobalKey();

  // Store the GLOBAL tap position for the context menu
  Offset _globalTapPosition = Offset.zero;

  @override
  void initState() {
    super.initState();
    _loadFormsForContact();
  }
  
  /// Încarcă formularele pentru contactul curent
  void _loadFormsForContact() {
    if (widget.contactId != null) {
      // Încarcă formularele existente pentru acest contact
      if (widget.type == FormContainerType.credit) {
        _formDataList = _contactService.getCreditForms(widget.contactId!);
      } else {
        _formDataList = _contactService.getIncomeForms(widget.contactId!);
      }
    } else {
      // Dacă nu există un contact selectat, folosim un formular gol
      _formDataList = widget.type == FormContainerType.credit
          ? [CreditFormData.empty()]
          : [IncomeFormData.empty()];
    }
  }
  
  @override
  void didUpdateWidget(FormsContainerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Verifică dacă s-a schimbat contactul și adaptează formularele corespunzător
    if (widget.contactId != oldWidget.contactId) {
      _loadFormsForContact();
    }
  }

  // Store GLOBAL tap position
  void _getTapPosition(TapDownDetails details) {
    // No need to convert to local, store the global position directly
    setState(() {
      _globalTapPosition = details.globalPosition;
    });
  }

  // Show context menu at the stored GLOBAL position
  void _showContextMenu(BuildContext context, int index) async {
    final RenderObject? overlay = Overlay.of(context).context.findRenderObject();
    if (overlay == null) return; // Guard against null overlay

    final String deleteLabel = widget.type == FormContainerType.credit ? 'Sterge credit' : 'Sterge venit';

    await showMenu(
      context: context,
      // Use the stored global position to create the RelativeRect
      position: RelativeRect.fromLTRB(
        _globalTapPosition.dx, 
        _globalTapPosition.dy, 
        overlay.paintBounds.size.width - _globalTapPosition.dx, 
        overlay.paintBounds.size.height - _globalTapPosition.dy
      ),
      items: [
        PopupMenuItem(
          value: 'delete',
          child: Text(
            deleteLabel,
            style: AppTheme.secondaryTitleStyle.copyWith(color: AppTheme.fontDarkPurple),
          ),
        ),
      ],
      elevation: 8.0,
      color: AppTheme.popupBackground.withOpacity(0.9), // Use popup background
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
      ),
    ).then((value) {
      if (value == 'delete') {
        _removeForm(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _formDataList.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTapDown: _getTapPosition, // Store tap position for context menu
          onLongPress: () => _showContextMenu(context, index),
          child: Container(
            margin: const EdgeInsets.only(bottom: AppTheme.mediumGap),
            child: widget.type == FormContainerType.credit
                ? CreditFormWidget(
                    formData: _formDataList[index] as CreditFormData,
                    onChanged: (updatedData) {
                      _handleFormChanged(index, updatedData);
                    },
                    contactId: widget.contactId, // Pass contactId
                  )
                : IncomeFormWidget(
                    formData: _formDataList[index] as IncomeFormData,
                    onChanged: (updatedData) {
                      _handleFormChanged(index, updatedData);
                    },
                    contactId: widget.contactId, // Pass contactId
                  ),
          ),
        );
      },
    );
  }

  /// Gestioneaza modificarile dintr-un formular
  void _handleFormChanged(int index, BaseFormData updatedData) {
    // Verificam starea curenta a formularului inainte de update
    final bool isLastForm = index == _formDataList.length - 1;
    final bool wasEmpty = _formDataList[index].isEmpty;
    
    // Actualizam formularul existent, pastrand referinta obiectului
    if (widget.type == FormContainerType.credit && 
        updatedData is CreditFormData && 
        _formDataList[index] is CreditFormData) {
      ((_formDataList[index] as CreditFormData)).updateFrom(updatedData);
      
      // Salvează formularul actualizat în service dacă avem un contact selectat
      if (widget.contactId != null) {
        _contactService.updateCreditForm(widget.contactId!, updatedData);
      }
    } else if (widget.type == FormContainerType.income && 
               updatedData is IncomeFormData && 
               _formDataList[index] is IncomeFormData) {
      ((_formDataList[index] as IncomeFormData)).updateFrom(updatedData);
      
      // Salvează formularul actualizat în service dacă avem un contact selectat
      if (widget.contactId != null) {
        _contactService.updateIncomeForm(widget.contactId!, updatedData);
      }
    } else {
      // Fallback in cazul in care tipurile nu se potrivesc (nu ar trebui sa se intample)
      _formDataList[index] = updatedData;
    }
    
    // Verificam daca formularul nu mai este gol dupa update
    final bool isNowFilled = !_formDataList[index].isEmpty;
    
    // Debugging
    print("Form at index $index: wasEmpty=$wasEmpty, isNowFilled=$isNowFilled, isLastForm=$isLastForm");
    print("Form data: ${_formDataList[index]}");
    
    // Daca este ultimul formular si acum contine date (banca si tip credit/venit), adaugam un nou formular
    if (isLastForm && isNowFilled) {
      print("Adding new form because the last one is now filled.");
      setState(() {
        if (widget.type == FormContainerType.credit) {
          _formDataList.add(CreditFormData.empty());
        } else {
          _formDataList.add(IncomeFormData.empty());
        }
      });
    }
  }

  /// Sterge un formular existent
  void _removeForm(int index) {
    // Nu permite stergerea ultimului element daca este singurul ramas si e gol
    if (_formDataList.length == 1 && _formDataList[0].isEmpty) {
      // Optionally show a message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Nu se poate șterge ultimul formular gol.',
            style: AppTheme.secondaryTitleStyle.copyWith(color: Colors.white),
          ),
          backgroundColor: AppTheme.fontLightRed,
          duration: const Duration(seconds: 2),
        ), 
      );
      return;
    }

    // Obține ID-ul formularului care va fi șters
    final String formId = _formDataList[index].id;

    setState(() {
      _formDataList.removeAt(index);

      // Asigura-te ca exista intotdeauna un formular gol la sfarsit
      if (_formDataList.isEmpty || !_formDataList.last.isEmpty) {
        if (widget.type == FormContainerType.credit) {
          _formDataList.add(CreditFormData.empty());
        } else {
          _formDataList.add(IncomeFormData.empty());
        }
      }
    });

    // Șterge și din service
    if (widget.contactId != null) {
      if (widget.type == FormContainerType.credit) {
        _contactService.removeCreditForm(widget.contactId!, formId);
      } else {
        _contactService.removeIncomeForm(widget.contactId!, formId);
      }
    }
  }
} 