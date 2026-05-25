import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_color.dart';
import '../../core/widgets/app_text.dart';
import '../../data/models/cart_item_model.dart';
import 'viewmodels/cart_viewmodel.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartViewModel>().fetchCart();
    });
  }

  Future<void> _refreshCart() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.buttonColor,
          backgroundColor: AppColors.white,
          displacement: 28,
          onRefresh: _refreshCart,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 118),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CartHeader(),
                SizedBox(height: 18),
                _CartItemsList(),
                SizedBox(height: 24),
                _PromoCodeSection(),
                SizedBox(height: 20),
                _OrderSummaryCard(),
                SizedBox(height: 20),
                _CheckoutButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CartHeader extends StatelessWidget {
  const _CartHeader();

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartViewModel>();
    final canPop = Navigator.canPop(context);

    return Row(
      children: [
        if (canPop) ...[
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.textPrimary.withAlpha(10),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: AppColors.textPrimary,
                size: 20,
                weight: 100,
              ),
            ),
          ),
        ],
        const Expanded(
          child: AppText.titleLarge(
            'My Cart',
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.buttonColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: AppText.bodySmall(
            '${cart.items.length} items',
            color: AppColors.buttonColor,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _CartItemsList extends StatelessWidget {
  const _CartItemsList();

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartViewModel>();
    final items = cart.items;

    if (cart.isLoading && items.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(color: AppColors.buttonColor),
      );
    }

    if (items.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: AppText.bodyMedium(
          'Your cart is empty',
          color: AppColors.textDisabled,
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
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
        children: List.generate(items.length, (index) {
          return Column(
            children: [
              _CartItemCard(item: items[index]),
              if (index != items.length - 1)
                Divider(
                  height: 1,
                  thickness: 1,
                  indent: 16,
                  endIndent: 16,
                  color: AppColors.border.withValues(alpha: 0.4),
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({required this.item});

  final CartItemModel item;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 102,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    width: 54,
                    height: 78,
                    color: AppColors.surface,
                    child: item.book.coverUrl.isNotEmpty
                        ? Image.network(item.book.coverUrl, fit: BoxFit.cover)
                        : Container(color: AppColors.primary100),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _CartItemCategory(
                          categoryName: item.book.category?.name ?? 'BOOK',
                        ),

                        AppText.bodySmall(
                          item.book.title,
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Divider(),
                        AppText.caption(
                          item.book.author,
                          color: AppColors.textPrimary.withValues(alpha: 0.6),
                          fontSize: 10,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        AppText.button(
                          '\$${item.book.price}',
                          color: AppColors.buttonColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ],
                    ),
                  ),
                ),
                _QuantityControl(item: item),
              ],
            ),
            Positioned(
              right: 0,
              top: 0,
              child: GestureDetector(
                onTap: () {
                  context.read<CartViewModel>().removeFromCart(item.id);
                },
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.error.withValues(alpha: 0.8),
                    size: 14,
                    weight: 100,
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

class _CartItemCategory extends StatelessWidget {
  const _CartItemCategory({required this.categoryName});

  final String categoryName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.buttonColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(5),
      ),
      child: AppText.caption(
        categoryName.toUpperCase(),
        color: AppColors.buttonColor,
        fontSize: 7,
        fontWeight: FontWeight.w800,
        height: 1,
      ),
    );
  }
}

class _QuantityControl extends StatelessWidget {
  const _QuantityControl({required this.item});

  final CartItemModel item;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              context.read<CartViewModel>().decreaseQuantity(item.id);
            },
            child: const _QuantityButton(
              icon: Icons.remove_rounded,
              isPrimary: false,
            ),
          ),
          const SizedBox(width: 10),
          AppText.button(
            '${item.quantity}',
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              context.read<CartViewModel>().increaseQuantity(item.id);
            },
            child: const _QuantityButton(
              icon: Icons.add_rounded,
              isPrimary: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({required this.icon, required this.isPrimary});

  final IconData icon;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: isPrimary ? AppColors.buttonColor : AppColors.white,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.buttonColor, width: 1.2),
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: AppColors.buttonColor.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Icon(
        icon,
        color: isPrimary ? AppColors.white : AppColors.buttonColor,
        size: 13,
        weight: 100,
      ),
    );
  }
}

class _PromoCodeSection extends StatelessWidget {
  const _PromoCodeSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(27),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_offer_outlined,
            color: AppColors.buttonColor,
            size: 20,
            weight: 100,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              cursorColor: AppColors.buttonColor,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: 'Enter Promo code',
                hintStyle: TextStyle(
                  color: AppColors.textDisabled.withValues(alpha: 0.8),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isCollapsed: true,
              ),
            ),
          ),
          Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.buttonColor,
              borderRadius: BorderRadius.circular(21),
              boxShadow: [
                BoxShadow(
                  color: AppColors.buttonColor.withValues(alpha: 0.25),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const AppText.button(
              'Apply',
              color: AppColors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard();

  @override
  Widget build(BuildContext context) {
    final subtotal = context.watch<CartViewModel>().subtotal;
    // Set discount to 0.00 per user request
    final discount = 0.0;
    final total = (subtotal - discount) > 0 ? (subtotal - discount) : 0.0;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 18),
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
          const AppText.bodyLarge(
            'Order Summary',
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
          const SizedBox(height: 20),
          _SummaryRow(
            label: 'Subtotal',
            value: '\$${subtotal.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 14),
          _SummaryRow(
            label: 'Discount',
            value: '-\$${discount.toStringAsFixed(2)}',
            valueColor: AppColors.error,
          ),
          const SizedBox(height: 14),
          const _SummaryRow(
            label: 'Delivery',
            value: 'FREE',
            valueColor: AppColors.buttonColor,
          ),
          const SizedBox(height: 18),
          Divider(color: AppColors.border.withValues(alpha: 0.6), height: 1),
          const SizedBox(height: 18),
          _SummaryRow(
            label: 'Total',
            value: '\$${total.toStringAsFixed(2)}',
            labelSize: 15,
            valueSize: 16,
            labelWeight: FontWeight.w700,
            valueColor: AppColors.buttonColor,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.labelSize = 13,
    this.valueSize = 14,
    this.labelWeight = FontWeight.w500,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final double labelSize;
  final double valueSize;
  final FontWeight labelWeight;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppText.bodySmall(
            label,
            color: AppColors.textPrimary.withValues(alpha: 0.8),
            fontSize: labelSize,
            fontWeight: labelWeight,
          ),
        ),
        AppText.button(
          value,
          color: valueColor ?? AppColors.textPrimary,
          fontSize: valueSize,
          fontWeight: FontWeight.w800,
        ),
      ],
    );
  }
}

class _CheckoutButton extends StatelessWidget {
  const _CheckoutButton();

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartViewModel>();

    return GestureDetector(
      onTap: cart.isLoading || cart.items.isEmpty
          ? null
          : () async {
              final success = await context.read<CartViewModel>().placeOrder();
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Order placed successfully!')),
                );
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(cart.error ?? 'Failed to place order'),
                  ),
                );
              }
            },
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: cart.isLoading || cart.items.isEmpty
                ? AppColors.textDisabled
                : AppColors.buttonColor,
            borderRadius: BorderRadius.circular(26),
            boxShadow: cart.isLoading || cart.items.isEmpty
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
                if (cart.isLoading)
                  const Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: AppColors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                AppText.button(
                  cart.isLoading ? 'Processing...' : 'Proceed to Checkout',
                  color: AppColors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
                if (!cart.isLoading) ...[
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: AppColors.white,
                    size: 18,
                    weight: 100,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
