part of 'student_home_screen.dart';

class _JoinLiveBlock extends StatefulWidget {
  const _JoinLiveBlock();

  @override
  State<_JoinLiveBlock> createState() => _JoinLiveBlockState();
}

class _JoinLiveBlockState extends State<_JoinLiveBlock> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _expanded = false;
  bool _focused = false;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      final f = _focusNode.hasFocus;
      if (f != _focused) setState(() => _focused = f);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _expand() {
    setState(() {
      _expanded = true;
      _error = null;
    });
    Future.delayed(const Duration(milliseconds: 230), () {
      if (mounted) _focusNode.requestFocus();
    });
  }

  void _collapse() {
    _focusNode.unfocus();
    _controller.clear();
    setState(() {
      _expanded = false;
      _error = null;
      _loading = false;
    });
  }

  void _onCellTap(int index) {
    _focusNode.requestFocus();
    final text = _controller.text;
    if (index < text.length) {
      final trimmed = text.substring(0, index);
      _controller.value = TextEditingValue(
        text: trimmed,
        selection: TextSelection.collapsed(offset: trimmed.length),
      );
    }
    setState(() {});
  }

  Future<void> _submit() async {
    final code = _controller.text.trim();
    if (code.length != 6 || _loading) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    LiveSessionMeta? meta;
    try {
      final repo = getIt<ILiveRepository>();
      meta = await repo.resolveLiveCode(code);

      if (!mounted) return;

      if (meta.phase != LivePhase.lobby) {
        setState(() {
          _loading = false;
          _error = 'Лобби уже закрыто или квиз завершён';
        });
        return;
      }

      final join = await repo.joinLiveSession(sessionId: meta.sessionId);

      if (!mounted) return;

      final moduleId = join.moduleId ?? meta.moduleId;
      context.push(
        '/live/${meta.sessionId}/student',
        extra: {
          'attemptId': join.attemptId,
          'wsToken': join.wsToken,
          'quizTitle': meta.quizTitle,
          'questionCount': meta.questionCount,
          if (moduleId != null) 'moduleId': moduleId,
        },
      );
      _collapse();
    } catch (e) {
      if (!mounted) return;
      final m = meta;
      if (m != null &&
          tryNavigateLiveStudentAfterJoinSessionCompleted(
            e,
            context: context,
            sessionId: m.sessionId,
            quizTitle: m.quizTitle,
            questionCount: m.questionCount,
            moduleId: m.moduleId,
          )) {
        _collapse();
        return;
      }
      setState(() {
        _loading = false;
        _error = e is ApiException && e.code == 'SESSION_COMPLETED'
            ? e.message
            : 'Квиз не найден';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 220),
      sizeCurve: Curves.easeInOut,
      firstChild: _buildCollapsed(),
      secondChild: _buildExpanded(),
      crossFadeState:
          _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
    );
  }

  Widget _buildCollapsed() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      child: InkWell(
        onTap: _expand,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusLg),
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
                  color: AppColors.mono900,
                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                ),
                child: const Icon(
                  CupertinoIcons.bolt_fill,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Присоединиться к лайву',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.mono900,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Введите 6-значный код от учителя',
                      style: AppTextStyles.helperText,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.mono300, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpanded() {
    return GestureDetector(
      onTap: () => _focusNode.requestFocus(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: _focused ? AppColors.mono700 : AppColors.mono200,
            width: AppDimens.borderWidth,
          ),
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('ПРИСОЕДИНИТЬСЯ К ЛАЙВУ',
                    style: AppTextStyles.sectionTag),
                const Spacer(),
                GestureDetector(
                  onTap: _collapse,
                  child: const Icon(Icons.close,
                      color: AppColors.mono400, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: AppDimens.otpCellH,
              child: Stack(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (i) {
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => _onCellTap(i),
                          child: AnimatedBuilder(
                            animation: _controller,
                            builder: (_, __) {
                              final text = _controller.text;
                              final hasDigit = i < text.length;
                              final isNext = i == text.length;
                              final borderColor = hasDigit
                                  ? AppColors.mono700
                                  : (isNext && _focused)
                                      ? AppColors.mono700
                                      : AppColors.mono150;
                              return Container(
                                height: AppDimens.otpCellH,
                                margin: EdgeInsets.symmetric(
                                    horizontal: AppDimens.otpCellGap / 2),
                                decoration: BoxDecoration(
                                  color: hasDigit
                                      ? Colors.white
                                      : AppColors.mono25,
                                  borderRadius: BorderRadius.circular(
                                      AppDimens.radiusSm),
                                  border: Border.all(
                                      color: borderColor,
                                      width: AppDimens.borderWidth),
                                ),
                                child: Center(
                                  child: hasDigit
                                      ? Text(text[i],
                                          style: AppTextStyles.otpDigit)
                                      : null,
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    }),
                  ),
                  Positioned.fill(
                    child: ExcludeSemantics(
                      child: Opacity(
                        opacity: 0,
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          showCursor: false,
                          enableInteractiveSelection: false,
                          stylusHandwritingEnabled: false,
                          contextMenuBuilder: (_, __) =>
                              const SizedBox.shrink(),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(6),
                          ],
                          onChanged: (value) {
                            if (_error != null) {
                              setState(() => _error = null);
                            }
                            setState(() {});
                            if (value.length == 6) _submit();
                          },
                          decoration: const InputDecoration(
                            counterText: '',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            if (_loading)
              const Center(
                child: SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.mono400),
                ),
              )
            else if (_error != null)
              Center(
                child: Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFFD32F2F)),
                ),
              )
            else
              const Center(
                child: Text(
                  'Учитель покажет код на экране',
                  style: TextStyle(fontSize: 12, color: AppColors.mono300),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
