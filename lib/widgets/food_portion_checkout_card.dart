import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ticketmaster_et/models/newmodels.dart';

class ProductCheckOutCard extends StatelessWidget {
  const ProductCheckOutCard({
    super.key,
    required this.product,
  });

  final Food product;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 10,
        ),
        AutoSizeText(
          'amount'.trParams({'am': (product.amount ?? 1).toStringAsFixed(2)}),
          maxLines: 1,
          minFontSize: 9,
          maxFontSize: 12,
          stepGranularity: 0.5,
          overflow: TextOverflow.visible,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        AutoSizeText(
          'price'.trParams(
              {'pr': NumberFormat('#,##0.00').format((product.price ?? 0))}),
          maxLines: 1,
          minFontSize: 9,
          maxFontSize: 12,
          stepGranularity: 0.5,
          overflow: TextOverflow.visible,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        // if (product.addons != null &&
        //     product.addons!.isNotEmpty &&
        //     product.addonsTotalPrice() != '0.00')
        //   AutoSizeText(
        //     "Add-ons price: ${product.addonsTotalPrice()} Birr",
        //     maxLines: 1,
        //     minFontSize: 9,
        //     maxFontSize: 12,
        //     stepGranularity: 0.5,
        //     overflow: TextOverflow.visible,
        //     style: const TextStyle(fontWeight: FontWeight.w600),
        //   ),
        AutoSizeText(
          "sub_total".trParams({'subtotal': product.totalPrice()}),
          maxLines: 1,
          minFontSize: 9,
          maxFontSize: 12,
          stepGranularity: 0.5,
          overflow: TextOverflow.visible,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        Divider(
          color: Theme.of(context).primaryColor,
        )
      ],
    );
  }
}
