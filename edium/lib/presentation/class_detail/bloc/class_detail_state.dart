import 'package:edium/domain/entities/class_detail.dart';

abstract class ClassDetailState {
  const ClassDetailState();
}

class ClassDetailInitial extends ClassDetailState {
  const ClassDetailInitial();
}

class ClassDetailLoading extends ClassDetailState {
  const ClassDetailLoading();
}

class ClassDetailLoaded extends ClassDetailState {
  final ClassDetail classDetail;
  const ClassDetailLoaded(this.classDetail);
}

class ClassDetailError extends ClassDetailState {
  final String message;
  const ClassDetailError(this.message);
}

class ClassNotFound extends ClassDetailState {
  const ClassNotFound();
}

class ClassTitleUpdated extends ClassDetailState {
  final ClassDetail classDetail;
  const ClassTitleUpdated(this.classDetail);
}

class ClassDeleted extends ClassDetailState {
  const ClassDeleted();
}

class MemberRemoved extends ClassDetailState {
  final ClassDetail classDetail;
  final String userId;
  const MemberRemoved(this.classDetail, this.userId);
}

class InviteLinkCopied extends ClassDetailState {
  final ClassDetail classDetail;
  final String link;
  const InviteLinkCopied(this.classDetail, this.link);
}

class CourseDeleted extends ClassDetailState {
  final ClassDetail classDetail;
  const CourseDeleted(this.classDetail);
}

class ClassDetailActionError extends ClassDetailState {
  final String message;
  final ClassDetail classDetail;
  const ClassDetailActionError(this.message, this.classDetail);
}
