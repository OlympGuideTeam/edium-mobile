import 'dart:convert';

import 'package:edium/core/storage/hive_storage.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

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

class _BoxView extends StatefulWidget {
  final Box<String> box;
  final bool isQuizBox;

  const _BoxView({required this.box, required this.isQuizBox});

  @override
  State<_BoxView> createState() => _BoxViewState();
}

class _BoxViewState extends State<_BoxView> {
  @override
  Widget build(BuildContext context) {
    final keys = widget.box.keys.toList();
    if (keys.isEmpty) {
      return const Center(
        child: Text('Бокс пуст', style: AppTextStyles.subtitle),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: keys.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final key = keys[i].toString();
        final value = widget.box.get(key) ?? '';
        final displayValue = _formatValue(value);

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      key,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  // View full
                  if (widget.isQuizBox && !key.startsWith('_'))
                    IconButton(
                      icon: const Icon(Icons.visibility_outlined,
                          size: 18, color: AppColors.textSecondary),
                      onPressed: () => _showFull(context, key, value),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Подробнее',
                    ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        size: 18, color: AppColors.error),
                    onPressed: () async {
                      await widget.box.delete(key);
                      setState(() {});
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Удалить',
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                displayValue,
                style: AppTextStyles.caption.copyWith(
                  fontFamily: 'monospace',
                  fontSize: 11,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatValue(String value) {
    try {
      final json = jsonDecode(value);
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(json);
    } catch (_) {
      return value;
    }
  }

  void _showFull(BuildContext context, String key, String value) {
    final formatted = _formatValue(value);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, controller) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Key: $key',
                style: AppTextStyles.subtitle
                    .copyWith(color: AppColors.primary),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  controller: controller,
                  child: SelectableText(
                    formatted,
                    style: AppTextStyles.caption.copyWith(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
