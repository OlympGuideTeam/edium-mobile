part of 'add_question_screen.dart';

class _ConnectionPairTile extends StatelessWidget {
  final TextEditingController leftController;
  final TextEditingController rightController;
  final int index;
  final int maxChars;

  const _ConnectionPairTile({
    required this.leftController,
    required this.rightController,
    required this.index,
    required this.maxChars,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _ConnectionInputField(
                controller: leftController,
                hint: 'Термин ${index + 1}',
                isLeft: true,
                maxChars: maxChars,
              ),
            ),

            Container(
              width: 36,
              color: Colors.white,
              alignment: Alignment.center,
              child: Container(
                width: 20,
                height: 1,
                color: AppColors.mono300,
              ),
            ),
            Expanded(
              child: _ConnectionInputField(
                controller: rightController,
                hint: 'Определение ${index + 1}',
                isLeft: false,
                maxChars: maxChars,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

