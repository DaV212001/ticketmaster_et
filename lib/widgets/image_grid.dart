import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../models/newmodels.dart';
import '../utils/cached_image_widget_wrapper.dart';

class OrderImageGrid extends StatelessWidget {
  final List<OrderItem> items;

  const OrderImageGrid({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return _buildGrid(context);
  }

  Widget _buildGrid(BuildContext context) {
    final itemCount = items.length;

    if (itemCount == 0) {
      return const Center(child: Text("No items"));
    }

    // Sort or prioritize first item if you want (optional)
    List<OrderItem> sortedItems = List.from(items);

    if (itemCount == 1) {
      return Row(
        children: [
          Expanded(child: _buildImageTile(sortedItems[0])),
        ],
      );
    } else if (itemCount == 2) {
      return Row(
        children: [
          Expanded(child: _buildImageTile(sortedItems[0])),
          Expanded(child: _buildImageTile(sortedItems[1])),
        ],
      );
    } else if (itemCount == 3) {
      return Row(
        children: [
          Expanded(child: _buildImageTile(sortedItems[0])),
          Expanded(
            child: Column(
              children: [
                Expanded(flex: 2, child: _buildImageTile(sortedItems[1])),
                Expanded(flex: 2, child: _buildImageTile(sortedItems[2])),
              ],
            ),
          ),
        ],
      );
    } else {
      // 4 or more
      return Row(
        children: [
          Expanded(child: _buildImageTile(sortedItems[0])),
          Expanded(
            child: Column(
              children: [
                Expanded(flex: 2, child: _buildImageTile(sortedItems[1])),
                Expanded(flex: 2, child: _buildImageTile(sortedItems[2])),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).primaryColor.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(7),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.3),
                          spreadRadius: 1,
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '+${itemCount - 3} more ${(itemCount - 3) > 1 ? 'items' : 'item'}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
  }

  Widget _buildImageTile(OrderItem item) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Stack(
        children: [
          cachedNetworkImageWrapper(
            imageUrl:
                item.image != null && item.image!.isNotEmpty ? item.image! : '',
            imageBuilder: (context, imageProvider) => Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: Image.network(
                  item.image!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
            placeholderBuilder: (context, path) => Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7),
                color: Colors.grey.withValues(alpha: 0.2),
              ),
              child: const CircularProgressIndicator(),
            ),
            errorWidgetBuilder: (context, path, obj) => Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: Image.asset(
                  'assets/images/logo.png', // fallback
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.3),
                  Colors.black.withValues(alpha: 0.8),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoSizeText(
                  item.foodName ?? "Unnamed",
                  maxLines: 1,
                  minFontSize: 6,
                  maxFontSize: 15,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                AutoSizeText(
                  "${item.price ?? '0'} ETB",
                  maxLines: 1,
                  minFontSize: 6,
                  maxFontSize: 10,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
