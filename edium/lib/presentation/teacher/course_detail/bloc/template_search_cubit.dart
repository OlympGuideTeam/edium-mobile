import 'dart:async';

import 'package:edium/domain/entities/quiz.dart';
import 'package:edium/domain/usecases/quiz/get_quizzes_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'template_search_cubit_template_search_initial.dart';
part 'template_search_cubit_template_search_loading.dart';
part 'template_search_cubit_template_search_loaded.dart';
part 'template_search_cubit_template_search_error.dart';
part 'template_search_cubit_template_search_cubit.dart';


abstract class TemplateSearchState {
  const TemplateSearchState();
}

