part of 'student_quiz_library_screen.dart';

class _QuizTabBar extends StatelessWidget {
  const _QuizTabBar();

  @override
  Widget build(BuildContext context) {
    return const TabBar(
      labelColor: AppColors.mono900,
      unselectedLabelColor: AppColors.mono400,
      indicatorColor: AppColors.mono900,
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: AppColors.mono150,
      splashFactory: NoSplash.splashFactory,
      overlayColor: WidgetStatePropertyAll(Colors.transparent),
      padding: EdgeInsets.symmetric(horizontal: AppDimens.screenPaddingH),
      labelStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      tabs: [
        Tab(text: 'Все'),
        Tab(text: 'Пройденные'),
      ],
    );
  }
}

