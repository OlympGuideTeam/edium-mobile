import 'package:edium/core/di/injection.dart';
import 'package:edium/core/storage/profile_storage.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/domain/entities/library_quiz.dart';
import 'package:edium/domain/usecases/library_quiz/get_quiz_for_student_usecase.dart';
import 'package:edium/presentation/student/quiz_library/quiz_preview_screen.dart';
import 'package:edium/presentation/teacher/quiz_library/quiz_detail_screen.dart';
import 'package:flutter/material.dart';

class QuizLinkScreen extends StatefulWidget {
  final String quizId;

  const QuizLinkScreen({super.key, required this.quizId});

  @override
  State<QuizLinkScreen> createState() => _QuizLinkScreenState();
}

class _QuizLinkScreenState extends State<QuizLinkScreen> {
  @override
  void initState() {
    super.initState();
    final role = getIt<ProfileStorage>().getRole();
    if (role == 'teacher') {
      // QuizDetailScreen loads itself — navigate immediately after first frame
      WidgetsBinding.instance.addPostFrameCallback((_) => _replaceWithTeacher());
    } else {
      _loadAndReplaceWithStudent();
    }
  }

  void _replaceWithTeacher() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => QuizDetailScreen(quizId: widget.quizId),
      ),
    );
  }

  Future<void> _loadAndReplaceWithStudent() async {
    try {
      final quiz = await getIt<GetQuizForStudentUsecase>().call(widget.quizId);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => QuizPreviewScreen(quiz: quiz)),
      );
    } catch (_) {
      if (mounted) setState(() => _error = true);
    }
  }

  bool _error = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.mono900,
      ),
      body: Center(
        child: _error
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Квиз не найден', style: AppTextStyles.screenSubtitle),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      setState(() => _error = false);
                      _loadAndReplaceWithStudent();
                    },
                    child: const Text('Повторить'),
                  ),
                ],
              )
            : const CircularProgressIndicator(
                color: AppColors.mono700, strokeWidth: 2),
      ),
    );
  }
}
