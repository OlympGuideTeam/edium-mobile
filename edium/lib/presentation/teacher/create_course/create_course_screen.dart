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

  void _reorderModule(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    context
        .read<CreateCourseBloc>()
        .add(ReorderModulesEvent(oldIndex, newIndex));
    final ctrl = _moduleControllers.removeAt(oldIndex);
    _moduleControllers.insert(newIndex, ctrl);
    final focus = _moduleFocusNodes.removeAt(oldIndex);
    _moduleFocusNodes.insert(newIndex, focus);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateCourseBloc, CreateCourseState>(
      listener: (context, state) {
        if (state.success && state.courseId != null) {
          context.pop(state.courseId);
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
            Theme(
              data: Theme.of(context).copyWith(
                canvasColor: Colors.transparent,
              ),
              child: ReorderableListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              proxyDecorator: (child, index, animation) {
                return Material(
                  elevation: 6,
                  color: Colors.transparent,
                  shadowColor: Colors.black12,
                  borderRadius:
                      BorderRadius.circular(AppDimens.radiusLg),
                  clipBehavior: Clip.antiAlias,
                  child: child,
                );
              },
              onReorder: _reorderModule,
              children: List.generate(state.modules.length, (i) {
                return _entryAnimation(
                  // ObjectKey привязывает виджет к конкретному контроллеру,
                  // а не к позиции — фокус следует за перемещённой ячейкой.
                  key: ObjectKey(_moduleControllers[i]),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildDismissible(
                      key: ValueKey(_moduleControllers[i]),
                      canDismiss: state.modules.length > 1,
                      onDismissed: () => _removeModule(i),
                      child: _ModuleCard(
                        index: i,
                        controller: _moduleControllers[i],
                        focusNode: _moduleFocusNodes[i],
                        onChanged: (value) => context
                            .read<CreateCourseBloc>()
                            .add(UpdateModuleEvent(i, value)),
                      ),
                    ),
                  ),
                );
              }),
            ),
            ),
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
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: AppColors.mono300,
          radius: AppDimens.radiusLg,
          strokeWidth: AppDimens.borderWidth,
        ),
        child: Container(
          width: double.infinity,
          height: AppDimens.buttonHSm,
          alignment: Alignment.center,
          child: Text(
            '+ Добавить модуль',
            style: AppTextStyles.fieldText.copyWith(color: AppColors.mono400),
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

// ─── Shared helpers ───────────────────────────────────────────────────────────

Widget _entryAnimation({required Key key, required Widget child}) {
  return TweenAnimationBuilder<double>(
    key: key,
    tween: Tween(begin: 0.0, end: 1.0),
    duration: const Duration(milliseconds: 280),
    curve: Curves.easeOutCubic,
    builder: (_, v, c) => Opacity(
      opacity: v,
      child: Transform.translate(offset: Offset(0, (1 - v) * 10), child: c),
    ),
    child: child,
  );
}

Widget _buildDismissible({
  required Key key,
  required bool canDismiss,
  required VoidCallback onDismissed,
  required Widget child,
}) {
  if (!canDismiss) return child;
  return ClipRRect(
    borderRadius: BorderRadius.circular(AppDimens.radiusLg),
    child: Container(
      color: AppColors.error,
      child: Dismissible(
        key: key,
        direction: DismissDirection.endToStart,
        onDismissed: (_) => onDismissed(),
        background: Container(
          color: AppColors.error,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(Icons.delete_outline, color: Colors.white, size: 18),
        ),
        child: child,
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────

class _ModuleCard extends StatelessWidget {
  final int index;
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  const _ModuleCard({
    required this.index,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border:
            Border.all(color: AppColors.mono250, width: AppDimens.borderWidth),
      ),
      child: Row(
        children: [
          ReorderableDragStartListener(
            index: index,
            child: const Icon(
                Icons.drag_indicator, size: 20, color: AppColors.mono300),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              cursorColor: AppColors.mono900,
              style: AppTextStyles.fieldText,
              onChanged: onChanged,
              decoration: const InputDecoration(
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
      color != old.color ||
      radius != old.radius ||
      strokeWidth != old.strokeWidth;
}
