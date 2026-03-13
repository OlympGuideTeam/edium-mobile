import 'package:edium/core/storage/hive_storage.dart';

class ProfileStorage {
  static const String _nameKey = 'name';
  static const String _roleKey = 'role';
  static const String _phoneKey = 'phone';
  static const String _usersPrefix = 'user_name_';

  bool get hasName => HiveStorage.profileBox.containsKey(_nameKey);
  bool get hasPhone => HiveStorage.profileBox.containsKey(_phoneKey);
  bool get isLoggedIn => hasName && hasPhone;

  String? getName() => HiveStorage.profileBox.get(_nameKey);
  Future<void> saveName(String name) =>
      HiveStorage.profileBox.put(_nameKey, name);

  String? getRole() => HiveStorage.profileBox.get(_roleKey);
  Future<void> saveRole(String role) =>
      HiveStorage.profileBox.put(_roleKey, role);

  String? getPhone() => HiveStorage.profileBox.get(_phoneKey);
  Future<void> savePhone(String phone) =>
      HiveStorage.profileBox.put(_phoneKey, phone);

  /// Persistent name storage per phone (survives logout)
  Future<void> saveUserName(String phone, String name) =>
      HiveStorage.profileBox.put('$_usersPrefix$phone', name);

  String? getUserName(String phone) =>
      HiveStorage.profileBox.get('$_usersPrefix$phone');

  /// Clears session data but keeps phone→name mappings
  Future<void> clear() async {
    final box = HiveStorage.profileBox;
    await box.delete(_nameKey);
    await box.delete(_roleKey);
    await box.delete(_phoneKey);
  }
}
