import 'package:flutter/material.dart';
import 'package:mobile_s2_flutter/core/constants/app_texts.dart';
import 'package:mobile_s2_flutter/data/repositories/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_s2_flutter/core/services/notification_service.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this._authRepository);
  final AuthRepository _authRepository;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> login({required String email, required String password}) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final result = await _authRepository.login(
        email: email,
        password: password,
      );

      if (!result) {
        _errorMessage = AppTexts.invalidEmailOrPassword;
      }

      if (result) {
        await _saveLoggedIn();
        await NotificationService.initialize();
      }

      return result;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = AppTexts.somethingWentWrong;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> loginWithGoogle() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final result = await _authRepository.loginWithGoogle();

      if (result) {
        await _saveLoggedIn();
        await NotificationService.initialize();
      }

      return result;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = AppTexts.somethingWentWrong;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> loginWithTelegram() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final result = await _authRepository.loginWithTelegram();

      if (result) {
        await _saveLoggedIn();
        await NotificationService.initialize();
      }

      return result;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = AppTexts.somethingWentWrong;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final result = await _authRepository.register(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
      );

      if (!result) {
        _errorMessage = 'Registration failed';
      }

      return result;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
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

  Future<void> _saveLoggedIn() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool('is_logged_in', true);
  }

  Future<void> logout() async {
    await NotificationService.clearToken();
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        serverClientId:
            '632874416504-30ue2elf9c0prf8g5fjd1k0lsqe28u6m.apps.googleusercontent.com',
      );
      await googleSignIn.signOut();
      await googleSignIn.disconnect();
    } catch (e) {
      debugPrint('Google Sign-In signOut/disconnect error: $e');
    }
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove('access_token');
    await preferences.remove('token');
    await preferences.remove('accessToken');
    await preferences.remove('refresh_token');
    await preferences.remove('refreshToken');
    await preferences.setBool('is_logged_in', false);
    _errorMessage = null;
    notifyListeners();
  }
}
