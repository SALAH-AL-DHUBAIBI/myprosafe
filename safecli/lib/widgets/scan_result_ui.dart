import 'package:flutter/material.dart';
import '../models/scan_result.dart';

/// Presentation-layer extension on [ScanResult].
///
/// All UI-specific mappings (Color, icons) live here — never in the model.
/// Import this file only in widgets and views that need to render scan results.
///
/// The domain model [ScanResult] in models/ remains free of any Flutter imports.
extension ScanResultPresentation on ScanResult {
  /// Returns the theme-aware color for this result's safety status.
  Color safetyColor(BuildContext context) {
    if (safe == true) return Theme.of(context).colorScheme.tertiary;
    if (safe == false) return Theme.of(context).colorScheme.error;
    return Theme.of(context).colorScheme.secondary;
  }

  /// Returns the appropriate icon for this result's safety status.
  IconData get safetyIcon {
    if (safe == true) return Icons.check_circle_outline;
    if (safe == false) return Icons.dangerous_outlined;
    return Icons.warning_amber_outlined;
  }
}
