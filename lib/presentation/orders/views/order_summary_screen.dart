import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_color.dart';
import '../../../data/models/order_model.dart';
import '../../../providers/order_provider.dart';
import '../../../data/repositories/invoice_repository.dart';
import '../../../shared/widgets/app_snackbar.dart';

class OrderSummaryScreen extends StatefulWidget {
  const OrderSummaryScreen({super.key, required this.orderId});

  final String orderId;

  @override
  State<OrderSummaryScreen> createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends State<OrderSummaryScreen> {
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadOrderSummary(widget.orderId);
    });
  }

  Future<void> _downloadInvoice(BuildContext context, String orderId) async {
    setState(() => _isDownloading = true);
    try {
      final repo = InvoiceRepository();
      final filepath = await repo.downloadInvoice(orderId);
      await repo.openInvoice(filepath);

      if (context.mounted) {
        AppSnackbar.showSuccess(context, 'Invoice downloaded successfully!');
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackbar.showError(context, 'Failed to download invoice');
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFECFDF5);
      case 'processing':
        return const Color(0xFFFEF3C7);
      case 'delivered':
        return const Color(0xFFECFDF5);
      case 'cancelled':
        return const Color(0xFFFEF2F2);
      default:
        return const Color(0xFFF3F4F6);
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFF059669);
      case 'processing':
        return const Color(0xFFB45309);
      case 'delivered':
        return const Color(0xFF059669);
      case 'cancelled':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF374151);
    }
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderProvider>();
    final summary = provider.summary;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Order Summary',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.shopping_bag_outlined,
              color: AppColors.buttonColor,
            ),
            onPressed: () => context.push(AppRoutes.cart),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: provider.isLoading || summary == null
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.buttonColor),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: 40,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Section 1 - Order status card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.buttonColor,
                        width: 0.1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '#${summary.shortId}',
                          style: const TextStyle(
                            color: AppColors.buttonColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ordered on ${summary.createdAt}',
                          style: const TextStyle(
                            color: AppColors.textDisabled,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusBgColor(summary.status),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.buttonColor,
                              width: 0.1,
                            ),
                          ),
                          child: Text(
                            _capitalize(summary.status),
                            style: TextStyle(
                              color: _getStatusTextColor(summary.status),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Section 2 - Customer Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.buttonColor,
                        width: 0.1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Customer Info',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(
                              Icons.person_outline_rounded,
                              color: AppColors.textDisabled,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              summary.customerName,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              Icons.email_outlined,
                              color: AppColors.textDisabled,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              summary.customerEmail,
                              style: const TextStyle(
                                color: AppColors.textDisabled,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              Icons.phone_outlined,
                              color: AppColors.textDisabled,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              summary.customerPhone,
                              style: const TextStyle(
                                color: AppColors.textDisabled,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Section 3 - Items Ordered
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.buttonColor,
                        width: 0.3,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Items Ordered',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${summary.itemCount} items',
                                style: const TextStyle(
                                  color: AppColors.textDisabled,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ...summary.items.asMap().entries.map((entry) {
                          final int idx = entry.key;
                          final OrderItemModel item = entry.value;
                          return Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child:
                                        item.bookCover != null &&
                                            item.bookCover!.isNotEmpty
                                        ? CachedNetworkImage(
                                            imageUrl: item.bookCover!,
                                            width: 60,
                                            height: 80,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                Container(
                                                  color: const Color(
                                                    0xFFF3F4F6,
                                                  ),
                                                ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Container(
                                                      color: const Color(
                                                        0xFFF3F4F6,
                                                      ),
                                                    ),
                                          )
                                        : Container(
                                            width: 60,
                                            height: 80,
                                            color: const Color(0xFFF3F4F6),
                                          ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.categoryName?.toUpperCase() ??
                                              'BOOK',
                                          style: const TextStyle(
                                            color: AppColors.buttonColor,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          item.bookTitle ?? 'Unknown',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          item.bookAuthor ?? 'Unknown',
                                          style: const TextStyle(
                                            color: AppColors.textDisabled,
                                            fontSize: 11,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Qty: x${item.quantity}',
                                              style: const TextStyle(
                                                color: AppColors.textDisabled,
                                                fontSize: 12,
                                              ),
                                            ),
                                            Text(
                                              '\$${item.subtotal.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                color: AppColors.buttonColor,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (idx != summary.items.length - 1)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Divider(
                                    height: 0.5,
                                    thickness: 0.5,
                                    color: Color(0xFFE5E7EB),
                                  ),
                                ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Section 4 - Payment Summary
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.buttonColor,
                        width: 0.3,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Subtotal',
                              style: TextStyle(
                                color: AppColors.textDisabled,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              '\$${summary.subtotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Discount',
                              style: TextStyle(
                                color: AppColors.textDisabled,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              '-\$${summary.discount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: AppColors.buttonColor,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Delivery',
                              style: TextStyle(
                                color: AppColors.textDisabled,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              summary.delivery == 0
                                  ? 'FREE'
                                  : '\$${summary.delivery.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: AppColors.buttonColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(
                            height: 1,
                            thickness: 1,
                            color: Color(0xFFE5E7EB),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '\$${summary.total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: AppColors.buttonColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Section 5 - Delivery Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.buttonColor,
                        width: 0.3,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFFECFDF5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.local_shipping_outlined,
                                color: AppColors.buttonColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Cash on Delivery',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Pay when you receive',
                                  style: TextStyle(
                                    color: AppColors.textDisabled,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Divider(height: 1, thickness: 1),
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFFF3F4F6),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.access_time_rounded,
                                color: AppColors.textDisabled,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Estimated Delivery',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  '3-5 business days',
                                  style: TextStyle(
                                    color: AppColors.textDisabled,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Buttons area
                  _buildBottomButtons(summary.status),
                ],
              ),
            ),
    );
  }

  Widget _buildBottomButtons(String status) {
    final lowerStatus = status.toLowerCase();

    Widget? button;
    if (lowerStatus == 'pending' || lowerStatus == 'processing') {
      button = SizedBox(
        width: double.infinity,
        height: 52,
        child: OutlinedButton(
          onPressed: () async {
            // Confirm cancel action
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text(
                  'Cancel Order',
                  style: TextStyle(fontWeight: FontWeight.normal),
                ),
                content: const Text(
                  'Are you sure you want to cancel this order?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => context.pop(false),
                    child: const Text(
                      'No',
                      style: TextStyle(color: AppColors.textDisabled),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.pop(true),
                    child: const Text(
                      'Yes, Cancel',
                      style: TextStyle(color: Color(0xFFEF4444)),
                    ),
                  ),
                ],
              ),
            );

            if (confirm == true && context.mounted) {
              final provider = context.read<OrderProvider>();
              final success = await provider.cancelOrder(widget.orderId);
              if (context.mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Order cancelled successfully'),
                      backgroundColor: Color(0xFF059669),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(provider.errorMessage),
                      backgroundColor: const Color(0xFFEF4444),
                    ),
                  );
                }
              }
            }
          },
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFFFEE2E2), width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            backgroundColor: Colors.transparent,
          ),
          child: const Text(
            'Cancel Order',
            style: TextStyle(
              color: Color(0xFFEF4444),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    } else if (lowerStatus == 'delivered') {
      button = SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: () {
            // Reorder action
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.buttonColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          child: const Text(
            'Reorder',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (button != null) button,
        if (button != null) const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _isDownloading
              ? null
              : () => _downloadInvoice(context, widget.orderId),
          icon: _isDownloading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.picture_as_pdf_outlined),
          label: Text(_isDownloading ? 'Downloading...' : 'Download Invoice'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Need help? ',
              style: TextStyle(color: AppColors.textDisabled, fontSize: 13),
            ),
            GestureDetector(
              onTap: () {
                // Contact support
              },
              child: const Text(
                'Contact Support',
                style: TextStyle(
                  color: AppColors.buttonColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
