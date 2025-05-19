import 'package:flutter/material.dart';
import 'package:broker_app/frontend/common/appTheme.dart';

/// A container widget with standardized styling for the application panels
class PanelContainer extends StatelessWidget {
  /// The width of the container
  final double? width;
  
  /// The height of the container
  final double? height;
  
  /// Whether the container should expand to fill its parent
  final bool isExpanded;
  
  /// The child widget to be displayed inside the container
  final Widget child;

  const PanelContainer({
    Key? key,
    this.width,
    this.height,
    this.isExpanded = false,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final container = Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(AppTheme.smallGap),
      decoration: AppTheme.widgetDecoration,
      child: child,
    );
    
    return isExpanded ? Expanded(child: container) : container;
  }
} 