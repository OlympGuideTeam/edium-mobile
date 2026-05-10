part of 'course_detail_screen.dart';

class _DraftTile extends StatelessWidget {
  final CourseDraft draft;
  final VoidCallback onTap;

  const _DraftTile({required this.draft, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final payload = draft.payload;
    final title = draft.title.isNotEmpty ? draft.title : 'Шаблон квиза';
    final isLive = payload?.mode == 'live';
    final meta = _buildMeta(payload);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          border: Border.all(
            color: AppColors.mono150,
            width: AppDimens.borderWidth,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: payload == null
                      ? AppColors.mono100
                      : (isLive ? AppColors.mono900 : AppColors.mono100),
                  borderRadius: BorderRadius.circular(AppDimens.radiusXs),
                ),
                child: Text(
                  payload == null ? 'КВИЗ' : (isLive ? 'ЛАЙВ' : 'ТЕСТ'),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: payload != null && isLive
                        ? Colors.white
                        : AppColors.mono400,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mono600,
                    ),
                  ),
                  if (meta.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      meta,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.mono400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Icon(
                Icons.chevron_right,
                size: 16,
                color: AppColors.mono250,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _buildMeta(CourseItemPayload? p) {
    if (p == null) return '';
    final parts = <String>[];
    const months = [
      'янв',
      'фев',
      'мар',
      'апр',
      'май',
      'июн',
      'июл',
      'авг',
      'сен',
      'окт',
      'ноя',
      'дек'
    ];

    if (p.startedAt != null) {
      final d = p.startedAt!.toLocal();
      parts.add('с ${d.day} ${months[d.month - 1]}');
    }
    if (p.finishedAt != null) {
      final d = p.finishedAt!.toLocal();
      parts.add('до ${d.day} ${months[d.month - 1]}');
    }
    if (p.totalTimeLimitSec != null) {
      final min = (p.totalTimeLimitSec! / 60).round();
      parts.add('$min мин');
    } else if (p.questionTimeLimitSec != null) {
      parts.add('${p.questionTimeLimitSec} с/вопр.');
    }

    return parts.join('  ·  ');
  }
}

