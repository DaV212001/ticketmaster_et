import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:ticketmaster_et/models/newmodels.dart';

import '../../../functions/functions.dart';
import '../../../models/review.dart';
import 'package:http/http.dart' as http;

import '../../../provider/loginpersistence.dart';

class OrganizerReview extends StatefulWidget {
  final Organizer organizer;
  OrganizerReview({super.key,
    required this.organizer
  });

  @override
  State<OrganizerReview> createState() => _OrganizerReviewState();
}

class _OrganizerReviewState extends State<OrganizerReview> {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final commentController = TextEditingController();
  int ratingController = 1;
  bool _isLoading = false;
  Future<http.Response> reviewByOrganizer(int? organizerId, String star, String comment) async {
    print("reviewByOrganizer");
    final loginDataProvider = Provider.of<LoginDataProvider>(context, listen: false);
    List<Review> tickets = [];

    // String? user_id = int.parse(loginDataProvider.loginData!.id);
    print(loginDataProvider.loginData!.id);
    print(star);
    print(organizerId);
    print(comment);
    String organizer_id = organizerId.toString();
    Map<String, dynamic> jsonData ={
      "user_id": loginDataProvider.loginData!.id,
      "sub_category_id":null,
      "category_id":null,
      "event_id": null,
      "organizer_id":organizer_id,
      "star": star,
      "comment": comment,
    };
    // user_id, sub_category_id, category_id, event_id , organizer_id ,star ,comment ]
    String sub_category_id= widget.organizer.id.toString();
    print(sub_category_id);
    String requestBody = jsonEncode(jsonData);
    var response;
    try {
      print("jsonData $jsonData");
      print("requestBody $requestBody");
      response = http.post(
          Uri.parse("https://api.ticketmaster-et.com/api/review"),
          body: requestBody,
          headers: {
            "Content-type": "application/json",
          }
      );
      print("Posted");
    } catch(e) {
      print("Error in getReviewByOrganizer $e");
    }


    return response;
  }
  List<Review> reviews = [];
  Future<void> getReviewByOrganizer(String id) async {
    List<Review> review = [];

    print("getReviewByOrganizer");
    try {
      var res = await retryOptions.retry(
            () => http.get(Uri.parse("https://api.ticketmaster-et.com/api/review-by-organizer/${int.parse(id)}")),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      print("getReviewByOrganizer ${res.body}");
      var data = jsonDecode(res.body);
      if (data['message'] == 'Review By selected Organizer get successfully') {
        var eventsData = data['data'] as List;
        review = eventsData.map((eventData) => Review.fromOrganizerJson(eventData)).toList();
      } else {
        throw Exception('Unexpected message from API: ${data['message']}');
      }
      setState(() {
        reviews = review;
        print(reviews);
        print(reviews[0].comment);
        // print(reviews[1].comment);
      });
    }catch(e){
      print("getReviewByOrganizer = $e");
    }finally {
      client.close();
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    print("Initstate");
    getReviewByOrganizer(widget.organizer.id!.toString());
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: ListView(
          scrollDirection: Axis.vertical,
          children:[
            Row(
              children: [
                Text(
                    tr("give_a_review"),
                    style: TextStyle(
                      fontSize: 15,
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
            Text(
                tr("give_a_comment"),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                )
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
            _isLoading? Center(child: CircularProgressIndicator(),)
                : OutlinedButton(
                style: const ButtonStyle(
                    backgroundColor:
                    MaterialStatePropertyAll(Colors.green),
                    foregroundColor:
                    MaterialStatePropertyAll(Colors.white),
                    minimumSize: MaterialStatePropertyAll(
                        Size(double.infinity, 50))),
                onPressed: () async{
                  setState(() {
                    _isLoading = true;
                  });
                  print("valid");
                  // final review = Review(
                  //
                  // );
                  print("star = ${ratingController}");
                  print("star = ${commentController.text}");
                  var response =
                  await reviewByOrganizer(
                      widget.organizer.id,
                      ratingController.toString(),
                      commentController.text
                  );
                  print("back");
                  print(response);
                  print(response.statusCode);
                  if(response.statusCode == 201){
                    print(response.statusCode);
                    print(response.body);
                    print("Review Added");
                    setState(() {
                      _isLoading = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(tr("thank_you_for_adding_a_review")),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }else{
                    setState(() {
                      _isLoading = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(tr("failed_to_add_review")),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                  // if(response.body != null){
                  //   print(response.body);
                  // }
                  setState(() {
                    commentController.text = '';
                    ratingController = 1;
                  });
                  getReviewByOrganizer(widget.organizer.id!.toString());
                  print("Back");


                },
                child: Text(
                  tr("add_review"),
                  style: TextStyle(fontSize: 18),
                )),
            SizedBox(
                height: 5
            ),
            ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children:[
                    Container(
                        child: index == 0? Text(
                            tr("other_reviews"),
                            style:  const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            )
                        ):SizedBox(height: 0,)
                    ),
                    const SizedBox(
                      height: 5,
                    ),

                    const Divider(
                      height: 2,
                      thickness: 2,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    RatingBar.builder(
                        ignoreGestures: true,
                        itemSize: 15,
                        initialRating: double.parse(reviews[index].star.toString()),
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                        itemBuilder: (context, _) => Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (value){

                        }
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                        reviews[index].comment ==null ||
                            reviews[index].comment == ''? '' : reviews[index].comment.toString(),
                        style: TextStyle(
                          fontSize: 15,
                        )
                    ),

                  ],
                );
              },
            )
          ]
      ),
    );
  }

}
