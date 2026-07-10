import 'package:flutter/material.dart';
extension PriorityExtension on int {
  // Returns the hazard color for the  high priority level (1–5)
  Color get priorityColor {
    switch (this) {
      case 1:
        return Colors.red[900]!;
      case 2:
        return Colors.orange[800]!;
      case 3:
        return Colors.yellow[700]!;
      case 4:
        return Colors.green[300]!;
      case 5:
        return Colors.blue[200]!;
      default:
        return Colors.grey;
    }
  }

  // Returns labels for the priority level (1–5)
  String get priorityLabel {
    switch (this) {
      case 1:
        return 'Critical';
      case 2:
        return 'Urgent';
      case 3:
        return 'Moderate';
      case 4:
        return 'Minor';
      case 5:
        return 'Non‑urgent';
      default:
        return '';
    }
  }
}

//priority values (1–5) for dropdowns
const List<int> priorityValues = [1, 2, 3, 4, 5];