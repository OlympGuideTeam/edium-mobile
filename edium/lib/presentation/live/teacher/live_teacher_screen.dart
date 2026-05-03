import 'dart:async';
import 'dart:math' as math;

import 'package:edium/core/di/injection.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_dimens.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/domain/entities/live_question.dart';
import 'package:edium/domain/entities/live_results.dart';
import 'package:edium/domain/entities/question.dart';
import 'package:edium/domain/entities/live_session.dart';
import 'package:edium/domain/repositories/live_repository.dart';
import 'package:edium/presentation/live/teacher/bloc/live_teacher_bloc.dart';
import 'package:edium/presentation/live/teacher/bloc/live_teacher_event.dart';
import 'package:edium/presentation/live/teacher/bloc/live_teacher_state.dart';
import 'package:edium/presentation/shared/widgets/edium_button.dart';
import 'package:edium/presentation/shared/widgets/edium_confirm_dialog.dart';
import 'package:edium/services/live_ws/live_ws_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// ─── Entry point ─────────────────────────────────────────────────────────────

class LiveTeacherScreen extends StatelessWidget {
  final String sessionId;
  final String quizTitle;
  final int questionCount;
  final String? moduleId;

  const LiveTeacherScreen({
    super.key,
    required this.sessionId,
    required this.quizTitle,
    required this.questionCount,
    this.moduleId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LiveTeacherBloc(
        repo: getIt<ILiveRepository>(),
        ws: getIt<LiveWsService>(),
      )..add(LiveTeacherLoad(
          sessionId: sessionId,
          quizTitle: quizTitle,
          questionCount: questionCount,
          moduleId: moduleId,
        )),
      child: _LiveTeacherBody(
        quizTitle: quizTitle,
        questionCount: questionCount,
      ),
    );
  }
}

class _LiveTeacherBody extends StatelessWidget {
  final String quizTitle;
  final int questionCount;

  const _LiveTeacherBody({
    required this.quizTitle,
    required this.questionCount,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LiveTeacherBloc, LiveTeacherState>(
      listener: (context, state) {
        if (state is LiveTeacherCompleted) {
          context.read<LiveTeacherBloc>().add(LiveTeacherLoadResults());
        }
      },
      builder: (context, state) {
        return switch (state) {
          LiveTeacherInitial() || LiveTeacherConnecting() =>
            _TeacherLoadingPhase(quizTitle: quizTitle),
          LiveTeacherPending() => _TeacherPendingPhase(
              state: state,
              onStartLobby: () =>
                  context.read<LiveTeacherBloc>().add(LiveTeacherStartLobby()),
            ),
          LiveTeacherLobby() => _TeacherLobbyPhase(
              state: state,
              onStartQuiz: () =>
                  context.read<LiveTeacherBloc>().add(LiveTeacherStartQuiz()),
              onKick: (id) =>
                  context.read<LiveTeacherBloc>().add(LiveTeacherKickParticipant(id)),
            ),
          LiveTeacherQuestionActive() => _TeacherQuestionPhase(
              state: state,
              onNext: () =>
                  context.read<LiveTeacherBloc>().add(LiveTeacherNextQuestion()),
            ),
          LiveTeacherQuestionLocked() => _TeacherLockedPhase(
              state: state,
              isLast: state.questionIndex >= state.questionTotal,
              onNext: () =>
                  context.read<LiveTeacherBloc>().add(LiveTeacherNextQuestion()),
            ),
          LiveTeacherCompleted() || LiveTeacherResultsLoading() =>
            const _TeacherResultsLoadingPhase(),
          LiveTeacherResultsLoaded() => _TeacherResultsPhase(state: state),
          LiveTeacherError() => _TeacherErrorPhase(message: state.message),
        };
      },
    );
  }
}

// ─── Loading ─────────────────────────────────────────────────────────────────

class _TeacherLoadingPhase extends StatelessWidget {
  final String quizTitle;
  const _TeacherLoadingPhase({required this.quizTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mono50,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.mono900),
            const SizedBox(height: 24),
            Text(quizTitle, style: AppTextStyles.heading3, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            const Text('Подключение...', style: AppTextStyles.screenSubtitle),
          ],
        ),
      ),
    );
  }
}

// ─── Pending ─────────────────────────────────────────────────────────────────

class _TeacherPendingPhase extends StatelessWidget {
  final LiveTeacherPending state;
  final VoidCallback onStartLobby;

  const _TeacherPendingPhase({required this.state, required this.onStartLobby});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mono50,
      appBar: AppBar(
        backgroundColor: AppColors.mono50,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(state.quizTitle, style: AppTextStyles.heading3),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: AppColors.mono100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.bolt_rounded, color: AppColors.mono400, size: 40),
                    ),
                    const SizedBox(height: 24),
                    const Text('Сессия создана', style: AppTextStyles.heading2),
                    const SizedBox(height: 8),
                    Text(
                      '${state.questionCount} вопрос${_suffix(state.questionCount)}',
                      style: AppTextStyles.screenSubtitle,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: onStartLobby,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mono900,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text('Открыть лобби',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _suffix(int n) {
    if (n % 10 == 1 && n % 100 != 11) return '';
    if (n % 10 >= 2 && n % 10 <= 4 && !(n % 100 >= 12 && n % 100 <= 14)) return 'а';
    return 'ов';
  }
}

// ─── Lobby ───────────────────────────────────────────────────────────────────

class _TeacherLobbyPhase extends StatelessWidget {
  final LiveTeacherLobby state;
  final VoidCallback onStartQuiz;
  final ValueChanged<String> onKick;

  const _TeacherLobbyPhase({
    required this.state,
    required this.onStartQuiz,
    required this.onKick,
  });

  String get _code => state.joinCode ?? '';

  @override
  Widget build(BuildContext context) {
    final joinedUserIds = state.participants
        .where((p) => p.userId != null)
        .map((p) => p.userId!)
        .toSet();

    final notJoined = state.roster.entries
        .where((e) => !joinedUserIds.contains(e.key))
        .map((e) => (userId: e.key, name: e.value))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    return Scaffold(
      backgroundColor: AppColors.mono50,
      appBar: AppBar(
        backgroundColor: AppColors.mono50,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(state.quizTitle, style: AppTextStyles.heading3),
      ),
      body: Column(
        children: [
          if (_code.isNotEmpty)
            Container(
              margin: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.mono150),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'КОД ДЛЯ ВХОДА',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.mono400,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _code,
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: AppColors.mono900,
                            letterSpacing: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _code));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Код скопирован')),
                      );
                    },
                    icon: const Icon(Icons.copy_rounded, color: AppColors.mono400),
                  ),
                ],
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionLabel(
                    label: 'Присоединились',
                    trailing: '${state.participants.length}',
                  ),
                  const SizedBox(height: 8),
                  if (state.participants.isEmpty)
                    _LobbyEmptyJoined()
                  else
                    ...state.participants.map(
                      (p) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _LobbyJoinedTile(
                          participant: p,
                          onKick: () => onKick(p.attemptId),
                        ),
                      ),
                    ),
                  if (notJoined.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _SectionLabel(
                      label: 'Ожидаем',
                      trailing: '${notJoined.length}',
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.mono150),
                      ),
                      child: Column(
                        children: notJoined.asMap().entries.map((entry) {
                          return _LobbyNotJoinedRow(
                            name: entry.value.name,
                            isLast: entry.key == notJoined.length - 1,
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: state.participants.isNotEmpty ? onStartQuiz : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mono900,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.mono200,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Text(
                state.participants.isNotEmpty
                    ? 'Начать квиз'
                    : 'Нет участников',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LobbyJoinedTile extends StatelessWidget {
  final LiveLobbyParticipant participant;
  final VoidCallback onKick;

  const _LobbyJoinedTile({required this.participant, required this.onKick});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        color: AppColors.error,
        child: Dismissible(
          key: ValueKey(participant.attemptId),
          direction: DismissDirection.endToStart,
          confirmDismiss: (_) => EdiumConfirmDialog.show(
            context,
            title: 'Исключить участника?',
            body: '${participant.name} будет удалён из квиза.',
            confirmLabel: 'Исключить',
            cancelLabel: 'Отмена',
            isDestructive: true,
          ),
          onDismissed: (_) => onKick(),
          background: Container(
            color: AppColors.error,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(
              Icons.person_remove_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.mono150),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.mono100,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _participantInitials(participant.name),
                    style: const TextStyle(
                      color: AppColors.mono600,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    participant.name,
                    style: const TextStyle(
                      color: AppColors.mono900,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LobbyEmptyJoined extends StatelessWidget {
  const _LobbyEmptyJoined();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.mono150),
      ),
      child: const Column(
        children: [
          Icon(Icons.people_outline, color: AppColors.mono300, size: 32),
          SizedBox(height: 8),
          Text(
            'Ждём участников...',
            style: TextStyle(color: AppColors.mono400, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _LobbyNotJoinedRow extends StatelessWidget {
  final String name;
  final bool isLast;

  const _LobbyNotJoinedRow({required this.name, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: AppColors.mono100, width: 1)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.mono100,
              borderRadius: BorderRadius.circular(9),
            ),
            alignment: Alignment.center,
            child: Text(
              _participantInitials(name),
              style: const TextStyle(
                color: AppColors.mono300,
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
                color: AppColors.mono400,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Text(
            'не вошёл',
            style: TextStyle(fontSize: 12, color: AppColors.mono300),
          ),
        ],
      ),
    );
  }
}

// ─── Question Active (Monitor) ────────────────────────────────────────────────

class _TeacherQuestionPhase extends StatelessWidget {
  final LiveTeacherQuestionActive state;
  final VoidCallback onNext;

  const _TeacherQuestionPhase({required this.state, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mono50,
      body: Column(
        children: [
          // Header outside scroll view — immune to content-height changes
          _MonitorHeader(
            questionIndex: state.questionIndex,
            questionTotal: state.questionTotal,
            deadlineAt: state.deadlineAt,
            timeLimitSec: state.timeLimitSec,
            isLocked: false,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  _QuestionCard(text: state.question.text),
                  const SizedBox(height: 12),
                  _QuestionDistribution(
                    question: state.question,
                    stats: state.stats,
                    showCorrect: false,
                    correctAnswer: null,
                  ),
                  const SizedBox(height: 12),
                  _LiveStatsRow(
                    answeredCount: state.answeredCount,
                    totalCount: state.totalCount,
                    stats: state.stats,
                  ),
                  const SizedBox(height: 16),
                  _ParticipantProgress(
                    participants: state.participants,
                    answeredMap: state.answeredMap,
                    deadlineAt: state.deadlineAt,
                    timeLimitSec: state.timeLimitSec,
                    isLocked: false,
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          _GatedMonitorBottomBar(
            key: ValueKey(state.question.id),
            isLast: state.questionIndex >= state.questionTotal,
            deadlineAt: state.deadlineAt,
            timeLimitSec: state.timeLimitSec,
            answeredCount: state.answeredCount,
            totalCount: state.totalCount,
            onNext: onNext,
          ),
        ],
      ),
    );
  }
}

// ─── Question Locked ──────────────────────────────────────────────────────────

class _TeacherLockedPhase extends StatelessWidget {
  final LiveTeacherQuestionLocked state;
  final bool isLast;
  final VoidCallback onNext;

  const _TeacherLockedPhase({
    required this.state,
    required this.isLast,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mono50,
      body: Column(
        children: [
          _MonitorHeader(
            questionIndex: state.questionIndex,
            questionTotal: state.questionTotal,
            deadlineAt: DateTime.now(),
            timeLimitSec: 0,
            isLocked: true,
            lockedSegmentFillStart: state.timerFillAtLock,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  _QuestionCard(text: state.question.text),
                  const SizedBox(height: 12),
                  _QuestionDistribution(
                    question: state.question,
                    stats: state.stats,
                    showCorrect: true,
                    correctAnswer: state.correctAnswer,
                  ),
                  const SizedBox(height: 12),
                  _LiveStatsRow(
                    answeredCount: state.stats.answeredCount,
                    totalCount: state.participants.length,
                    stats: state.stats,
                  ),
                  const SizedBox(height: 16),
                  _ParticipantProgress(
                    participants: state.participants,
                    answeredMap: state.answeredMap,
                    deadlineAt: DateTime.now(),
                    timeLimitSec: 0,
                    isLocked: true,
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          _MonitorBottomBar(
            isLast: isLast,
            onNext: onNext,
          ),
        ],
      ),
    );
  }
}

// ─── Shared monitor header ────────────────────────────────────────────────────

Widget _monitorSegmentTrack({
  required EdgeInsets margin,
  required double widthFactor,
  required Color fillColor,
}) {
  final f = widthFactor.clamp(0.0, 1.0);
  return Container(
    height: 4,
    margin: margin,
    decoration: BoxDecoration(
      color: AppColors.mono150,
      borderRadius: BorderRadius.circular(999),
    ),
    clipBehavior: Clip.antiAlias,
    child: Align(
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: f,
        heightFactor: 1.0,
        child: ColoredBox(color: fillColor),
      ),
    ),
  );
}

class _MonitorHeader extends StatelessWidget {
  final int questionIndex;
  final int questionTotal;
  final DateTime deadlineAt;
  final int timeLimitSec;
  final bool isLocked;
  /// Доля заполнения активного сегмента в момент закрытия; дорисовка до 100% в UI.
  final double? lockedSegmentFillStart;

  const _MonitorHeader({
    required this.questionIndex,
    required this.questionTotal,
    required this.deadlineAt,
    required this.timeLimitSec,
    required this.isLocked,
    this.lockedSegmentFillStart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.mono50,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: live dot + title + timer
          Row(
            children: [
              _LiveDot(isLocked: isLocked),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Лайв · идёт',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mono900,
                  ),
                ),
              ),
              if (!isLocked)
                _LiveTimer(deadlineAt: deadlineAt)
              else
                _LockedBadge(),
            ],
          ),
          const SizedBox(height: 12),

          // Question X / Y
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'Вопрос $questionIndex',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.mono900,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              Text(
                ' / $questionTotal',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: AppColors.mono400,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Progress segments
          Row(
            children: List.generate(questionTotal, (i) {
              final filled = i < questionIndex - 1;
              final active = i == questionIndex - 1;
              final segMargin =
                  EdgeInsets.only(right: i < questionTotal - 1 ? 3 : 0);
              return Expanded(
                child: filled
                    ? Container(
                        height: 4,
                        margin: segMargin,
                        decoration: BoxDecoration(
                          color: AppColors.mono900,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      )
                    : active
                        ? (isLocked
                            ? _LockedSnapSegment(
                                margin: segMargin,
                                fillStart: lockedSegmentFillStart ?? 1.0,
                              )
                            : _TimerProgressSegment(
                                margin: segMargin,
                                deadlineAt: deadlineAt,
                                timeLimitSec: timeLimitSec,
                              ))
                        : Container(
                            height: 4,
                            margin: segMargin,
                            decoration: BoxDecoration(
                              color: AppColors.mono150,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

/// Заполнение активного сегмента по времени до [deadlineAt].
class _TimerProgressSegment extends StatefulWidget {
  final EdgeInsets margin;
  final DateTime deadlineAt;
  final int timeLimitSec;

  const _TimerProgressSegment({
    required this.margin,
    required this.deadlineAt,
    required this.timeLimitSec,
  });

  @override
  State<_TimerProgressSegment> createState() => _TimerProgressSegmentState();
}

class _TimerProgressSegmentState extends State<_TimerProgressSegment>
    with SingleTickerProviderStateMixin {
  Ticker? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((_) {
      if (mounted) setState(() {});
    })..start();
  }

  @override
  void dispose() {
    _ticker?.dispose();
    super.dispose();
  }

  double get _fraction {
    if (widget.timeLimitSec <= 0) return 1.0;
    final totalMs = widget.timeLimitSec * 1000;
    final started = widget.deadlineAt
        .subtract(Duration(seconds: widget.timeLimitSec));
    final elapsedMs = DateTime.now().difference(started).inMilliseconds;
    return (elapsedMs / totalMs).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return _monitorSegmentTrack(
      margin: widget.margin,
      widthFactor: _fraction,
      fillColor: AppColors.liveAccent,
    );
  }
}

/// Досрочное закрытие: коротко дорисовываем сегмент до конца.
class _LockedSnapSegment extends StatefulWidget {
  final EdgeInsets margin;
  final double fillStart;

  const _LockedSnapSegment({
    required this.margin,
    required this.fillStart,
  });

  @override
  State<_LockedSnapSegment> createState() => _LockedSnapSegmentState();
}

class _LockedSnapSegmentState extends State<_LockedSnapSegment>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _anim = Tween<double>(
      begin: widget.fillStart.clamp(0.0, 1.0),
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
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
      builder: (_, __) => _monitorSegmentTrack(
        margin: widget.margin,
        widthFactor: _anim.value,
        fillColor: AppColors.mono900,
      ),
    );
  }
}

class _LiveDot extends StatefulWidget {
  final bool isLocked;
  const _LiveDot({required this.isLocked});

  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLocked) {
      return Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(color: AppColors.mono400, shape: BoxShape.circle),
      );
    }
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: AppColors.liveAccent.withValues(alpha: 0.4 + 0.6 * _anim.value),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.liveAccent.withValues(alpha: 0.3 * _anim.value),
              blurRadius: 6,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}

class _LockedBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.mono900,
        borderRadius: BorderRadius.circular(AppDimens.radiusXs),
      ),
      child: const Text(
        'ЗАКРЫТ',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ─── Timer ───────────────────────────────────────────────────────────────────

class _LiveTimer extends StatefulWidget {
  final DateTime deadlineAt;
  const _LiveTimer({required this.deadlineAt});

  @override
  State<_LiveTimer> createState() => _LiveTimerState();
}

class _LiveTimerState extends State<_LiveTimer> {
  late int _secondsLeft;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(_tick);
    });
  }

  void _tick() {
    _secondsLeft =
        widget.deadlineAt.difference(DateTime.now()).inSeconds.clamp(0, 99999);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = _secondsLeft ~/ 60;
    final s = _secondsLeft % 60;
    final label = _secondsLeft >= 60
        ? '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}'
        : '$_secondsLeft с';
    final urgent = _secondsLeft <= 10;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: urgent ? AppColors.liveAccent : AppColors.mono900,
        borderRadius: BorderRadius.circular(AppDimens.radiusXs),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.8,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

// ─── Question card ────────────────────────────────────────────────────────────

class _QuestionCard extends StatelessWidget {
  final String text;
  const _QuestionCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.mono150, width: 1.5),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.mono900,
          height: 1.35,
        ),
      ),
    );
  }
}

// ─── Distribution (choice / binary / free) ───────────────────────────────────

class _QuestionDistribution extends StatelessWidget {
  final LiveQuestion question;
  final LiveQuestionStats? stats;
  final bool showCorrect;
  final LiveCorrectAnswer? correctAnswer;

  const _QuestionDistribution({
    required this.question,
    required this.stats,
    required this.showCorrect,
    required this.correctAnswer,
  });

  @override
  Widget build(BuildContext context) {
    final type = question.type;
    final isChoice = type == QuestionType.singleChoice || type == QuestionType.multiChoice;

    if (isChoice) {
      return _ChoiceDistribution(
        stats: stats is LiveChoiceStats ? stats as LiveChoiceStats : null,
        options: question.options,
        showCorrect: showCorrect,
        correctAnswer: correctAnswer,
        isMulti: type == QuestionType.multiChoice,
      );
    }

    if (type == QuestionType.withGivenAnswer) {
      return _GivenAnswerDistribution(
        stats: stats is LiveBinaryStats ? stats as LiveBinaryStats : null,
      );
    }

    return _BinaryDistribution(
      stats: stats is LiveBinaryStats ? stats as LiveBinaryStats : null,
    );
  }
}

// Choice option cells with fill bars (design taken from add_question screen)
class _ChoiceDistribution extends StatelessWidget {
  final LiveChoiceStats? stats;
  final List<LiveAnswerOption> options;
  final bool showCorrect;
  final LiveCorrectAnswer? correctAnswer;
  final bool isMulti;

  const _ChoiceDistribution({
    required this.stats,
    required this.options,
    required this.showCorrect,
    required this.correctAnswer,
    required this.isMulti,
  });

  @override
  Widget build(BuildContext context) {
    final total = stats?.answeredCount ?? 0;
    final correctIds = _correctIds();

    return Column(
      children: options.asMap().entries.map((entry) {
        final opt = entry.value;

        final dist = stats?.distribution.where((d) => d.optionId == opt.id).firstOrNull;
        final count = dist?.count ?? 0;
        final pct = total > 0 ? count / total : 0.0;

        final isCorrectOpt = showCorrect &&
            (correctIds.contains(opt.id) || opt.isCorrect == true);

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _OptionFillCell(
            text: opt.text,
            fillFraction: pct,
            count: count,
            isCorrect: isCorrectOpt,
            isMulti: isMulti,
            showCount: total > 0,
          ),
        );
      }).toList(),
    );
  }

  List<String> _correctIds() {
    if (correctAnswer == null) return [];
    if (correctAnswer!.correctOptionIds != null) return correctAnswer!.correctOptionIds!;
    if (correctAnswer!.correctOptionId != null) return [correctAnswer!.correctOptionId!];
    return [];
  }
}

class _OptionFillCell extends StatelessWidget {
  final String text;
  final double fillFraction;
  final int count;
  final bool isCorrect;
  final bool isMulti;
  final bool showCount;

  const _OptionFillCell({
    required this.text,
    required this.fillFraction,
    required this.count,
    required this.isCorrect,
    required this.isMulti,
    required this.showCount,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isCorrect ? AppColors.mono900 : AppColors.mono150;
    // Одна и та же ширина рамки до/после подсветки правильных — иначе при 1.0 → 1.5
    // ячейка меняет размер на ~1 px и список визуально «прыгает».
    const borderWidth = 1.5;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.mono25,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: borderWidth),
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
                        ? const Color(0xFF22C55E).withValues(alpha: 0.12)
                        : AppColors.mono100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                _ChoiceIndicator(isCorrect: isCorrect, isMulti: isMulti),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isCorrect ? AppColors.mono900 : AppColors.mono700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Always rendered — prevents layout shift when first answer arrives
                const SizedBox(width: 8),
                SizedBox(
                  width: 36,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        showCount ? '${(fillFraction * 100).round()}%' : '—',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: showCount
                              ? (isCorrect ? const Color(0xFF22C55E) : AppColors.mono600)
                              : AppColors.mono200,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      Visibility(
                        visible: showCount,
                        maintainSize: true,
                        maintainAnimation: true,
                        maintainState: true,
                        child: Text(
                          '$count',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.mono400,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    ],
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

class _ChoiceIndicator extends StatelessWidget {
  final bool isCorrect;
  final bool isMulti;

  const _ChoiceIndicator({required this.isCorrect, required this.isMulti});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 20,
      height: 20,
      decoration: isMulti
          ? BoxDecoration(
              color: isCorrect ? AppColors.mono900 : Colors.transparent,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: isCorrect ? AppColors.mono900 : AppColors.mono300,
                width: 1.5,
              ),
            )
          : BoxDecoration(
              color: isCorrect ? AppColors.mono900 : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: isCorrect ? AppColors.mono900 : AppColors.mono300,
                width: 1.5,
              ),
            ),
      child: isCorrect
          ? Center(
              child: isMulti
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
            )
          : null,
    );
  }
}

// Binary distribution (correct / incorrect bar for with_given_answer)
class _GivenAnswerDistribution extends StatelessWidget {
  final LiveBinaryStats? stats;
  const _GivenAnswerDistribution({required this.stats});

  @override
  Widget build(BuildContext context) {
    final total = stats?.answeredCount ?? 0;
    final correct = stats?.correctCount ?? 0;
    final incorrect = stats?.incorrectCount ?? 0;
    final correctPct = total > 0 ? correct / total : 0.0;
    final incorrectPct = total > 0 ? incorrect / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.mono150),
      ),
      child: Column(
        children: [
          _BinaryBar(label: 'Верно', count: correct, pct: correctPct, color: const Color(0xFF22C55E)),
          const SizedBox(height: 8),
          _BinaryBar(label: 'Неверно', count: incorrect, pct: incorrectPct, color: AppColors.mono300),
        ],
      ),
    );
  }
}

class _BinaryDistribution extends StatelessWidget {
  final LiveBinaryStats? stats;
  const _BinaryDistribution({required this.stats});

  @override
  Widget build(BuildContext context) {
    final total = stats?.answeredCount ?? 0;
    final correctPct = total > 0 ? (stats!.correctCount / total) : 0.0;
    final incorrectPct = total > 0 ? (stats!.incorrectCount / total) : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.mono150),
      ),
      child: Column(
        children: [
          _BinaryBar(label: 'Верно', count: stats?.correctCount ?? 0, pct: correctPct, color: const Color(0xFF22C55E)),
          const SizedBox(height: 8),
          _BinaryBar(label: 'Неверно', count: stats?.incorrectCount ?? 0, pct: incorrectPct, color: AppColors.mono300),
        ],
      ),
    );
  }
}

class _BinaryBar extends StatelessWidget {
  final String label;
  final int count;
  final double pct;
  final Color color;

  const _BinaryBar({
    required this.label,
    required this.count,
    required this.pct,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 56,
          child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.mono600)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 8,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(color: AppColors.mono100),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AnimatedFractionallySizedBox(
                      duration: const Duration(milliseconds: 400),
                      widthFactor: pct.clamp(0.0, 1.0),
                      heightFactor: 1.0,
                      child: ColoredBox(color: color),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 28,
          child: Text(
            '$count',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.mono600,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

// ─── Live Stats Row ───────────────────────────────────────────────────────────

class _LiveStatsRow extends StatelessWidget {
  final int answeredCount;
  final int totalCount;
  final LiveQuestionStats? stats;

  const _LiveStatsRow({
    required this.answeredCount,
    required this.totalCount,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final correctPct = stats != null && stats!.answeredCount > 0
        ? (stats!.correctCount / stats!.answeredCount * 100).round()
        : null;
    final avgTimeSec = stats?.avgTimeMs != null ? (stats!.avgTimeMs! / 1000).round() : null;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _StatsCell(
              label: 'Ответили',
              value: '$answeredCount',
              sub: '/ $totalCount',
              progress: totalCount > 0 ? answeredCount / totalCount : 0.0,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatsCell(
              label: 'Верно',
              value: correctPct != null ? '$correctPct%' : '—',
              valueColor: correctPct != null ? const Color(0xFF22C55E) : null,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatsCell(
              label: 'Ср. время',
              value: avgTimeSec != null ? '$avgTimeSec с' : '—',
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsCell extends StatelessWidget {
  final String label;
  final String value;
  final String? sub;
  final double? progress;
  final Color? valueColor;

  const _StatsCell({
    required this.label,
    required this.value,
    this.sub,
    this.progress,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.mono150),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.mono400,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: valueColor ?? AppColors.mono900,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              if (sub != null) ...[
                const SizedBox(width: 3),
                Text(
                  sub!,
                  style: const TextStyle(fontSize: 12, color: AppColors.mono400),
                ),
              ],
            ],
          ),
          if (progress != null) ...[
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                height: 3,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const ColoredBox(color: AppColors.mono100),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: AnimatedFractionallySizedBox(
                        duration: const Duration(milliseconds: 300),
                        widthFactor: progress!.clamp(0.0, 1.0),
                        heightFactor: 1.0,
                        child: const ColoredBox(color: AppColors.mono900),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Participant progress ─────────────────────────────────────────────────────

class _ParticipantProgress extends StatelessWidget {
  final List<LiveLobbyParticipant> participants;
  final Map<String, LiveTeacherParticipantAnswer> answeredMap;
  final DateTime deadlineAt;
  final int timeLimitSec;
  final bool isLocked;

  const _ParticipantProgress({
    required this.participants,
    required this.answeredMap,
    required this.deadlineAt,
    required this.timeLimitSec,
    required this.isLocked,
  });

  @override
  Widget build(BuildContext context) {
    if (participants.isEmpty) return const SizedBox.shrink();

    final pending = participants.where((p) => !answeredMap.containsKey(p.attemptId)).toList();
    final answered = participants.where((p) => answeredMap.containsKey(p.attemptId)).toList();

    // Question started at
    final questionStartedAt = timeLimitSec > 0
        ? deadlineAt.subtract(Duration(seconds: timeLimitSec))
        : DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Пока вопрос открыт — блок всегда того же каркаса (без AnimatedSize:
        // иначе при анимации высота обрезает дочерний Column и кажется, что
        // «сжались» отступы между секциями).
        if (!isLocked) ...[
          _SectionLabel(
            label: 'Ещё отвечают',
            trailing: '${pending.length}',
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.mono150),
            ),
            child: pending.isEmpty
                ? const _AllPendingAnsweredPlaceholder()
                : Column(
                    children: pending.asMap().entries.map((e) {
                      final isLast = e.key == pending.length - 1;
                      return _PendingRow(
                        participant: e.value,
                        questionStartedAt: questionStartedAt,
                        isLast: isLast,
                      );
                    }).toList(),
                  ),
          ),
          const SizedBox(height: 16),
        ],

        _SectionLabel(label: 'Ответили', trailing: '${answered.length}'),
        const SizedBox(height: 8),
        if (answered.isEmpty)
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 50),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.mono150),
            ),
            alignment: Alignment.center,
            child: const Text(
              'Ожидаем ответов...',
              style: TextStyle(fontSize: 13, color: AppColors.mono300),
              textAlign: TextAlign.center,
            ),
          )
        else
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.mono150),
            ),
            child: Column(
              children: answered.asMap().entries.map((e) {
                final isLast = e.key == answered.length - 1;
                final result = answeredMap[e.value.attemptId];
                return _AnsweredRow(
                  participant: e.value,
                  result: result,
                  isLast: isLast,
                );
              }).toList(),
            ),
          ),

        if (isLocked && pending.isNotEmpty) ...[
          const SizedBox(height: 16),
          _SectionLabel(label: 'Не ответили', trailing: '${pending.length}'),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.mono150),
            ),
            child: Column(
              children: pending.asMap().entries.map((e) {
                final isLast = e.key == pending.length - 1;
                return _NoAnswerRow(participant: e.value, isLast: isLast);
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }
}

/// Строка той же высоты, что [_ParticipantRow], когда некому показывать в «Ещё отвечают».
class _AllPendingAnsweredPlaceholder extends StatelessWidget {
  const _AllPendingAnsweredPlaceholder();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 50),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(
          children: [
            Icon(Icons.check_circle_outline_rounded, size: 18, color: AppColors.mono400),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Все ответили',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.mono600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final String trailing;
  const _SectionLabel({required this.label, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.mono400,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          height: 18,
          padding: const EdgeInsets.symmetric(horizontal: 7),
          decoration: BoxDecoration(
            color: AppColors.mono100,
            borderRadius: BorderRadius.circular(999),
          ),
          alignment: Alignment.center,
          child: Text(
            trailing,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.mono600,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ],
    );
  }
}

class _PendingRow extends StatefulWidget {
  final LiveLobbyParticipant participant;
  final DateTime questionStartedAt;
  final bool isLast;

  const _PendingRow({
    required this.participant,
    required this.questionStartedAt,
    required this.isLast,
  });

  @override
  State<_PendingRow> createState() => _PendingRowState();
}

class _PendingRowState extends State<_PendingRow> {
  int _elapsed = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(_tick);
    });
  }

  void _tick() {
    _elapsed = DateTime.now().difference(widget.questionStartedAt).inSeconds.clamp(0, 99999);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ParticipantRow(
      name: widget.participant.name,
      isLast: widget.isLast,
      trailing: Text(
        'обдумывает… $_elapsed с',
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.mono400,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
      dotColor: AppColors.mono300,
    );
  }
}

class _AnsweredRow extends StatelessWidget {
  final LiveLobbyParticipant participant;
  final LiveTeacherParticipantAnswer? result;
  final bool isLast;

  const _AnsweredRow({
    required this.participant,
    required this.result,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final timeSec = result != null ? (result!.timeTakenMs / 1000).round() : null;
    final isCorrect = result?.isCorrect ?? false;

    return _ParticipantRow(
      name: participant.name,
      isLast: isLast,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (timeSec != null)
            Text(
              '$timeSec с',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.mono400,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          const SizedBox(width: 8),
          Icon(
            isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
            size: 18,
            color: isCorrect ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
          ),
        ],
      ),
      dotColor: isCorrect ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
    );
  }
}

class _NoAnswerRow extends StatelessWidget {
  final LiveLobbyParticipant participant;
  final bool isLast;

  const _NoAnswerRow({required this.participant, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return _ParticipantRow(
      name: participant.name,
      isLast: isLast,
      trailing: const Text(
        'не ответил',
        style: TextStyle(fontSize: 12, color: AppColors.mono400),
      ),
      dotColor: AppColors.mono300,
    );
  }
}

String _participantInitials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.length >= 2) {
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
  return name.isNotEmpty ? name[0].toUpperCase() : '?';
}

class _ParticipantRow extends StatelessWidget {
  final String name;
  final bool isLast;
  final Widget trailing;
  final Color dotColor;

  const _ParticipantRow({
    required this.name,
    required this.isLast,
    required this.trailing,
    required this.dotColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: AppColors.mono100, width: 1)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          // Avatar
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.mono100,
              borderRadius: BorderRadius.circular(7),
            ),
            alignment: Alignment.center,
            child: Text(
              _participantInitials(name),
              style: const TextStyle(
                  color: AppColors.mono600, fontSize: 10, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.mono900),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

// ─── Bottom bar ───────────────────────────────────────────────────────────────

/// Пока вопрос активен — «Следующий» доступен только после дедлайна или когда ответили все.
class _GatedMonitorBottomBar extends StatefulWidget {
  final bool isLast;
  final DateTime deadlineAt;
  final int timeLimitSec;
  final int answeredCount;
  final int totalCount;
  final VoidCallback onNext;

  const _GatedMonitorBottomBar({
    super.key,
    required this.isLast,
    required this.deadlineAt,
    required this.timeLimitSec,
    required this.answeredCount,
    required this.totalCount,
    required this.onNext,
  });

  @override
  State<_GatedMonitorBottomBar> createState() => _GatedMonitorBottomBarState();
}

class _GatedMonitorBottomBarState extends State<_GatedMonitorBottomBar> {
  Timer? _timer;

  bool _canProceed() {
    final hasTimer = widget.timeLimitSec > 0;
    final timeEnded = hasTimer && !DateTime.now().isBefore(widget.deadlineAt);
    final allAnswered =
        widget.totalCount > 0 && widget.answeredCount >= widget.totalCount;
    return timeEnded || allAnswered;
  }

  void _syncTimer() {
    if (_canProceed()) {
      _timer?.cancel();
      _timer = null;
      return;
    }
    _timer ??= Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_canProceed()) {
        _timer?.cancel();
        _timer = null;
      }
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    _syncTimer();
  }

  @override
  void didUpdateWidget(covariant _GatedMonitorBottomBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _MonitorBottomBar(
      isLast: widget.isLast,
      onNext: _canProceed() ? widget.onNext : null,
    );
  }
}

class _MonitorBottomBar extends StatelessWidget {
  final bool isLast;
  final VoidCallback? onNext;

  const _MonitorBottomBar({
    required this.isLast,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.mono50.withValues(alpha: 0.95),
        border: const Border(top: BorderSide(color: AppColors.mono150)),
      ),
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, math.max(MediaQuery.of(context).padding.bottom, 16)),
      child: EdiumButton(
        label: isLast ? 'Завершить квиз' : 'Следующий →',
        onPressed: onNext,
      ),
    );
  }
}

// ─── Results Loading ──────────────────────────────────────────────────────────

class _TeacherResultsLoadingPhase extends StatelessWidget {
  const _TeacherResultsLoadingPhase();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.mono50,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.mono900),
            SizedBox(height: 16),
            Text('Загрузка результатов...', style: AppTextStyles.screenSubtitle),
          ],
        ),
      ),
    );
  }
}

// ─── Results ─────────────────────────────────────────────────────────────────

class _TeacherResultsPhase extends StatelessWidget {
  final LiveTeacherResultsLoaded state;
  const _TeacherResultsPhase({required this.state});

  @override
  Widget build(BuildContext context) {
    final results = state.results;

    return Scaffold(
      backgroundColor: AppColors.mono50,
      appBar: AppBar(
        backgroundColor: AppColors.mono50,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text('Результаты квиза', style: AppTextStyles.heading3),
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              labelColor: AppColors.mono900,
              unselectedLabelColor: AppColors.mono400,
              indicatorColor: AppColors.mono900,
              tabs: [
                Tab(text: 'Лидерборд'),
                Tab(text: 'По вопросам'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _LeaderboardTab(leaderboard: results.leaderboard),
                  _QuestionsTab(questions: results.questions),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardTab extends StatelessWidget {
  final List<LiveResultsTeacherAttempt> leaderboard;
  const _LeaderboardTab({required this.leaderboard});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      itemCount: leaderboard.length,
      itemBuilder: (context, i) {
        final row = leaderboard[i];
        final pct = row.maxScore > 0 ? (row.score / row.maxScore * 100).round() : 0;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.mono150),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 28,
                child: Text(
                  '${row.position}',
                  style: const TextStyle(
                      color: AppColors.mono400, fontSize: 14, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(row.name,
                        style: const TextStyle(
                            color: AppColors.mono900, fontSize: 15, fontWeight: FontWeight.w600)),
                    Text('${row.correctCount} верных ответов',
                        style: const TextStyle(color: AppColors.mono400, fontSize: 12)),
                  ],
                ),
              ),
              Text('$pct%',
                  style: const TextStyle(
                      color: AppColors.mono900, fontSize: 18, fontWeight: FontWeight.w800)),
            ],
          ),
        );
      },
    );
  }
}

class _QuestionsTab extends StatelessWidget {
  final List<LiveResultsTeacherQuestion> questions;
  const _QuestionsTab({required this.questions});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      itemCount: questions.length,
      itemBuilder: (context, i) {
        final q = questions[i];
        final pct = (q.correctRate * 100).round();

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.mono150),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(color: AppColors.mono100, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(
                  '${q.orderIndex}',
                  style: const TextStyle(
                      color: AppColors.mono600, fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(q.text,
                        style: const TextStyle(
                            color: AppColors.mono900, fontSize: 14, fontWeight: FontWeight.w500),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: q.correctRate.clamp(0.0, 1.0),
                        minHeight: 6,
                        backgroundColor: AppColors.mono100,
                        color: pct >= 60 ? const Color(0xFF22C55E) : AppColors.liveAccent,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('$pct% ответили верно',
                        style: const TextStyle(color: AppColors.mono400, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Error ────────────────────────────────────────────────────────────────────

class _TeacherErrorPhase extends StatelessWidget {
  final String message;
  const _TeacherErrorPhase({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mono50,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded, color: AppColors.mono300, size: 48),
              const SizedBox(height: 16),
              Text(message,
                  style: AppTextStyles.screenSubtitle, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () => context.pop(),
                child: const Text('Закрыть'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
