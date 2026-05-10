import 'package:edium/core/di/injection.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_dimens.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/domain/entities/attempt_review.dart';
import 'package:edium/domain/entities/quiz_attempt.dart' show QuizQuestionType;
import 'package:edium/presentation/shared/test/bloc/attempt_review_bloc.dart';
import 'package:edium/presentation/shared/test/bloc/attempt_review_event.dart';
import 'package:edium/presentation/shared/test/bloc/attempt_review_state.dart';
import 'package:edium/presentation/shared/widgets/question_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

part 'attempt_review_screen_attempt_review_body.dart';
part 'attempt_review_screen_view.dart';
part 'attempt_review_screen_question_card.dart';
part 'attempt_review_screen_order_item.dart';
part 'attempt_review_screen_connection_pair_row.dart';
part 'attempt_review_screen_option_line.dart';


class AttemptReviewScreen extends StatelessWidget {
  final String attemptId;
  const AttemptReviewScreen({super.key, required this.attemptId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AttemptReviewBloc(getIt())
        ..add(LoadAttemptReviewEvent(attemptId)),
      child: const _View(),
    );
  }
}

