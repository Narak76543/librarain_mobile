import 'package:flutter/material.dart';
import 'package:mobile_s2_flutter/core/widgets/app_text.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_color.dart';
import 'viewmodels/history_viewmodel.dart';
import '../../../data/models/order_model.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final List<String> _statusFilters = [
    'All',
    'Processing',
    'Shipped',
    'Delivered',
    'Cancelled',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryViewModel>().fetchOrders();
    });
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return isoDate;
    }
  }

  Widget _buildFilterChips(HistoryViewModel viewModel) {
    return SizedBox(
      height: 50,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        scrollDirection: Axis.horizontal,
        itemCount: _statusFilters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _statusFilters[index];
          final isSelected = viewModel.selectedStatus == filter;
          return GestureDetector(
            onTap: () => viewModel.setStatusFilter(filter),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Text(
                filter,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[600],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 10,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Colors.teal.withValues(alpha: 0.15);
      case 'processing':
      case 'pending':
        return Colors.brown.withValues(alpha: 0.15);
      case 'shipped':
        return Colors.grey.withValues(alpha: 0.25);
      case 'Cancelled':
        return AppColors.error;
      default:
        return Colors.grey.withValues(alpha: 0.2);
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Colors.teal[700]!;
      case 'processing':
      case 'pending':
        return Colors.brown[600]!;
      case 'shipped':
        return Colors.grey[700]!;
      case 'Cancelled':
        return AppColors.error;
      default:
        return Colors.grey[800]!;
    }
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  Widget _buildStackedImages(OrderModel order) {
    final maxImages = 2;
    final images = order.orderItems.take(maxImages).toList();
    final remainingCount = order.orderItems.length - images.length;

    return SizedBox(
      width:
          70 + (images.length > 1 ? 25.0 : 0) + (remainingCount > 0 ? 30.0 : 0),
      height: 70,
      child: Stack(
        children: [
          for (int i = 0; i < images.length; i++)
            Positioned(
              left: i * 25.0,
              child: Container(
                width: 50,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(-2, 0),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: images[i].bookCover != null
                    ? Image.network(
                        images[i].bookCover!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.book,
                          size: 24,
                          color: Colors.grey,
                        ),
                      )
                    : const Icon(Icons.book, size: 24, color: Colors.grey),
              ),
            ),
          if (remainingCount > 0)
            Positioned(
              left: images.length * 25.0,
              child: Container(
                width: 40,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(6),
                    bottomRight: Radius.circular(6),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  '+$remainingCount',
                  style: const TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HistoryViewModel>();
    final orders = viewModel.filteredOrders;
    final allOrders =
        viewModel.orders; // To check if entirely empty vs just filter empty

    return Scaffold(
      backgroundColor: Colors.grey[50], // Slightly off-white background
      appBar: AppBar(
        title: const Text(
          'History',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.grey[50],
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildFilterChips(viewModel),
          Expanded(
            child: viewModel.isLoading && allOrders.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : viewModel.error != null && allOrders.isEmpty
                ? Center(
                    child: Text(
                      viewModel.error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                : orders.isEmpty
                ? RefreshIndicator(
                    onRefresh: () =>
                        context.read<HistoryViewModel>().fetchOrders(),
                    color: AppColors.primary,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.3,
                        ),
                        const Center(
                          child: Text(
                            'No orders found',
                            style: TextStyle(color: AppColors.textDisabled),
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () =>
                        context.read<HistoryViewModel>().fetchOrders(),
                    color: AppColors.primary,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        final shortId = order.id.length > 4
                            ? order.id.substring(order.id.length - 4)
                            : order.id;

                        final totalItems = order.orderItems.fold<int>(
                          0,
                          (prev, item) => prev + item.quantity,
                        );
                        final itemText = totalItems == 1
                            ? '1 item'
                            : '$totalItems items';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16.0),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      AppText.bodySmall(
                                        'Order No. : ',
                                        color: AppColors.accent,
                                        fontSize: 10,
                                      ),
                                      Text(
                                        '#$shortId',
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(order.status),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _capitalize(order.status),
                                      style: TextStyle(
                                        color: _getStatusTextColor(
                                          order.status,
                                        ),
                                        fontWeight: FontWeight.w500,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  AppText.bodySmall(
                                    'Order Date : ',
                                    color: AppColors.accent,
                                    fontSize: 10,
                                  ),
                                  Text(
                                    _formatDate(order.createdAt),
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                              // const SizedBox(height: 16),
                              Divider(),
                              Row(
                                children: [
                                  _buildStackedImages(order),
                                  const SizedBox(width: 16),
                                  Text(
                                    itemText,
                                    style: TextStyle(
                                      color: AppColors.accent,
                                      fontSize: 10,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '\$${order.total}',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
