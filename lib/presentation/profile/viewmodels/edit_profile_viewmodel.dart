import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/models/user_profile_model.dart';
import '../../../data/repositories/profile_repository.dart';

class EditProfileViewModel extends ChangeNotifier {
  EditProfileViewModel(this._profileRepository);

  final ProfileRepository _profileRepository;
  final ImagePicker _imagePicker = ImagePicker();

  UserProfileModel? profile;
  File? pendingAvatarFile;
  bool isLoading = false;
  String? errorMessage;

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController firstNameLocalController =
      TextEditingController();
  final TextEditingController lastNameLocalController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController telegramController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  Future<void> loadProfile() async {
    _setLoading(true);
    errorMessage = null;

    try {
      profile = await _profileRepository.getProfile();
      _populateControllers(profile);
    } on ProfileException catch (error) {
      errorMessage = error.message;
    } catch (_) {
      errorMessage = 'Failed to load profile';
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> saveProfile() async {
    _setLoading(true);
    errorMessage = null;

    try {
      var updatedProfile = await _profileRepository.updateProfile(
        UserProfileUpdateRequest(
          firstName: firstNameController.text.trim(),
          lastName: lastNameController.text.trim(),
          firstNameLocal: firstNameLocalController.text.trim(),
          lastNameLocal: lastNameLocalController.text.trim(),
          phone: phoneController.text.trim(),
          telegram: telegramController.text.trim(),
          address: addressController.text.trim(),
        ),
      );

      final avatarFile = pendingAvatarFile;
      if (avatarFile != null) {
        updatedProfile = await _profileRepository.uploadAvatar(avatarFile);
        pendingAvatarFile = null;
      }

      profile = updatedProfile;
      _populateControllers(profile);
      return true;
    } on ProfileException catch (error) {
      errorMessage = error.message;
      return false;
    } catch (_) {
      errorMessage = 'Failed to update profile';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> pickAvatar() async {
    final pickedImage = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (pickedImage == null) return;

    final croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedImage.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Photo',
          toolbarColor: const Color(0xFF45837B), // AppColors.buttonColor
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'Crop Photo',
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
        ),
      ],
    );

    if (croppedFile == null) return;

    pendingAvatarFile = File(croppedFile.path);
    errorMessage = null;
    notifyListeners();
  }

  void _populateControllers(UserProfileModel? profile) {
    if (profile == null) return;

    firstNameController.text = profile.firstName ?? '';
    lastNameController.text = profile.lastName ?? '';
    firstNameLocalController.text = profile.firstNameLocal ?? '';
    lastNameLocalController.text = profile.lastNameLocal ?? '';
    phoneController.text = profile.phone ?? '';
    telegramController.text = profile.telegram ?? '';
    addressController.text = profile.address ?? '';
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    firstNameLocalController.dispose();
    lastNameLocalController.dispose();
    phoneController.dispose();
    telegramController.dispose();
    addressController.dispose();
    super.dispose();
  }
}
