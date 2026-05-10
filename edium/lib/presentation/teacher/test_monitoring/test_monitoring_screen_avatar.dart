part of 'test_monitoring_screen.dart';

class _Avatar extends StatelessWidget {
  final String name;

  const _Avatar({required this.name});

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.mono100,
        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
      ),
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.mono600,
        ),
      ),
    );
  }
}

