import 'package:edium/core/di/injection.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/domain/usecases/quiz/get_quiz_results_usecase.dart';
import 'package:flutter/material.dart';

class QuizResultsScreen extends StatefulWidget {
  final String quizId;

  const QuizResultsScreen({super.key, required this.quizId});

  @override
  State<QuizResultsScreen> createState() => _QuizResultsScreenState();
}

class _QuizResultsScreenState extends State<QuizResultsScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await getIt<GetQuizResultsUsecase>()(widget.quizId);
      setState(() {
        _data = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Результаты квиза')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final totalAttempts = _data!['total_attempts'] as int;

    if (totalAttempts == 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.assessment_outlined,
                    size: 40, color: AppColors.primary),
              ),
              const SizedBox(height: 20),
              Text('Пока нет результатов', style: AppTextStyles.subtitle),
              const SizedBox(height: 8),
              Text(
                'Когда студенты пройдут квиз,\nих результаты появятся здесь.',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _ResultStat(
                  label: 'Прохождений',
                  value: '$totalAttempts',
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ResultStat(
                  label: 'Ср. балл',
                  value: '${_data!['average_score']}%',
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ResultStat(
                  label: 'Завершили',
                  value:
                      '${(((_data!['completion_rate'] as double) * 100)).round()}%',
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text('Результаты студентов', style: AppTextStyles.subtitle),
          const SizedBox(height: 12),
          ...(_data!['student_results'] as List)
              .map((r) =>
                  _StudentResultTile(result: r as Map<String, dynamic>)),
        ],
      ),
    );
  }
}

class _ResultStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ResultStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(76)),
      ),
      child: Column(
        children: [
          Text(value,
              style: AppTextStyles.heading3.copyWith(color: color)),
          const SizedBox(height: 4),
          Text(label,
              style: AppTextStyles.caption, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _StudentResultTile extends StatelessWidget {
  final Map<String, dynamic> result;

  const _StudentResultTile({required this.result});

  @override
  Widget build(BuildContext context) {
    final score = result['score'] as int;
    final total = result['total'] as int;
    final pct = total > 0 ? (score / total * 100).round() : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primaryLight,
            child: Text(
              (result['name'] as String)[0],
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(result['name'] as String,
                    style: AppTextStyles.bodySmall
                        .copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text('$score / $total вопросов',
                    style: AppTextStyles.caption),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: pct >= 70
                  ? AppColors.successLight
                  : AppColors.errorLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$pct%',
              style: AppTextStyles.caption.copyWith(
                color: pct >= 70 ? AppColors.success : AppColors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
