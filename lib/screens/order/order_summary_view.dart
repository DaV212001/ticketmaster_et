import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../models/newmodels.dart';
import '../../utils/cached_image_widget_wrapper.dart';

class OrderSummary extends StatelessWidget {
  const OrderSummary({
    super.key,
    required this.orderItems,
  });

  final List<OrderItem> orderItems;

  @override
  Widget build(BuildContext context) {
    var maincolor = Theme.of(context).primaryColor;

    // Group order items by date
    final Map<String, List<OrderItem>> groupedOrders = {};
    for (final item in orderItems) {
      final dateKey = item.foodName ?? 'No Date';
      if (!groupedOrders.containsKey(dateKey)) {
        groupedOrders[dateKey] = [];
      }
      groupedOrders[dateKey]!.add(item);
    }

    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
      child: ListView.builder(
        itemCount: groupedOrders.keys.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, dateIndex) {
          String dateKey = groupedOrders.keys.elementAt(dateIndex);
          List<OrderItem> dateOrders = groupedOrders[dateKey]!;

          // Calculate total for this date group
          double dateTotalPrice = dateOrders.fold(
              0, (sum, item) => sum + double.parse(item.price ?? '0'));

          int dateTotalQuantity =
              dateOrders.fold(0, (sum, item) => sum + (item.quantity ?? 0));

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Theme(
              data:
                  Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ListTile(
                tileColor: maincolor.withValues(alpha: 0.2),
                // expandedCrossAxisAlignment: CrossAxisAlignment.start,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                  // side: BorderSide(color: maincolor),
                ),
                // collapsedBackgroundColor: maincolor.withValues(alpha: 0.2),
                // collapsedShape: RoundedRectangleBorder(
                //   borderRadius: BorderRadius.circular(7),
                // ),
                // initiallyExpanded: false,
                // childrenPadding:
                //     const EdgeInsets.only(left: 16.0, bottom: 16.0),
                leading: _buildDateLeading(dateOrders.first, maincolor),
                title: Text(
                  _formatDateTitle(dateKey),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: maincolor,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "total_birr".trParams(
                          {'total': dateTotalPrice.toStringAsFixed(2)}),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (dateOrders.isNotEmpty)
                      Text(
                        "$dateTotalQuantity ${dateTotalQuantity == 1 ? 'piece'.tr : 'pieces'.tr}",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
                // children: [
                //   Divider(color: maincolor),
                //   Padding(
                //     padding: const EdgeInsets.symmetric(horizontal: 16.0),
                //     child: ListView.builder(
                //       shrinkWrap: true,
                //       physics: const NeverScrollableScrollPhysics(),
                //       itemCount: dateOrders.length,
                //       itemBuilder: (context, index) {
                //         OrderItem orderItem = dateOrders[index];
                //         return OrderItemCard(orderItem: orderItem);
                //       },
                //     ),
                //   ),
                // ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateLeading(OrderItem firstItem, Color maincolor) {
    return cachedNetworkImageWrapper(
      imageUrl: firstItem.image ?? '',
      imageBuilder: (context, imageProvider) => Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: maincolor.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: Image.network(
            firstItem.image ?? '',
            fit: BoxFit.cover,
          ),
        ),
      ),
      placeholderBuilder: (context, path) => Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: const SizedBox(
            height: 40,
            width: 40,
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      errorWidgetBuilder: (context, path, object) => Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: maincolor,
          shape: BoxShape.circle,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: Image.asset(
            'assets/images/logo.png',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  String _formatDateTitle(String dateKey) {
    if (dateKey == 'No Date') return 'No Date';

    try {
      final date = DateTime.parse(dateKey);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateKey;
    }
  }
}

// Example OrderItemCard widget (you'll need to implement this based on your design)
class OrderItemCard extends StatelessWidget {
  const OrderItemCard({
    super.key,
    required this.orderItem,
  });

  final OrderItem orderItem;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('${orderItem.price} ${"etb".tr}',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Container(
              height: 5,
              width: 5,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Colors.grey),
            ),
          ),
          Row(
            children: [
              Text('${orderItem.rating}'),
              const Icon(
                Icons.star,
                color: Colors.amber,
                size: 20.0,
              )
            ],
          ),
        ],
      ),
      trailing: Text(
        orderItem.orderDate != null
            ? DateFormat('HH:mm').format(orderItem.orderDate!)
            : '',
      ),
    );
  }
}
