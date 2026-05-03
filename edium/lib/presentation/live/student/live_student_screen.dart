import 'dart:async';

import 'package:edium/core/di/injection.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/domain/entities/live_question.dart';
import 'package:edium/domain/entities/question.dart';
import 'package:edium/domain/entities/live_results.dart';
import 'package:edium/domain/entities/live_session.dart';
import 'package:edium/domain/repositories/live_repository.dart';
import 'package:edium/presentation/live/student/bloc/live_student_bloc.dart';
import 'package:edium/presentation/live/student/bloc/live_student_event.dart';
import 'package:edium/presentation/live/student/bloc/live_student_state.dart';
import 'package:edium/presentation/shared/mixins/screen_protection_mixin.dart';
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
      child: _LiveStudentBody(
        quizTitle: widget.quizTitle,
        questionCount: widget.questionCount,
      ),
    );
  }
}

class _LiveStudentBody extends StatelessWidget {
  final String quizTitle;
  final int questionCount;

  const _LiveStudentBody({
    required this.quizTitle,
    required this.questionCount,
  });

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
                questionCount: questionCount,
                state: state,
              ),
            LiveStudentQuestionActive() => _QuestionPhase(state: state),
            LiveStudentQuestionLocked() => _LockedPhase(state: state),
            LiveStudentCompleted() || LiveStudentResultsLoading() => _LoadingPhase(quizTitle: quizTitle),
            LiveStudentResultsLoaded() => _ResultsPhase(state: state),
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
  final int questionCount;
  final LiveStudentLobby state;

  const _LobbyPhase({
    required this.quizTitle,
    required this.questionCount,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.liveAccent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.bolt_rounded,
                  color: AppColors.liveAccent,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                quizTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                '$questionCount вопрос${_questionsSuffix(questionCount)}',
                style: const TextStyle(
                  color: AppColors.liveDarkMuted,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),
              // Participants counter
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.liveDarkSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.people_alt_outlined,
                        color: AppColors.liveDarkMuted, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      state.classmatesTotal != null && state.classmatesTotal! > 0
                          ? '${state.participants.length} из ${state.classmatesTotal} в классе'
                          : '${state.participants.length} подключилось',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: state.participants.isEmpty
                    ? Center(
                        child: Text(
                          'Ждём участников...',
                          style: TextStyle(
                            color: AppColors.liveDarkMuted,
                            fontSize: 15,
                          ),
                        ),
                      )
                    : _ParticipantGrid(participants: state.participants),
              ),
              const SizedBox(height: 24),
              const _PulsingWaitBadge(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  String _questionsSuffix(int n) {
    if (n % 10 == 1 && n % 100 != 11) return '';
    if (n % 10 >= 2 && n % 10 <= 4 && !(n % 100 >= 12 && n % 100 <= 14)) return 'а';
    return 'ов';
  }
}

class _ParticipantGrid extends StatelessWidget {
  final List<LiveLobbyParticipant> participants;
  const _ParticipantGrid({required this.participants});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: participants.map((p) => _ParticipantChip(name: p.name)).toList(),
    );
  }
}

class _ParticipantChip extends StatelessWidget {
  final String name;
  const _ParticipantChip({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.liveDarkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.liveDarkBorder),
      ),
      child: Text(
        name,
        style: const TextStyle(color: Colors.white, fontSize: 13),
      ),
    );
  }
}

class _PulsingWaitBadge extends StatefulWidget {
  const _PulsingWaitBadge();

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
      child: const Text(
        'Ожидайте начала квиза',
        style: TextStyle(
          color: AppColors.liveDarkMuted,
          fontSize: 14,
          letterSpacing: 0.3,
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
              total: state.questionTotal,
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

class _QuestionHeader extends StatefulWidget {
  final int index;
  final int total;
  final DateTime deadlineAt;
  final int timeLimitSec;

  const _QuestionHeader({
    required this.index,
    required this.total,
    required this.deadlineAt,
    required this.timeLimitSec,
  });

  @override
  State<_QuestionHeader> createState() => _QuestionHeaderState();
}

class _QuestionHeaderState extends State<_QuestionHeader> {
  late Timer _timer;
  late int _secondsLeft;

  @override
  void initState() {
    super.initState();
    _secondsLeft = widget.deadlineAt.difference(DateTime.now()).inSeconds.clamp(0, widget.timeLimitSec);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _secondsLeft = widget.deadlineAt.difference(DateTime.now()).inSeconds.clamp(0, widget.timeLimitSec);
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.timeLimitSec > 0 ? _secondsLeft / widget.timeLimitSec : 0.0;
    final isUrgent = _secondsLeft <= 5;

    return Container(
      color: AppColors.liveDarkSurface,
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
      child: Row(
        children: [
          Text(
            '${widget.index} / ${widget.total}',
            style: TextStyle(
              color: AppColors.liveDarkMuted,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: 48,
            height: 48,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 3,
                  backgroundColor: AppColors.liveDarkCard,
                  color: isUrgent ? Colors.redAccent : AppColors.liveAccent,
                ),
                Center(
                  child: Text(
                    '$_secondsLeft',
                    style: TextStyle(
                      color: isUrgent ? Colors.redAccent : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
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
          width: isSelected ? 2 : 1,
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
            border: Border.all(color: AppColors.liveAccent, width: 2),
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
        final pairs = (myAnswer['pairs'] as Map<String, dynamic>?)
                ?.map((k, v) => MapEntry(k, v.toString())) ??
            {};
        return Column(
          children: pairs.entries.map((entry) {
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
                  Expanded(
                    child: Text(entry.key,
                        style: const TextStyle(
                            fontSize: 14, color: Colors.white)),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.arrow_forward,
                        size: 16, color: AppColors.liveAccent),
                  ),
                  Expanded(
                    child: Text(entry.value,
                        style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            );
          }).toList(),
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
              width: isSelected ? 2 : 1,
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

  List<Widget> _buildLockedOptions() {
    const green = Color(0xFF22C55E);
    const greenBg = Color(0xFF16A34A);

    switch (state.question.type) {
      case QuestionType.drag:
        final order = state.correctAnswer.correctOrder ?? [];
        return order.asMap().entries.map((e) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: greenBg.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: green, width: 1.5),
              ),
              child: Row(
                children: [
                  Text(
                    '${e.key + 1}',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: green),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(e.value,
                        style: const TextStyle(
                            fontSize: 15, color: Colors.white)),
                  ),
                  const Icon(Icons.check_rounded, color: green, size: 18),
                ],
              ),
            ),
          );
        }).toList();

      case QuestionType.connection:
        final pairs = state.correctAnswer.correctPairs ?? {};
        return pairs.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: greenBg.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: green, width: 1.5),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(entry.key,
                        style: const TextStyle(
                            fontSize: 14, color: Colors.white)),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.arrow_forward, size: 16, color: green),
                  ),
                  Expanded(
                    child: Text(entry.value,
                        style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          );
        }).toList();

      default:
        final correctIds = state.question.type == QuestionType.multiChoice
            ? (state.correctAnswer.correctOptionIds?.toSet() ?? <String>{})
            : <String>{
                if (state.correctAnswer.correctOptionId != null)
                  state.correctAnswer.correctOptionId!
              };
        final isMulti = state.question.type == QuestionType.multiChoice;

        return state.question.options.map((opt) {
          final isCorrectOpt = correctIds.contains(opt.id);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Opacity(
              opacity: isCorrectOpt ? 1.0 : 0.4,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isCorrectOpt
                      ? greenBg.withValues(alpha: 0.15)
                      : AppColors.liveDarkCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isCorrectOpt ? green : AppColors.liveDarkBorder,
                    width: isCorrectOpt ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    if (isMulti)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: isCorrectOpt ? green : Colors.transparent,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: isCorrectOpt ? green : const Color(0xFF4A4A4A),
                            width: 2,
                          ),
                        ),
                        child: isCorrectOpt
                            ? const Icon(Icons.check,
                                size: 13, color: Colors.white)
                            : null,
                      )
                    else
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isCorrectOpt ? green : const Color(0xFF4A4A4A),
                            width: isCorrectOpt ? 6 : 2,
                          ),
                        ),
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        opt.text,
                        style: TextStyle(
                          fontSize: 15,
                          color: isCorrectOpt ? Colors.white : Colors.white70,
                          fontWeight: isCorrectOpt
                              ? FontWeight.w600
                              : FontWeight.w400,
                          height: 1.4,
                        ),
                      ),
                    ),
                    if (isCorrectOpt)
                      const Icon(Icons.check_rounded, color: green, size: 20),
                  ],
                ),
              ),
            ),
          );
        }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final myResult = state.myResult;
    final isCorrect = myResult?.isCorrect ?? false;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top result banner
            Container(
              width: double.infinity,
              color: isCorrect
                  ? const Color(0xFF16A34A).withValues(alpha: 0.15)
                  : Colors.redAccent.withValues(alpha: 0.15),
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  Icon(
                    isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                    color: isCorrect ? const Color(0xFF22C55E) : Colors.redAccent,
                    size: 40,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isCorrect ? 'Верно!' : 'Неверно',
                    style: TextStyle(
                      color: isCorrect ? const Color(0xFF22C55E) : Colors.redAccent,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (myResult != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '+${myResult.score.toStringAsFixed(0)} очков',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
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
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ..._buildLockedOptions(),
                    if (state.stats is LiveChoiceStats) ...[
                      const SizedBox(height: 24),
                      _StatsBar(
                          stats: state.stats as LiveChoiceStats,
                          options: state.question.options),
                    ],
                  ],
                ),
              ),
            ),
            Container(
              color: AppColors.liveDarkSurface,
              padding: const EdgeInsets.all(16),
              child: const Text(
                'Ожидайте следующий вопрос...',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.liveDarkMuted, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsBar extends StatelessWidget {
  final LiveChoiceStats stats;
  final List<LiveAnswerOption> options;

  const _StatsBar({required this.stats, required this.options});

  @override
  Widget build(BuildContext context) {
    final total = stats.answeredCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ответы участников',
          style: TextStyle(
            color: AppColors.liveDarkMuted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        ...stats.distribution.map((d) {
          final opt = options.firstWhere((o) => o.id == d.optionId,
              orElse: () => LiveAnswerOption(id: d.optionId, text: d.optionId));
          final pct = total > 0 ? d.count / total : 0.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  child: Text(
                    opt.text.isNotEmpty ? opt.text[0] : '?',
                    style: const TextStyle(
                        color: AppColors.liveDarkMuted, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        height: 20,
                        decoration: BoxDecoration(
                          color: AppColors.liveDarkCard,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: pct,
                        child: Container(
                          height: 20,
                          decoration: BoxDecoration(
                            color: d.isCorrect
                                ? const Color(0xFF22C55E).withValues(alpha: 0.5)
                                : AppColors.liveAccent.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  d.count.toString(),
                  style: const TextStyle(
                      color: AppColors.liveDarkMuted, fontSize: 12),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

// ─── Results ─────────────────────────────────────────────────────────────────

class _ResultsPhase extends StatelessWidget {
  final LiveStudentResultsLoaded state;
  const _ResultsPhase({required this.state});

  @override
  Widget build(BuildContext context) {
    final r = state.results;
    final pct = r.maxScore > 0 ? (r.myScore / r.maxScore * 100).round() : 0;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Score header
            Container(
              width: double.infinity,
              color: AppColors.liveDarkSurface,
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
              child: Column(
                children: [
                  // Rank circle
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.liveAccent, width: 3),
                      color: AppColors.liveAccent.withValues(alpha: 0.1),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '#${r.myPosition}',
                            style: const TextStyle(
                              color: AppColors.liveAccent,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'из ${r.totalParticipants}',
                            style: const TextStyle(
                              color: AppColors.liveDarkMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '$pct%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${r.myScore.toStringAsFixed(0)} / ${r.maxScore.toStringAsFixed(0)} очков',
                    style: const TextStyle(
                      color: AppColors.liveDarkMuted,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _StatBadge(
                        icon: Icons.check_rounded,
                        color: const Color(0xFF22C55E),
                        label: '${r.correctCount}',
                        sublabel: 'верно',
                      ),
                      const SizedBox(width: 16),
                      _StatBadge(
                        icon: Icons.close_rounded,
                        color: Colors.redAccent,
                        label: '${r.questionsCount - r.correctCount}',
                        sublabel: 'неверно',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Leaderboard
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Row(
                children: [
                  const Text(
                    'Таблица лидеров',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: r.top.length,
                itemBuilder: (context, i) {
                  final row = r.top[i];
                  return _LeaderboardRow(row: row, isLast: i == r.top.length - 1);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: SizedBox(
                width: double.infinity,
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
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String sublabel;

  const _StatBadge({
    required this.icon,
    required this.color,
    required this.label,
    required this.sublabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            '$label $sublabel',
            style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  final LiveLeaderboardRow row;
  final bool isLast;

  const _LeaderboardRow({required this.row, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final isMe = row.isMe;
    final isTop3 = row.position <= 3;

    final medalColors = {1: const Color(0xFFFFD700), 2: const Color(0xFFC0C0C0), 3: const Color(0xFFCD7F32)};

    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isMe
            ? AppColors.liveAccent.withValues(alpha: 0.15)
            : AppColors.liveDarkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMe ? AppColors.liveAccent.withValues(alpha: 0.5) : AppColors.liveDarkBorder,
          width: isMe ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: isTop3
                ? Icon(Icons.emoji_events_rounded,
                    color: medalColors[row.position]!, size: 20)
                : Text(
                    '${row.position}',
                    style: const TextStyle(
                        color: AppColors.liveDarkMuted,
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              row.name,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.white70,
                fontSize: 15,
                fontWeight: isMe ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
          Text(
            row.score.toStringAsFixed(0),
            style: TextStyle(
              color: isMe ? AppColors.liveAccent : AppColors.liveDarkMuted,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
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
