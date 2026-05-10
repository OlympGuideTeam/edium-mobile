import 'dart:convert';

import 'package:edium/core/storage/hive_storage.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'debug_panel_screen_box_view.dart';


class DebugPanelScreen extends StatefulWidget {
  const DebugPanelScreen({super.key});

  @override
  State<DebugPanelScreen> createState() => _DebugPanelScreenState();
}

class _DebugPanelScreenState extends State<DebugPanelScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Hive Debug'),
        bottom: TabBar(
          controller: _tab,
          tabs: const [
            Tab(text: 'Quizzes'),
            Tab(text: 'Sessions'),
            Tab(text: 'Profile'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Очистить все',
            onPressed: () => _confirmClearAll(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Обновить',
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _BoxView(box: HiveStorage.quizzesBox, isQuizBox: true),
          _BoxView(box: HiveStorage.sessionsBox, isQuizBox: false),
          _BoxView(box: HiveStorage.profileBox, isQuizBox: false),
        ],
      ),
    );
  }

  void _confirmClearAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Очистить все данные?'),
        content:
            const Text('Все квизы и данные профиля будут удалены безвозвратно.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              await HiveStorage.quizzesBox.clear();
              await HiveStorage.sessionsBox.clear();
              await HiveStorage.profileBox.clear();
              if (context.mounted) Navigator.pop(context);
              setState(() {});
            },
            child: const Text('Удалить', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

