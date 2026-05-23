import 'package:flutter/material.dart';

import '../../core/theme/app_color.dart';
import '../../core/widgets/app_text.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  Future<void> _refreshCart() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
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
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 118),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CartHeader(),
                SizedBox(height: 18),
                _CartItemsList(),
                SizedBox(height: 26),
                _PromoCodeSection(),
                SizedBox(height: 26),
                _OrderSummaryCard(),
                SizedBox(height: 10),
                _CheckoutButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CartItem {
  const _CartItem({
    required this.title,
    required this.author,
    required this.price,
    required this.imagePath,
  });

  final String title;
  final String author;
  final String price;
  final String imagePath;

  static const List<_CartItem> items = [
    _CartItem(
      title: 'The Silent Patient',
      author: 'Alex Michaelides',
      price: '\$16.99',
      imagePath: 'assets/images/books/image.png',
    ),
    _CartItem(
      title: 'Cloud Cuckoo Land',
      author: 'Anthony Doerr',
      price: '\$16.99',
      imagePath: 'assets/images/books/image-6.jpg',
    ),
    _CartItem(
      title: 'The Lincoln Highway',
      author: 'Amor Towles',
      price: '\$16.99',
      imagePath: 'assets/images/books/image-8.jpg',
    ),
  ];
}

class _CartHeader extends StatelessWidget {
  const _CartHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: AppText.titleSmall(
            'My Cart',
            color: AppColors.buttonColor,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        AppText.bodySmall(
          '${_CartItem.items.length} items',
          color: AppColors.textPrimary.withAlpha(170),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ],
    );
  }
}

class _CartItemsList extends StatelessWidget {
  const _CartItemsList();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withAlpha(18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: List.generate(_CartItem.items.length, (index) {
          return Column(
            children: [
              _CartItemCard(item: _CartItem.items[index]),
              if (index != _CartItem.items.length - 1)
                Divider(
                  height: 1,
                  thickness: 1,
                  indent: 12,
                  endIndent: 12,
                  color: AppColors.border.withAlpha(150),
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

  final _CartItem item;

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
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    width: 54,
                    height: 78,
                    color: AppColors.surface,
                    child: Image.asset(item.imagePath, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _CartItemCategory(),
                        const SizedBox(height: 5),
                        AppText.bodySmall(
                          item.title,
                          color: AppColors.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        AppText.caption(
                          item.author,
                          color: AppColors.textPrimary.withAlpha(145),
                          fontSize: 9,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        AppText.button(
                          item.price,
                          color: AppColors.buttonColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ],
                    ),
                  ),
                ),
                const _QuantityControl(),
              ],
            ),
            Positioned(
              right: 0,
              top: 0,
              child: Icon(
                Icons.delete_outline_rounded,
                color: AppColors.error.withAlpha(190),
                size: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartItemCategory extends StatelessWidget {
  const _CartItemCategory();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.buttonColor.withAlpha(18),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const AppText.caption(
        'FICTION',
        color: AppColors.buttonColor,
        fontSize: 7,
        fontWeight: FontWeight.w900,
        height: 1,
      ),
    );
  }
}

class _QuantityControl extends StatelessWidget {
  const _QuantityControl();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _QuantityButton(icon: Icons.remove_rounded, isPrimary: false),
          const SizedBox(width: 10),
          const AppText.button(
            '1',
            color: AppColors.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
          const SizedBox(width: 10),
          const _QuantityButton(icon: Icons.add_rounded, isPrimary: true),
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
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: isPrimary ? AppColors.buttonColor : AppColors.white,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.buttonColor, width: 1.2),
      ),
      child: Icon(
        icon,
        color: isPrimary ? AppColors.white : AppColors.buttonColor,
        size: 13,
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
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.local_offer_outlined,
            color: AppColors.buttonColor,
            size: 20,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: TextField(
              cursorColor: AppColors.buttonColor,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: 'Promo code',
                hintStyle: TextStyle(
                  color: AppColors.textDisabled.withAlpha(185),
                  fontSize: 13,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isCollapsed: true,
              ),
            ),
          ),
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.buttonColor,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const AppText.button(
              'Apply',
              color: AppColors.white,
              fontSize: 13,
              fontWeight: FontWeight.w800,
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
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border.withAlpha(150)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withAlpha(12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText.bodySmall(
            'Order Summary',
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
          const SizedBox(height: 18),
          const _SummaryRow(label: 'Subtotal', value: '\$50.97'),
          const SizedBox(height: 12),
          const _SummaryRow(
            label: 'Discount',
            value: '-\$5.00',
            valueColor: AppColors.buttonColor,
          ),
          const SizedBox(height: 12),
          const _SummaryRow(
            label: 'Delivery',
            value: 'FREE',
            valueColor: AppColors.buttonColor,
          ),
          const SizedBox(height: 16),
          Divider(color: AppColors.border.withAlpha(160), height: 1),
          const SizedBox(height: 18),
          const _SummaryRow(
            label: 'Total',
            value: '\$42.97',
            labelSize: 15,
            valueSize: 15,
            labelWeight: FontWeight.w600,
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
            color: AppColors.textPrimary,
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
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.buttonColor,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.buttonColor.withAlpha(65),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText.button(
                'Proceed to Checkout',
                color: AppColors.white,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
              SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.white,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
