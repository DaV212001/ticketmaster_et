import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticketmaster_et/models/newmodels.dart';

class ProductCheckOutCard extends StatelessWidget {
  const ProductCheckOutCard({
    super.key,
    required this.product,
  });

  final FoodPortions product;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${product.name}",
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              // if (product.addons != null && product.addons!.isNotEmpty)
              // Column(
              //   crossAxisAlignment: CrossAxisAlignment.start,
              //   children: product.addons!
              //       .where(
              //           (addon) => addon.amount != null && addon.amount! > 0)
              //       .map(
              //         (addon) => AutoSizeText(
              //       "${addon.name} (x${addon.amount}) - ${addon.price! * (addon.amount ?? 1)} Birr",
              //       maxLines: 1,
              //       minFontSize: 9,
              //       maxFontSize: 12,
              //       stepGranularity: 0.5,
              //       overflow: TextOverflow.visible,
              //       style: TextStyle(
              //           color: maincolor, fontWeight: FontWeight.w600),
              //     ),
              //   )
              //       .toList(),
              // ),
            ],
          ),
        ),
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
          'price'.trParams({'pr': (product.price ?? 0).toStringAsFixed(2)}),
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
