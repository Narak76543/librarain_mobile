import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/constants/app_texts.dart';
import '../../../data/repositories/auth_repository.dart';

class OtpViewModel extends ChangeNotifier {
  OtpViewModel(this._authRepository) {
    _startTimer();
  }

  final AuthRepository _authRepository;
  Timer? _timer;

  bool _isLoading = false;
  String? _errorMessage;
  int _timerSeconds = 60;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get timerSeconds => _timerSeconds;
  bool get canResend => _timerSeconds == 0 && !_isLoading;

  Future<bool> verifyOtp(String email, String code) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final result = await _authRepository.verifyOtp(
        email: email,
        otpCode: code,
      );

      if (!result) {
        _errorMessage = AppTexts.otpVerificationFailed;
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

  Future<bool> resend(String email) async {
    if (!canResend) return false;

    _setLoading(true);
    _errorMessage = null;

    try {
      final result = await _authRepository.forgotPassword(email: email);

      if (result) {
        _resetTimer();
      } else {
        _errorMessage = AppTexts.resendOtpFailed;
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

  void _resetTimer() {
    _timer?.cancel();
    _timerSeconds = 60;
    _startTimer();
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds == 0) {
        timer.cancel();
      } else {
        _timerSeconds--;
      }

      notifyListeners();
    });
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
