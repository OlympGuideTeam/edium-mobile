part of 'welcome_screen.dart';

class _EnvSwitcher extends StatelessWidget {
  final AppEnvironment current;
  final bool switching;
  final Future<void> Function(AppEnvironment) onSelect;

  const _EnvSwitcher({
    required this.current,
    required this.switching,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: AppEnvironment.values.map((env) {
        final isActive = env == current;
        return GestureDetector(
          onTap: switching ? null : () => onSelect(env),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: isActive ? AppColors.mono900 : AppColors.mono50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: switching && isActive
                ? const SizedBox(
                    width: 10,
                    height: 10,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    env.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: isActive ? Colors.white : AppColors.mono300,
                    ),
                  ),
          ),
        );
      }).toList(),
    );
  }
}

