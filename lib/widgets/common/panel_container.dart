import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Un container reutilizabil pentru paneluri care menține același design
/// în toate ecranele aplicației.
class PanelContainer extends StatelessWidget {
  /// Conținutul care va fi afișat în panel
  final Widget child;
  
  /// Lățimea panel-ului
  final double width;
  
  /// Înălțimea panel-ului (opțional, defaults to null pentru a permite flexibilitate)
  final double? height;
  
  /// Padding pentru conținutul din interiorul panel-ului
  final EdgeInsetsGeometry padding;
  
  /// Flag pentru a indica dacă panel-ul ar trebui să se extindă pentru a ocupa spațiul disponibil
  final bool isExpanded;

  const PanelContainer({
    Key? key,
    required this.child,
    required this.width,
    this.height,
    this.padding = const EdgeInsets.all(AppTheme.defaultGap),
    this.isExpanded = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final container = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: AppTheme.widgetDecoration,
      child: child,
    );

    // Dacă panel-ul trebuie să ocupe spațiul disponibil, îl înfășurăm într-un Expanded
    if (isExpanded) {
      return Expanded(child: container);
    }
    
    return container;
  }
} 