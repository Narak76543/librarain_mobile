import 'package:flutter/material.dart';

import '../../../core/constants/app_texts.dart';
import '../../../data/repositories/auth_repository.dart';

class ForgotPasswordViewModel extends ChangeNotifier {
  ForgotPasswordViewModel(this._authRepository);

  final AuthRepository _authRepository;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> submit(String email) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final result = await _authRepository.forgotPassword(email: email);

      if (!result) {
        _errorMessage = AppTexts.forgotPasswordFailed;
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
