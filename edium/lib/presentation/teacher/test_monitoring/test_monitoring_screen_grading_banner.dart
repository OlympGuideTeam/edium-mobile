part of 'test_monitoring_screen.dart';

class _GradingBanner extends StatelessWidget {
  const _GradingBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.mono900,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      ),
      child: Row(
        children: const [
          Icon(Icons.edit_outlined, size: 16, color: Colors.white),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Есть вопросы с развёрнутым ответом — нужна ручная проверка',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

