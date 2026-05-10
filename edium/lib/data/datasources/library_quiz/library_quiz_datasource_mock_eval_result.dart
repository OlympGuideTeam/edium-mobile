part of 'library_quiz_datasource_mock.dart';

class _EvalResult {
  final double score;
  final String source;
  final String? feedback;
  final Map<String, dynamic>? correctData;

  _EvalResult({
    required this.score,
    required this.source,
    this.feedback,
    this.correctData,
  });
}

