import 'package:edium/core/di/injection.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_dimens.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/domain/entities/class_detail.dart';
import 'package:edium/presentation/class_detail/bloc/class_detail_bloc.dart';
import 'package:edium/presentation/class_detail/bloc/class_detail_event.dart';
import 'package:edium/presentation/class_detail/bloc/class_detail_state.dart';
import 'package:edium/presentation/shared/widgets/edium_notification.dart';
import 'package:edium/presentation/shared/widgets/edium_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

part 'class_detail_screen_class_detail_view.dart';
part 'class_detail_screen_courses_tab.dart';
part 'class_detail_screen_course_card.dart';
part 'class_detail_screen_chip.dart';
part 'class_detail_screen_members_tab.dart';


class ClassDetailScreen extends StatelessWidget {
  final String classId;

  const ClassDetailScreen({super.key, required this.classId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ClassDetailBloc(
        getClassDetail: getIt(),
        updateClass: getIt(),
        deleteClass: getIt(),
        deleteCourse: getIt(),
        removeMember: getIt(),
        getInviteLink: getIt(),
        classId: classId,
      )..add(LoadClassDetailEvent(classId)),
      child: const _ClassDetailView(),
    );
  }
}

