import 'package:edium/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

part 'edium_tab_bar_edium_tab_bar.dart';
part 'edium_tab_bar_tab_item.dart';


class EdiumTabItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;


  final VoidCallback? onDoubleTap;

  const EdiumTabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.onDoubleTap,
  });
}

