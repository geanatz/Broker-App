import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart'; // Import for gesture recognizer
import '../../models/form_data.dart'; // Import data models
import '../../theme/app_theme.dart';
import 'credit_form_widget.dart';
import 'income_form_widget.dart';

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

  const FormsContainerWidget({
    Key? key,
    required this.type,
    required this.isClientForm,
  }) : super(key: key);

  @override
  State<FormsContainerWidget> createState() => _FormsContainerWidgetState();
}

class _FormsContainerWidgetState extends State<FormsContainerWidget> {
  // Lista de modele de date pentru formulare
  // Initializata cu un formular gol
  late List<BaseFormData> _formDataList;

  // GlobalKey to access ScaffoldMessenger for SnackBar or other context needs
  final GlobalKey _containerKey = GlobalKey();

  // Offset for placing the context menu
  Offset _tapPosition = Offset.zero;

  @override
  void initState() {
    super.initState();
    // Initializeaza lista cu un formular gol specific tipului
    _formDataList = widget.type == FormContainerType.credit
        ? [CreditFormData.empty()]
        : [IncomeFormData.empty()];
  }

  // Store tap position
  void _getTapPosition(TapDownDetails details) {
    final RenderBox referenceBox = context.findRenderObject() as RenderBox;
    setState(() {
      _tapPosition = referenceBox.globalToLocal(details.globalPosition);
    });
  }

  // Show context menu
  void _showContextMenu(BuildContext context, int index) async {
    final RenderObject? overlay = Overlay.of(context).context.findRenderObject();
    final String deleteLabel = widget.type == FormContainerType.credit ? 'Sterge credit' : 'Sterge venit';

    await showMenu(
      context: context,
      position: RelativeRect.fromRect(
          Rect.fromLTWH(_tapPosition.dx, _tapPosition.dy, 30, 30),
          Rect.fromLTWH(0, 0, overlay!.paintBounds.size.width, overlay.paintBounds.size.height)),
      items: [
        PopupMenuItem(
          value: 'delete',
          child: Text(deleteLabel, style: const TextStyle(fontFamily: 'Outfit')), // Ensure font
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
    // Containerul nu mai are decoratiuni proprii, preia stilul din parinte
    return Column(
      key: _containerKey, // Assign key
      children: List.generate(_formDataList.length, (index) {
        return _buildFormWidget(index);
      }),
    );
  }

  /// Construieste un formular individual (credit sau venit)
  Widget _buildFormWidget(int index) {
    final formData = _formDataList[index];
    final bool isLastForm = index == _formDataList.length - 1;
    // Only allow deletion if it's not the last empty form
    final bool allowDelete = !isLastForm || !formData.isEmpty;

    Widget formContent;
    if (widget.type == FormContainerType.credit && formData is CreditFormData) {
      formContent = CreditFormWidget(
        formData: formData,
        onChanged: (updatedData) => _handleFormChanged(index, updatedData),
      );
    } else if (widget.type == FormContainerType.income && formData is IncomeFormData) {
      formContent = IncomeFormWidget(
        formData: formData,
        onChanged: (updatedData) => _handleFormChanged(index, updatedData),
      );
    } else {
      formContent = const SizedBox.shrink(); // Should not happen
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector( // Changed from Stack to GestureDetector
        onTapDown: _getTapPosition, // Store position on tap down
        onSecondaryTap: allowDelete // Enable right-click only if deletion is allowed
            ? () => _showContextMenu(context, index)
            : null,
        child: formContent, // The actual form widget
      ),
    );
  }

  /// Gestioneaza modificarile dintr-un formular
  void _handleFormChanged(int index, BaseFormData updatedData) {
    // Salveaza starea anterioara a ultimului element
    bool lastElementWasEmpty = _formDataList.isNotEmpty && _formDataList.last.isEmpty;
    
    // Determine the new filled status based on the updatedData
    bool isNowFilled = false;
    if (updatedData is CreditFormData) {
      isNowFilled = updatedData.isFilled();
    } else if (updatedData is IncomeFormData) {
      isNowFilled = updatedData.isFilled();
    }

    // Update the isEmpty property explicitly
    updatedData.isEmpty = !isNowFilled;

    // Use setState only if the data actually changed or if a new form needs to be added
    if (_formDataList[index] != updatedData || (index == _formDataList.length - 1 && lastElementWasEmpty && isNowFilled)) {
        setState(() {
            _formDataList[index] = updatedData;

            // Verifica daca ultimul formular a fost completat
            if (index == _formDataList.length - 1 && lastElementWasEmpty && isNowFilled) {
                // Adauga un nou formular gol daca ultimul a devenit completat
                if (widget.type == FormContainerType.credit) {
                  _formDataList.add(CreditFormData.empty());
                } else {
                  _formDataList.add(IncomeFormData.empty());
                }
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
          content: Text('Nu se poate șterge ultimul formular gol.', style: TextStyle(fontFamily: 'Outfit')),
          backgroundColor: AppTheme.fontLightRed,
          duration: Duration(seconds: 2),
          ), 
      );
      return;
    }

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
  }
} 