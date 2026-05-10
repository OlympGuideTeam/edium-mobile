import 'package:edium/core/di/injection.dart';
import 'package:edium/core/storage/profile_storage.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_dimens.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

part 'onboarding_screen_slide_data.dart';
part 'onboarding_screen_slide_page.dart';


class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const _slides = [
    _SlideData(
      icon: Icons.auto_awesome_rounded,
      title: 'Умная проверка и генерация',
      subtitle:
          'AI проверяет свободные ответы и создаёт тесты по вашему материалу',
    ),
    _SlideData(
      icon: Icons.cell_tower_rounded,
      title: 'Квизы в прямом эфире',
      subtitle:
          'Проводите интерактивные квизы в реальном времени для всего класса',
    ),
    _SlideData(
      icon: Icons.dashboard_rounded,
      title: 'Всё для учёбы в одном месте',
      subtitle:
          'Классы, курсы, библиотека квизов и ведомости — больше не нужно переключаться между сервисами',
    ),
  ];

  bool get _isLastPage => _currentPage == _slides.length - 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _complete() async {
    await getIt<ProfileStorage>().completeOnboarding();
    if (mounted) context.go('/welcome');
  }

  void _next() {
    if (_isLastPage) {
      _complete();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppDimens.screenPaddingH),
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildSkipButton(),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _slides.length,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (_, i) => _SlidePage(data: _slides[i]),
                ),
              ),
              _buildDots(),
              const SizedBox(height: 32),
              _buildNextButton(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkipButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: AnimatedOpacity(
        opacity: _isLastPage ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: GestureDetector(
          onTap: _isLastPage ? null : _complete,
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Пропустить',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.mono300,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_slides.length, (i) {
        final isActive = i == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? AppColors.mono900 : AppColors.mono150,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildNextButton() {
    return SizedBox(
      width: double.infinity,
      height: AppDimens.buttonH,
      child: ElevatedButton(
        onPressed: _next,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.mono900,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          ),
          elevation: 0,
          textStyle: AppTextStyles.primaryButton,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            _isLastPage ? 'Начать' : 'Далее',
            key: ValueKey(_isLastPage),
          ),
        ),
      ),
    );
  }
}

