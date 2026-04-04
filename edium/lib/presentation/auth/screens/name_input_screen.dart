import 'package:edium/presentation/auth/bloc/auth_bloc.dart';
import 'package:edium/presentation/auth/bloc/auth_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NameInputScreen extends StatefulWidget {
  const NameInputScreen({super.key});

  @override
  State<NameInputScreen> createState() => _NameInputScreenState();
}

class _NameInputScreenState extends State<NameInputScreen> {
  final _nameCtrl = TextEditingController();
  final _surnameCtrl = TextEditingController();
  bool _canSubmit = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl.addListener(_updateCanSubmit);
    _surnameCtrl.addListener(_updateCanSubmit);
  }

  void _updateCanSubmit() {
    setState(() {
      _canSubmit = _nameCtrl.text.trim().isNotEmpty &&
          _surnameCtrl.text.trim().isNotEmpty;
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _surnameCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    final surname = _surnameCtrl.text.trim();
    if (name.isEmpty || surname.isEmpty) return;
    final fullName = '$name $surname';
    context.read<AuthBloc>().add(NameSubmittedEvent(fullName));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 56),
                // Тег "Новый аккаунт"
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'НОВЫЙ АККАУНТ',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Как вас зовут?',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Укажите имя и фамилию — их увидят\nученики и учителя',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF888888),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 28),
                // Фамилия
                const Text(
                  'Фамилия',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF888888),
                  ),
                ),
                const SizedBox(height: 8),
                _buildTextField(_surnameCtrl, 'Иванов'),
                const SizedBox(height: 16),
                // Имя
                const Text(
                  'Имя',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF888888),
                  ),
                ),
                const SizedBox(height: 8),
                _buildTextField(_nameCtrl, 'Иван'),
                const Spacer(),
                // Кнопка
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _canSubmit ? _submit : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A1A1A),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFCCCCCC),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: const Text('Продолжить'),
                  ),
                ),
                const SizedBox(height: 12),
                const Center(
                  child: Text(
                    'Вы сможете изменить имя позже\nв настройках профиля',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFAAAAAA),
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFBBBBBB),
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: controller,
        cursorColor: const Color(0xFF1A1A1A),
        style: const TextStyle(
          fontSize: 15,
          color: Color(0xFF333333),
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            fontSize: 15,
            color: Color(0xFFBBBBBB),
          ),
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }
}
