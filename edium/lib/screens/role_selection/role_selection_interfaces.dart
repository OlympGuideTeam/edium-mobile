import 'package:edium/screens/role_selection/role_selection_entity.dart';

abstract class IRoleSelectionModel {
  Future<void> setUserRole(UserRole role);
}

abstract class IRoleSelectionViewModel {
  Future<void> setUserRole(UserRole role);
  Future<void> handleQRCodeSelected();
}