import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_color.dart';
import '../../../core/widgets/app_text.dart';
import '../../../data/models/user_profile_model.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../viewmodels/profile_viewmodel.dart';

class ShippingAddressScreen extends StatefulWidget {
  const ShippingAddressScreen({super.key});

  @override
  State<ShippingAddressScreen> createState() => _ShippingAddressScreenState();
}

class _ShippingAddressScreenState extends State<ShippingAddressScreen> {
  late final TextEditingController _addressController;
  final _profileRepository = ProfileRepository();
  bool _isLoading = false;
  bool _isDetecting = false;

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileViewModel>().profile;
    _addressController = TextEditingController(text: profile?.address ?? '');
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _autoDetectLocation() async {
    setState(() => _isDetecting = true);
    try {
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ));

      double? lat;
      double? lng;
      String? formattedAddress;

      // 1. Google Geolocation API
      try {
        final geoResponse = await dio.post<dynamic>(
          'https://www.googleapis.com/geolocation/v1/geolocate?key=AIzaSyBMomse-7qenHBhXCe6iaq8UUCgY6LQ2jc',
          data: {},
        );
        if (geoResponse.statusCode == 200 && geoResponse.data != null) {
          final location = geoResponse.data['location'];
          if (location != null) {
            lat = double.tryParse(location['lat'].toString());
            lng = double.tryParse(location['lng'].toString());
          }
        }
      } catch (e) {
        debugPrint('Google Geolocation failed: $e');
      }

      // 2. Google Geocoding API
      if (lat != null && lng != null) {
        try {
          final geocodeResponse = await dio.get<dynamic>(
            'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=AIzaSyBMomse-7qenHBhXCe6iaq8UUCgY6LQ2jc',
          );
          if (geocodeResponse.statusCode == 200 && geocodeResponse.data != null) {
            final results = geocodeResponse.data['results'] as List?;
            if (results != null && results.isNotEmpty) {
              formattedAddress = results[0]['formatted_address'] as String?;
            }
          }
        } catch (e) {
          debugPrint('Google Geocoding failed: $e');
        }
      }

      // 3. Fallback IP Geolocation
      if (formattedAddress == null || formattedAddress.isEmpty) {
        try {
          final fallbackResponse = await dio.get<dynamic>('http://ip-api.com/json');
          if (fallbackResponse.statusCode == 200 && fallbackResponse.data != null) {
            final data = fallbackResponse.data;
            final city = data['city'] as String?;
            final region = data['regionName'] as String?;
            final country = data['country'] as String?;
            final latVal = data['lat'];
            final lonVal = data['lon'];

            if (city != null && country != null) {
              formattedAddress = '$city, $region, $country ($latVal, $lonVal) (IP-based)';
            }
          }
        } catch (e) {
          debugPrint('Fallback IP Geolocation failed: $e');
        }
      }

      if (mounted) {
        if (formattedAddress != null && formattedAddress.isNotEmpty) {
          _addressController.text = formattedAddress;
          AppSnackbar.showSuccess(context, 'Location auto-detected successfully!');
        } else {
          AppSnackbar.showError(context, 'Could not automatically detect location. Please enter manually.');
        }
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(context, 'Location detection failed: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isDetecting = false);
      }
    }
  }

  Future<void> _saveAddress() async {
    final currentProfile = context.read<ProfileViewModel>().profile;
    if (currentProfile == null) {
      AppSnackbar.showError(context, 'Profile data not loaded');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final updatedProfile = await _profileRepository.updateProfile(
        UserProfileUpdateRequest(
          firstName: currentProfile.firstName ?? '',
          lastName: currentProfile.lastName ?? '',
          firstNameLocal: currentProfile.firstNameLocal ?? '',
          lastNameLocal: currentProfile.lastNameLocal ?? '',
          phone: currentProfile.phone ?? '',
          telegram: currentProfile.telegram ?? '',
          address: _addressController.text.trim(),
        ),
      );

      if (mounted) {
        context.read<ProfileViewModel>().setProfile(updatedProfile);
        AppSnackbar.showSuccess(context, 'Shipping address updated successfully!');
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(context, 'Failed to save address: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: Row(
                children: [
                  if (canPop) ...[
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.border),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.textPrimary.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: AppColors.textPrimary,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                  const Expanded(
                    child: AppText.titleLarge(
                      'Shipping Address',
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            
            // Content Card
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.textPrimary.withValues(alpha: 0.03),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppText.bodySmall(
                          'Your Delivery/Shipping Location',
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _addressController,
                          cursorColor: AppColors.buttonColor,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 4,
                          minLines: 2,
                          decoration: InputDecoration(
                            hintText: 'Enter your shipping address here...',
                            hintStyle: TextStyle(
                              color: AppColors.textDisabled.withValues(alpha: 0.8),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF9FAFB),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.8)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.8)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.buttonColor),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            suffixIcon: _isDetecting
                                ? const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.buttonColor,
                                      ),
                                    ),
                                  )
                                : IconButton(
                                    icon: const Icon(
                                      Icons.my_location_rounded,
                                      color: AppColors.buttonColor,
                                      size: 20,
                                    ),
                                    onPressed: _autoDetectLocation,
                                  ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const AppText.caption(
                          'Tap the location icon to auto-detect your location using Google Maps Geocoding & Geolocation APIs.',
                          color: AppColors.textDisabled,
                          fontSize: 11,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Save Button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              child: GestureDetector(
                onTap: _isLoading ? null : _saveAddress,
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: _isLoading ? AppColors.textDisabled : AppColors.buttonColor,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: _isLoading
                          ? []
                          : [
                              BoxShadow(
                                color: AppColors.buttonColor.withValues(alpha: 0.35),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                    ),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isLoading) ...[
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: AppColors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const AppText.button(
                              'Saving...',
                              color: AppColors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ] else ...[
                            const AppText.button(
                              'Save Address',
                              color: AppColors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
