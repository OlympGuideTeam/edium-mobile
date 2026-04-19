import 'package:edium/core/config/api_config.dart';
import 'package:edium/core/storage/hive_storage.dart';

class ProfileStorage {
  static const String _nameKey = 'name';
  static const String _surnameKey = 'surname';
  static const String _roleKey = 'role';
  static const String _phoneKey = 'phone';
  static const String _envKey = 'environment';
  static const String _notifPermissionKey = 'notifications_permission_asked';
  static const String _usersPrefix = 'user_name_';

  bool get hasName => HiveStorage.profileBox.containsKey(_nameKey);
  bool get hasPhone => HiveStorage.profileBox.containsKey(_phoneKey);
  bool get isLoggedIn => hasName && hasPhone;

  String? getName() => HiveStorage.profileBox.get(_nameKey);
  Future<void> saveName(String name) =>
      HiveStorage.profileBox.put(_nameKey, name);

  String? getSurname() => HiveStorage.profileBox.get(_surnameKey);
  Future<void> saveSurname(String surname) =>
      HiveStorage.profileBox.put(_surnameKey, surname);

  String? getRole() => HiveStorage.profileBox.get(_roleKey);
  Future<void> saveRole(String role) =>
      HiveStorage.profileBox.put(_roleKey, role);

  String? getPhone() => HiveStorage.profileBox.get(_phoneKey);
  Future<void> savePhone(String phone) =>
      HiveStorage.profileBox.put(_phoneKey, phone);

  bool get hasAskedNotificationPermission =>
      HiveStorage.profileBox.get(_notifPermissionKey) == 'true';

  Future<void> markNotificationPermissionAsked() =>
      HiveStorage.profileBox.put(_notifPermissionKey, 'true');

  Future<void> saveUserName(String phone, String name) =>
      HiveStorage.profileBox.put('$_usersPrefix$phone', name);

  String? getUserName(String phone) =>
      HiveStorage.profileBox.get('$_usersPrefix$phone');

  Future<void> clear() async {
    final box = HiveStorage.profileBox;
    await box.delete(_nameKey);
    await box.delete(_surnameKey);
    await box.delete(_roleKey);
    await box.delete(_phoneKey);
  }

  static AppEnvironment loadEnvironment() {
    final val = HiveStorage.profileBox.get(_envKey);
    return AppEnvironment.values.firstWhere(
      (e) => e.name == val,
      orElse: () => AppEnvironment.mock,
    );
  }

  static Future<void> saveEnvironment(AppEnvironment env) =>
      HiveStorage.profileBox.put(_envKey, env.name);
}
