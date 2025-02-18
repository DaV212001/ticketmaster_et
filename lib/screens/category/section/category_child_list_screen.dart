import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ticketmaster_et/models/newmodels.dart';
import 'package:ticketmaster_et/screens/category/section/subcategorydetails.dart';

class CategoryChildList extends StatefulWidget {
  const CategoryChildList(
      {required this.subCategories, super.key, required this.selectedIndex});
  final List<SubCategory> subCategories;
  final ValueNotifier<int> selectedIndex;
  @override
  State<CategoryChildList> createState() => _CategoryChildListState();
}

class _CategoryChildListState extends State<CategoryChildList> {
  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    if (widget.subCategories.isNotEmpty) {
      return ListView.builder(
          controller: scrollController,
          physics: BouncingScrollPhysics(),
          itemCount: widget.subCategories.length,
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return SubCatDetail(
                    id: widget.subCategories[index].id!,
                  );
                }));
              },
              child: Container(
                color: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 8.0,
                    bottom: 3.0,
                    left: 10,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: SizedBox(
                              width: 70,
                              height: 70,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: CachedNetworkImage(
                                  fadeOutDuration:
                                      const Duration(milliseconds: 300),
                                  fadeOutCurve: Curves.easeOut,
                                  fadeInDuration:
                                      const Duration(milliseconds: 700),
                                  fadeInCurve: Curves.easeIn,
                                  imageUrl: widget.subCategories[index].image!
                                                  .trim() ==
                                              'https://admin.ticketmaster-et.com/public/storage' ||
                                          widget.subCategories[index].image!
                                                  .trim() ==
                                              'https://admin.ticketmaster-et.com/public/storage/%5Bvalue-2%5D' ||
                                          widget.subCategories[index].image!
                                                  .trim() ==
                                              'https://admin.ticketmaster-et.com/public/storage/aaa' ||
                                          widget.subCategories[index].image!
                                                  .trim() ==
                                              'https://admin.ticketmaster-et.com/public/storage/' ||
                                          widget.subCategories[index].image!
                                                  .trim() ==
                                              'https://admin.ticketmaster-et.com/public/storage/[value-2]'
                                      ? 'https://i.postimg.cc/4dyhqLLY/THICKET-MASTER-LOGO.png'
                                      : widget.subCategories[index].image!
                                          .trim(),
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
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
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.subCategories[index].name!,
                                  style: const TextStyle(
                                      fontFamily: 'PoppinsSB',
                                      fontSize: 15,
                                      overflow: TextOverflow.ellipsis),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      const Divider(
                        color: Colors.white54,
                        thickness: 1,
                        endIndent: 20,
                        indent: 10,
                      ),
                    ],
                  ),
                ),
              ),
            );
          });
    } else {
      return Center(
          child: Container(
        height: 200,
        width: 200,
        child: Image.network(
            'https://i.postimg.cc/4dyhqLLY/THICKET-MASTER-LOGO.png'),
      ));
    }
  }
}
