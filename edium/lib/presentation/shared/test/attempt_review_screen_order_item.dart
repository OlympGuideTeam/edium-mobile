part of 'attempt_review_screen.dart';

class _OrderItem extends StatelessWidget {
  final int index;
  final String text;
  final bool isCorrect;
  final bool showIcon;

  static const _green = Color(0xFF22C55E);
  static const _greenBg = Color(0xFFE8F5E9);
  static const _red = Color(0xFFEF4444);
  static const _redBg = Color(0xFFFEE2E2);

  const _OrderItem({
    required this.index,
    required this.text,
    required this.isCorrect,
    required this.showIcon,
  });

  @override
  Widget build(BuildContext context) {
    final color = isCorrect ? _green : _red;
    final bgColor = isCorrect ? _greenBg : _redBg;

    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Center(
              child: Text(
                '$index',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: color, height: 1.3),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (showIcon) ...[
            const SizedBox(width: 4),
            Icon(
              isCorrect ? Icons.check : Icons.close,
              size: 12,
              color: color,
            ),
          ],
        ],
      ),
    );
  }
}

