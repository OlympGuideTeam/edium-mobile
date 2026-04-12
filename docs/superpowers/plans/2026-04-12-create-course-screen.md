# CreateCourse Screen Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a "Новый курс" screen where teachers create a course (name + modules) from within a class, following the monochrome auth-screen design system.

**Architecture:** Clean Architecture — domain (repository interface + usecases), data (datasource interface + mock/impl + repository impl), presentation (BLoC + screen). Navigation via GoRouter, DI via GetIt.

**Tech Stack:** Flutter, flutter_bloc, go_router, get_it, equatable, dio

---

### Task 1: Domain Layer — Repository Interface & Usecases

**Files:**
- Create: `lib/domain/repositories/course_repository.dart`
- Create: `lib/domain/usecases/course/create_course_usecase.dart`
- Create: `lib/domain/usecases/course/create_module_usecase.dart`

- [ ] **Step 1: Create repository interface**

Create `lib/domain/repositories/course_repository.dart`:

```dart
abstract class ICourseRepository {
  Future<String> createCourse({required String title, required String classId});
  Future<void> createModule({required String courseId, required String title});
}
```

- [ ] **Step 2: Create CreateCourseUsecase**

Create `lib/domain/usecases/course/create_course_usecase.dart`:

```dart
import 'package:edium/domain/repositories/course_repository.dart';

class CreateCourseUsecase {
  final ICourseRepository _repository;

  CreateCourseUsecase(this._repository);

  Future<String> call({required String title, required String classId}) =>
      _repository.createCourse(title: title, classId: classId);
}
```

- [ ] **Step 3: Create CreateModuleUsecase**

Create `lib/domain/usecases/course/create_module_usecase.dart`:

```dart
import 'package:edium/domain/repositories/course_repository.dart';

class CreateModuleUsecase {
  final ICourseRepository _repository;

  CreateModuleUsecase(this._repository);

  Future<void> call({required String courseId, required String title}) =>
      _repository.createModule(courseId: courseId, title: title);
}
```

- [ ] **Step 4: Verify no analysis errors**

Run: `cd edium && flutter analyze lib/domain/repositories/course_repository.dart lib/domain/usecases/course/`
Expected: No issues found

- [ ] **Step 5: Commit**

```bash
git add lib/domain/repositories/course_repository.dart lib/domain/usecases/course/
git commit -m "feat: add course domain layer — repository interface and usecases"
```

---

### Task 2: Data Layer — Datasource Interface, Mock, Impl & Repository

**Files:**
- Create: `lib/data/datasources/course/course_datasource.dart`
- Create: `lib/data/datasources/course/course_datasource_mock.dart`
- Create: `lib/data/datasources/course/course_datasource_impl.dart`
- Create: `lib/data/repositories/course_repository_impl.dart`

- [ ] **Step 1: Create datasource interface**

Create `lib/data/datasources/course/course_datasource.dart`:

```dart
abstract class ICourseDatasource {
  Future<String> createCourse({required String title, required String classId});
  Future<void> createModule({required String courseId, required String title});
}
```

- [ ] **Step 2: Create mock datasource**

Create `lib/data/datasources/course/course_datasource_mock.dart`:

```dart
import 'package:edium/data/datasources/course/course_datasource.dart';

class CourseDatasourceMock implements ICourseDatasource {
  @override
  Future<String> createCourse({
    required String title,
    required String classId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return 'course-${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Future<void> createModule({
    required String courseId,
    required String title,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
```

- [ ] **Step 3: Create HTTP datasource**

Create `lib/data/datasources/course/course_datasource_impl.dart`:

```dart
import 'package:edium/data/datasources/course/course_datasource.dart';
import 'package:edium/services/network/base_api_service.dart';
import 'package:edium/services/network/http_method.dart';

class CourseDatasourceImpl extends BaseApiService implements ICourseDatasource {
  CourseDatasourceImpl(super.dio);

  @override
  Future<String> createCourse({
    required String title,
    required String classId,
  }) {
    return request(
      'caesar/v1/courses',
      method: HttpMethod.post,
      req: {'title': title, 'class_id': classId},
      parser: (data) => (data as Map<String, dynamic>)['id'] as String,
    );
  }

  @override
  Future<void> createModule({
    required String courseId,
    required String title,
  }) {
    return request(
      'caesar/v1/courses/$courseId/modules',
      method: HttpMethod.post,
      req: {'title': title},
      parser: (_) {},
    );
  }
}
```

- [ ] **Step 4: Create repository implementation**

Create `lib/data/repositories/course_repository_impl.dart`:

```dart
import 'package:edium/data/datasources/course/course_datasource.dart';
import 'package:edium/domain/repositories/course_repository.dart';

class CourseRepositoryImpl implements ICourseRepository {
  final ICourseDatasource _datasource;

  CourseRepositoryImpl(this._datasource);

  @override
  Future<String> createCourse({
    required String title,
    required String classId,
  }) {
    return _datasource.createCourse(title: title, classId: classId);
  }

  @override
  Future<void> createModule({
    required String courseId,
    required String title,
  }) {
    return _datasource.createModule(courseId: courseId, title: title);
  }
}
```

- [ ] **Step 5: Verify no analysis errors**

Run: `cd edium && flutter analyze lib/data/datasources/course/ lib/data/repositories/course_repository_impl.dart`
Expected: No issues found

- [ ] **Step 6: Commit**

```bash
git add lib/data/datasources/course/ lib/data/repositories/course_repository_impl.dart
git commit -m "feat: add course data layer — datasources (mock + impl) and repository"
```

---

### Task 3: DI Registration

**Files:**
- Modify: `lib/core/di/injection.dart`

- [ ] **Step 1: Add imports to injection.dart**

Add these imports at the top of `lib/core/di/injection.dart` (after the existing import block):

```dart
import 'package:edium/data/datasources/course/course_datasource.dart';
import 'package:edium/data/datasources/course/course_datasource_impl.dart';
import 'package:edium/data/datasources/course/course_datasource_mock.dart';
import 'package:edium/data/repositories/course_repository_impl.dart';
import 'package:edium/domain/repositories/course_repository.dart';
import 'package:edium/domain/usecases/course/create_course_usecase.dart';
import 'package:edium/domain/usecases/course/create_module_usecase.dart';
```

- [ ] **Step 2: Register mock datasource**

Inside the `if (ApiConfig.useMock) {` block (after line 89 — `ClassDatasourceMock()` registration), add:

```dart
    getIt.registerLazySingleton<ICourseDatasource>(
        () => CourseDatasourceMock());
```

- [ ] **Step 3: Register impl datasource**

Inside the `else {` block (after line 99 — `ClassDatasourceImpl()` registration), add:

```dart
    getIt.registerLazySingleton<ICourseDatasource>(
        () => CourseDatasourceImpl(getIt<DioHandler>().dio));
```

- [ ] **Step 4: Register repository and usecases**

After the `IClassRepository` registration (after line 124), add:

```dart
  getIt.registerLazySingleton<ICourseRepository>(
    () => CourseRepositoryImpl(getIt()),
  );
```

After the existing usecase registrations (after `DeleteCourseUsecase` line ~140), add:

```dart
  getIt.registerLazySingleton(() => CreateCourseUsecase(getIt()));
  getIt.registerLazySingleton(() => CreateModuleUsecase(getIt()));
```

- [ ] **Step 5: Verify no analysis errors**

Run: `cd edium && flutter analyze lib/core/di/injection.dart`
Expected: No issues found

- [ ] **Step 6: Commit**

```bash
git add lib/core/di/injection.dart
git commit -m "feat: register course datasource, repository, and usecases in DI"
```

---

### Task 4: BLoC — Events, State, Bloc

**Files:**
- Create: `lib/presentation/teacher/create_course/bloc/create_course_event.dart`
- Create: `lib/presentation/teacher/create_course/bloc/create_course_state.dart`
- Create: `lib/presentation/teacher/create_course/bloc/create_course_bloc.dart`

- [ ] **Step 1: Create events**

Create `lib/presentation/teacher/create_course/bloc/create_course_event.dart`:

```dart
import 'package:equatable/equatable.dart';

abstract class CreateCourseEvent extends Equatable {
  const CreateCourseEvent();
  @override
  List<Object?> get props => [];
}

class UpdateCourseTitleEvent extends CreateCourseEvent {
  final String title;
  const UpdateCourseTitleEvent(this.title);
  @override
  List<Object?> get props => [title];
}

class AddModuleEvent extends CreateCourseEvent {
  const AddModuleEvent();
}

class UpdateModuleEvent extends CreateCourseEvent {
  final int index;
  final String title;
  const UpdateModuleEvent(this.index, this.title);
  @override
  List<Object?> get props => [index, title];
}

class RemoveModuleEvent extends CreateCourseEvent {
  final int index;
  const RemoveModuleEvent(this.index);
  @override
  List<Object?> get props => [index];
}

class SubmitCourseEvent extends CreateCourseEvent {
  final String classId;
  const SubmitCourseEvent(this.classId);
  @override
  List<Object?> get props => [classId];
}
```

- [ ] **Step 2: Create state**

Create `lib/presentation/teacher/create_course/bloc/create_course_state.dart`:

```dart
import 'package:equatable/equatable.dart';

class CreateCourseState extends Equatable {
  final String title;
  final List<String> modules;
  final bool isSubmitting;
  final String? error;
  final bool success;

  const CreateCourseState({
    this.title = '',
    this.modules = const [],
    this.isSubmitting = false,
    this.error,
    this.success = false,
  });

  bool get canSubmit => title.trim().isNotEmpty && !isSubmitting;

  CreateCourseState copyWith({
    String? title,
    List<String>? modules,
    bool? isSubmitting,
    String? error,
    bool? success,
  }) {
    return CreateCourseState(
      title: title ?? this.title,
      modules: modules ?? this.modules,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
      success: success ?? this.success,
    );
  }

  @override
  List<Object?> get props => [title, modules, isSubmitting, error, success];
}
```

- [ ] **Step 3: Create bloc**

Create `lib/presentation/teacher/create_course/bloc/create_course_bloc.dart`:

```dart
import 'package:edium/domain/usecases/course/create_course_usecase.dart';
import 'package:edium/domain/usecases/course/create_module_usecase.dart';
import 'package:edium/presentation/teacher/create_course/bloc/create_course_event.dart';
import 'package:edium/presentation/teacher/create_course/bloc/create_course_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateCourseBloc extends Bloc<CreateCourseEvent, CreateCourseState> {
  final CreateCourseUsecase _createCourse;
  final CreateModuleUsecase _createModule;

  CreateCourseBloc(this._createCourse, this._createModule)
      : super(const CreateCourseState()) {
    on<UpdateCourseTitleEvent>(
        (e, emit) => emit(state.copyWith(title: e.title)));
    on<AddModuleEvent>(
        (_, emit) => emit(state.copyWith(modules: [...state.modules, ''])));
    on<UpdateModuleEvent>((e, emit) {
      final updated = List<String>.from(state.modules);
      updated[e.index] = e.title;
      emit(state.copyWith(modules: updated));
    });
    on<RemoveModuleEvent>((e, emit) {
      final updated = List<String>.from(state.modules)..removeAt(e.index);
      emit(state.copyWith(modules: updated));
    });
    on<SubmitCourseEvent>(_onSubmit);
  }

  Future<void> _onSubmit(
    SubmitCourseEvent event,
    Emitter<CreateCourseState> emit,
  ) async {
    if (!state.canSubmit) return;
    emit(state.copyWith(isSubmitting: true));
    try {
      final courseId = await _createCourse(
        title: state.title.trim(),
        classId: event.classId,
      );

      final validModules =
          state.modules.where((m) => m.trim().isNotEmpty).toList();
      if (validModules.isNotEmpty) {
        await Future.wait(
          validModules
              .map((m) => _createModule(courseId: courseId, title: m.trim())),
        );
      }

      emit(state.copyWith(isSubmitting: false, success: true));
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, error: e.toString()));
    }
  }
}
```

- [ ] **Step 4: Verify no analysis errors**

Run: `cd edium && flutter analyze lib/presentation/teacher/create_course/bloc/`
Expected: No issues found

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/teacher/create_course/bloc/
git commit -m "feat: add CreateCourseBloc with events and state"
```

---

### Task 5: CreateCourseScreen UI

**Files:**
- Create: `lib/presentation/teacher/create_course/create_course_screen.dart`

Reference files for style:
- `lib/presentation/auth/screens/name_input_screen.dart` — layout, text field, button patterns
- `lib/core/theme/app_colors.dart` — mono palette
- `lib/core/theme/app_dimens.dart` — spacing, radii
- `lib/core/theme/app_text_styles.dart` — screenTitle, fieldLabel, fieldText, fieldHint, primaryButton

- [ ] **Step 1: Create the screen file**

Create `lib/presentation/teacher/create_course/create_course_screen.dart`:

```dart
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

class _CreateCourseView extends StatefulWidget {
  final String classId;
  const _CreateCourseView({required this.classId});

  @override
  State<_CreateCourseView> createState() => _CreateCourseViewState();
}

class _CreateCourseViewState extends State<_CreateCourseView> {
  final _titleCtrl = TextEditingController();
  final List<TextEditingController> _moduleControllers = [];
  final List<FocusNode> _moduleFocusNodes = [];

  @override
  void dispose() {
    _titleCtrl.dispose();
    for (final c in _moduleControllers) {
      c.dispose();
    }
    for (final n in _moduleFocusNodes) {
      n.dispose();
    }
    super.dispose();
  }

  void _addModule() {
    context.read<CreateCourseBloc>().add(const AddModuleEvent());
    final controller = TextEditingController();
    final focusNode = FocusNode();
    _moduleControllers.add(controller);
    _moduleFocusNodes.add(focusNode);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNode.requestFocus();
    });
  }

  void _removeModule(int index) {
    context.read<CreateCourseBloc>().add(RemoveModuleEvent(index));
    _moduleControllers[index].dispose();
    _moduleFocusNodes[index].dispose();
    _moduleControllers.removeAt(index);
    _moduleFocusNodes.removeAt(index);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateCourseBloc, CreateCourseState>(
      listener: (context, state) {
        if (state.success) {
          context.pop(true);
        } else if (state.error != null) {
          EdiumNotification.show(
            context,
            state.error!,
            type: EdiumNotificationType.error,
          );
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.screenPaddingH),
              child: CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        _buildHeader(context),
                        const SizedBox(height: 28),
                        _buildTitleField(),
                        const SizedBox(height: 24),
                        _buildModulesSection(),
                        const Spacer(),
                        _buildSubmitButton(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => context.pop(),
          child: const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(
              Icons.arrow_back_ios_new,
              size: 20,
              color: AppColors.mono400,
            ),
          ),
        ),
        const Text('Новый курс', style: AppTextStyles.screenTitle),
      ],
    );
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Название курса', style: AppTextStyles.fieldLabel),
        const SizedBox(height: 8),
        Container(
          height: AppDimens.inputH,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            border: Border.all(
                color: AppColors.mono250, width: AppDimens.borderWidth),
          ),
          child: TextField(
            controller: _titleCtrl,
            cursorColor: AppColors.mono900,
            style: AppTextStyles.fieldText,
            onChanged: (v) => context
                .read<CreateCourseBloc>()
                .add(UpdateCourseTitleEvent(v)),
            decoration: const InputDecoration(
              hintText: 'Алгебра. Базовый курс',
              hintStyle: AppTextStyles.fieldHint,
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModulesSection() {
    return BlocBuilder<CreateCourseBloc, CreateCourseState>(
      buildWhen: (prev, curr) => prev.modules != curr.modules,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Модули (${state.modules.length})',
                  style: AppTextStyles.fieldLabel,
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _addModule,
                  child: Text(
                    '+ Добавить',
                    style: AppTextStyles.fieldLabel
                        .copyWith(color: AppColors.mono700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...List.generate(state.modules.length, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ModuleCard(
                  index: i,
                  controller: _moduleControllers[i],
                  focusNode: _moduleFocusNodes[i],
                  onChanged: (value) => context
                      .read<CreateCourseBloc>()
                      .add(UpdateModuleEvent(i, value)),
                  onRemove: () => _removeModule(i),
                ),
              );
            }),
            const SizedBox(height: 4),
            _buildAddModuleButton(),
          ],
        );
      },
    );
  }

  Widget _buildAddModuleButton() {
    return GestureDetector(
      onTap: _addModule,
      child: Container(
        width: double.infinity,
        height: AppDimens.buttonHSm,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          border: Border.all(
            color: AppColors.mono300,
            width: AppDimens.borderWidth,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: CustomPaint(
          painter: _DashedBorderPainter(
            color: AppColors.mono300,
            radius: AppDimens.radiusLg,
            strokeWidth: AppDimens.borderWidth,
          ),
          child: Center(
            child: Text(
              '+ Добавить модуль',
              style:
                  AppTextStyles.fieldText.copyWith(color: AppColors.mono400),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return BlocBuilder<CreateCourseBloc, CreateCourseState>(
      buildWhen: (prev, curr) =>
          prev.canSubmit != curr.canSubmit ||
          prev.isSubmitting != curr.isSubmitting,
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          height: AppDimens.buttonH,
          child: ElevatedButton(
            onPressed: state.canSubmit
                ? () => context
                    .read<CreateCourseBloc>()
                    .add(SubmitCourseEvent(widget.classId))
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mono900,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.mono200,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimens.radiusLg),
              ),
              elevation: 0,
              textStyle: AppTextStyles.primaryButton,
            ),
            child: state.isSubmitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Text('Сохранить курс'),
          ),
        );
      },
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final int index;
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onRemove;

  const _ModuleCard({
    required this.index,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(
            color: AppColors.mono250, width: AppDimens.borderWidth),
      ),
      child: Row(
        children: [
          const Icon(Icons.drag_indicator, size: 20, color: AppColors.mono300),
          const SizedBox(width: 8),
          Text(
            'Модуль ${index + 1}',
            style: AppTextStyles.fieldText
                .copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 6),
          Text('·', style: AppTextStyles.fieldText.copyWith(color: AppColors.mono300)),
          const SizedBox(width: 6),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              cursorColor: AppColors.mono900,
              style: AppTextStyles.fieldText,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: 'Название модуля',
                hintStyle: AppTextStyles.fieldHint,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            child: const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(Icons.close, size: 18, color: AppColors.mono400),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double strokeWidth;

  _DashedBorderPainter({
    required this.color,
    required this.radius,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(radius),
      ));

    const dashWidth = 6.0;
    const dashSpace = 4.0;

    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      double distance = 0;
      while (distance < metric.length) {
        final end = (distance + dashWidth).clamp(0, metric.length).toDouble();
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter old) =>
      color != old.color || radius != old.radius || strokeWidth != old.strokeWidth;
}
```

- [ ] **Step 2: Verify no analysis errors**

Run: `cd edium && flutter analyze lib/presentation/teacher/create_course/`
Expected: No issues found

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/teacher/create_course/create_course_screen.dart
git commit -m "feat: add CreateCourseScreen UI with monochrome design"
```

---

### Task 6: Routing & Navigation Wiring

**Files:**
- Modify: `lib/core/router/app_router.dart`
- Modify: `lib/presentation/class_detail/class_detail_screen.dart`

- [ ] **Step 1: Add route in app_router.dart**

Add import at top of `lib/core/router/app_router.dart`:

```dart
import 'package:edium/presentation/teacher/create_course/create_course_screen.dart';
```

Add route before the closing `],` of the routes list (after the `/class/:classId` route, before line 102):

```dart
      GoRoute(
        path: '/course/create',
        builder: (_, state) {
          final classId = state.uri.queryParameters['classId'] ?? '';
          return CreateCourseScreen(classId: classId);
        },
      ),
```

- [ ] **Step 2: Wire navigation from ClassDetailScreen**

In `lib/presentation/class_detail/class_detail_screen.dart`, find the TODO on line ~591:

```dart
                onPressed: () {
                  // TODO: навигация на экран создания курса
                },
```

Replace with:

```dart
                onPressed: () async {
                  final result = await context.push<bool>(
                    '/course/create?classId=${widget.classId}',
                  );
                  if (result == true && context.mounted) {
                    context
                        .read<ClassDetailBloc>()
                        .add(LoadClassDetailEvent(widget.classId));
                  }
                },
```

Make sure `go_router` is imported (it already is if `context.push` is used elsewhere in the file — verify). Also verify `widget.classId` is accessible — the screen takes `classId` as a constructor param.

- [ ] **Step 3: Verify no analysis errors**

Run: `cd edium && flutter analyze lib/core/router/app_router.dart lib/presentation/class_detail/class_detail_screen.dart`
Expected: No issues found

- [ ] **Step 4: Commit**

```bash
git add lib/core/router/app_router.dart lib/presentation/class_detail/class_detail_screen.dart
git commit -m "feat: wire CreateCourse route and navigation from ClassDetail"
```

---

### Task 7: Manual Smoke Test

- [ ] **Step 1: Run the app**

Run: `cd edium && flutter run`

- [ ] **Step 2: Navigate to CreateCourse**

1. Log in (any phone + OTP `1234` in mock mode)
2. Go to Classes tab
3. Tap a class you own
4. On the "Курсы" tab, tap "Создать курс"
5. Verify: screen opens with "Новый курс" header, back button, title field, modules section

- [ ] **Step 3: Test core flows**

1. Type a course name → "Сохранить курс" button becomes active (black)
2. Clear the name → button becomes disabled (gray)
3. Tap "+ Добавить" → module card appears with focus on name field
4. Tap the bottom "+ Добавить модуль" → another module card appears
5. Type module names
6. Tap ✕ on a module → it is removed
7. Tap "Сохранить курс" → loading spinner → screen closes, returns to class detail

- [ ] **Step 4: Test edge cases**

1. Save with empty modules (no modules added) → should succeed (course with no modules)
2. Save with modules that have empty names → empty modules should be skipped
3. Tap back arrow → returns to class detail without saving
4. Tap outside text fields → keyboard dismisses
