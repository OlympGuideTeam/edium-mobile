abstract class ClassDetailEvent {
  const ClassDetailEvent();
}

class LoadClassDetailEvent extends ClassDetailEvent {
  final String classId;
  const LoadClassDetailEvent(this.classId);
}

class UpdateClassTitleEvent extends ClassDetailEvent {
  final String newTitle;
  const UpdateClassTitleEvent(this.newTitle);
}

class DeleteClassEvent extends ClassDetailEvent {
  const DeleteClassEvent();
}

class RemoveMemberEvent extends ClassDetailEvent {
  final String userId;
  const RemoveMemberEvent(this.userId);
}

class GetInviteLinkEvent extends ClassDetailEvent {
  final String role;
  const GetInviteLinkEvent(this.role);
}

class DeleteCourseEvent extends ClassDetailEvent {
  final String courseId;
  const DeleteCourseEvent(this.courseId);
}
