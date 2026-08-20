import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_color.dart';
import '../../../core/widgets/app_text.dart';
import '../../../data/models/book_model.dart';
import '../viewmodels/book_detail_viewmodel.dart';
import '../../cart/viewmodels/cart_viewmodel.dart';
import '../../../shared/widgets/wishlist_heart.dart';

class BookDetailScreen extends StatefulWidget {
  const BookDetailScreen({super.key, required this.bookId});

  final String bookId;

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookDetailViewModel>().fetchBookDetails(widget.bookId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookDetailViewModel>();
    final book = provider.book;
    final isLoading = provider.isLoading;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.background,
        ),
        child: isLoading || book == null
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.buttonColor),
              )
            : Stack(
              children: [

                SafeArea(
                  child: CustomScrollView(
                    slivers: [
                      _buildAppBar(context, book),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              _buildTopSection(book),
                              const SizedBox(height: 32),
                              _buildStatsRow(book),
                              const SizedBox(height: 24),
                              _buildBuyButton(context, book),
                              const SizedBox(height: 32),
                              _buildAboutSection(book),
                              const SizedBox(height: 32),
                              _buildRatingsAndReviews(book),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, BookModel book) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.buttonColor, size: 20),
        onPressed: () => context.pop(),
      ),
      title: const AppText.titleSmall(
        'Librarain',
        color: AppColors.buttonColor,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      centerTitle: true,
      actions: [
        WishlistHeart(bookId: book.id),
        const SizedBox(width: 8),
        IconButton(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.shopping_bag_outlined, color: AppColors.buttonColor),
              Positioned(
                right: -4,
                top: -4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.buttonColor,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${context.watch<CartViewModel>().items.length}',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
            ],
          ),
          onPressed: () => context.push(AppRoutes.cart),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildTopSection(BookModel book) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Book Cover
        Container(
          width: 140,
          height: 210,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.textPrimary.withAlpha(30),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: book.coverUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: AppColors.surface),
              errorWidget: (context, url, error) => Container(
                color: AppColors.surface,
                child: const Icon(Icons.book_rounded, color: AppColors.textDisabled),
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        // Book Details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              AppText.titleMedium(
                book.title,
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
              const SizedBox(height: 12),
              AppText.bodyMedium(
                book.author,
                color: AppColors.buttonColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              const SizedBox(height: 8),
              AppText.caption(
                'Released on ${book.publishedDate}',
                color: AppColors.textPrimary.withAlpha(150),
                fontSize: 12,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (book.category != null) _buildTag(book.category!.name),
                  _buildTag('Fiction'), // Placeholder based on design
                  _buildTag('Magic'), // Placeholder based on design
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withAlpha(150)),
      ),
      child: AppText.caption(
        label,
        color: AppColors.textPrimary.withAlpha(180),
        fontSize: 10,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildStatsRow(BookModel book) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withAlpha(12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(
            '${book.ratingAverage} \u2B50',
            '${book.ratingCount >= 1000 ? '${(book.ratingCount / 1000).toStringAsFixed(1)}K' : book.ratingCount} reviews',
          ),
          _buildDivider(),
          _buildStatItem(book.fileSize ?? '5.6 MB', 'size'),
          _buildDivider(),
          _buildStatItem('${book.pages}', 'pages'),
          _buildDivider(),
          _buildStatItem('${book.stock}', 'stock'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    Widget valueWidget;
    if (value.contains('\u2B50')) {
      valueWidget = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText.bodyLarge(
            value.replaceAll(' \u2B50', ''),
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          const SizedBox(width: 4),
          const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 14),
        ],
      );
    } else {
      valueWidget = AppText.bodyLarge(
        value,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      );
    }

    return Column(
      children: [
        valueWidget,
        const SizedBox(height: 4),
        AppText.caption(
          label,
          color: AppColors.textPrimary.withAlpha(150),
          fontSize: 11,
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(height: 30, width: 1, color: AppColors.border);
  }

  Widget _buildBuyButton(BuildContext context, BookModel book) {
    final isOutOfStock = book.stock <= 0;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isOutOfStock
            ? null
            : () {
                context.read<CartViewModel>().addToCart(book);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${book.title} added to cart!'),
                    backgroundColor: AppColors.buttonColor,
                  ),
                );
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutOfStock ? AppColors.textDisabled : AppColors.buttonColor,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: AppText.button(
          isOutOfStock ? 'OUT OF STOCK' : 'Buy USD \$${book.price}',
          color: AppColors.white,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildAboutSection(BookModel book) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const AppText.subTitle(
              'About this book',
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.buttonColor,
              size: 16,
            ),
          ],
        ),
        const SizedBox(height: 12),
        AppText.bodyMedium(
          book.description.isNotEmpty
              ? book.description
              : 'Harry is waiting in Privet Drive. The Order of the Phoenix is coming to escort him safely away without Voldemort and his supporters knowing... but what will he do then? In this...',
          color: AppColors.textPrimary.withAlpha(160),
          height: 1.6,
        ),
      ],
    );
  }

  Widget _buildRatingsAndReviews(BookModel book) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const AppText.subTitle(
              'Ratings & Reviews',
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            const Icon(Icons.arrow_forward_rounded, color: AppColors.buttonColor, size: 20),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Column(
              children: [
                AppText.titleLarge(
                  book.ratingAverage,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                Row(
                  children: List.generate(5, (index) {
                    final rating = double.tryParse(book.ratingAverage) ?? 0.0;
                    final bool isFilled = index < rating.round();
                    return Icon(
                      isFilled ? Icons.star_rounded : Icons.star_border_rounded,
                      size: 14,
                      color: const Color(0xFFF59E0B),
                    );
                  }),
                ),
                const SizedBox(height: 8),
                AppText.caption(
                  '(${book.ratingCount >= 1000 ? '${(book.ratingCount / 1000).toStringAsFixed(1)}K' : book.ratingCount} reviews)',
                  color: AppColors.textPrimary.withAlpha(150),
                  fontSize: 11,
                ),
              ],
            ),
            const SizedBox(width: 32),
            Expanded(
              child: Column(
                children: [
                  _buildProgressRow('5', 0.8),
                  _buildProgressRow('4', 0.1),
                  _buildProgressRow('3', 0.05),
                  _buildProgressRow('2', 0.02),
                  _buildProgressRow('1', 0.03),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.edit_rounded, size: 16, color: AppColors.buttonColor),
            label: const AppText.button(
              'Write a Review',
              color: AppColors.buttonColor,
              fontSize: 13,
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: AppColors.buttonColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        if (book.reviews != null && book.reviews!.isNotEmpty)
          ...book.reviews!.map(
            (r) => _buildReviewCard(
              r.userName,
              r.userAvatar,
              r.rating,
              r.date,
              r.text,
            ),
          )
        else ...[
          _buildReviewCard(
            'James Wilson',
            '',
            5,
            'Oct 12, 2023',
            'An absolute masterpiece. This concluding chapter was everything I hoped for. The emotional depth and the stakes were perfectly handled by Rowling.',
          ),
          _buildReviewCard(
            'Sarah Connor',
            '',
            4,
            'Nov 05, 2023',
            'The pacing in the first half felt a bit slow, but the final battle was breathtaking. A fitting end to a legendary series.',
          ),
        ],
      ],
    );
  }

  Widget _buildProgressRow(String star, double percent) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          AppText.bodySmall(
            star,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: AppColors.surface,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.buttonColor,
              ),
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(
    String name,
    String avatar,
    double rating,
    String date,
    String text,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.surface,
                backgroundImage: avatar.isNotEmpty
                    ? NetworkImage(avatar)
                    : null,
                child: avatar.isEmpty
                    ? const Icon(Icons.person_rounded, size: 20, color: AppColors.textDisabled)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.bodyMedium(
                      name,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    Row(
                      children: List.generate(5, (index) {
                        final bool isFilled = index < rating.round();
                        return Icon(
                          isFilled ? Icons.star_rounded : Icons.star_border_rounded,
                          size: 10,
                          color: const Color(0xFFF59E0B),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              AppText.caption(
                date,
                color: AppColors.textPrimary.withAlpha(150),
                fontSize: 10,
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppText.bodyMedium(
            text,
            color: AppColors.textPrimary.withAlpha(200),
            height: 1.5,
          ),
        ],
      ),
    );
  }
}
