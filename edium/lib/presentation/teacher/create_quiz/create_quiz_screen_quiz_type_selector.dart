part of 'create_quiz_screen.dart';

class _QuizTypeSelector extends StatefulWidget {
  final QuizCreationMode quizType;
  final bool isInCourseContext;
  const _QuizTypeSelector({
    required this.quizType,
    required this.isInCourseContext,
  });

  @override
  State<_QuizTypeSelector> createState() => _QuizTypeSelectorState();
}

class _QuizTypeSelectorState extends State<_QuizTypeSelector> {
  List<_TypePillData> get _items {
    final list = <_TypePillData>[];
    if (!widget.isInCourseContext) {
      list.add(_TypePillData(
        label: 'Шаблон',
        icon: Icons.bookmark_border_outlined,
        mode: QuizCreationMode.template,
      ));
    }
    list.add(_TypePillData(
      label: 'Тест',
      icon: Icons.timer_outlined,
      mode: QuizCreationMode.test,
    ));
    list.add(_TypePillData(
      label: 'Лайв',
      icon: Icons.bolt_outlined,
      mode: QuizCreationMode.live,
    ));
    return list;
  }

  int get _activeIndex {
    final items = _items;
    for (var i = 0; i < items.length; i++) {
      if (items[i].mode == widget.quizType) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    final count = items.length;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.mono50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.mono100),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = constraints.maxWidth / count;
          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                left: _activeIndex * itemWidth,
                top: 0,
                bottom: 0,
                width: itemWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.mono900,
                    borderRadius: BorderRadius.circular(9),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.mono900.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: List.generate(count, (i) {
                  final item = items[i];
                  final isActive = i == _activeIndex;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => context
                          .read<CreateQuizBloc>()
                          .add(SetQuizTypeEvent(item.mode)),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 250),
                              style: TextStyle(
                                fontSize: 0,
                                color: isActive
                                    ? Colors.white
                                    : AppColors.mono400,
                              ),
                              child: Icon(
                                item.icon,
                                size: 18,
                                color: isActive
                                    ? Colors.white
                                    : AppColors.mono400,
                              ),
                            ),
                            const SizedBox(height: 3),
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 250),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isActive
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isActive
                                    ? Colors.white
                                    : AppColors.mono400,
                              ),
                              child: Text(item.label),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}

