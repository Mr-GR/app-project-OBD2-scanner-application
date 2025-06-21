import 'package:flutter/material.dart';

// Utility functions for color operations
class ColorUtil {
  static Color? fromString(String? colorString) {
    if (colorString == null || colorString.isEmpty) return null;
    
    // Handle hex colors
    if (colorString.startsWith('#')) {
      try {
        return Color(int.parse(colorString.substring(1), radix: 16));
      } catch (e) {
        return null;
      }
    }
    
    // Handle named colors
    switch (colorString.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'pink':
        return Colors.pink;
      case 'brown':
        return Colors.brown;
      case 'grey':
      case 'gray':
        return Colors.grey;
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.white;
      default:
        return null;
    }
  }

  static String toColorString(Color? color) {
    if (color == null) return '';
    return '#${color.value.toRadixString(16).padLeft(8, '0')}';
  }
} 