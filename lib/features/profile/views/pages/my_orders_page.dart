import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopsphere/app/theme/app_colors.dart';
import 'package:shopsphere/features/profile/controllers/profile_controllers.dart';
import 'package:shopsphere/features/profile/models/order.dart';
import 'package:shopsphere/features/profile/views/widgets/empty_orders_view.dart';
import 'package:shopsphere/features/profile/views/widgets/order_card.dart';

class MyOrdersPage extends ConsumerStatefulWidget {
  const MyOrdersPage({super.key});

  @override
  ConsumerState<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends ConsumerState<MyOrdersPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allOrders = ref.watch(ordersControllerProvider);
    final activeOrders = ref.watch(activeOrdersProvider);
    final deliveredOrders = ref.watch(deliveredOrdersProvider);
    final cancelledOrders = ref.watch(cancelledOrdersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Orders'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
          tabs: [
            Tab(text: 'All (${allOrders.length})'),
            Tab(text: 'Active (${activeOrders.length})'),
            Tab(text: 'Delivered (${deliveredOrders.length})'),
            Tab(text: 'Cancelled (${cancelledOrders.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrdersList(allOrders, 'No orders found'),
          _buildOrdersList(activeOrders, 'No active orders in transit'),
          _buildOrdersList(deliveredOrders, 'No delivered orders yet'),
          _buildOrdersList(cancelledOrders, 'No cancelled orders'),
        ],
      ),
    );
  }

  Widget _buildOrdersList(List<Order> orders, String emptyMessage) {
    if (orders.isEmpty) {
      return EmptyOrdersView(message: emptyMessage);
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      separatorBuilder: (context, index) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        return OrderCard(order: orders[index]);
      },
    );
  }
}
