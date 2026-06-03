import 'package:flutter/material.dart';

import '../../../data/repositories/profile_repository.dart';

class ChangePasswordViewModel extends ChangeNotifier {
  ChangePasswordViewModel(this._profileRepository);

  final ProfileRepository _profileRepository;

  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  bool get obscureCurrent => _obscureCurrent;
  bool get obscureNew => _obscureNew;
  bool get obscureConfirm => _obscureConfirm;

  void toggleCurrentVisibility() {
    _obscureCurrent = !_obscureCurrent;
    notifyListeners();
  }

  void toggleNewVisibility() {
    _obscureNew = !_obscureNew;
    notifyListeners();
  }

  void toggleConfirmVisibility() {
    _obscureConfirm = !_obscureConfirm;
    notifyListeners();
  }

  Future<bool> changePassword() async {
    final currentPassword = currentPasswordController.text.trim();
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (currentPassword.isEmpty) {
      errorMessage = 'Please enter your current password';
      notifyListeners();
      return false;
    }

    if (newPassword.isEmpty) {
      errorMessage = 'Please enter your new password';
      notifyListeners();
      return false;
    }

    if (newPassword.length < 6) {
      errorMessage = 'New password must be at least 6 characters';
      notifyListeners();
      return false;
    }

    if (confirmPassword.isEmpty) {
      errorMessage = 'Please confirm your new password';
      notifyListeners();
      return false;
    }

    if (newPassword != confirmPassword) {
      errorMessage = 'New passwords do not match';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    errorMessage = null;

    try {
      final success = await _profileRepository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      if (success) {
        currentPasswordController.clear();
        newPasswordController.clear();
        confirmPasswordController.clear();
        return true;
      } else {
        errorMessage = 'Failed to change password';
        return false;
      }
    } on ProfileException catch (e) {
      errorMessage = e.message;
      return false;
    } catch (_) {
      errorMessage = 'Failed to change password. Please try again.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
