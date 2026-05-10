part of 'class_detail_state.dart';

class ClassDetailActionError extends ClassDetailState {
  final String message;
  final ClassDetail classDetail;
  const ClassDetailActionError(this.message, this.classDetail);
}

