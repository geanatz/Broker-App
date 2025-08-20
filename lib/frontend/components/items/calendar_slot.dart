import 'package:flutter/material.dart';
import 'package:mat_finance/app_theme.dart';

class CalendarSlot extends StatefulWidget {
  final bool isReserved;
  final String? hourText;
  final String? consultantName;
  final String? timeText;
  final VoidCallback? onTap;
  final bool isClickable;

  const CalendarSlot._({
    required this.isReserved,
    this.hourText,
    this.consultantName,
    this.timeText,
    this.onTap,
    required this.isClickable,
    super.key,
  });

  factory CalendarSlot.free({
    required String hourText,
    VoidCallback? onTap,
    Key? key,
  }) {
    return CalendarSlot._(
      isReserved: false,
      hourText: hourText,
      onTap: onTap,
      isClickable: true,
      key: key,
    );
  }

  factory CalendarSlot.reserved({
    required String consultantName,
    required String timeText,
    VoidCallback? onTap,
    bool isClickable = true,
    Key? key,
  }) {
    return CalendarSlot._(
      isReserved: true,
      consultantName: consultantName,
      timeText: timeText,
      onTap: onTap,
      isClickable: isClickable,
      key: key,
    );
  }

  @override
  State<CalendarSlot> createState() => _CalendarSlotState();
}

class _CalendarSlotState extends State<CalendarSlot> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.isClickable ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) {
        setState(() {
          _isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
        });
      },
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (widget.isReserved) {
      return _buildReserved();
    }
    return _buildFree();
  }

  Widget _buildFree() {
    final bool showHover = _isHovered;
    if (!showHover) {
      return Container(
        height: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.calendarFreeFill,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
        ),
      );
    }

    return _GradientBorderContainer(
      topColor: AppTheme.calendarHoverStrokeTop,
      bottomColor: AppTheme.calendarHoverStrokeBottom,
      borderWidth: AppTheme.slotBorderThickness,
      borderRadius: AppTheme.borderRadiusSmall,
      fillColor: AppTheme.containerColor1,
      child: Center(
        child: Text(
          widget.hourText ?? '',
          textAlign: TextAlign.center,
          style: AppTheme.safeOutfit(
            fontSize: 17.0,
            fontWeight: FontWeight.w600,
            color: AppTheme.elementColor2,
          ),
        ),
      ),
    );
  }

  Widget _buildReserved() {
    return _GradientBorderContainer(
      topColor: AppTheme.calendarReservedStrokeTop,
      bottomColor: AppTheme.calendarReservedStrokeBottom,
      borderWidth: AppTheme.slotBorderThickness,
      borderRadius: AppTheme.borderRadiusSmall,
      fillColor: AppTheme.containerColor2,
      boxShadow: const [
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.1),
          offset: Offset(0, 2),
          blurRadius: 4,
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                widget.consultantName ?? '',
                overflow: TextOverflow.ellipsis,
                style: AppTheme.safeOutfit(
                  fontSize: 17.0,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.elementColor3,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.timeText ?? '',
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.safeOutfit(
                  fontSize: 15.0,
                  fontWeight: AppTheme.fontWeightMedium,
                  color: AppTheme.elementColor2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GradientBorderContainer extends StatelessWidget {
  final Color topColor;
  final Color bottomColor;
  final double borderWidth;
  final double borderRadius;
  final Color fillColor;
  final List<BoxShadow>? boxShadow;
  final Widget child;

  const _GradientBorderContainer({
    required this.topColor,
    required this.bottomColor,
    required this.borderWidth,
    required this.borderRadius,
    required this.fillColor,
    this.boxShadow,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [topColor, bottomColor],
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: boxShadow,
      ),
      child: Padding(
        padding: EdgeInsets.all(borderWidth),
        child: Container(
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(borderRadius - 0.5),
          ),
          child: child,
        ),
      ),
    );
  }
}


