part of 'courses_screen.dart';

class _ModuleSection extends StatelessWidget {
  final ModuleDetail module;
  final VoidCallback onAddQuiz;

  const _ModuleSection({required this.module, required this.onAddQuiz});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.mono25,
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          border: Border.all(color: AppColors.mono100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      module.title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.mono900,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: onAddQuiz,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: AppColors.mono900,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child:
                          const Icon(Icons.add, size: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            if (module.items.isNotEmpty)
              ...module.items.map((item) => _ItemTile(item: item)),
            if (module.items.isEmpty)
              const Padding(
                padding: EdgeInsets.fromLTRB(12, 0, 12, 10),
                child: Text(
                  'Квизов нет',
                  style: TextStyle(fontSize: 12, color: AppColors.mono300),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

