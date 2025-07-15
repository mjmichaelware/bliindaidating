// lib/widgets/dashboard_shell/side_menu_category_item.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';
import 'package:bliindaidating/widgets/dashboard_shell/side_menu_item.dart'; // Import the new SideMenuItem

/// Side Menu Category Item (Enhanced ExpansionTile)
class SideMenuCategoryItem extends StatefulWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final bool isCollapsed;
  final Animation<double> expandAnimation;

  const SideMenuCategoryItem({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
    required this.isCollapsed,
    required this.expandAnimation,
  });

  @override
  State<SideMenuCategoryItem> createState() => _SideMenuCategoryItemState();
}

class _SideMenuCategoryItemState extends State<SideMenuCategoryItem> with SingleTickerProviderStateMixin {
  late AnimationController _expansionController;
  late Animation<double> _expansionAnimation;
  late AnimationController _hoverController;
  late Animation<double> _hoverAnimation;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _expansionController = AnimationController(
      vsync: this,
      duration: AppConstants.animationDurationMedium,
    );
    _expansionAnimation = CurvedAnimation(parent: _expansionController, curve: Curves.easeInOutCubic);

    _hoverController = AnimationController(
      vsync: this,
      duration: AppConstants.animationDurationShort,
    );
    _hoverAnimation = CurvedAnimation(parent: _hoverController, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _expansionController.dispose();
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final isDarkMode = themeController.isDarkMode;

    final Color textColor = isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor;
    final Color unselectedItemColor = isDarkMode ? AppConstants.textMediumEmphasis : AppConstants.lightTextMediumEmphasis;
    final Color selectedItemColor = isDarkMode ? AppConstants.secondaryColor : AppConstants.lightSecondaryColor;

    return MouseRegion(
      onEnter: (_) => _hoverController.forward(),
      onExit: (_) => _hoverController.reverse(),
      child: AnimatedBuilder(
        animation: Listenable.merge([widget.expandAnimation, _hoverAnimation, _expansionAnimation]),
        builder: (context, child) {
          final double expandFactor = widget.expandAnimation.value;
          final double hoverFactor = _hoverAnimation.value;

          return Container(
            margin: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingSmall,
              vertical: AppConstants.paddingExtraSmall,
            ),
            decoration: BoxDecoration(
              color: _isExpanded
                  ? selectedItemColor.withOpacity(0.15 + 0.05 * hoverFactor)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
              border: _isExpanded
                  ? Border.all(color: selectedItemColor.withOpacity(0.3 + 0.1 * hoverFactor), width: 1.0)
                  : null,
              boxShadow: [
                if (_isExpanded)
                  BoxShadow(
                    color: selectedItemColor.withOpacity(0.1 * hoverFactor + 0.05),
                    blurRadius: 5 * hoverFactor + 2,
                    spreadRadius: 1 * hoverFactor + 0.5,
                  ),
              ],
            ),
            child: ClipRRect( // Clip to prevent overflow during collapse
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
              child: Theme( // Override default ExpansionTile theme for custom styling
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                  listTileTheme: ListTileThemeData(
                    iconColor: unselectedItemColor,
                    textColor: textColor,
                    selectedColor: selectedItemColor,
                    minLeadingWidth: AppConstants.fontSizeExtraLarge,
                  ),
                ),
                child: ExpansionTile(
                  key: ValueKey(widget.title), // Key to ensure state is reset when title changes
                  onExpansionChanged: (bool expanded) {
                    setState(() {
                      _isExpanded = expanded;
                    });
                    if (expanded) {
                      _expansionController.forward();
                    } else {
                      _expansionController.reverse();
                    }
                  },
                  leading: Icon(
                    widget.icon,
                    color: Color.lerp(unselectedItemColor, selectedItemColor, hoverFactor),
                    size: AppConstants.fontSizeExtraLarge * (1.0 + 0.1 * hoverFactor),
                  ),
                  title: ClipRect(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      widthFactor: expandFactor,
                      child: Opacity(
                        opacity: expandFactor,
                        child: Text(
                          widget.title,
                          style: TextStyle(
                            color: Color.lerp(unselectedItemColor, textColor, hoverFactor),
                            fontSize: AppConstants.fontSizeMedium,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ),
                  trailing: AnimatedRotation(
                    turns: _isExpanded ? 0.25 : 0.0, // Rotate arrow when expanded
                    duration: AppConstants.animationDurationMedium,
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: unselectedItemColor.withOpacity(expandFactor),
                      size: AppConstants.fontSizeSmall * 1.5,
                    ),
                  ),
                  children: [
                    // Sub-items are only visible when expanded
                    Padding(
                      padding: EdgeInsets.only(left: AppConstants.paddingLarge * expandFactor),
                      child: SizeTransition(
                        sizeFactor: _expansionAnimation,
                        child: FadeTransition(
                          opacity: AlwaysStoppedAnimation<double>(_expansionAnimation.value),
                          child: Column(
                            children: widget.children.map<Widget>((child) {
                              // Ensure sub-items also respect the theme and expand factor
                              // The type check and re-creation ensures expandAnimation and isCollapsed are passed
                              if (child is SideMenuItem) {
                                return SideMenuItem( // Use the new SideMenuItem class
                                  key: child.key,
                                  icon: child.icon,
                                  title: child.title,
                                  routeName: child.routeName,
                                  isSelected: child.isSelected,
                                  isEnabled: child.isEnabled,
                                  isCollapsed: widget.isCollapsed, // Pass collapsed state from parent category
                                  onTabSelected: child.onTabSelected,
                                  tabIndex: child.tabIndex,
                                  expandAnimation: widget.expandAnimation, // Pass parent animation
                                );
                              }
                              return child; // Return other widget types as is
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}