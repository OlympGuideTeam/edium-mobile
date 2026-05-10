import 'package:edium/core/di/injection.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/domain/entities/live_session.dart';
import 'package:edium/domain/repositories/live_repository.dart';
import 'package:edium/presentation/live/live_session_completed_navigation.dart';
import 'package:edium/presentation/shared/widgets/edium_button.dart';
import 'package:edium/services/network/api_exception.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class LiveJoinNameScreen extends StatefulWidget {
  final LiveSessionMeta meta;

  const LiveJoinNameScreen({super.key, required this.meta});

  @override
  State<LiveJoinNameScreen> createState() => _LiveJoinNameScreenState();
}

class _LiveJoinNameScreenState extends State<LiveJoinNameScreen> {
  final _nameController = TextEditingController();
  final _nameFocus = FocusNode();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Введите ваше имя');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final repo = getIt<ILiveRepository>();
      final join = await repo.joinLiveSession(
        sessionId: widget.meta.sessionId,
        name: name,
      );

      if (!mounted) return;

      final moduleId = join.moduleId ?? widget.meta.moduleId;
      context.pushReplacement(
        '/live/${widget.meta.sessionId}/student',
        extra: {
          'attemptId': join.attemptId,
          'wsToken': join.wsToken,
          'quizTitle': widget.meta.quizTitle,
          'questionCount': widget.meta.questionCount,
          if (moduleId != null) 'moduleId': moduleId,
        },
      );
    } catch (e) {
      if (!mounted) return;
      final m = widget.meta;
      if (tryNavigateLiveStudentAfterJoinSessionCompleted(
            e,
            context: context,
            sessionId: m.sessionId,
            quizTitle: m.quizTitle,
            questionCount: m.questionCount,
            moduleId: m.moduleId,
            replaceCurrentRoute: true,
          )) {
        setState(() => _loading = false);
        return;
      }
      setState(() {
        _loading = false;
        _error = e is ApiException && e.code == 'SESSION_COMPLETED'
            ? e.message
            : 'Не удалось войти. Попробуйте ещё раз.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _nameFocus.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.mono900),
            onPressed: () => context.pop(),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(widget.meta.quizTitle, style: AppTextStyles.h2),
                const SizedBox(height: 4),
                Text(
                  '${widget.meta.questionCount} вопросов',
                  style: const TextStyle(fontSize: 14, color: AppColors.mono400),
                ),
                const SizedBox(height: 40),
                const Text('Как вас зовут?', style: AppTextStyles.h3),
                const SizedBox(height: 12),
                TextField(
                  controller: _nameController,
                  focusNode: _nameFocus,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  style: AppTextStyles.body,
                  onChanged: (_) {
                    if (_error != null) setState(() => _error = null);
                  },
                  onSubmitted: (_) => _join(),
                  decoration: InputDecoration(
                    hintText: 'Имя',
                    hintStyle: const TextStyle(color: AppColors.mono300),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.mono200, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.mono700, width: 1.5),
                    ),
                    errorText: _error,
                  ),
                ),
                const Spacer(),
                EdiumButton(
                  label: _loading ? 'Подключение...' : 'Войти',
                  onPressed: _loading ? null : _join,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
