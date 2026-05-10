import 'package:edium/core/di/injection.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_dimens.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/domain/usecases/course/create_course_usecase.dart';
import 'package:edium/domain/usecases/course/create_module_usecase.dart';
import 'package:edium/presentation/shared/widgets/edium_notification.dart';
import 'package:edium/presentation/teacher/create_course/bloc/create_course_bloc.dart';
import 'package:edium/presentation/teacher/create_course/bloc/create_course_event.dart';
import 'package:edium/presentation/teacher/create_course/bloc/create_course_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

part 'create_course_screen_create_course_view.dart';
part 'create_course_screen_module_card.dart';
part 'create_course_screen_dashed_border_painter.dart';


class CreateCourseScreen extends StatelessWidget {
  final String classId;

  const CreateCourseScreen({super.key, required this.classId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CreateCourseBloc(
        getIt<CreateCourseUsecase>(),
        getIt<CreateModuleUsecase>(),
      ),
      child: _CreateCourseView(classId: classId),
    );
  }
}

