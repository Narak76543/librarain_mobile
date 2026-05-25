import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_color.dart';
import '../../providers/wishlist_provider.dart';

class WishlistHeart extends StatelessWidget {
  const WishlistHeart({super.key, required this.bookId});

  final String bookId;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WishlistProvider>();
    final isWishlisted = provider.isWishlisted(bookId);

    return GestureDetector(
      onTap: () {
        provider.toggle(bookId).catchError((error) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to update wishlist'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        });
      },
      child: CircleAvatar(
        radius: 16,
        backgroundColor: Colors.white,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child: Icon(
            isWishlisted ? Icons.favorite : Icons.favorite_border,
            key: ValueKey<bool>(isWishlisted),
            size: 20,
            color: isWishlisted ? const Color(0xFF059669) : Colors.grey,
          ),
        ),
      ),
    );
  }
}
