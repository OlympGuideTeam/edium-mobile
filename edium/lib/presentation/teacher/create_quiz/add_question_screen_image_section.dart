part of 'add_question_screen.dart';

class _ImageSection extends StatelessWidget {
  final String? imageId;
  final bool uploading;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  const _ImageSection({
    required this.imageId,
    required this.uploading,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (uploading) {
      return Container(
        height: 180,
        decoration: BoxDecoration(
          color: AppColors.mono25,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.mono150),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.mono700, strokeWidth: 2),
              SizedBox(height: 12),
              Text('Загрузка изображения...', style: AppTextStyles.helperText),
            ],
          ),
        ),
      );
    }

    if (imageId != null) {
      return Stack(
        children: [
          QuestionImageWidget(imageId: imageId!),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: onPick,
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: AppColors.mono300,
          radius: AppDimens.radiusLg,
          strokeWidth: AppDimens.borderWidth,
        ),
        child: Container(
          width: double.infinity,
          height: AppDimens.buttonHSm,
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.image_outlined, size: 16, color: AppColors.mono400),
              const SizedBox(width: 6),
              Text(
                'Добавить изображение',
                style: AppTextStyles.fieldText.copyWith(color: AppColors.mono400),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

