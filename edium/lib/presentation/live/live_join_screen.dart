import 'package:edium/core/di/injection.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/domain/entities/live_session.dart';
import 'package:edium/domain/repositories/live_repository.dart';
import 'package:edium/presentation/live/live_session_completed_navigation.dart';
import 'package:edium/presentation/shared/widgets/edium_button.dart';
import 'package:edium/services/network/api_exception.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

/// Screen shown when a student wants to join a live quiz by entering a 6-digit code.
/// Resolves the code → session meta → calls /live/join → pushes to live_lobby_student.
class LiveJoinScreen extends StatefulWidget {
  final String? prefillCode; // from deep link / QR

  const LiveJoinScreen({super.key, this.prefillCode});

  @override
  State<LiveJoinScreen> createState() => _LiveJoinScreenState();
}

class _LiveJoinScreenState extends State<LiveJoinScreen> {
  final _controller = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.prefillCode != null) {
      _controller.text = widget.prefillCode!;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    final code = _controller.text.trim();
    if (code.length != 6) {
      setState(() => _error = 'Введите 6-значный код');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    LiveSessionMeta? meta;
    try {
      final repo = getIt<ILiveRepository>();

      // Step 1: resolve code → session meta
      meta = await repo.resolveLiveCode(code);

      if (!mounted) return;

      if (meta.phase != LivePhase.lobby) {
        setState(() {
          _loading = false;
          _error = 'Лобби уже закрыто или квиз завершён';
        });
        return;
      }

      // Step 2: join — get attemptId + wsToken
      final join = await repo.joinLiveSession(sessionId: meta.sessionId);

      if (!mounted) return;

      final moduleId = join.moduleId ?? meta.moduleId;
      context.push(
        '/live/${meta.sessionId}/student',
        extra: {
          'attemptId': join.attemptId,
          'wsToken': join.wsToken,
          'quizTitle': meta.quizTitle,
          'questionCount': meta.questionCount,
          if (moduleId != null) 'moduleId': moduleId,
        },
      );
    } catch (e) {
      if (!mounted) return;
      final m = meta;
      if (m != null &&
          tryNavigateLiveStudentAfterJoinSessionCompleted(
            e,
            context: context,
            sessionId: m.sessionId,
            quizTitle: m.quizTitle,
            questionCount: m.questionCount,
            moduleId: m.moduleId,
          )) {
        setState(() => _loading = false);
        return;
      }
      setState(() {
        _loading = false;
        _error = e is ApiException && e.code == 'SESSION_COMPLETED'
            ? e.message
            : e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mono50,
      appBar: AppBar(
        backgroundColor: AppColors.mono50,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.mono900),
          onPressed: () => context.pop(),
        ),
        title: Text('Войти в квиз', style: AppTextStyles.h3),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Введите код',
              style: AppTextStyles.h2,
            ),
            const SizedBox(height: 8),
            Text(
              'Учитель покажет 6-значный код на экране',
              style: AppTextStyles.body.copyWith(color: AppColors.mono400),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              maxLength: 6,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                letterSpacing: 12,
                color: AppColors.mono900,
              ),
              decoration: InputDecoration(
                counterText: '',
                hintText: '······',
                hintStyle: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 12,
                  color: AppColors.mono200,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 20),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.mono200, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.mono900, width: 1.5),
                ),
              ),
              onSubmitted: (_) => _join(),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red[700], fontSize: 14),
              ),
            ],
            const Spacer(),
            EdiumButton(
              label: _loading ? 'Подключение...' : 'Войти',
              onPressed: _loading ? null : _join,
            ),
          ],
        ),
      ),
    );
  }
}
