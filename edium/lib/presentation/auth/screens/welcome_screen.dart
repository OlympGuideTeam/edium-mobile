import 'package:edium/core/config/api_config.dart';
import 'package:edium/core/di/injection.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_dimens.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/domain/entities/live_session.dart';
import 'package:edium/domain/repositories/live_repository.dart';
import 'package:edium/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

part 'welcome_screen_env_switcher.dart';
part 'welcome_screen_quiz_code_block.dart';


class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  final _codeController = TextEditingController();
  final _codeFocus = FocusNode();
  bool _codeFieldFocused = false;
  bool _switching = false;
  bool _codeLoading = false;
  String? _codeError;

  late final AnimationController _animController;
  late final Animation<double> _logoOpacity;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _logoOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    _codeFocus.addListener(() {
      final focused = _codeFocus.hasFocus;
      if (focused != _codeFieldFocused) {
        setState(() => _codeFieldFocused = focused);
        if (focused) {
          _animController.forward();
        } else {
          _animController.reverse();
        }
      }
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    _codeFocus.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _submitCode() async {
    final code = _codeController.text.trim();
    if (code.length != 6 || _codeLoading) return;

    setState(() {
      _codeLoading = true;
      _codeError = null;
    });

    try {
      final repo = getIt<ILiveRepository>();
      final meta = await repo.resolveLiveCode(code);

      if (!mounted) return;

      if (meta.phase != LivePhase.lobby) {
        setState(() {
          _codeLoading = false;
          _codeError = 'Квиз уже идёт или завершён';
        });
        return;
      }

      if (meta.source == 'course') {
        setState(() {
          _codeLoading = false;
          _codeError = 'Этот квиз — только для авторизованных участников класса';
        });
        return;
      }

      context.push('/live/join/name', extra: meta);
      setState(() => _codeLoading = false);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _codeLoading = false;
        _codeError = 'Квиз не найден';
      });
    }
  }

  void _onCellTap(int index) {
    _codeFocus.requestFocus();
    final text = _codeController.text;
    if (index < text.length) {
      final trimmed = text.substring(0, index);
      _codeController.value = TextEditingValue(
        text: trimmed,
        selection: TextSelection.collapsed(offset: trimmed.length),
      );
    }
    setState(() {});
  }

  void _dismissKeyboard() {
    if (_codeFocus.hasFocus) {
      _codeFocus.unfocus();
    }
  }

  Future<void> _switchEnv(AppEnvironment env) async {
    if (env == ApiConfig.environment || _switching) return;
    setState(() => _switching = true);
    await reinitializeDependencies(env);
    appRestartKey.value++;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _dismissKeyboard,
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.screenPaddingH),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(flex: 3),
                AnimatedBuilder(
                  animation: _animController,
                  builder: (context, child) =>
                      FadeTransition(opacity: _logoOpacity, child: child),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppDimens.radiusXl),
                        child: Image.asset(
                          'assets/images/logo_e.png',
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text('edium', style: AppTextStyles.screenTitle),
                      const SizedBox(height: 6),
                      const Text(
                        'Образовательная платформа',
                        style: TextStyle(fontSize: 14, color: AppColors.mono300),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
                const Spacer(flex: 4),
                SizedBox(
                  width: double.infinity,
                  height: AppDimens.buttonH,
                  child: ElevatedButton(
                    onPressed: () => context.push('/phone'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mono900,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                      ),
                      elevation: 0,
                      textStyle: AppTextStyles.primaryButton,
                    ),
                    child: const Text('Войти'),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: Divider(color: AppColors.mono150)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'или',
                        style: TextStyle(fontSize: 13, color: AppColors.mono250),
                      ),
                    ),
                    Expanded(child: Divider(color: AppColors.mono150)),
                  ],
                ),
                const SizedBox(height: 20),
                _QuizCodeBlock(
                  controller: _codeController,
                  focusNode: _codeFocus,
                  isFocused: _codeFieldFocused,
                  loading: _codeLoading,
                  onSubmit: _submitCode,
                  onCellTap: _onCellTap,
                  onChanged: (_) {
                    if (_codeError != null) setState(() => _codeError = null);
                  },
                ),
                if (_codeError != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    _codeError!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, color: Color(0xFFD32F2F)),
                  ),
                ],
                const SizedBox(height: 24),
                if (!ApiConfig.isStoreBuild) ...[
                  _EnvSwitcher(
                    current: ApiConfig.environment,
                    switching: _switching,
                    onSelect: _switchEnv,
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

