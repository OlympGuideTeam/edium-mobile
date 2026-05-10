part of 'student_home_screen.dart';

class _DashboardSection extends StatelessWidget {
  final void Function(int) onNavigateToTab;

  const _DashboardSection({required this.onNavigateToTab});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StudentDashboardCubit, StudentDashboardState>(
      builder: (context, state) {
        final dashboard =
            state is StudentDashboardLoaded ? state.dashboard : null;
        final hasActiveTests =
            dashboard != null && dashboard.activeTests.isNotEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (dashboard != null && dashboard.recentGrades.isNotEmpty) ...[
              const Text('ПОСЛЕДНИЕ ОЦЕНКИ',
                  style: AppTextStyles.sectionTag),
              const SizedBox(height: 12),
              _RecentGradesBlock(items: dashboard.recentGrades),
              const SizedBox(height: 24),
            ],
            if (hasActiveTests) ...[
              const Text('ДОСТУПНЫЕ ТЕСТЫ',
                  style: AppTextStyles.sectionTag),
              const SizedBox(height: 12),
              ...dashboard.activeTests.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _ActiveTestTile(item: item),
                  )),
              const SizedBox(height: 24),
            ],
            Material(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(AppDimens.radiusLg),
              child: InkWell(
                onTap: () => onNavigateToTab(1),
                borderRadius:
                    BorderRadius.circular(AppDimens.radiusLg),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(AppDimens.radiusLg),
                    border: Border.all(
                      color: AppColors.mono150,
                      width: AppDimens.borderWidth,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.mono50,
                          borderRadius: BorderRadius.circular(
                              AppDimens.radiusMd),
                        ),
                        child: Icon(CupertinoIcons.compass,
                            color: AppColors.mono700, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Начните обучение',
                              style:
                                  AppTextStyles.fieldText.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Перейдите в «Квизы», чтобы найти тест',
                              style: AppTextStyles.helperText,
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right,
                          color: AppColors.mono300, size: 20),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }
}

