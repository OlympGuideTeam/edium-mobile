import 'dart:async';

import 'package:edium/core/di/injection.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/domain/entities/live_question.dart';
import 'package:edium/domain/entities/question.dart';
import 'package:edium/domain/entities/live_results.dart';
import 'package:edium/domain/repositories/live_repository.dart';
import 'package:edium/presentation/live/student/bloc/live_student_bloc.dart';
import 'package:edium/presentation/live/student/bloc/live_student_event.dart';
import 'package:edium/presentation/live/student/bloc/live_student_state.dart';
import 'package:edium/presentation/shared/mixins/screen_protection_mixin.dart';
import 'package:edium/presentation/shared/test/attempt_review_screen.dart';
import 'package:edium/services/live_ws/live_ws_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class LiveStudentScreen extends StatefulWidget {
  final String sessionId;
  final String attemptId;
  final String wsToken;
  final String quizTitle;
  final int questionCount;
  final String? moduleId;

  const LiveStudentScreen({
    super.key,
    required this.sessionId,
    required this.attemptId,
    required this.wsToken,
    required this.quizTitle,
    required this.questionCount,
    this.moduleId,
  });

  @override
  State<LiveStudentScreen> createState() => _LiveStudentScreenState();
}

class _LiveStudentScreenState extends State<LiveStudentScreen>
    with WidgetsBindingObserver, ScreenProtectionMixin {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LiveStudentBloc(
        repo: getIt<ILiveRepository>(),
        ws: getIt<LiveWsService>(),
      )..add(LiveStudentStart(
          sessionId: widget.sessionId,
          attemptId: widget.attemptId,
          wsToken: widget.wsToken,
          quizTitle: widget.quizTitle,
          questionCount: widget.questionCount,
          moduleId: widget.moduleId,
        )),
      child: _LiveStudentBody(quizTitle: widget.quizTitle, attemptId: widget.attemptId),
    );
  }
}

class _LiveStudentBody extends StatelessWidget {
  final String quizTitle;
  final String attemptId;

  const _LiveStudentBody({required this.quizTitle, required this.attemptId});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _darkTheme(),
      child: BlocConsumer<LiveStudentBloc, LiveStudentState>(
        listener: (context, state) {
          if (state is LiveStudentCompleted) {
            context.read<LiveStudentBloc>().add(LiveStudentLoadResults());
          }
        },
        builder: (context, state) {
          return switch (state) {
            LiveStudentInitial() || LiveStudentConnecting() => _LoadingPhase(quizTitle: quizTitle),
            LiveStudentLobby() => _LobbyPhase(
                quizTitle: quizTitle,
                state: state,
              ),
            LiveStudentQuestionActive() => _QuestionPhase(state: state),
            LiveStudentQuestionLocked() => _LockedPhase(state: state),
            LiveStudentCompleted() || LiveStudentResultsLoading() => _LoadingPhase(quizTitle: quizTitle),
            LiveStudentResultsLoaded() => _ResultsPhase(state: state, attemptId: attemptId),
            LiveStudentKicked() => _KickedPhase(),
            LiveStudentError() => _ErrorPhase(message: state.message),
          };
        },
      ),
    );
  }

  ThemeData _darkTheme() => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.liveDarkBg,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.liveAccent,
          surface: AppColors.liveDarkSurface,
        ),
      );
}

// ─── Loading ─────────────────────────────────────────────────────────────────

class _LoadingPhase extends StatelessWidget {
  final String quizTitle;
  const _LoadingPhase({required this.quizTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.liveAccent),
            const SizedBox(height: 24),
            Text(
              quizTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Подключение...',
              style: TextStyle(color: AppColors.liveDarkMuted, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Lobby ───────────────────────────────────────────────────────────────────

class _LobbyPhase extends StatelessWidget {
  final String quizTitle;
  final LiveStudentLobby state;

  const _LobbyPhase({
    required this.quizTitle,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    quizTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                    textAlign: TextAlign.start,
                    maxLines: 6,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Participant list
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LobbySectionLabel(
                      label: 'Присоединились',
                      trailing: '${state.participants.length}',
                    ),
                    const SizedBox(height: 8),
                    if (state.participants.isEmpty)
                      _LobbyEmptyCard()
                    else
                      ...state.participants.map(
                        (p) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _LobbyParticipantTile(name: p.name),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: const _PulsingWaitBadge(),
        ),
      ),
    );
  }
}

class _LobbySectionLabel extends StatelessWidget {
  final String label;
  final String trailing;
  const _LobbySectionLabel({required this.label, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.liveDarkMuted,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          height: 18,
          padding: const EdgeInsets.symmetric(horizontal: 7),
          decoration: BoxDecoration(
            color: AppColors.liveDarkSurface,
            borderRadius: BorderRadius.circular(999),
          ),
          alignment: Alignment.center,
          child: Text(
            trailing,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white70,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ],
    );
  }
}

class _LobbyParticipantTile extends StatelessWidget {
  final String name;
  const _LobbyParticipantTile({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.liveDarkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.liveDarkBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.liveDarkSurface,
              borderRadius: BorderRadius.circular(9),
            ),
            alignment: Alignment.center,
            child: Text(
              _initials(name),
              style: const TextStyle(
                color: AppColors.liveDarkMuted,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _LobbyEmptyCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.liveDarkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.liveDarkBorder),
      ),
      child: const Column(
        children: [
          Icon(Icons.people_outline, color: AppColors.liveDarkMuted, size: 32),
          SizedBox(height: 8),
          Text(
            'Ждём участников...',
            style: TextStyle(color: AppColors.liveDarkMuted, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _PulsingWaitBadge extends StatefulWidget {
  final String text;
  const _PulsingWaitBadge({this.text = 'Ожидайте начала квиза'});

  @override
  State<_PulsingWaitBadge> createState() => _PulsingWaitBadgeState();
}

class _PulsingWaitBadgeState extends State<_PulsingWaitBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.5, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.liveDarkSurface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          widget.text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.liveDarkMuted,
            fontSize: 14,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}

// ─── Question Active ──────────────────────────────────────────────────────────

class _QuestionPhase extends StatelessWidget {
  final LiveStudentQuestionActive state;
  const _QuestionPhase({required this.state});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _QuestionHeader(
              index: state.questionIndex,
              deadlineAt: state.deadlineAt,
              timeLimitSec: state.timeLimitSec,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.question.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (!state.hasAnswered)
                      _AnswerOptions(
                        question: state.question,
                        onSelect: (answerData) {
                          context.read<LiveStudentBloc>().add(
                                LiveStudentSubmitAnswer(
                                  questionId: state.question.id,
                                  answerData: answerData,
                                ),
                              );
                        },
                      )
                    else
                      _AnsweredOverlay(question: state.question, myAnswer: state.myAnswer!),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// _QuestionHeader: StatelessWidget — не перестраивается само по себе.
// Два дочерних виджета управляют своей анимацией независимо:
//   _TimerBadge   — Timer раз в секунду (текст + цвет бейджа)
//   _TimerProgressBar — AnimationController плавно заполняет бар без мерцания
class _QuestionHeader extends StatelessWidget {
  final int index;
  final DateTime deadlineAt;
  final int timeLimitSec;

  const _QuestionHeader({
    required this.index,
    required this.deadlineAt,
    required this.timeLimitSec,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.liveDarkSurface,
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Вопрос $index',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const Spacer(),
              _TimerBadge(
                deadlineAt: deadlineAt,
                timeLimitSec: timeLimitSec,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _TimerProgressBar(
            deadlineAt: deadlineAt,
            timeLimitSec: timeLimitSec,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

// Бейдж с таймером: перестраивается только раз в секунду.
class _TimerBadge extends StatefulWidget {
  final DateTime deadlineAt;
  final int timeLimitSec;

  const _TimerBadge({
    required this.deadlineAt,
    required this.timeLimitSec,
  });

  @override
  State<_TimerBadge> createState() => _TimerBadgeState();
}

class _TimerBadgeState extends State<_TimerBadge> {
  late int _secondsLeft;
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _secondsLeft = _computeSeconds();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _secondsLeft = _computeSeconds());
    });
  }

  int _computeSeconds() =>
      widget.deadlineAt.difference(DateTime.now()).inSeconds
          .clamp(0, widget.timeLimitSec);

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isUrgent = _secondsLeft <= 5;
    final m = _secondsLeft ~/ 60;
    final s = _secondsLeft % 60;
    final label = _secondsLeft >= 60
        ? '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}'
        : '$_secondsLeft с';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isUrgent ? AppColors.liveAccent : Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: isUrgent ? Colors.white : AppColors.liveDarkBg,
          letterSpacing: 0.8,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

// Полоса прогресса: AnimationController плавно везёт fill от текущей
// доли до 1.0 за оставшееся время — никакого Ticker на родителе,
// AnimatedBuilder перерисовывает только эту полосу.
class _TimerProgressBar extends StatefulWidget {
  final DateTime deadlineAt;
  final int timeLimitSec;

  const _TimerProgressBar({
    required this.deadlineAt,
    required this.timeLimitSec,
  });

  @override
  State<_TimerProgressBar> createState() => _TimerProgressBarState();
}

class _TimerProgressBarState extends State<_TimerProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    final totalMs = widget.timeLimitSec > 0 ? widget.timeLimitSec * 1000 : 1;
    final started =
        widget.deadlineAt.subtract(Duration(seconds: widget.timeLimitSec));
    final elapsedMs =
        DateTime.now().difference(started).inMilliseconds.clamp(0, totalMs);
    final remainingMs = totalMs - elapsedMs;
    final startFraction = (elapsedMs / totalMs).clamp(0.0, 1.0);

    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: remainingMs),
    );
    _anim = Tween<double>(begin: startFraction, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.linear),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final urgent = _anim.value >= 0.85;
        final fillColor =
            urgent ? Colors.redAccent : AppColors.liveAccent;
        return Container(
          height: 6,
          decoration: BoxDecoration(
            color: AppColors.liveDarkCard,
            borderRadius: BorderRadius.circular(999),
          ),
          clipBehavior: Clip.antiAlias,
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: _anim.value,
              heightFactor: 1.0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                decoration: BoxDecoration(
                  color: fillColor,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AnswerOptions extends StatefulWidget {
  final LiveQuestion question;
  final ValueChanged<Map<String, dynamic>> onSelect;

  const _AnswerOptions({required this.question, required this.onSelect});

  @override
  State<_AnswerOptions> createState() => _AnswerOptionsState();
}

class _AnswerOptionsState extends State<_AnswerOptions> {
  String? _selectedId;
  final Set<String> _selectedIds = {};
  final TextEditingController _textCtrl = TextEditingController();

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return switch (widget.question.type) {
      QuestionType.multiChoice => _buildMultiChoice(),
      QuestionType.withGivenAnswer => _buildTextInput(multiline: false),
      QuestionType.withFreeAnswer => _buildTextInput(multiline: true),
      QuestionType.drag => _LiveDragQuestion(
          question: widget.question,
          onConfirm: (order) => widget.onSelect({'order': order}),
        ),
      QuestionType.connection => _LiveConnectionQuestion(
          question: widget.question,
          onConfirm: (pairs) => widget.onSelect({'pairs': pairs}),
        ),
      _ => _buildSingleChoice(),
    };
  }

  Widget _buildSingleChoice() {
    return Column(
      children: widget.question.options.map((opt) {
        final isSelected = _selectedId == opt.id;
        return GestureDetector(
          onTap: () {
            setState(() => _selectedId = opt.id);
            widget.onSelect({'selected_option_id': opt.id});
          },
          child: _OptionCard(
            isSelected: isSelected,
            child: Row(
              children: [
                _RadioDot(isSelected: isSelected),
                const SizedBox(width: 12),
                Expanded(child: _OptionText(opt.text, isSelected: isSelected)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMultiChoice() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...widget.question.options.map((opt) {
          final isSelected = _selectedIds.contains(opt.id);
          return GestureDetector(
            onTap: () => setState(() {
              if (isSelected) {
                _selectedIds.remove(opt.id);
              } else {
                _selectedIds.add(opt.id);
              }
            }),
            child: _OptionCard(
              isSelected: isSelected,
              child: Row(
                children: [
                  _CheckDot(isSelected: isSelected),
                  const SizedBox(width: 12),
                  Expanded(child: _OptionText(opt.text, isSelected: isSelected)),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 4),
        _ConfirmButton(
          enabled: _selectedIds.isNotEmpty,
          onTap: () =>
              widget.onSelect({'selected_option_ids': _selectedIds.toList()}),
        ),
      ],
    );
  }

  Widget _buildTextInput({required bool multiline}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.liveDarkCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.liveDarkBorder),
          ),
          child: TextField(
            controller: _textCtrl,
            maxLines: multiline ? 4 : 1,
            style: const TextStyle(fontSize: 15, color: Colors.white),
            cursorColor: AppColors.liveAccent,
            enableInteractiveSelection: false,
            contextMenuBuilder: (context, editableTextState) => const SizedBox.shrink(),
            decoration: InputDecoration(
              hintText: multiline ? 'Введите развёрнутый ответ…' : 'Введите ответ…',
              hintStyle: const TextStyle(
                  color: AppColors.liveDarkMuted, fontSize: 15),
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: multiline
                  ? const EdgeInsets.all(16)
                  : const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        const SizedBox(height: 12),
        _ConfirmButton(
          enabled: _textCtrl.text.trim().isNotEmpty,
          onTap: () => widget.onSelect({'text': _textCtrl.text.trim()}),
        ),
      ],
    );
  }
}

// ── Shared answer-card primitives ─────────────────────────────────────────────

class _OptionCard extends StatelessWidget {
  final bool isSelected;
  final Widget child;

  const _OptionCard({required this.isSelected, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.liveDarkSurface : AppColors.liveDarkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.liveAccent : AppColors.liveDarkBorder,
          width: 1.5,
        ),
      ),
      child: child,
    );
  }
}

class _RadioDot extends StatelessWidget {
  final bool isSelected;
  const _RadioDot({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? AppColors.liveAccent : const Color(0xFF4A4A4A),
          width: isSelected ? 6 : 2,
        ),
      ),
    );
  }
}

class _CheckDot extends StatelessWidget {
  final bool isSelected;
  const _CheckDot({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.liveAccent : Colors.transparent,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: isSelected ? AppColors.liveAccent : const Color(0xFF4A4A4A),
          width: 2,
        ),
      ),
      child: isSelected
          ? const Icon(Icons.check, size: 13, color: Colors.white)
          : null,
    );
  }
}

class _OptionText extends StatelessWidget {
  final String text;
  final bool isSelected;
  const _OptionText(this.text, {required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 15,
        color: isSelected ? Colors.white : Colors.white70,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        height: 1.4,
      ),
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;
  const _ConfirmButton({required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: enabled ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.mono900,
          disabledBackgroundColor: AppColors.liveDarkCard,
          disabledForegroundColor: AppColors.liveDarkMuted,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: const Text(
          'Подтвердить',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

// ── Answered overlay ──────────────────────────────────────────────────────────

class _AnsweredOverlay extends StatelessWidget {
  final LiveQuestion question;
  final Map<String, dynamic> myAnswer;

  const _AnsweredOverlay({required this.question, required this.myAnswer});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildAnswerDisplay(),
        const SizedBox(height: 20),
        _WaitingBanner(),
      ],
    );
  }

  Widget _buildAnswerDisplay() {
    switch (question.type) {
      case QuestionType.multiChoice:
        final selectedIds = ((myAnswer['selected_option_ids'] as List<dynamic>? ??
                    myAnswer['option_ids'] as List<dynamic>?) ??
                [])
            .map((e) => e.toString())
            .toSet();
        return Column(
          children: question.options.map((opt) {
            final isSelected = selectedIds.contains(opt.id);
            return _LockedOption(
              isSelected: isSelected,
              indicator: _CheckDot(isSelected: isSelected),
              text: opt.text,
              trailing: isSelected
                  ? const Icon(Icons.check_circle_rounded,
                      color: AppColors.liveAccent, size: 20)
                  : null,
            );
          }).toList(),
        );

      case QuestionType.withGivenAnswer:
      case QuestionType.withFreeAnswer:
        final text = myAnswer['text'] as String? ?? '';
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.liveDarkSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.liveAccent, width: 1.5),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.liveAccent, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        );

      case QuestionType.drag:
        final order = ((myAnswer['order'] as List<dynamic>?) ?? [])
            .map((e) => e.toString())
            .toList();
        return Column(
          children: order.asMap().entries.map((e) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.liveDarkSurface,
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: AppColors.liveAccent, width: 1.5),
              ),
              child: Row(
                children: [
                  Text(
                    '${e.key + 1}',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.liveDarkMuted),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(e.value,
                        style: const TextStyle(
                            fontSize: 15, color: Colors.white)),
                  ),
                ],
              ),
            );
          }).toList(),
        );

      case QuestionType.connection:
        final rawPairs = (myAnswer['pairs'] as Map<String, dynamic>?)
                ?.map((k, v) => MapEntry(k, v.toString())) ??
            {};
        return _AnsweredConnectionDisplay(
          question: question,
          myPairs: rawPairs,
        );

      default:
        final selectedId = myAnswer['selected_option_id'] as String? ??
            myAnswer['option_id'] as String?;
        return Column(
          children: question.options.map((opt) {
            final isSelected = selectedId == opt.id;
            return _LockedOption(
              isSelected: isSelected,
              indicator: _RadioDot(isSelected: isSelected),
              text: opt.text,
              trailing: isSelected
                  ? const Icon(Icons.check_circle_rounded,
                      color: AppColors.liveAccent, size: 20)
                  : null,
            );
          }).toList(),
        );
    }
  }
}

class _LockedOption extends StatelessWidget {
  final bool isSelected;
  final Widget indicator;
  final String text;
  final Widget? trailing;

  const _LockedOption({
    required this.isSelected,
    required this.indicator,
    required this.text,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Opacity(
        opacity: isSelected ? 1.0 : 0.45,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.liveDarkSurface : AppColors.liveDarkCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.liveAccent : AppColors.liveDarkBorder,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              indicator,
              const SizedBox(width: 12),
              Expanded(child: _OptionText(text, isSelected: isSelected)),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}

class _WaitingBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.liveDarkSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.hourglass_top_rounded,
              color: AppColors.liveDarkMuted, size: 18),
          SizedBox(width: 8),
          Text(
            'Ждём других участников...',
            style: TextStyle(color: AppColors.liveDarkMuted, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// ─── Drag (live, dark) ───────────────────────────────────────────────────────

class _LiveDragQuestion extends StatefulWidget {
  final LiveQuestion question;
  final ValueChanged<List<String>> onConfirm;

  const _LiveDragQuestion({required this.question, required this.onConfirm});

  @override
  State<_LiveDragQuestion> createState() => _LiveDragQuestionState();
}

class _LiveDragQuestionState extends State<_LiveDragQuestion> {
  late List<String> _items;

  @override
  void initState() {
    super.initState();
    _items = (widget.question.metadata?['items'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Перетащите элементы в правильном порядке:',
          style: TextStyle(fontSize: 13, color: AppColors.liveDarkMuted),
        ),
        const SizedBox(height: 12),
        Theme(
          data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
          child: ReorderableListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            proxyDecorator: (child, index, animation) => Material(
              elevation: 6,
              color: Colors.transparent,
              shadowColor: Colors.black26,
              borderRadius: BorderRadius.circular(12),
              clipBehavior: Clip.antiAlias,
              child: child,
            ),
            onReorder: (oldIdx, newIdx) {
              setState(() {
                if (newIdx > oldIdx) newIdx--;
                final item = _items.removeAt(oldIdx);
                _items.insert(newIdx, item);
              });
            },
            children: _items.asMap().entries.map((e) {
              final i = e.key;
              final item = e.value;
              return ReorderableDragStartListener(
                key: ValueKey(item),
                index: i,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.liveDarkCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.liveDarkBorder),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${i + 1}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.liveDarkMuted,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item,
                          style: const TextStyle(
                              fontSize: 15, color: Colors.white),
                        ),
                      ),
                      const Icon(Icons.drag_handle,
                          color: AppColors.liveDarkMuted, size: 20),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 4),
        _ConfirmButton(
          enabled: _items.isNotEmpty,
          onTap: () => widget.onConfirm(List.from(_items)),
        ),
      ],
    );
  }
}

// ─── Connection (live, dark) ──────────────────────────────────────────────────

class _LiveConnectionQuestion extends StatefulWidget {
  final LiveQuestion question;
  final ValueChanged<Map<String, String>> onConfirm;

  const _LiveConnectionQuestion(
      {required this.question, required this.onConfirm});

  @override
  State<_LiveConnectionQuestion> createState() =>
      _LiveConnectionQuestionState();
}

class _LiveConnectionQuestionState extends State<_LiveConnectionQuestion> {
  String? _selectedLeft;
  final Map<String, String> _pairs = {};

  late List<GlobalKey> _leftKeys;
  late List<GlobalKey> _rightKeys;
  final _stackKey = GlobalKey();

  List<String> get _leftItems =>
      (widget.question.metadata?['left'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
      [];

  List<String> get _rightItems =>
      (widget.question.metadata?['right'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
      [];

  @override
  void initState() {
    super.initState();
    _initKeys();
  }

  void _initKeys() {
    _leftKeys = List.generate(_leftItems.length, (_) => GlobalKey());
    _rightKeys = List.generate(_rightItems.length, (_) => GlobalKey());
  }

  void _onTapLeft(String item) =>
      setState(() => _selectedLeft = _selectedLeft == item ? null : item);

  void _onTapRight(String item) {
    if (_selectedLeft == null) return;
    setState(() {
      _pairs.removeWhere((_, v) => v == item);
      _pairs[_selectedLeft!] = item;
      _selectedLeft = null;
    });
  }

  void _removePair(String left) =>
      setState(() => _pairs.remove(left));

  Rect? _rectOf(GlobalKey key) {
    final box = key.currentContext?.findRenderObject() as RenderBox?;
    final stackBox =
        _stackKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || stackBox == null) return null;
    final tl = stackBox.globalToLocal(box.localToGlobal(Offset.zero));
    return tl & box.size;
  }

  List<({Rect fromRect, Rect toRect, String leftItem})> _arrowData() {
    final left = _leftItems;
    final right = _rightItems;
    final result = <({Rect fromRect, Rect toRect, String leftItem})>[];
    for (final entry in _pairs.entries) {
      final li = left.indexOf(entry.key);
      final ri = right.indexOf(entry.value);
      if (li == -1 || ri == -1) continue;
      final from = _rectOf(_leftKeys[li]);
      final to = _rectOf(_rightKeys[ri]);
      if (from != null && to != null) {
        result.add((fromRect: from, toRect: to, leftItem: entry.key));
      }
    }
    return result;
  }

  void _onTapStack(TapUpDetails details) {
    for (final arrow in _arrowData()) {
      final from = Offset(arrow.fromRect.right, arrow.fromRect.center.dy);
      final to = Offset(arrow.toRect.left, arrow.toRect.center.dy);
      final mid = Offset((from.dx + to.dx) / 2, (from.dy + to.dy) / 2);
      if ((details.localPosition - mid).distance < 20) {
        _removePair(arrow.leftItem);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final left = _leftItems;
    final right = _rightItems;
    final rowCount = left.length > right.length ? left.length : right.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Нажмите на элемент слева, затем на соответствующий справа:',
          style: TextStyle(fontSize: 13, color: AppColors.liveDarkMuted),
        ),
        const SizedBox(height: 14),
        GestureDetector(
          onTapUp: _onTapStack,
          child: Stack(
            key: _stackKey,
            children: [
              Column(
                children: List.generate(rowCount, (i) {
                  final l = i < left.length ? left[i] : null;
                  final r = i < right.length ? right[i] : null;
                  final isLeftSel = l != null && _selectedLeft == l;
                  final isLeftPaired = l != null && _pairs.containsKey(l);
                  final isRightPaired = r != null && _pairs.values.contains(r);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: SizedBox(
                      height: 72,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: l != null
                                ? GestureDetector(
                                    onTap: () => _onTapLeft(l),
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        AnimatedContainer(
                                          key: _leftKeys[i],
                                          duration: const Duration(
                                              milliseconds: 150),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 10),
                                          decoration: BoxDecoration(
                                            color: isLeftSel
                                                ? AppColors.liveAccent
                                                    .withValues(alpha: 0.2)
                                                : isLeftPaired
                                                    ? AppColors.liveDarkSurface
                                                    : AppColors.liveDarkCard,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color: isLeftSel
                                                  ? AppColors.liveAccent
                                                  : isLeftPaired
                                                      ? AppColors.liveDarkMuted
                                                      : AppColors.liveDarkBorder,
                                              width: isLeftSel ? 2 : 1.5,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              l,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: isLeftSel
                                                    ? AppColors.liveAccent
                                                    : Colors.white,
                                              ),
                                              textAlign: TextAlign.center,
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          right: -5,
                                          top: 0,
                                          bottom: 0,
                                          child: Center(
                                            child: _LiveEdgeDot(
                                              active: isLeftPaired || isLeftSel,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                          const SizedBox(width: 32),
                          Expanded(
                            child: r != null
                                ? GestureDetector(
                                    onTap: () => _onTapRight(r),
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        AnimatedContainer(
                                          key: _rightKeys[i],
                                          duration: const Duration(
                                              milliseconds: 150),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 10),
                                          decoration: BoxDecoration(
                                            color: isRightPaired
                                                ? AppColors.liveDarkSurface
                                                : AppColors.liveDarkCard,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color: isRightPaired
                                                  ? AppColors.liveDarkMuted
                                                  : AppColors.liveDarkBorder,
                                              width: 1.5,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              r,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white,
                                              ),
                                              textAlign: TextAlign.center,
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left: -5,
                                          top: 0,
                                          bottom: 0,
                                          child: Center(
                                            child: _LiveEdgeDot(
                                              active: isRightPaired,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _LiveArrowPainter(arrows: _arrowData()),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        _ConfirmButton(
          enabled: _pairs.length == left.length,
          onTap: () => widget.onConfirm(Map.from(_pairs)),
        ),
      ],
    );
  }
}

class _LiveEdgeDot extends StatelessWidget {
  final bool active;
  const _LiveEdgeDot({required this.active});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? AppColors.liveDarkMuted : AppColors.liveDarkCard,
        border: Border.all(
          color: active ? AppColors.liveDarkMuted : AppColors.liveDarkBorder,
          width: 1.5,
        ),
      ),
    );
  }
}

class _LiveArrowPainter extends CustomPainter {
  final List<({Rect fromRect, Rect toRect, String leftItem})> arrows;
  const _LiveArrowPainter({required this.arrows});

  @override
  void paint(Canvas canvas, Size size) {
    if (arrows.isEmpty) return;
    final paint = Paint()
      ..color = AppColors.liveDarkMuted
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (final a in arrows) {
      final from = Offset(a.fromRect.right, a.fromRect.center.dy);
      final to = Offset(a.toRect.left, a.toRect.center.dy);
      if ((to - from).distance < 4) continue;
      final dx = (to.dx - from.dx) * 0.5;
      final path = Path()..moveTo(from.dx, from.dy);
      path.cubicTo(
          from.dx + dx, from.dy, to.dx - dx, to.dy, to.dx, to.dy);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_LiveArrowPainter old) => old.arrows != arrows;
}

// ─── Question Locked ─────────────────────────────────────────────────────────

class _LockedPhase extends StatelessWidget {
  final LiveStudentQuestionLocked state;
  const _LockedPhase({required this.state});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header mirrors _QuestionHeader layout to prevent layout shift
            Container(
              color: AppColors.liveDarkSurface,
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'Вопрос ${state.questionIndex}',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                      const Spacer(),
                      _CorrectnessBadge(myResult: state.myResult),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.liveDarkCard,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: 1.0,
                        heightFactor: 1.0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF22C55E),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.question.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildLockedContent(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: _PulsingWaitBadge(text: 'Ожидайте следующий вопрос...'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLockedContent() {
    switch (state.question.type) {
      case QuestionType.singleChoice:
      case QuestionType.multiChoice:
        return _LockedChoiceDistribution(
          question: state.question,
          stats: state.stats is LiveChoiceStats
              ? state.stats as LiveChoiceStats
              : null,
          correctAnswer: state.correctAnswer,
          myAnswer: state.myAnswer,
        );
      case QuestionType.withGivenAnswer:
        return _WordCloudView(
          words: state.wordCloud ?? [],
          correctAnswers: state.correctAnswer.correctAnswers ?? [],
        );
      case QuestionType.drag:
        return _LockedDragResult(correctAnswer: state.correctAnswer);
      case QuestionType.connection:
        final rawPairs =
            state.myAnswer?['pairs'] as Map<String, dynamic>?;
        if (rawPairs != null && rawPairs.isNotEmpty) {
          return _LockedConnectionMyAnswer(
            question: state.question,
            myPairs: rawPairs.map((k, v) => MapEntry(k, v.toString())),
            correctPairs: state.correctAnswer.correctPairs ?? {},
          );
        }
        return _LockedConnectionResult(correctAnswer: state.correctAnswer);
      default:
        return const SizedBox.shrink();
    }
  }
}

class _LockedChoiceDistribution extends StatelessWidget {
  final LiveQuestion question;
  final LiveChoiceStats? stats;
  final LiveCorrectAnswer correctAnswer;
  final Map<String, dynamic>? myAnswer;

  const _LockedChoiceDistribution({
    required this.question,
    required this.stats,
    required this.correctAnswer,
    this.myAnswer,
  });

  @override
  Widget build(BuildContext context) {
    final total = stats?.answeredCount ?? 0;
    final correctIds = _correctIds();
    final selectedIds = _selectedIds();
    final isMulti = question.type == QuestionType.multiChoice;

    return Column(
      children: question.options.map((opt) {
        final dist = stats?.distribution
            .where((d) => d.optionId == opt.id)
            .firstOrNull;
        final pct = total > 0 ? (dist?.count ?? 0) / total : 0.0;
        final isCorrectOpt = correctIds.contains(opt.id);

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _LockedOptionFillCell(
            text: opt.text,
            fillFraction: pct,
            isCorrect: isCorrectOpt,
            isMulti: isMulti,
            isSelected: selectedIds.contains(opt.id),
          ),
        );
      }).toList(),
    );
  }

  Set<String> _selectedIds() {
    if (myAnswer == null) return {};
    final singleId = myAnswer!['selected_option_id'] as String? ??
        myAnswer!['option_id'] as String?;
    if (singleId != null) return {singleId};
    final multiIds = (myAnswer!['selected_option_ids'] as List<dynamic>?) ??
        (myAnswer!['option_ids'] as List<dynamic>?);
    if (multiIds != null) return multiIds.map((e) => e.toString()).toSet();
    return {};
  }

  Set<String> _correctIds() {
    if (correctAnswer.correctOptionIds != null) {
      return correctAnswer.correctOptionIds!.toSet();
    }
    if (correctAnswer.correctOptionId != null) {
      return {correctAnswer.correctOptionId!};
    }
    return {};
  }
}

class _LockedOptionFillCell extends StatelessWidget {
  final String text;
  final double fillFraction;
  final bool isCorrect;
  final bool isMulti;
  final bool isSelected;

  const _LockedOptionFillCell({
    required this.text,
    required this.fillFraction,
    required this.isCorrect,
    required this.isMulti,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF22C55E);
    final borderColor = isCorrect ? green : AppColors.liveDarkBorder;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.liveDarkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerLeft,
              child: AnimatedFractionallySizedBox(
                duration: const Duration(milliseconds: 400),
                widthFactor: fillFraction.clamp(0.0, 1.0),
                heightFactor: 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: isCorrect
                        ? green.withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                _LockedChoiceIndicator(
                    isCorrect: isCorrect, isMulti: isMulti, isSelected: isSelected),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isCorrect ? Colors.white : Colors.white70,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LockedChoiceIndicator extends StatelessWidget {
  final bool isCorrect;
  final bool isMulti;
  final bool isSelected;

  const _LockedChoiceIndicator({
    required this.isCorrect,
    required this.isMulti,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF22C55E);
    const red = Colors.redAccent;

    final Color borderColor;
    final Color bgColor;
    final Widget? inner;

    if (isSelected && isCorrect) {
      borderColor = green;
      bgColor = green;
      inner = isMulti
          ? const Icon(Icons.check, size: 12, color: Colors.white)
          : Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Colors.white));
    } else if (isSelected && !isCorrect) {
      borderColor = red;
      bgColor = red;
      inner = isMulti
          ? const Icon(Icons.close, size: 12, color: Colors.white)
          : Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Colors.white));
    } else if (!isSelected && isCorrect) {
      borderColor = green.withValues(alpha: 0.6);
      bgColor = green.withValues(alpha: 0.1);
      inner = isMulti
          ? Icon(Icons.check, size: 12, color: green.withValues(alpha: 0.7))
          : Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: green.withValues(alpha: 0.5)));
    } else {
      borderColor = const Color(0xFF4A4A4A);
      bgColor = Colors.transparent;
      inner = null;
    }

    return Container(
      width: 20,
      height: 20,
      decoration: isMulti
          ? BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: borderColor, width: 1.5),
            )
          : BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: 1.5),
            ),
      child: inner != null ? Center(child: inner) : null,
    );
  }
}

class _LockedDragResult extends StatelessWidget {
  final LiveCorrectAnswer correctAnswer;
  const _LockedDragResult({required this.correctAnswer});

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF22C55E);
    final order = correctAnswer.correctOrder ?? [];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.liveDarkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.liveDarkBorder),
      ),
      child: Column(
        children: order.asMap().entries.map((e) {
          final isLast = e.key == order.length - 1;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: isLast
                  ? null
                  : const Border(
                      bottom: BorderSide(
                          color: AppColors.liveDarkBorder, width: 1)),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${e.key + 1}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: green,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    e.value,
                    style: const TextStyle(fontSize: 15, color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _LockedConnectionResult extends StatelessWidget {
  final LiveCorrectAnswer correctAnswer;
  const _LockedConnectionResult({required this.correctAnswer});

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF22C55E);
    final pairs = correctAnswer.correctPairs ?? {};

    return Container(
      decoration: BoxDecoration(
        color: AppColors.liveDarkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.liveDarkBorder),
      ),
      child: Column(
        children: pairs.entries.toList().asMap().entries.map((e) {
          final isLast = e.key == pairs.length - 1;
          final entry = e.value;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: isLast
                  ? null
                  : const Border(
                      bottom: BorderSide(
                          color: AppColors.liveDarkBorder, width: 1)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    entry.key,
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(Icons.arrow_forward_rounded,
                      size: 16, color: green),
                ),
                Expanded(
                  child: Text(
                    entry.value,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Correctness badge ───────────────────────────────────────────────────────

class _CorrectnessBadge extends StatelessWidget {
  final LiveStudentResult? myResult;
  const _CorrectnessBadge({required this.myResult});

  @override
  Widget build(BuildContext context) {
    if (myResult == null) {
      return Container(
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.liveDarkCard,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.liveDarkBorder),
        ),
        child: const Text(
          'Нет ответа',
          style: TextStyle(
            color: AppColors.liveDarkMuted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
    const green = Color(0xFF22C55E);
    final isCorrect = myResult!.isCorrect;
    final color = isCorrect ? green : Colors.redAccent;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCorrect ? Icons.check_rounded : Icons.close_rounded,
            size: 13,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            isCorrect ? 'Верно' : 'Неверно',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Word cloud ───────────────────────────────────────────────────────────────

class _WordCloudView extends StatelessWidget {
  final List<String> words;
  final List<String> correctAnswers;

  const _WordCloudView({
    required this.words,
    required this.correctAnswers,
  });

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF22C55E);
    final correctSet =
        correctAnswers.map((a) => a.toLowerCase().trim()).toSet();

    final freq = <String, int>{};
    for (final w in words) {
      freq[w] = (freq[w] ?? 0) + 1;
    }

    final someoneCorrect =
        freq.keys.any((w) => correctSet.contains(w.toLowerCase().trim()));
    final showNote = !someoneCorrect;

    final maxFreq =
        freq.values.fold(1, (a, b) => a > b ? a : b);

    final entries = freq.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (entries.isNotEmpty) ...[
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: entries.map((e) {
              final isCorrect =
                  correctSet.contains(e.key.toLowerCase().trim());
              final fontSize = 13.0 + (e.value / maxFreq) * 14.0;
              return Text(
                e.key,
                style: TextStyle(
                  fontSize: fontSize,
                  color: isCorrect ? green : Colors.white70,
                  fontWeight:
                      isCorrect ? FontWeight.w700 : FontWeight.w400,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],
        if (showNote && correctAnswers.isNotEmpty)
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: green.withValues(alpha: 0.35)),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline,
                    color: green, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Правильный ответ: ${correctAnswers.join(', ')}',
                    style: const TextStyle(
                      color: green,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (entries.isEmpty && correctAnswers.isEmpty)
          const Text(
            'Никто не ответил',
            style: TextStyle(color: AppColors.liveDarkMuted, fontSize: 14),
          ),
      ],
    );
  }
}

// ─── Connection locked (my answer + correct highlights) ──────────────────────

class _LockedConnectionMyAnswer extends StatefulWidget {
  final LiveQuestion question;
  final Map<String, String> myPairs;
  final Map<String, String> correctPairs;

  const _LockedConnectionMyAnswer({
    required this.question,
    required this.myPairs,
    required this.correctPairs,
  });

  @override
  State<_LockedConnectionMyAnswer> createState() =>
      _LockedConnectionMyAnswerState();
}

class _LockedConnectionMyAnswerState
    extends State<_LockedConnectionMyAnswer> {
  late List<GlobalKey> _leftKeys;
  late List<GlobalKey> _rightKeys;
  final _stackKey = GlobalKey();

  List<String> get _leftItems =>
      (widget.question.metadata?['left'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
      [];

  List<String> get _rightItems =>
      (widget.question.metadata?['right'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
      [];

  @override
  void initState() {
    super.initState();
    _leftKeys = List.generate(_leftItems.length, (_) => GlobalKey());
    _rightKeys = List.generate(_rightItems.length, (_) => GlobalKey());
    // Trigger repaint after layout so GlobalKey positions are available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  Rect? _rectOf(GlobalKey key) {
    final box = key.currentContext?.findRenderObject() as RenderBox?;
    final stackBox =
        _stackKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || stackBox == null) return null;
    final tl = stackBox.globalToLocal(box.localToGlobal(Offset.zero));
    return tl & box.size;
  }

  List<({Rect fromRect, Rect toRect, bool isCorrect})> _arrowData() {
    final left = _leftItems;
    final right = _rightItems;
    final result = <({Rect fromRect, Rect toRect, bool isCorrect})>[];

    // Wrong user connections drawn first (under green arrows)
    for (final entry in widget.myPairs.entries) {
      if (widget.correctPairs[entry.key] == entry.value) continue;
      final li = left.indexOf(entry.key);
      final ri = right.indexOf(entry.value);
      if (li == -1 || ri == -1) continue;
      final from = _rectOf(_leftKeys[li]);
      final to = _rectOf(_rightKeys[ri]);
      if (from != null && to != null) {
        result.add((fromRect: from, toRect: to, isCorrect: false));
      }
    }

    // All correct connections on top (green, over red)
    for (final entry in widget.correctPairs.entries) {
      final li = left.indexOf(entry.key);
      final ri = right.indexOf(entry.value);
      if (li == -1 || ri == -1) continue;
      final from = _rectOf(_leftKeys[li]);
      final to = _rectOf(_rightKeys[ri]);
      if (from != null && to != null) {
        result.add((fromRect: from, toRect: to, isCorrect: true));
      }
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final left = _leftItems;
    final right = _rightItems;
    final rowCount = left.length > right.length ? left.length : right.length;

    return Stack(
      key: _stackKey,
      children: [
        Column(
          children: List.generate(rowCount, (i) {
            final l = i < left.length ? left[i] : null;
            final r = i < right.length ? right[i] : null;
            final isLeftPaired = l != null && widget.myPairs.containsKey(l);
            final isLeftCorrect = l != null &&
                isLeftPaired &&
                widget.correctPairs[l] == widget.myPairs[l];
            final isRightPaired = r != null && widget.myPairs.values.contains(r);
            final rightLeftKey =
                r != null ? widget.myPairs.entries.where((e) => e.value == r).firstOrNull?.key : null;
            final isRightCorrect = rightLeftKey != null &&
                widget.correctPairs[rightLeftKey] == r;

            const green = Color(0xFF22C55E);

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SizedBox(
                height: 72,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: l != null
                          ? Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  key: _leftKeys[i],
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isLeftPaired
                                        ? AppColors.liveDarkSurface
                                        : AppColors.liveDarkCard,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isLeftCorrect
                                          ? green
                                          : isLeftPaired
                                              ? Colors.redAccent
                                              : AppColors.liveDarkBorder,
                                      width: isLeftPaired ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      l,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: -5,
                                  top: 0,
                                  bottom: 0,
                                  child: Center(
                                    child: _LiveEdgeDot(
                                        active: isLeftPaired),
                                  ),
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),
                    const SizedBox(width: 32),
                    Expanded(
                      child: r != null
                          ? Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  key: _rightKeys[i],
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isRightPaired
                                        ? AppColors.liveDarkSurface
                                        : AppColors.liveDarkCard,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isRightCorrect
                                          ? green
                                          : isRightPaired
                                              ? Colors.redAccent
                                              : AppColors.liveDarkBorder,
                                      width: isRightPaired ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      r,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: -5,
                                  top: 0,
                                  bottom: 0,
                                  child: Center(
                                    child: _LiveEdgeDot(
                                        active: isRightPaired),
                                  ),
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _LockedArrowPainter(arrows: _arrowData()),
            ),
          ),
        ),
      ],
    );
  }
}

class _LockedArrowPainter extends CustomPainter {
  final List<({Rect fromRect, Rect toRect, bool isCorrect})> arrows;
  const _LockedArrowPainter({required this.arrows});

  @override
  void paint(Canvas canvas, Size size) {
    if (arrows.isEmpty) return;
    const green = Color(0xFF22C55E);

    for (final a in arrows) {
      final paint = Paint()
        ..color = a.isCorrect ? green : Colors.redAccent
        ..strokeWidth = a.isCorrect ? 2.0 : 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final from = Offset(a.fromRect.right, a.fromRect.center.dy);
      final to = Offset(a.toRect.left, a.toRect.center.dy);
      if ((to - from).distance < 4) continue;
      final dx = (to.dx - from.dx) * 0.5;
      final path = Path()..moveTo(from.dx, from.dy);
      path.cubicTo(
          from.dx + dx, from.dy, to.dx - dx, to.dy, to.dx, to.dy);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_LockedArrowPainter old) => old.arrows != arrows;
}

// ─── Connection answered (locked, no correctness) ────────────────────────────

class _AnsweredConnectionDisplay extends StatefulWidget {
  final LiveQuestion question;
  final Map<String, String> myPairs;

  const _AnsweredConnectionDisplay({
    required this.question,
    required this.myPairs,
  });

  @override
  State<_AnsweredConnectionDisplay> createState() =>
      _AnsweredConnectionDisplayState();
}

class _AnsweredConnectionDisplayState
    extends State<_AnsweredConnectionDisplay> {
  late List<GlobalKey> _leftKeys;
  late List<GlobalKey> _rightKeys;
  final _stackKey = GlobalKey();

  List<String> get _leftItems =>
      (widget.question.metadata?['left'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
      [];

  List<String> get _rightItems =>
      (widget.question.metadata?['right'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
      [];

  @override
  void initState() {
    super.initState();
    _leftKeys = List.generate(_leftItems.length, (_) => GlobalKey());
    _rightKeys = List.generate(_rightItems.length, (_) => GlobalKey());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  Rect? _rectOf(GlobalKey key) {
    final box = key.currentContext?.findRenderObject() as RenderBox?;
    final stackBox =
        _stackKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || stackBox == null) return null;
    final tl = stackBox.globalToLocal(box.localToGlobal(Offset.zero));
    return tl & box.size;
  }

  List<({Rect fromRect, Rect toRect})> _arrowData() {
    final left = _leftItems;
    final right = _rightItems;
    final result = <({Rect fromRect, Rect toRect})>[];
    for (final entry in widget.myPairs.entries) {
      final li = left.indexOf(entry.key);
      final ri = right.indexOf(entry.value);
      if (li == -1 || ri == -1) continue;
      final from = _rectOf(_leftKeys[li]);
      final to = _rectOf(_rightKeys[ri]);
      if (from != null && to != null) {
        result.add((fromRect: from, toRect: to));
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final left = _leftItems;
    final right = _rightItems;
    final rowCount = left.length > right.length ? left.length : right.length;

    return Stack(
      key: _stackKey,
      children: [
        Column(
          children: List.generate(rowCount, (i) {
            final l = i < left.length ? left[i] : null;
            final r = i < right.length ? right[i] : null;
            final isLeftPaired = l != null && widget.myPairs.containsKey(l);
            final isRightPaired =
                r != null && widget.myPairs.values.contains(r);

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SizedBox(
                height: 72,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: l != null
                          ? Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  key: _leftKeys[i],
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isLeftPaired
                                        ? AppColors.liveDarkSurface
                                        : AppColors.liveDarkCard,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isLeftPaired
                                          ? AppColors.liveDarkMuted
                                          : AppColors.liveDarkBorder,
                                      width: isLeftPaired ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      l,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: -5,
                                  top: 0,
                                  bottom: 0,
                                  child: Center(
                                    child:
                                        _LiveEdgeDot(active: isLeftPaired),
                                  ),
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),
                    const SizedBox(width: 32),
                    Expanded(
                      child: r != null
                          ? Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  key: _rightKeys[i],
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isRightPaired
                                        ? AppColors.liveDarkSurface
                                        : AppColors.liveDarkCard,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isRightPaired
                                          ? AppColors.liveDarkMuted
                                          : AppColors.liveDarkBorder,
                                      width: isRightPaired ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      r,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: -5,
                                  top: 0,
                                  bottom: 0,
                                  child: Center(
                                    child:
                                        _LiveEdgeDot(active: isRightPaired),
                                  ),
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _NeutralArrowPainter(arrows: _arrowData()),
            ),
          ),
        ),
      ],
    );
  }
}

class _NeutralArrowPainter extends CustomPainter {
  final List<({Rect fromRect, Rect toRect})> arrows;
  const _NeutralArrowPainter({required this.arrows});

  @override
  void paint(Canvas canvas, Size size) {
    if (arrows.isEmpty) return;
    final paint = Paint()
      ..color = AppColors.liveDarkMuted
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (final a in arrows) {
      final from = Offset(a.fromRect.right, a.fromRect.center.dy);
      final to = Offset(a.toRect.left, a.toRect.center.dy);
      if ((to - from).distance < 4) continue;
      final dx = (to.dx - from.dx) * 0.5;
      final path = Path()..moveTo(from.dx, from.dy);
      path.cubicTo(from.dx + dx, from.dy, to.dx - dx, to.dy, to.dx, to.dy);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_NeutralArrowPainter old) => old.arrows != arrows;
}

// ─── Results ─────────────────────────────────────────────────────────────────

class _ResultsPhase extends StatelessWidget {
  final LiveStudentResultsLoaded state;
  final String attemptId;
  const _ResultsPhase({required this.state, required this.attemptId});

  static const _green = Color(0xFF22C55E);

  String _fmt(double v) =>
      v % 1 == 0 ? v.toInt().toString() : v.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    final r = state.results;
    final pct = r.maxScore > 0 ? (r.myScore / r.maxScore * 100).round() : 0;
    final progress =
        r.maxScore > 0 ? (r.myScore / r.maxScore).clamp(0.0, 1.0) : 0.0;
    final wrongCount = r.questionsCount - r.correctCount;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Score header ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _ResultPositionCircle(position: r.myPosition),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Квиз завершён',
                                style: TextStyle(
                                  color: AppColors.liveDarkMuted,
                                  fontSize: 12,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${r.myPosition} место из ${r.totalParticipants}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _fmt(r.myScore),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 40,
                                    fontWeight: FontWeight.w800,
                                    height: 1.0,
                                    letterSpacing: -1.5,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 5),
                                  child: Text(
                                    '/${_fmt(r.maxScore)}',
                                    style: const TextStyle(
                                      color: AppColors.liveDarkMuted,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      height: 1.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '$pct%',
                              style: const TextStyle(
                                color: AppColors.liveDarkMuted,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        height: 6,
                        color: AppColors.liveDarkCard,
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: progress,
                          child: Container(color: AppColors.liveAccent),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _DarkStatCard(
                            label: 'ПРАВИЛЬНО',
                            value: '${r.correctCount}',
                            valueColor: _green,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _DarkStatCard(
                            label: 'НЕВЕРНО',
                            value: '$wrongCount',
                            valueColor: Colors.redAccent,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _DarkStatCard(
                            label: 'ВОПРОСОВ',
                            value: '${r.questionsCount}',
                            valueColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              // ── Tabs ─────────────────────────────────────────────────
              const TabBar(
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.liveDarkMuted,
                indicatorColor: AppColors.liveAccent,
                dividerColor: AppColors.liveDarkBorder,
                tabs: [
                  Tab(text: 'Лидерборд'),
                  Tab(text: 'Разбор вопросов'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _LeaderboardTabContent(top: r.top),
                    AttemptReviewBody(attemptId: attemptId),
                  ],
                ),
              ),
              // ── Done button ───────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => context.pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.liveAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Готово',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
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

// ── Position circle ───────────────────────────────────────────────────────────

class _ResultPositionCircle extends StatelessWidget {
  final int position;
  const _ResultPositionCircle({required this.position});

  static const _gold = Color(0xFFFACC15);
  static const _silver = Color(0xFF94A3B8);
  static const _bronze = Color(0xFFFB923C);

  @override
  Widget build(BuildContext context) {
    final isTop3 = position >= 1 && position <= 3;
    final medalColor = [_gold, _silver, _bronze];

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isTop3
            ? medalColor[position - 1]
            : AppColors.liveDarkSurface,
        border: isTop3
            ? null
            : Border.all(color: AppColors.liveDarkBorder, width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        '$position',
        style: TextStyle(
          color: isTop3 ? Colors.white : Colors.white70,
          fontSize: isTop3 ? 20 : 18,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

// ── Dark stat card ────────────────────────────────────────────────────────────

class _DarkStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _DarkStatCard({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.liveDarkCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.liveDarkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: AppColors.liveDarkMuted,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: valueColor,
              letterSpacing: -0.3,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Leaderboard tab ───────────────────────────────────────────────────────────

class _LeaderboardTabContent extends StatelessWidget {
  final List<LiveLeaderboardRow> top;
  const _LeaderboardTabContent({required this.top});

  @override
  Widget build(BuildContext context) {
    if (top.isEmpty) {
      return const Center(
        child: Text(
          'Нет данных',
          style: TextStyle(color: AppColors.liveDarkMuted, fontSize: 14),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      itemCount: top.length,
      itemBuilder: (_, i) =>
          _LeaderboardRow(row: top[i], isLast: i == top.length - 1),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  final LiveLeaderboardRow row;
  final bool isLast;

  const _LeaderboardRow({required this.row, required this.isLast});

  static const _gold = Color(0xFFFACC15);
  static const _silver = Color(0xFF94A3B8);
  static const _bronze = Color(0xFFFB923C);

  @override
  Widget build(BuildContext context) {
    final isMe = row.isMe;
    final isTop3 = row.position >= 1 && row.position <= 3;
    final medalColors = [_gold, _silver, _bronze];

    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isMe
            ? AppColors.liveAccent.withValues(alpha: 0.12)
            : AppColors.liveDarkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMe
              ? AppColors.liveAccent.withValues(alpha: 0.5)
              : AppColors.liveDarkBorder,
          width: isMe ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          isTop3
              ? Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: medalColors[row.position - 1],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${row.position}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                )
              : SizedBox(
                  width: 28,
                  child: Text(
                    '${row.position}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.liveDarkMuted,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              row.name.isNotEmpty ? row.name : '—',
              style: TextStyle(
                color: isMe ? Colors.white : Colors.white70,
                fontSize: 15,
                fontWeight: isMe ? FontWeight.w700 : FontWeight.w400,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isMe) ...[
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.liveAccent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Я',
                style: TextStyle(
                  color: AppColors.liveAccent,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Text(
            row.score.toStringAsFixed(row.score % 1 == 0 ? 0 : 1),
            style: TextStyle(
              color: isMe ? AppColors.liveAccent : Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}


// ─── Helpers ────────────────────────────────────────────────────────────────

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.length >= 2) {
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
  return name.isNotEmpty ? name[0].toUpperCase() : '?';
}

// ─── Kicked ──────────────────────────────────────────────────────────────────

class _KickedPhase extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.block_rounded, color: Colors.redAccent, size: 56),
              const SizedBox(height: 20),
              const Text(
                'Вас исключили из квиза',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => context.pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.liveDarkSurface,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('Выйти'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Error ───────────────────────────────────────────────────────────────────

class _ErrorPhase extends StatelessWidget {
  final String message;
  const _ErrorPhase({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded,
                  color: AppColors.liveDarkMuted, size: 48),
              const SizedBox(height: 20),
              Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => context.pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.liveDarkSurface,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('Выйти'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
