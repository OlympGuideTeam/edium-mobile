import 'package:edium/core/di/injection.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/domain/usecases/quiz/get_quiz_results_usecase.dart';
import 'package:flutter/material.dart';

part 'quiz_results_screen_result_stat.dart';
part 'quiz_results_screen_student_result_tile.dart';


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

