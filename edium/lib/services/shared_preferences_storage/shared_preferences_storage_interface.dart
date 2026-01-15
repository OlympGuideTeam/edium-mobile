abstract class ISharedPreferencesStorage {
  Future<void> setRole(String value);
  String? getRole();
}