import 'package:equatable/equatable.dart';

class CreateCourseState extends Equatable {
  final String title;
  final List<String> modules;
  final bool isSubmitting;
  final String? error;
  final bool success;

  const CreateCourseState({
    this.title = '',
    this.modules = const [],
    this.isSubmitting = false,
    this.error,
    this.success = false,
  });

  bool get canSubmit => title.trim().isNotEmpty && !isSubmitting;

  CreateCourseState copyWith({
    String? title,
    List<String>? modules,
    bool? isSubmitting,
    String? error,
    bool? success,
  }) {
    return CreateCourseState(
      title: title ?? this.title,
      modules: modules ?? this.modules,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
      success: success ?? this.success,
    );
  }

  @override
  List<Object?> get props => [title, modules, isSubmitting, error, success];
}
