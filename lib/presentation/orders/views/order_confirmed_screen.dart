import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_color.dart';
import '../../../core/widgets/app_text.dart';

class OrderConfirmedScreen extends StatelessWidget {
  const OrderConfirmedScreen({
    super.key,
    required this.orderId,
    required this.orderTotal,
    required this.orderItems,
    this.deliveryWay = 'Pick Up',
    this.deliveryPartner,
    this.paymentMethod = 'COD',
  });

  final String orderId;
  final double orderTotal;
  final List<dynamic> orderItems;
  final String deliveryWay;
  final String? deliveryPartner;
  final String paymentMethod;

  String _formatCurrentDate() {
    final now = DateTime.now();
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
          onPressed: () => context.go(AppRoutes.main),
        ),
        title: const AppText.titleSmall(
          'Librarain',
          color: AppColors.buttonColor,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 24, bottom: 40),
        child: Column(
          children: [
            // Hero section with Confetti
            SizedBox(
              height: 180,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  _buildConfetti(context),
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      color: AppColors.buttonColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: const BoxDecoration(
                          color: AppColors.buttonColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const AppText.titleLarge(
              'Order Placed! 🎉',
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
            const SizedBox(height: 8),
            const AppText.bodyMedium(
              'Your order has been confirmed',
              color: AppColors.textDisabled,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            const SizedBox(height: 32),

            // Order info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.textPrimary.withValues(alpha: 0.03),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  AppText.titleSmall(
                    'ORDER #${orderId.length > 8 ? orderId.substring(0, 8).toUpperCase() : orderId.toUpperCase()}',
                    color: AppColors.buttonColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                  const SizedBox(height: 4),
                  AppText.titleSmall(
                    _formatCurrentDate(),
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Divider(height: 1, thickness: 1, color: AppColors.border.withValues(alpha: 0.5)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText.bodyMedium(
                        deliveryWay == 'Delivery' ? 'Estimated Delivery' : 'Collect Location',
                        color: AppColors.textDisabled,
                        fontSize: 13,
                      ),
                      AppText.bodyMedium(
                        deliveryWay == 'Delivery'
                            ? '3-5 business days (via ${deliveryPartner ?? 'Grab'})'
                            : 'Store Pick Up',
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const AppText.bodyMedium(
                        'Payment Method',
                        color: AppColors.textDisabled,
                        fontSize: 13,
                      ),
                      Row(
                        children: [
                          Icon(
                            paymentMethod == 'KHQR' ? Icons.qr_code_scanner_rounded : Icons.payments_outlined,
                            color: AppColors.textPrimary,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          AppText.bodyMedium(
                            paymentMethod == 'KHQR' ? 'KHQR Payment' : 'Cash on Delivery',
                            color: AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Items card
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.textPrimary.withValues(alpha: 0.03),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppText.bodyLarge(
                    'Items Ordered',
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      for (int i = 0; i < min(3, orderItems.length); i++)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: _buildCover(orderItems[i], isOverlay: i == 2 && orderItems.length > 3, remaining: orderItems.length - 2),
                        ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Divider(height: 1, thickness: 1, color: AppColors.border.withValues(alpha: 0.5)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const AppText.bodyMedium('Total Paid', color: AppColors.textDisabled, fontSize: 13, fontWeight: FontWeight.w500),
                      AppText.titleLarge('\$${orderTotal.toStringAsFixed(2)}', color: AppColors.buttonColor, fontSize: 18, fontWeight: FontWeight.w800),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Buttons
            GestureDetector(
              onTap: () {
                context.push(AppRoutes.orderSummary(orderId));
              },
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.buttonColor,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.buttonColor.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: AppText.button(
                      'View Order Details',
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () {
                  context.go(AppRoutes.main);
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.buttonColor, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                  backgroundColor: Colors.transparent,
                ),
                child: const AppText.button(
                  'Continue Shopping',
                  color: AppColors.buttonColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const AppText.bodySmall(
              'A confirmation email has been sent to your inbox.',
              color: AppColors.textDisabled,
              fontSize: 11,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCover(dynamic item, {bool isOverlay = false, int remaining = 0}) {
    String? coverUrl;
    if (item is Map) {
      coverUrl = item['cover_url'] ?? item['book_cover'] ?? item['bookCover'];
    } else {
      try {
        coverUrl = item.coverUrl;
      } catch (_) {
        try {
          coverUrl = item.bookCover;
        } catch (_) {}
      }
    }

    return Container(
      width: 80,
      height: 106,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (coverUrl != null && coverUrl.isNotEmpty)
              CachedNetworkImage(
                imageUrl: coverUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: const Color(0xFFF3F4F6)),
                errorWidget: (context, url, error) => Container(color: const Color(0xFFF3F4F6)),
              ),
            if (isOverlay)
              Container(
                color: Colors.black.withValues(alpha: 0.6),
                child: Center(
                  child: AppText.bodyMedium(
                    '+$remaining more',
                    textAlign: TextAlign.center,
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfetti(BuildContext context) {
    return Stack(
      children: [
        _ConfettiDot(color: const Color(0xFF059669), size: 8, top: 0, left: 20),
        _ConfettiDot(color: const Color(0xFF1D4ED8), size: 10, top: 20, right: 30),
        _ConfettiDot(color: const Color(0xFFF59E0B), size: 7, bottom: 40, left: 10),
        _ConfettiDot(color: const Color(0xFFEF4444), size: 9, bottom: 10, right: 40),
        _ConfettiDot(color: const Color(0xFF059669), size: 6, top: 50, left: -10),
        _ConfettiDot(color: const Color(0xFFF59E0B), size: 8, bottom: -10, left: 60),
        _ConfettiDot(color: const Color(0xFF1D4ED8), size: 6, top: 10, right: 0),
        _ConfettiDot(color: const Color(0xFFEF4444), size: 8, bottom: 60, right: -10),
      ],
    );
  }
}

class _ConfettiDot extends StatelessWidget {
  const _ConfettiDot({
    required this.color,
    required this.size,
    this.top,
    this.bottom,
    this.left,
    this.right,
  });

  final Color color;
  final double size;
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Transform.rotate(
        angle: Random().nextDouble() * 2 * pi,
        child: Container(
          width: size,
          height: size,
          color: color,
        ),
      ),
    );
  }
}
