import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class AdsCarousel extends StatefulWidget {
  // List<Promotions> promotions;
  const AdsCarousel({
    super.key,
  });

  @override
  State<AdsCarousel> createState() => _AdsCarouselState();
}

class _AdsCarouselState extends State<AdsCarousel> {
  @override
  void initState() {
    super.initState;
  }

  final List<String> imgList = [
    'assets/images/carousel/megeb-06.png',
    'assets/images/carousel/screen-04.png',
    'assets/images/carousel/screen-05.png',
  ];
  final CarouselSliderController carouselController =
      CarouselSliderController();
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Column(children: [
      Stack(
        children: [
          CarouselSlider(
            // items: widget.promotions.map((promotion) {
            //   return Builder(
            //     builder: (BuildContext context) {
            //       return Container(
            //         width: MediaQuery.of(context).size.width,
            //         child: CachedImage(
            //           url: promotion.image,
            //           fit: BoxFit.contain,
            //         ),
            //       );
            //     },
            //   );
            // }).toList(),
            items: imgList.map((image) {
              return Builder(builder: (BuildContext context) {
                return SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Image.asset(image, fit: BoxFit.contain),
                );
              });
            }).toList(),
            carouselController: carouselController,
            options: CarouselOptions(
              scrollPhysics: const BouncingScrollPhysics(),
              autoPlay: true,
              aspectRatio:
                  2.5, // TODO Modify this to increase or decrease the height of the promotion carousel
              viewportFraction: 1,
              onPageChanged: (index, reason) {
                setState(() {
                  currentIndex = index;
                });
              },
            ),
          ),
          Positioned(
              bottom: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 17),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: imgList.asMap().entries.map((entry) {
                        return GestureDetector(
                          onTap: () =>
                              carouselController.animateToPage(entry.key),
                          child: Container(
                            width: currentIndex == entry.key ? 17 : 7,
                            height: 7,
                            margin: const EdgeInsets.symmetric(
                              horizontal: 3.0,
                            ),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: currentIndex == entry.key
                                    ? theme.colorScheme.inversePrimary
                                    : theme.colorScheme.primary),
                          ),
                        );
                      }).toList(),
                    )
                  ],
                ),
              ))
        ],
      ),
    ]);
  }
}
