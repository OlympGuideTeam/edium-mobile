part of 'create_course_screen.dart';

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
      height: AppDimens.buttonH,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border:
            Border.all(color: AppColors.mono250, width: AppDimens.borderWidth),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
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

