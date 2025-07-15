// lib/widgets/common/loading_indicator_widget.dart

import 'package:flutter/material.dart';
import 'package:bliindaidating/app_constants.dart'; // Assuming AppConstants has colors

class LoadingIndicatorWidget extends StatelessWidget {
  final Color? color;
  final double size;
  final double strokeWidth;

  const LoadingIndicatorWidget({
    super.key,
    this.color,
    this.size = 40.0,
    this.strokeWidth = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    final defaultColor = Theme.of(context).colorScheme.secondary;
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(color ?? defaultColor),
        strokeWidth: strokeWidth,
      ),
    );
  }
}