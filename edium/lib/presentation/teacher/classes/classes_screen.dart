import 'package:edium/core/di/injection.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_dimens.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/domain/entities/class_summary.dart';
import 'package:edium/presentation/shared/widgets/edium_notification.dart';
import 'package:edium/presentation/shared/widgets/edium_refresh_indicator.dart';
import 'package:edium/presentation/shared/widgets/search_bar_widget.dart';
import 'package:edium/presentation/teacher/classes/bloc/classes_bloc.dart';
import 'package:edium/presentation/teacher/classes/bloc/classes_event.dart';
import 'package:edium/presentation/teacher/classes/bloc/classes_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

part 'classes_screen_classes_view.dart';
part 'classes_screen_class_tile.dart';
part 'classes_screen_ownership_badge.dart';


class ClassesScreen extends StatelessWidget {
  final String role;

  const ClassesScreen({super.key, this.role = 'teacher'});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ClassesBloc(
        getMyClasses: getIt(),
        createClass: getIt(),
        deleteClass: getIt(),
        role: role,
      )..add(const LoadClassesEvent()),
      child: _ClassesView(role: role),
    );
  }
}

