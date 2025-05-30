import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:broker_app/frontend/common/appTheme.dart';

/// Widget reutilizabil pentru dropdown-uri in formulare
class DropdownWidget extends StatelessWidget {
  /// Lista de optiuni pentru dropdown
  final List<String> items;
  
  /// Valoarea selectata curent
  final String? value;
  
  /// Hint text cand nu e selectata nicio valoare
  final String hintText;
  
  /// Callback apelat cand se schimba valoarea
  final Function(String?) onChanged;
  
  /// Culoarea de background a dropdownului
  final Color backgroundColor;
  
  /// Culoarea textului
  final Color textColor;

  const DropdownWidget({
    super.key,
    required this.items,
    this.value,
    required this.hintText,
    required this.onChanged,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        height: 48,
        padding: const EdgeInsets.only(left: 16, right: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            hint: Text(
              hintText,
              style: AppTheme.primaryTitleStyle.copyWith(
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            icon: SvgPicture.asset(
              'assets/expandIcon.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
            ),
            isExpanded: true,
            dropdownColor: backgroundColor,
            style: AppTheme.primaryTitleStyle.copyWith(
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
            items: items.map<DropdownMenuItem<String>>((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
} 