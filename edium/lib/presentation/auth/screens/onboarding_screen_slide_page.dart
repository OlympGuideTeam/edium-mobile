part of 'onboarding_screen.dart';

class _SlidePage extends StatelessWidget {
  final _SlideData data;

  const _SlidePage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(flex: 2),
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.mono50,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.mono150, width: 1.5),
          ),
          child: Icon(data.icon, size: 48, color: AppColors.mono700),
        ),
        const SizedBox(height: 40),
        Text(
          data.title,
          style: AppTextStyles.screenTitle,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          data.subtitle,
          style: AppTextStyles.screenSubtitle,
          textAlign: TextAlign.center,
        ),
        const Spacer(flex: 3),
      ],
    );
  }
}

