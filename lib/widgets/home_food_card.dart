import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ticketmaster_et/controllers/time_controller.dart';

import '../models/newmodels.dart';
import '../prefs/routes.dart';
import '../prefs/shimmer_wrapper.dart';
import '../setup_files/wrappers/cached_image_widget_wrapper.dart';

class HomeFoodCard extends StatelessWidget {
  const HomeFoodCard({
    super.key,
    required this.subCategory,
    this.shimmering,
  });

  final Food subCategory;
  final bool? shimmering;

  @override
  Widget build(BuildContext context) {
    var width = 135.0;
    var height = 100.0;
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: GestureDetector(
        onTap: () {
          if (Get.find<TimeController>(tag: TimeController.tag)
              .closedHours
              .value) {
            return;
          }
          Get.toNamed(Routes.foodDetailRoute,
              arguments: {'id': subCategory.id!});
        },
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.2),
              spreadRadius: -8,
              blurRadius: 10,
              offset: const Offset(0, 0), // changes position of shadow
            ),
          ]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image stack
              ShimmerWrapper(
                isEnabled: shimmering ?? false,
                child: Stack(
                  children: [
                    Container(
                      width: width,
                      height: height,
                      decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(7),
                            topRight: Radius.circular(7),
                          ),
                          color: Theme.of(context).cardColor),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(7),
                          topRight: Radius.circular(7),
                        ),
                        child: SizedBox(
                          width: width,
                          height: height,
                          child: cachedNetworkImageWrapper(
                            imageUrl: subCategory.image!.trim(),
                            imageBuilder: (context, imageProvider) => Image(
                              image: imageProvider,
                              fit: BoxFit.cover,
                              width: width,
                              height: height,
                            ),
                            placeholderBuilder: (context, path) => Container(
                              width: width,
                              height: height,
                              alignment: Alignment.center,
                              child: const SizedBox(
                                height: 40,
                                width: 40,
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidgetBuilder: (context, path, object) =>
                                Container(
                              width: width,
                              height: height,
                              child: Image.asset(
                                'assets/images/na_logo.jpg',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (shimmering != true)
                      Obx(() =>
                          Get.find<TimeController>(tag: TimeController.tag)
                                  .closedHours
                                  .value
                              ? Positioned(
                                  child: Container(
                                    height: height,
                                    width: width,
                                    decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(7),
                                          topRight: Radius.circular(7),
                                        ),
                                        color: Colors.black45),
                                    child: const Center(
                                        child: Text(
                                      'Closed',
                                      style: TextStyle(color: Colors.white),
                                    )),
                                  ),
                                )
                              : const SizedBox.shrink()),

                    // Discount badge
                    if (subCategory.isDiscounted == true)
                      Positioned(
                        top: 5,
                        left: 0,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(5),
                              bottomRight: Radius.circular(5),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              '${subCategory.discountPercentage}% Discount',
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.white),
                            ),
                          ),
                        ),
                      ),

                    // Bottom black overlay with name & price
                  ],
                ),
              ),
              Container(
                width: width,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(7),
                    bottomRight: Radius.circular(7),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ShimmerWrapper(
                    isEnabled: shimmering,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4.0, vertical: 2),
                          child: Text(
                            subCategory.name!,
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4.0, vertical: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${NumberFormat('#,##0.00').format(subCategory.price)} ${'etb'.tr}',
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (subCategory.isDiscounted == true)
                                Text(
                                  '${NumberFormat('#,##0.00').format(subCategory.price! + subCategory.price! * (subCategory.discountPercentage! / 100))} ${'etb'.tr}',
                                  style: const TextStyle(
                                      decoration: TextDecoration.lineThrough,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 8),
                                )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
