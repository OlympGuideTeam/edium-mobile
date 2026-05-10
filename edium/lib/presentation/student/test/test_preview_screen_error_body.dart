part of 'test_preview_screen.dart';

class _ErrorBody extends StatelessWidget {
  final String message;
  const _ErrorBody({required this.message});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Text(
          'Не удалось загрузить тест:\n$message',
          textAlign: TextAlign.center,
          style: AppTextStyles.screenSubtitle,
        ),
      ),
    );
  }
}

