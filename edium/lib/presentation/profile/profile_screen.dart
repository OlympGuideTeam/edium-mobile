import 'package:edium/core/di/injection.dart';
import 'package:edium/core/storage/profile_storage.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_dimens.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/domain/entities/user.dart';
import 'package:edium/domain/entities/user_statistic.dart';
import 'package:edium/presentation/profile/bloc/profile_bloc.dart';
import 'package:edium/presentation/profile/bloc/profile_event.dart';
import 'package:edium/presentation/profile/bloc/profile_state.dart';
import 'package:edium/presentation/shared/widgets/edium_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

part 'profile_screen_profile_view.dart';
part 'profile_screen_profile_content.dart';
part 'profile_screen_teacher_stats.dart';
part 'profile_screen_student_stats.dart';
part 'profile_screen_stat_card.dart';
part 'profile_screen_action_tile.dart';


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileBloc(
        getMe: getIt(),
        getStatistic: getIt(),
      )..add(const LoadProfileEvent()),
      child: const _ProfileView(),
    );
  }
}

