part of 'quiz_library_screen.dart';

class _QuizLibraryScaffold extends StatefulWidget {
  const _QuizLibraryScaffold();

  @override
  State<_QuizLibraryScaffold> createState() => _QuizLibraryScaffoldState();
}

class _QuizLibraryScaffoldState extends State<_QuizLibraryScaffold> {
  final _allTabKey = GlobalKey<_AllQuizzesTabState>();
  final _mineTabKey = GlobalKey<_MyQuizzesTabState>();

  void _onCreateTap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => CreateQuizBloc(
            getIt(),
            getIt<CreateSessionUsecase>(),
            getIt<IQuizRepository>(),
          ),
          child: const CreateQuizScreen(),
        ),
      ),
    ).then((_) {
      _allTabKey.currentState?.reload();
      _mineTabKey.currentState?.reload();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppDimens.screenPaddingH, 32, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.mono900,
                        borderRadius:
                            BorderRadius.circular(AppDimens.radiusXs),
                      ),
                      child: const Text('УЧИТЕЛЬ',
                          style: AppTextStyles.badgeText),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Expanded(
                          child: Text('Библиотека',
                              style: AppTextStyles.screenTitle),
                        ),
                        IconButton(
                          onPressed: _onCreateTap,
                          icon: const Icon(Icons.add, size: 26),
                          color: AppColors.mono900,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              const TabBar(
                labelColor: AppColors.mono900,
                unselectedLabelColor: AppColors.mono400,
                indicatorColor: AppColors.mono900,
                indicatorSize: TabBarIndicatorSize.label,
                dividerColor: AppColors.mono150,
                splashFactory: NoSplash.splashFactory,
                overlayColor: WidgetStatePropertyAll(Colors.transparent),
                padding: EdgeInsets.symmetric(
                    horizontal: AppDimens.screenPaddingH),
                labelStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                tabs: [
                  Tab(text: 'Все квизы'),
                  Tab(text: 'Мои квизы'),
                  Tab(text: 'Мои лайвы'),
                ],
              ),

              Expanded(
                child: TabBarView(
                  children: [
                    _AllQuizzesTab(key: _allTabKey),
                    _MyQuizzesTab(key: _mineTabKey),
                    const _LiveTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

