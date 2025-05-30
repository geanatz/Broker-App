import 'package:flutter/material.dart';
import 'package:broker_app/frontend/common/appTheme.dart';

/// Widget reutilizabil pentru campuri de input text in formulare
class InputFieldWidget extends StatelessWidget {
  /// Controller-ul pentru textul din input
  final TextEditingController? controller;
  
  /// Hint text cand nu e introdus niciun text
  final String hintText;
  
  /// Poate fi folosit in loc de controller
  final String? value;
  
  /// Callback apelat cand se schimba valoarea
  final Function(String)? onChanged;
  
  /// Callback apelat cand se termina editarea
  final Function(String)? onSubmitted;
  
  /// Tipul de input (text, number, email etc.)
  final TextInputType keyboardType;
  
  /// Culoarea de background a inputului
  final Color backgroundColor;
  
  /// Culoarea textului
  final Color textColor;
  
  /// Daca inputul este read-only
  final bool readOnly;

  const InputFieldWidget({
    super.key,
    this.controller,
    required this.hintText,
    this.value,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType = TextInputType.text,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.text,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          keyboardType: keyboardType,
          readOnly: readOnly,
          style: AppTheme.primaryTitleStyle.copyWith(
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AppTheme.primaryTitleStyle.copyWith(
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }
} 