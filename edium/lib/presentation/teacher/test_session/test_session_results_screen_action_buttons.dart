part of 'test_session_results_screen.dart';

class _ActionButtons extends StatelessWidget {
  final TestSessionResultsLoaded state;
  const _ActionButtons({required this.state});

  @override
  Widget build(BuildContext context) {
    final buttons = <Widget>[];


    if (state.sessionStatus == 'active') {
      buttons.add(_FinishButton(isFinishing: state.isFinishing));
      buttons.add(const SizedBox(height: 10));
    }


    if (state.canPublish) {
      buttons.add(_PublishButton(isPublishing: state.isPublishing));
      buttons.add(const SizedBox(height: 10));
    }


    if (state.canDelete) {
      buttons.add(_DeleteButton(isDeleting: state.isDeleting));
    }

    if (buttons.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: buttons,
    );
  }
}

