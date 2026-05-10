part of 'live_student_screen.dart';

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
                    if (state.question.imageId != null) ...[
                      const SizedBox(height: 16),
                      QuestionImageWidget(imageId: state.question.imageId!, dark: true),
                    ],
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

