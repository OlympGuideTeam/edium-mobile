import 'package:edium/screens/role_selection/role_selection_entity.dart';
import 'package:edium/screens/role_selection/role_selection_interfaces.dart';
import 'package:flutter/material.dart';

class RoleSelectionViewModel with ChangeNotifier implements IRoleSelectionViewModel {
  final IRoleSelectionModel _model;

  RoleSelectionViewModel({required IRoleSelectionModel model}) : _model = model;

  @override
  Future<void> setUserRole(UserRole role) async {
    notifyListeners();
    try {
      await _model.setUserRole(role);
      notifyListeners();
    } catch (e) {
      notifyListeners();
      return;
    }
  }
  
  @override
  Future<void> handleQRCodeSelected() {
    // TODO: implement handleQRCodeSelected
    throw UnimplementedError();
  }
}