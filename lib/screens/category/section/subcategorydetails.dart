import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ticketmaster_et/models/newmodels.dart';
import 'package:ticketmaster_et/screens/category/component/tab_bar_views.dart';



class SubCatDetail extends StatefulWidget {
  const SubCatDetail({required this.subCategory, super.key});
  final SubCategory subCategory;
  @override
  State<SubCatDetail> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<SubCatDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(80.0),
          child: AppBar(
            leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: (){
              Navigator.pop(context);
            },color: Colors.green),
            automaticallyImplyLeading: false,
            leadingWidth: 40,
            systemOverlayStyle: const SystemUiOverlayStyle(
                statusBarColor: Colors.white,
                statusBarIconBrightness: Brightness.dark),
            elevation: 0,
            backgroundColor: Colors.white,
            title: Center(
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(10)),
                padding:
                const EdgeInsets.only(left: 8, top: 0, right: 8, bottom: 0),
                child: Text(widget.subCategory.name!,
                    style: TextStyle(
                      color: Color(0xFF00A600),
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    )),
              ),
            ),
          ),
        ),
        body: TabBarAndTabViews(subCategories: widget.subCategory));
  }
}

// class FavoritesScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//       body: Center(child: Text('Favorites Screen')),
//     );
//   }
// }

class InfoCard extends StatelessWidget {
  final String title;
  final String body;
  final Function() onMoreTap;

  final String subInfoTitle;
  final String subInfoText;
  final Widget subIcon;

  const InfoCard(
      {required this.title,
        this.body = """Delivery boy departed at 20:00""",
        required this.onMoreTap,
        this.subIcon = const CircleAvatar(
          child: Icon(
            Icons.payment,
            color: Colors.white,
          ),
          backgroundColor: Colors.cyanAccent,
          radius: 25,
        ),
        this.subInfoText = "ETB 545",
        this.subInfoTitle = "Fee",
        Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(25.0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.05),
                offset: const Offset(0, 10),
                blurRadius: 0,
                spreadRadius: 0,
              )
            ],
            gradient: const RadialGradient(
              colors: [Colors.cyanAccent, Color(0xFF3AE0C4)],
              focal: Alignment.topCenter,
              radius: .85,
            )),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                    fontSize: 26,
                    fontFamily: 'Oswald',
                  ),
                ),
                Container(
                  width: 75,
                  height: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100.0),
                    gradient: const LinearGradient(
                        colors: [Colors.white, Colors.white],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter),
                  ),
                  child: GestureDetector(
                    onTap: onMoreTap,
                    child: const Center(
                        child: Text(
                          "Cancel",
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w400,
                              fontFamily: 'Oswald'),
                        )),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              body,
              style: TextStyle(
                color: Colors.black.withOpacity(.75),
                fontSize: 17,
                fontWeight: FontWeight.w400,
                fontFamily: 'Oswald',
              ),
            ),
            const SizedBox(height: 15),
            Container(
              width: double.infinity,
              height: 75,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25.0),
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    subIcon,
                    const SizedBox(width: 10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(subInfoTitle),
                        Text(
                          subInfoText,
                          style: const TextStyle(
                            color: Colors.cyanAccent,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}


