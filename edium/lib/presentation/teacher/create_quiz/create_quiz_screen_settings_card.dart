part of 'create_quiz_screen.dart';

class _SettingsCard extends StatelessWidget {
  final CreateQuizState state;
  const _SettingsCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final showTotalTime = !state.isInCourseContext ||
        state.quizType == QuizCreationMode.template ||
        state.quizType == QuizCreationMode.test;
    final showQuestionTime = !state.isInCourseContext ||
        state.quizType == QuizCreationMode.template ||
        state.quizType == QuizCreationMode.live;
    final showShuffle =
        state.isInCourseContext && state.quizType == QuizCreationMode.test;
    final showDates =
        state.isInCourseContext && state.quizType == QuizCreationMode.test;

    final rows = <Widget>[];

    if (showTotalTime) {
      rows.add(_TimeRow(
        key: const ValueKey('totalTime'),
        label: 'Время на весь квиз',
        subtitle:
            !state.isInCourseContext ? 'Используется в режиме «Тест»' : null,
        valueSec: state.totalTimeLimitSec,
        unit: 'мин',
        unitDivisor: 60,
        sliderMinUnits: 5,
        sliderMaxUnits: 90,
        sliderStep: 5,
        defaultValueSec: 1200,
        onToggle: (on) => context
            .read<CreateQuizBloc>()
            .add(UpdateTotalTimeLimitEvent(on ? 1200 : null)),
        onValueChanged: (sec) => context
            .read<CreateQuizBloc>()
            .add(UpdateTotalTimeLimitEvent(sec)),
      ));
    }

    if (showTotalTime && showQuestionTime) {
      rows.add(_CardDivider());
    }

    if (showQuestionTime) {
      rows.add(_TimeRow(
        key: const ValueKey('questionTime'),
        label: 'Время на вопрос',
        subtitle:
            !state.isInCourseContext ? 'Используется в режиме «Лайв»' : null,
        valueSec: state.questionTimeLimitSec,
        unit: 'сек',
        unitDivisor: 1,
        sliderMinUnits: 5,
        sliderMaxUnits: 90,
        sliderStep: 5,
        defaultValueSec: 30,
        onToggle: (on) => context
            .read<CreateQuizBloc>()
            .add(UpdateQuestionTimeLimitEvent(on ? 30 : null)),
        onValueChanged: (sec) => context
            .read<CreateQuizBloc>()
            .add(UpdateQuestionTimeLimitEvent(sec)),
      ));
    }

    if (showShuffle && (showTotalTime || showQuestionTime)) {
      rows.add(_CardDivider());
    }

    if (showShuffle) {
      rows.add(_ShuffleRow(value: state.shuffleQuestions));
    }

    if (showDates) {
      if (rows.isNotEmpty) rows.add(_CardDivider());
      rows.add(_DateTimeRow(
        key: const ValueKey('startedAt'),
        label: 'Открыть с',
        value: state.startedAt,
        onToggle: (on) => context.read<CreateQuizBloc>().add(
              UpdateStartedAtEvent(on ? DateTime.now() : null),
            ),
        onPick: (dt) =>
            context.read<CreateQuizBloc>().add(UpdateStartedAtEvent(dt)),
      ));
      rows.add(_CardDivider());
      rows.add(_DateTimeRow(
        key: const ValueKey('finishedAt'),
        label: 'Дедлайн',
        value: state.finishedAt,
        onToggle: (on) => context.read<CreateQuizBloc>().add(
              UpdateFinishedAtEvent(
                  on ? DateTime.now().add(const Duration(days: 7)) : null),
            ),
        onPick: (dt) =>
            context.read<CreateQuizBloc>().add(UpdateFinishedAtEvent(dt)),
      ));
    }

    if (rows.isEmpty) return const SizedBox.shrink();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SizeTransition(
            sizeFactor: animation,
            axisAlignment: -1,
            child: child,
          ),
        );
      },
      layoutBuilder: (currentChild, previousChildren) {
        return Stack(
          alignment: Alignment.topCenter,
          children: [
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        );
      },
      child: Container(
        key: ValueKey('settings_${state.quizType}_$showDates'),
        decoration: BoxDecoration(
          color: AppColors.mono25,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.mono100),
        ),
        child: Column(children: rows),
      ),
    );
  }
}

