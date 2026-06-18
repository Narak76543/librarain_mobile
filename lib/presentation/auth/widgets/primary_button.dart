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

    return Container(
      width: double.infinity,
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: isOnDark ? null : AppGradients.primary,
        color: isOnDark ? AppColors.white : null,
        boxShadow: isOnDark ? null : [
          BoxShadow(
            color: AppColors.primary400.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
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
