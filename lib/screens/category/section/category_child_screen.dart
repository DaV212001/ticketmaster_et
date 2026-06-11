import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticketmaster_et/models/newmodels.dart';

import '../../../controllers/time_controller.dart';
import '../../../prefs/routes.dart';

class CategoryChild extends StatefulWidget {
  const CategoryChild({required this.subCategories, super.key});
  final List<Food> subCategories;
  // final ValueNotifier<int> selectedIndex;

  @override
  State<CategoryChild> createState() => _CategoryChildState();
}

class _CategoryChildState extends State<CategoryChild> {
  @override
  Widget build(BuildContext context) {
    if (widget.subCategories.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 50.0),
        child: SizedBox(
          height: 200,
          child: CarouselSlider.builder(
            options: CarouselOptions(
              disableCenter: true,
              viewportFraction: 0.8,
              enlargeCenterPage: true,
              autoPlay: true,
            ),
            itemBuilder: (BuildContext context, int index, pageViewIndex) =>
                GestureDetector(
              onTap: () {
                if (Get.find<TimeController>(tag: TimeController.tag)
                    .closedHours
                    .value) {
                  return;
                }
                Get.toNamed(Routes.foodDetailRoute,
                    arguments: {'id': widget.subCategories[index].id!});
                // Navigator.push(context, MaterialPageRoute(builder: (context) {
                //   return SubCatDetail(
                //     id: widget.subCategories[index].id!,
                //   );
                // }));
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: CachedNetworkImage(
                  height: 100,
                  fadeOutDuration: const Duration(milliseconds: 300),
                  fadeOutCurve: Curves.easeOut,
                  fadeInDuration: const Duration(milliseconds: 700),
                  fadeInCurve: Curves.easeIn,
                  imageUrl: widget.subCategories[index].image!.trim() ==
                              'https://admin.ticketmaster-et.com/public/storage' ||
                          widget.subCategories[index].image!.trim() ==
                              'https://admin.ticketmaster-et.com/public/storage/%5Bvalue-2%5D' ||
                          widget.subCategories[index].image!.trim() ==
                              'https://admin.ticketmaster-et.com/public/storage/aaa' ||
                          widget.subCategories[index].image!.trim() ==
                              'https://admin.ticketmaster-et.com/public/storage/' ||
                          widget.subCategories[index].image!.trim() ==
                              'https://admin.ticketmaster-et.com/public/storage/[value-2]'
                      ? 'https://i.postimg.cc/9FkTYfDq/THICKET-MASTER-LOGO.jpg'
                      : widget.subCategories[index].image!.trim(),
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            itemCount: widget.subCategories.length,
          ),
        ),
      );
    } else {
      return Center(
          child: Container(
        height: 200,
        width: 200,
        child: Image.network(
            'https://i.postimg.cc/9FkTYfDq/THICKET-MASTER-LOGO.jpg'),
      ));
    }
  }
}
