import 'package:edium/services/network/api_exception.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';


bool tryNavigateLiveStudentAfterJoinSessionCompleted(
  Object error, {
  required BuildContext context,
  required String sessionId,
  required String quizTitle,
  required int questionCount,
  String? moduleId,
  bool replaceCurrentRoute = false,
}) {
  if (error is! ApiException || error.code != 'SESSION_COMPLETED') {
    return false;
  }
  final aid = error.details?['attempt_id'] as String?;
  if (aid == null || aid.isEmpty) return false;

  final extra = <String, dynamic>{
    'attemptId': aid,
    'wsToken': '',
    'quizTitle': quizTitle,
    'questionCount': questionCount,
    if (moduleId != null && moduleId.isNotEmpty) 'moduleId': moduleId,
  };
  final path = '/live/$sessionId/student';
  if (replaceCurrentRoute) {
    context.pushReplacement(path, extra: extra);
  } else {
    context.push(path, extra: extra);
  }
  return true;
}
