import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_color.dart';

class OrderConfirmedScreen extends StatelessWidget {
  const OrderConfirmedScreen({
    super.key,
    required this.orderId,
    required this.orderTotal,
    required this.orderItems,
  });

  final String orderId;
  final double orderTotal;
  final List<dynamic> orderItems;

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
        title: const Text(
          'BookStore',
          style: TextStyle(
            color: AppColors.buttonColor,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
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
                    decoration: const BoxDecoration(
                      color: Color(0xFFECFDF5),
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
            const Text(
              'Order Placed! 🎉',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 26,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your order has been confirmed',
              style: TextStyle(
                color: AppColors.textDisabled,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),

            // Order info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                children: [
                  Text(
                    'ORDER #${orderId.length > 8 ? orderId.substring(0, 8).toUpperCase() : orderId.toUpperCase()}',
                    style: const TextStyle(
                      color: AppColors.buttonColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'May 25, 2026',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Estimated Delivery', style: TextStyle(color: AppColors.textDisabled, fontSize: 13)),
                      Text('3-5 business days', style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Payment Method', style: TextStyle(color: AppColors.textDisabled, fontSize: 13)),
                      Row(
                        children: [
                          Icon(Icons.local_shipping_outlined, color: AppColors.textPrimary, size: 16),
                          SizedBox(width: 6),
                          Text('Cash on Delivery', style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w700)),
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
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Items Ordered',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
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
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Paid', style: TextStyle(color: AppColors.textDisabled, fontSize: 14)),
                      Text('\$${orderTotal.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.buttonColor, fontSize: 20, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Buttons
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  context.push(AppRoutes.orderSummary(orderId));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text(
                  'View Order Details',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  backgroundColor: Colors.transparent,
                ),
                child: const Text(
                  'Continue Shopping',
                  style: TextStyle(
                    color: AppColors.buttonColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'A confirmation email has been sent to your inbox.',
              style: TextStyle(
                color: AppColors.textDisabled,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
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
      coverUrl = item['book_cover'] ?? item['bookCover'];
    } else {
      try {
        coverUrl = item.bookCover;
      } catch (_) {}
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
                  child: Text(
                    '+$remaining more',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
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
