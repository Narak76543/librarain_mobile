import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_color.dart';
import '../../../core/widgets/app_text.dart';
import '../../../data/models/book_model.dart';
import '../../../shared/widgets/wishlist_heart.dart';

class BookCard extends StatefulWidget {
  const BookCard({
    super.key,
    required this.book,
    required this.onTap,
    required this.onAddToCart,
  });

  final BookModel book;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  @override
  State<BookCard> createState() => _BookCardState();
}

class _BookCardState extends State<BookCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border.withAlpha(130)),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withAlpha(34),
              blurRadius: 30,
              offset: const Offset(0, 18),
            ),
            BoxShadow(
              color: AppColors.buttonColor.withAlpha(18),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 170,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: widget.book.coverUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 170,
                      placeholder: (context, url) => Container(
                        color: AppColors.surface,
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.surface,
                        child: const Center(
                          child: Icon(Icons.book_rounded, color: AppColors.textDisabled),
                        ),
                      ),
                    ),
                  ),
                  if (widget.book.category != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.buttonColor.withAlpha(220),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: AppText.caption(
                          widget.book.category!.name.toUpperCase(),
                          color: AppColors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: WishlistHeart(bookId: widget.book.id),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.bodySmall(
                      widget.book.title,
                      color: AppColors.textPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      height: 1.2,
                    ),
                    const SizedBox(height: 3),
                    AppText.caption(
                      widget.book.author,
                      color: AppColors.textPrimary.withAlpha(150),
                      fontSize: 9,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          final rating = double.tryParse(widget.book.ratingAverage) ?? 0.0;
                          final bool isFilled = index < rating.round();
                          return Icon(
                            isFilled ? Icons.star_rounded : Icons.star_border_rounded,
                            size: 12,
                            color: isFilled ? AppColors.buttonColor : AppColors.textDisabled.withAlpha(120),
                          );
                        }),
                        const SizedBox(width: 4),
                        AppText.caption(
                          widget.book.ratingAverage,
                          color: AppColors.textPrimary.withAlpha(150),
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: AppText.button(
                            '\$${double.tryParse(widget.book.price)?.toStringAsFixed(2) ?? widget.book.price}',
                            color: AppColors.buttonColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        GestureDetector(
                          onTap: widget.onAddToCart,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: widget.book.stock > 0 ? AppColors.buttonColor : AppColors.border,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.add_rounded,
                              color: widget.book.stock > 0 ? AppColors.white : AppColors.textDisabled,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
