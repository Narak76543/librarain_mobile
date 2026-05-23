import 'package:flutter/material.dart';

import '../../../data/models/user_profile_model.dart';
import '../../../data/repositories/profile_repository.dart';

class ProfileViewModel extends ChangeNotifier {
  ProfileViewModel(this._profileRepository);

  final ProfileRepository _profileRepository;

  UserProfileModel? profile;
  bool isLoading = false;
  bool _hasLoaded = false;
  String? errorMessage;

  Future<void> loadProfile({bool force = false}) async {
    if (isLoading) return;
    if (_hasLoaded && !force) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      profile = await _profileRepository.getProfile();
      _hasLoaded = true;
    } on ProfileException catch (error) {
      errorMessage = error.message;
    } catch (_) {
      errorMessage = 'Failed to load profile';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshProfile() => loadProfile(force: true);

  void setProfile(UserProfileModel? value) {
    if (value == null) return;
    profile = value;
    _hasLoaded = true;
    errorMessage = null;
    notifyListeners();
  }

  void clearProfile() {
    profile = null;
    _hasLoaded = false;
    errorMessage = null;
    notifyListeners();
  }
}
