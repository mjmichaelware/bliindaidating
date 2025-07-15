// lib/widgets/dashboard_shell/side_menu_item.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';

/// Side Menu Item (Enhanced with Hover and Animation)
class SideMenuItem extends StatefulWidget {
  final IconData icon;
  final String title;
  final String routeName;
  final bool isSelected;
  final bool isEnabled;
  final bool isCollapsed;
  final ValueChanged<int>? onTabSelected; // For main dashboard tabs
  final int? tabIndex; // Corresponding tab index for onTabSelected
  final Animation<double> expandAnimation;

  const SideMenuItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.routeName,
    this.isSelected = false,
    this.isEnabled = true,
    required this.isCollapsed,
    this.onTabSelected,
    this.tabIndex,
    required this.expandAnimation,
  }) : super(key: key);

  @override
  State<SideMenuItem> createState() => _SideMenuItemState();
}

class _SideMenuItemState extends State<SideMenuItem> with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _hoverAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: AppConstants.animationDurationShort,
    );
    _hoverAnimation = CurvedAnimation(parent: _hoverController, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final isDarkMode = themeController.isDarkMode;

    final Color textColor = isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor;
    final Color selectedItemColor = isDarkMode ? AppConstants.secondaryColor : AppConstants.lightSecondaryColor;
    final Color unselectedItemColor = isDarkMode ? AppConstants.textMediumEmphasis : AppConstants.lightTextMediumEmphasis;
    final Color disabledColor = isDarkMode ? AppConstants.textLowEmphasis.withOpacity(0.3) : AppConstants.lightTextLowEmphasis.withOpacity(0.3);

    final Color currentIconColor = widget.isEnabled
        ? (widget.isSelected ? selectedItemColor : unselectedItemColor)
        : disabledColor;
    final Color currentTextColor = widget.isEnabled
        ? (widget.isSelected ? textColor : unselectedItemColor)
        : disabledColor;

    return MouseRegion(
      onEnter: (_) {
        if (widget.isEnabled) _hoverController.forward();
      },
      onExit: (_) {
        if (widget.isEnabled) _hoverController.reverse();
      },
      child: GestureDetector(
        onTap: widget.isEnabled
            ? () {
                if (widget.onTabSelected != null && widget.tabIndex != null) {
                  widget.onTabSelected!(widget.tabIndex!);
                } else {
                  context.go(widget.routeName);
                }
              }
            : null,
        child: AnimatedBuilder(
          animation: Listenable.merge([widget.expandAnimation, _hoverAnimation]),
          builder: (context, child) {
            final double expandFactor = widget.expandAnimation.value;
            final double hoverFactor = _hoverAnimation.value;

            return Container(
              margin: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingSmall,
                vertical: AppConstants.paddingExtraSmall,
              ),
              decoration: BoxDecoration(
                color: widget.isSelected && widget.isEnabled
                    ? selectedItemColor.withOpacity(0.2 + 0.1 * hoverFactor)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                border: widget.isSelected && widget.isEnabled
                    ? Border.all(color: selectedItemColor.withOpacity(0.5 + 0.2 * hoverFactor), width: 1.0 + 0.5 * hoverFactor)
                    : null,
                boxShadow: [
                  if (widget.isSelected && widget.isEnabled)
                    BoxShadow(
                      color: selectedItemColor.withOpacity(0.2 * hoverFactor + 0.1),
                      blurRadius: 8 * hoverFactor + 4,
                      spreadRadius: 2 * hoverFactor + 1,
                    ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingMedium,
                  vertical: AppConstants.paddingSmall,
                ),
                child: Row(
                  children: [
                    Icon(
                      widget.icon,
                      color: Color.lerp(currentIconColor, selectedItemColor, hoverFactor),
                      size: AppConstants.fontSizeExtraLarge * (1.0 + 0.1 * hoverFactor),
                    ),
                    SizedBox(width: AppConstants.spacingMedium * expandFactor),
                    Expanded(
                      child: ClipRect(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          widthFactor: expandFactor,
                          child: Opacity(
                            opacity: expandFactor,
                            child: Text(
                              widget.title,
                              style: TextStyle(
                                color: Color.lerp(currentTextColor, textColor, hoverFactor),
                                fontSize: AppConstants.fontSizeMedium,
                                fontFamily: 'Inter',
                                fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}