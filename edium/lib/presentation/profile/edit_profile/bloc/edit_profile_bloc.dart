import 'package:edium/domain/usecases/user/delete_account_usecase.dart';
import 'package:edium/domain/usecases/user/update_profile_usecase.dart';
import 'package:edium/presentation/profile/edit_profile/bloc/edit_profile_event.dart';
import 'package:edium/presentation/profile/edit_profile/bloc/edit_profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditProfileBloc extends Bloc<EditProfileEvent, EditProfileState> {
  final UpdateProfileUsecase _updateProfile;
  final DeleteAccountUsecase _deleteAccount;

  EditProfileBloc({
    required UpdateProfileUsecase updateProfile,
    required DeleteAccountUsecase deleteAccount,
    required EditProfileInitial initialState,
  })  : _updateProfile = updateProfile,
        _deleteAccount = deleteAccount,
        super(initialState) {
    on<UpdateProfileEvent>(_onUpdate);
    on<DeleteAccountEvent>(_onDelete);
  }

  Future<void> _onUpdate(
    UpdateProfileEvent event,
    Emitter<EditProfileState> emit,
  ) async {
    emit(const EditProfileLoading());
    try {
      final user = await _updateProfile(name: event.name, surname: event.surname);
      emit(EditProfileSuccess(user));
    } catch (e) {
      emit(EditProfileError(e.toString()));
    }
  }

  Future<void> _onDelete(
    DeleteAccountEvent event,
    Emitter<EditProfileState> emit,
  ) async {
    emit(const EditProfileLoading());
    try {
      await _deleteAccount();
      emit(const EditProfileDeleted());
    } catch (e) {
      emit(EditProfileError(e.toString()));
    }
  }
}
