import 'package:edium/core/di/injection.dart';
import 'package:edium/presentation/shared/widgets/edium_notification.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_dimens.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/domain/entities/user.dart';
import 'package:edium/presentation/auth/bloc/auth_bloc.dart';
import 'package:edium/presentation/auth/bloc/auth_event.dart';
import 'package:edium/presentation/profile/edit_profile/bloc/edit_profile_bloc.dart';
import 'package:edium/presentation/profile/edit_profile/bloc/edit_profile_event.dart';
import 'package:edium/presentation/profile/edit_profile/bloc/edit_profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

part 'edit_profile_screen_edit_profile_view.dart';
part 'edit_profile_screen_input_field.dart';


class EditProfileScreen extends StatelessWidget {
  final User user;

  const EditProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EditProfileBloc(
        updateProfile: getIt(),
        deleteAccount: getIt(),
        initialState: EditProfileInitial(user),
      ),
      child: const _EditProfileView(),
    );
  }
}

