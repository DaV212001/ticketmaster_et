
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../models/review.dart';
class OtherReviews extends StatefulWidget {

  OtherReviews({super.key});

  @override
  State<OtherReviews> createState() => _OtherReviewsState();
}

class _OtherReviewsState extends State<OtherReviews> {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final commentController = TextEditingController();
  int ratingController = 1;

  @override
  Widget build(BuildContext context) {
    return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: ListView.builder(
            itemCount: 5,
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemBuilder: (context, index) {
              return ListView(
                shrinkWrap: true,
                children: [
                  Row(
                    children: [
                      Text(
                          "Review",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          )
                      ),
                      RatingBar.builder(
                        itemSize: 20,
                        initialRating: 3,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                        itemBuilder: (context, _) => Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (rating) {
                          print(rating);
                          setState(() {
                            ratingController = rating.round();
                          });
                          print("ratingController = $ratingController");
                        },
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 16.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        color: Colors.grey[200], // Background color
                      ),
                      child:Text("Other Comment")
                  )
                ],
              );
          },)
        );
  }

}