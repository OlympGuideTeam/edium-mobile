part of 'course_detail_screen.dart';

class _TemplatePickerContent extends StatefulWidget {
  final ScrollController scrollController;
  final void Function(Quiz quiz) onSelected;

  const _TemplatePickerContent({
    required this.scrollController,
    required this.onSelected,
  });

  @override
  State<_TemplatePickerContent> createState() => _TemplatePickerContentState();
}

class _TemplatePickerContentState extends State<_TemplatePickerContent> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Column(
      children: [
        const SizedBox(height: 14),
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.mono150,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppDimens.screenPaddingH),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Выберите шаблон',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.mono900,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),


        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.screenPaddingH,
          ),
          child: SearchBarWidget(
            controller: _searchController,
            hint: 'Поиск шаблонов…',
            onChanged: (v) => context.read<TemplateSearchCubit>().search(v),
            onClear: () => context.read<TemplateSearchCubit>().search(''),
          ),
        ),
        const SizedBox(height: 14),


        Expanded(
          child: BlocBuilder<TemplateSearchCubit, TemplateSearchState>(
            builder: (context, state) {
              if (state is TemplateSearchLoading ||
                  state is TemplateSearchInitial) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.mono900,
                    strokeWidth: 2,
                  ),
                );
              }

              if (state is TemplateSearchError) {
                return Center(
                  child: Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.mono400,
                    ),
                  ),
                );
              }

              final quizzes = (state as TemplateSearchLoaded).quizzes;
              final query = _searchController.text;

              if (quizzes.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.search_off,
                        size: 40,
                        color: AppColors.mono200,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        query.isNotEmpty
                            ? 'Ничего не найдено по «$query»'
                            : 'Шаблонов пока нет',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.mono400,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                controller: widget.scrollController,
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.screenPaddingH,
                  4,
                  AppDimens.screenPaddingH,
                  24,
                ),
                itemCount: quizzes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _TemplateCard(
                  quiz: quizzes[i],
                  onTap: () => widget.onSelected(quizzes[i]),
                ),
              );
            },
          ),
        ),
      ],
      ),
    );
  }
}

