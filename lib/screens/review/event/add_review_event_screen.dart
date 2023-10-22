
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:ticketmaster_et/models/newmodels.dart';
import 'package:ticketmaster_et/screens/review/see_other_review.dart';

import '../../../models/review.dart';
class EventReview extends StatefulWidget {
  int? subCategory_id;
  int? category_id;
  int? event_id;
  int? organizer_id;
  EventReview({super.key,
    required this.subCategory_id,
    required this.category_id,
    required this.event_id,
    required this.organizer_id,

  });

  @override
  State<EventReview> createState() => _EventReviewState();
}

class _EventReviewState extends State<EventReview> {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final commentController = TextEditingController();
  int ratingController = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
          children:[
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
              child: TextFormField(
                maxLines: 10,
                minLines: 3,
                keyboardType: TextInputType.name,
                controller: commentController,
                textAlignVertical: TextAlignVertical.top,
                key: const ValueKey("comment"),
                validator: (value) {

                },
                onSaved: (newValue) {
                },
                onChanged: (value) {
                },
                decoration: const InputDecoration(
                  hintText: "Comment",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16.0),
                ),
              ),
            ), SizedBox(
              height: 10,
            ),
            OutlinedButton(
                style: const ButtonStyle(
                    backgroundColor:
                    MaterialStatePropertyAll(Colors.green),
                    foregroundColor:
                    MaterialStatePropertyAll(Colors.white),
                    minimumSize: MaterialStatePropertyAll(
                        Size(double.infinity, 50))),
                onPressed: () async{
                  if (formKey.currentState!.validate()) {
                    // final review = Review(
                    //
                    // );
                    print("star = ${ratingController}");
                    print("star = ${commentController.text}");
                    print("Review Added");
                  }
                },
                child: Text(
                  "Add Reivew",
                  style: TextStyle(fontSize: 10),
                )),
            ListView.builder(
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return Column(
                  children:[
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
              },
            )
          ]
      ),
    );
  }

}

/*
* ,
                    OtherReviews()
* */