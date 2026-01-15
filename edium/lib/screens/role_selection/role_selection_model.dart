import 'package:edium/screens/role_selection/role_selection_entity.dart';
import 'package:edium/screens/role_selection/role_selection_interfaces.dart';
import 'package:edium/services/shared_preferences_storage/shared_preferences_storage_interface.dart';

class RoleSelectionModel implements IRoleSelectionModel {
  final ISharedPreferencesStorage _storage;

  RoleSelectionModel({required ISharedPreferencesStorage storage}) : _storage = storage;

  @override
  Future<void> setUserRole(UserRole role) async {
    await _storage.setRole(role.rawValue);
  }
}