import 'package:edium/domain/entities/course_detail.dart';
import 'package:edium/domain/entities/question.dart';
import 'package:edium/domain/entities/quiz.dart';
import 'package:edium/presentation/teacher/create_quiz/bloc/create_quiz_state.dart';

/// Maps a domain question into the JSON shape used by [AddQuestionScreen] / create flow.
Map<String, dynamic> questionEntityToCreateMap(Question q) {
  switch (q.type) {
    case QuestionType.multiChoice:
      return {
        'type': 'multiple_choice',
        'text': q.text,
        'max_score': 10,
        'answer_options': q.options
            .map((o) => {'text': o.text, 'is_correct': o.isCorrect})
            .toList(),
      };
    case QuestionType.textInput:
      return {
        'type': 'with_free_answer',
        'text': q.text,
        'max_score': 10,
        'answer_options': <Map<String, dynamic>>[],
      };
    case QuestionType.singleChoice:
      return {
        'type': 'single_choice',
        'text': q.text,
        'max_score': 10,
        'answer_options': q.options
            .map((o) => {'text': o.text, 'is_correct': o.isCorrect})
            .toList(),
      };
  }
}

/// Builds initial bloc state from a loaded quiz template.
///
/// When [treatAsExistingCourseTemplate] is true (course draft), submit updates that template.
/// When false, data is only prefilled and submit creates a new quiz (e.g. library template copy).
CreateQuizState createQuizStateFromQuiz(
  Quiz quiz, {
  CourseItemPayload? courseDraftPayload,
  required bool inCourseContext,
  bool treatAsExistingCourseTemplate = false,
}) {
  final payload = courseDraftPayload;
  final payloadTitle = payload?.title?.trim();

  /// Course draft payload in Caesar can lag behind Riddler; when editing the
  /// real template, prefer the quiz returned by `getQuizById`.
  final useQuizCanonical = treatAsExistingCourseTemplate;

  final title = useQuizCanonical
      ? quiz.title
      : ((payloadTitle != null && payloadTitle.isNotEmpty)
          ? payloadTitle
          : quiz.title);

  final effectiveMode = useQuizCanonical
      ? (quiz.settings.riddlerMode ?? payload?.mode ?? 'test')
      : (payload?.mode ?? 'test');

  final quizType = !inCourseContext
      ? QuizCreationMode.template
      : (effectiveMode == 'live'
          ? QuizCreationMode.live
          : QuizCreationMode.test);

  int? totalSec;
  int? questionSec;
  bool shuffle;
  DateTime? startedAt;
  DateTime? finishedAt;

  if (useQuizCanonical) {
    // Riddler template is authoritative; Caesar draft payload can disagree.
    shuffle = quiz.settings.shuffleQuestions;
    questionSec = quiz.settings.questionTimeLimitSec;
    totalSec = quiz.settings.timeLimitMinutes != null
        ? quiz.settings.timeLimitMinutes! * 60
        : null;
    startedAt = quiz.settings.sessionStartedAt;
    finishedAt = quiz.settings.sessionFinishedAt;
  } else {
    totalSec = payload?.totalTimeLimitSec;
    questionSec = payload?.questionTimeLimitSec;
    shuffle = payload?.shuffleQuestions ?? quiz.settings.shuffleQuestions;
    startedAt = payload?.startedAt;
    finishedAt = payload?.finishedAt;
    if (totalSec == null && quiz.settings.timeLimitMinutes != null) {
      totalSec = quiz.settings.timeLimitMinutes! * 60;
    }
  }

  final questions = quiz.questions.map(questionEntityToCreateMap).toList();
  final templateId =
      treatAsExistingCourseTemplate ? quiz.id : null;
  final originalIds =
      treatAsExistingCourseTemplate ? quiz.questions.map((q) => q.id).toList() : const <String>[];

  return CreateQuizState(
    title: title,
    description: quiz.description ?? '',
    totalTimeLimitSec: totalSec,
    questionTimeLimitSec: questionSec,
    shuffleQuestions: shuffle,
    startedAt: startedAt,
    finishedAt: finishedAt,
    questions: questions,
    isInCourseContext: inCourseContext,
    quizType: quizType,
    existingQuizTemplateId: templateId,
    originalQuestionIds: originalIds,
  );
}
