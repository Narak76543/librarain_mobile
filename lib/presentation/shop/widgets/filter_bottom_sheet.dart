import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_color.dart';
import '../../../core/widgets/app_text.dart';
import '../viewmodels/shop_viewmodel.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  String _tempSort = '';
  double _tempMinPrice = 0;
  double _tempMaxPrice = 100;
  String _tempCategory = '';

  @override
  void initState() {
    super.initState();
    final shopProvider = context.read<ShopViewModel>();
    _tempSort = shopProvider.selectedSort;
    _tempMinPrice = shopProvider.minPrice;
    _tempMaxPrice = shopProvider.maxPrice;
    _tempCategory = shopProvider.selectedCategory;
  }

  @override
  Widget build(BuildContext context) {
    final shopProvider = context.read<ShopViewModel>();

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: ListView(
          controller: scrollController,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textDisabled.withAlpha(80),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const AppText.titleSmall(
              'Filter & Sort',
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
            const Divider(height: 32, color: AppColors.border),
            const AppText.subTitle(
              'Sort By',
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
            const SizedBox(height: 8),
            _buildSortOption('Relevance', ''),
            _buildSortOption('Newest', 'newest'),
            _buildSortOption('Price Low→High', 'price_asc'),
            _buildSortOption('Price High→Low', 'price_desc'),
            _buildSortOption('Highest Rated', 'rating'),
            const Divider(height: 32, color: AppColors.border),
            Row(
              children: [
                const AppText.subTitle(
                  'Price Range',
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
                const Spacer(),
                AppText.bodyMedium(
                  '\$${_tempMinPrice.toInt()} — \$${_tempMaxPrice.toInt()}',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.buttonColor,
                ),
              ],
            ),
            RangeSlider(
              values: RangeValues(_tempMinPrice, _tempMaxPrice),
              min: 0,
              max: 200,
              divisions: 40,
              activeColor: AppColors.buttonColor,
              inactiveColor: AppColors.buttonColor.withAlpha(40),
              onChanged: (values) {
                setState(() {
                  _tempMinPrice = values.start;
                  _tempMaxPrice = values.end;
                });
              },
            ),
            const Divider(height: 32, color: AppColors.border),
            const AppText.subTitle(
              'Category',
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildCategoryChip('All', ''),
                ...shopProvider.categories.map(
                  (c) => _buildCategoryChip(c.name, c.slug),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _tempSort = '';
                        _tempMinPrice = 0;
                        _tempMaxPrice = 100;
                        _tempCategory = '';
                      });
                      shopProvider.clearAllFilters();
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const AppText.button(
                      'Reset',
                      color: AppColors.textPrimary,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_tempSort != shopProvider.selectedSort) {
                        shopProvider.onSortSelected(_tempSort);
                      }
                      if (_tempCategory != shopProvider.selectedCategory) {
                        shopProvider.onCategorySelected(_tempCategory);
                      }
                      if (_tempMinPrice != shopProvider.minPrice ||
                          _tempMaxPrice != shopProvider.maxPrice) {
                        shopProvider.onPriceRangeApplied(_tempMinPrice, _tempMaxPrice);
                      }
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonColor,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const AppText.button(
                      'Apply',
                      color: AppColors.white,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String label, String value) {
    final bool isSelected = _tempSort == value;
    return InkWell(
      onTap: () {
        setState(() {
          _tempSort = value;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: _tempSort,
              activeColor: AppColors.buttonColor,
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _tempSort = val;
                  });
                }
              },
            ),
            AppText.bodyMedium(
              label,
              color: AppColors.textPrimary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, String value) {
    final isSelected = _tempCategory == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _tempCategory = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.buttonColor : AppColors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? AppColors.buttonColor : AppColors.border,
          ),
        ),
        child: AppText.button(
          label,
          color: isSelected ? AppColors.white : AppColors.textPrimary,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
