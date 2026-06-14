import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_color.dart';
import '../../../core/widgets/app_text.dart';
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
        return AppColors.successLight;
      case 'processing':
        return AppColors.warningLight;
      case 'delivered':
        return AppColors.successLight;
      case 'cancelled':
        return AppColors.errorLight;
      default:
        return AppColors.divider;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.success;
      case 'processing':
        return AppColors.warning;
      case 'delivered':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textPrimary;
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
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
        title: const AppText.subTitle(
          'Order Summary',
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
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
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.buttonColor,
                        width: 0.1,
                      ),
                    ),
                    child: Column(
                      children: [
                        AppText.bodySmall(
                          '#${summary.shortId}',
                          color: AppColors.buttonColor,
                          fontWeight: FontWeight.w600,
                        ),
                        const SizedBox(height: 4),
                        AppText.bodySmall(
                          'Ordered on ${summary.createdAt}',
                          color: AppColors.textDisabled,
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
                          child: AppText.bodySmall(
                            _capitalize(summary.status),
                            color: _getStatusTextColor(summary.status),
                            fontWeight: FontWeight.w600,
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
                        const AppText.bodyMedium(
                          'Customer Info',
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
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
                            AppText.bodySmall(
                              summary.customerName,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
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
                            AppText.bodySmall(
                              summary.customerEmail,
                              color: AppColors.textDisabled,
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
                            AppText.bodySmall(
                              summary.customerPhone,
                              color: AppColors.textDisabled,
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
                      color: AppColors.white,
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
                            const AppText.bodyMedium(
                              'Items Ordered',
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.divider,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: AppText.bodySmall(
                                '${summary.itemCount} items',
                                color: AppColors.textDisabled,
                                fontWeight: FontWeight.w500,
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
                                                  color: AppColors.divider,
                                                ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Container(
                                                      color: AppColors.divider,
                                                    ),
                                          )
                                        : Container(
                                            width: 60,
                                            height: 80,
                                            color: AppColors.divider,
                                          ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        AppText.caption(
                                          item.categoryName?.toUpperCase() ??
                                              'BOOK',
                                          color: AppColors.buttonColor,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        const SizedBox(height: 4),
                                        AppText.bodyMedium(
                                          item.bookTitle ?? 'Unknown',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        const SizedBox(height: 2),
                                        AppText.caption(
                                          item.bookAuthor ?? 'Unknown',
                                          color: AppColors.textDisabled,
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            AppText.bodySmall(
                                              'Qty: x${item.quantity}',
                                              color: AppColors.textDisabled,
                                            ),
                                            AppText.bodyMedium(
                                              '\$${item.subtotal.toStringAsFixed(2)}',
                                              color: AppColors.buttonColor,
                                              fontWeight: FontWeight.w700,
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
                                    color: AppColors.border,
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
                      color: AppColors.white,
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
                            const AppText.bodyMedium(
                              'Subtotal',
                              color: AppColors.textDisabled,
                            ),
                            AppText.bodyMedium(
                              '\$${summary.subtotal.toStringAsFixed(2)}',
                              color: AppColors.textPrimary,
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
                            const AppText.bodySmall(
                              'Delivery',
                              color: AppColors.textDisabled,
                            ),
                            AppText.bodySmall(
                              summary.delivery == 0
                                  ? 'FREE'
                                  : '\$${summary.delivery.toStringAsFixed(2)}',
                              color: AppColors.buttonColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(
                            height: 1,
                            thickness: 1,
                            color: AppColors.border,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const AppText.bodyMedium(
                              'Total',
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                            AppText.bodyMedium(
                              '\$${summary.total.toStringAsFixed(2)}',
                              color: AppColors.buttonColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Section 5 - Delivery Info
                  Builder(
                    builder: (context) {
                      final isKhqr = summary.paymentMethod == 'KHQR';
                      final paymentIcon = isKhqr
                          ? Icons.qr_code_scanner_rounded
                          : Icons.payments_outlined;
                      final paymentTitle = isKhqr
                          ? 'KHQR Payment'
                          : 'Cash on Delivery';
                      final paymentSubtitle = isKhqr
                          ? 'Scanned and paid'
                          : 'Pay when you receive';
                      final paymentBg = isKhqr
                          ? AppColors.primary50
                          : AppColors.successLight;
                      final paymentIconColor = isKhqr
                          ? AppColors.primary600
                          : AppColors.buttonColor;

                      final isDelivery = summary.deliveryWay == 'Delivery';
                      final deliveryIcon = isDelivery
                          ? Icons.local_shipping_outlined
                          : Icons.storefront_rounded;
                      final deliveryTitle = isDelivery
                          ? 'Delivery'
                          : 'Store Pick Up';
                      final deliverySubtitle = isDelivery
                          ? 'Via ${summary.deliveryPartner ?? 'Standard Carrier'}'
                          : 'Collect from our store';
                      final deliveryBg = isDelivery
                          ? AppColors.successLight
                          : AppColors.divider;
                      final deliveryIconColor = isDelivery
                          ? AppColors.buttonColor
                          : AppColors.textDisabled;

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
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
                                  decoration: BoxDecoration(
                                    color: paymentBg,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    paymentIcon,
                                    color: paymentIconColor,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppText.bodySmall(
                                      paymentTitle,
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    const SizedBox(height: 2),
                                    AppText.caption(
                                      paymentSubtitle,
                                      color: AppColors.textDisabled,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Divider(
                                height: 1,
                                thickness: 1,
                                color: AppColors.divider,
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: deliveryBg,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    deliveryIcon,
                                    color: deliveryIconColor,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppText.bodySmall(
                                      deliveryTitle,
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    const SizedBox(height: 2),
                                    AppText.caption(
                                      deliverySubtitle,
                                      color: AppColors.textDisabled,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (isDelivery &&
                                summary.deliveryAddress != null &&
                                summary.deliveryAddress!.isNotEmpty) ...[
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Divider(height: 1, thickness: 1),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                      color: AppColors.warningLight,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.location_on_rounded,
                                      color: AppColors.warning,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const AppText.bodySmall(
                                          'Delivery Address',
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        const SizedBox(height: 2),
                                        AppText.caption(
                                          summary.deliveryAddress!,
                                          color: AppColors.textDisabled,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ] else if (!isDelivery) ...[
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: AppColors.divider,
                                ),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.buttonColor.withValues(
                                        alpha: 0.1,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.location_on_rounded,
                                      color: AppColors.buttonColor,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const AppText.bodySmall(
                                          'Librarain Main Shop Address',
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        const SizedBox(height: 2),
                                        const AppText.caption(
                                          'St 123, Phnom Penh, Cambodia',
                                          color: AppColors.textDisabled,
                                        ),
                                        const SizedBox(height: 10),
                                        GestureDetector(
                                          onTap: () async {
                                            final url = Uri.parse(
                                              'https://maps.app.goo.gl/X6JSrKwfBJzKY34aA',
                                            );
                                            if (!await launchUrl(
                                              url,
                                              mode: LaunchMode
                                                  .externalApplication,
                                            )) {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Could not open Maps link',
                                                    ),
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                          child: Container(
                                            height: 32,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: AppColors.buttonColor,
                                                width: 1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.map_outlined,
                                                  color: AppColors.buttonColor,
                                                  size: 14,
                                                ),
                                                SizedBox(width: 6),
                                                AppText.caption(
                                                  'View on Google Maps',
                                                  color: AppColors.buttonColor,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      );
                    },
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
                title: const AppText.bodyLarge(
                  'Cancel Order',
                  fontWeight: FontWeight.w600,
                ),
                content: const AppText.bodyMedium(
                  'Are you sure you want to cancel this order?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => context.pop(false),
                    child: const AppText.button(
                      'No',
                      color: AppColors.textDisabled,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.pop(true),
                    child: const AppText.button(
                      'Yes, Cancel',
                      color: AppColors.error,
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
                      backgroundColor: AppColors.success,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(provider.errorMessage),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            }
          },
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.errorLight, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            backgroundColor: AppColors.transparent,
          ),
          child: const AppText.bodySmall(
            'Cancel Order',
            color: AppColors.error,
            fontWeight: FontWeight.w500,
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
          child: const AppText.bodyMedium(
            'Reorder',
            color: AppColors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ?button,
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
          label: AppText.button(
            _isDownloading ? 'Downloading...' : 'Download Invoice',
            color: AppColors.primary,
          ),
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
            const AppText.bodyMedium(
              'Need help? ',
              color: AppColors.textDisabled,
            ),
            GestureDetector(
              onTap: () {
                // Contact support
              },
              child: const Text(
                'Contact Support',
                style: TextStyle(
                  color: AppColors.buttonColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
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
