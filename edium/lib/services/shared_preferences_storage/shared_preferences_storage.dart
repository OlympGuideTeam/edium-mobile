import 'package:edium/services/shared_preferences_storage/shared_preferences_storage_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesStorage implements ISharedPreferencesStorage {
  final SharedPreferences _prefs;
  SharedPreferencesStorage({required SharedPreferences prefs}) : _prefs = prefs;

  final String _userRole = 'user_role';
    
  @override
  Future<void> setRole(String role) async {
    await _prefs.setString(_userRole, role);
  }

  @override
  String? getRole() {
    return _prefs.getString(_userRole);
  }
}