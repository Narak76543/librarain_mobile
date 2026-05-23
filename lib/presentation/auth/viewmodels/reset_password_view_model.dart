import 'package:flutter/material.dart';

import '../../../core/constants/app_texts.dart';
import '../../../data/repositories/auth_repository.dart';

enum PasswordStrength { weak, medium, strong }

class ResetPasswordViewModel extends ChangeNotifier {
  ResetPasswordViewModel(this._authRepository);

  final AuthRepository _authRepository;

  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  PasswordStrength _passwordStrength = PasswordStrength.weak;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get obscurePassword => _obscurePassword;
  bool get obscureConfirm => _obscureConfirm;
  PasswordStrength get passwordStrength => _passwordStrength;

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void toggleConfirmVisibility() {
    _obscureConfirm = !_obscureConfirm;
    notifyListeners();
  }

  void updateStrength(String password) {
    final hasMinLength = password.length >= 8;
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasDigit = password.contains(RegExp(r'\d'));
    final hasSymbol = password.contains(RegExp(r'[^A-Za-z0-9]'));
    final score = <bool>[
      hasMinLength,
      hasUppercase,
      hasLowercase,
      hasDigit,
      hasSymbol,
    ].where((value) => value).length;

    if (score >= 4) {
      _passwordStrength = PasswordStrength.strong;
    } else if (score >= 3) {
      _passwordStrength = PasswordStrength.medium;
    } else {
      _passwordStrength = PasswordStrength.weak;
    }

    notifyListeners();
  }

  Future<bool> submit(String email, String newPassword) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final result = await _authRepository.resetPassword(
        email: email,
        newPassword: newPassword,
      );

      if (!result) {
        _errorMessage = AppTexts.resetPasswordFailed;
      }

      return result;
    } on AuthException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = AppTexts.somethingWentWrong;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
