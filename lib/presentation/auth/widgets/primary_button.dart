import 'package:flutter/material.dart';

import '../../../core/theme/app_color.dart';
import '../../../core/widgets/app_text.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.isOnDark = false,
  });

  final String title;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final bool isOnDark;

  @override
  Widget build(BuildContext context) {
    final textColor = isOnDark && !isOutlined
        ? AppColors.primary
        : isOnDark
            ? AppColors.white
            : null;

    final child = isLoading
        ? SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: isOnDark && !isOutlined
                  ? AppColors.primary
                  : AppColors.white,
            ),
          )
        : AppText.button(title, color: textColor);

    if (isOutlined) {
      return SizedBox(
        width: double.infinity,
        height: 44,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: isOnDark ? AppColors.white : AppColors.primary,
            side: BorderSide(
              color: isOnDark ? AppColors.white : AppColors.primary100,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            backgroundColor: isOnDark ? AppColors.transparent : AppColors.white,
          ),
          onPressed: isLoading ? null : onPressed,
          child: child,
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isOnDark ? AppColors.white : AppColors.waterBlue,
          foregroundColor: isOnDark ? AppColors.primary : AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        onPressed: isLoading ? null : onPressed,
        child: child,
      ),
    );
  }
}
