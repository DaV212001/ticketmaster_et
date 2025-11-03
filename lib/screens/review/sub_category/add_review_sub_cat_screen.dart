import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ticketmaster_et/models/newmodels.dart';

import '../../../functions/functions.dart';
import '../../../models/review.dart';
import '../../../provider/loginpersistence.dart';

class FoodReview extends StatefulWidget {
  final Food food;
  const FoodReview({super.key, required this.food});

  @override
  State<FoodReview> createState() => _FoodReviewState();
}

class _FoodReviewState extends State<FoodReview> {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final commentController = TextEditingController();
  int ratingController = 1;
  bool _isLoading = false;
  Future<http.Response> reviewBySubCategory(
      int? categoryId, int? foodId, String star, String comment) async {
    // print("reviewBySubCategory");
    final loginDataProvider = Get.find<LoginDataProvider>(tag: 'login');
    // List<Review> tickets = [];

    // String? user_id = int.parse(loginDataProvider.loginData!.id);
    // print(loginDataProvider.loginData!.id);
    // print(foodId);
    // print(categoryId);
    // print(star);
    // print(comment);
    // String category_id = categoryId.toString();
    String foodIdString = foodId.toString();
    // user_id, sub_category_id, category_id, event_id , organizer_id ,star ,comment
    Map<String, dynamic> jsonData = {
      "user_id": loginDataProvider.loginData!.id,
      "food_id": foodIdString,
      // "category_id": category_id,
      // "event_id": null,
      // "organizer_id": null,
      "star": star,
      "comment": comment,
    };
    String sub_category_id = foodId.toString();
    // print(sub_category_id);
    String requestBody = jsonEncode(jsonData);
    var response;
    try {
      // print("jsonData $jsonData");
      // print("requestBody $requestBody");
      response = http
          .post(Uri.parse("${baseUrlFunc}review"), body: requestBody, headers: {
        "Content-type": "application/json",
      });
      print("Posted");
    } catch (e) {
      print("Error in reviewBySubCategory $e");
    }

    return response;
  }

  List<Review> reviews = [];
  Future<void> getReviewBySubCategory(String id) async {
    List<Review> review = [];

    print("getReviewBySubCategory: ${baseUrlFunc}review/${int.parse(id)}");
    try {
      var res = await retryOptions.retry(
        () => http.get(Uri.parse("${baseUrlFunc}review/${int.parse(id)}")),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      print("getReviewBySubCategory ${res.body}");
      var data = jsonDecode(res.body);
      if (data['message'] == 'Review get successfully') {
        var eventsData = data['data'] as List;
        review = eventsData
            .map((eventData) => Review.fromSubCategoryJson(eventData))
            .toList();
      } else {
        if (data['mesage'] == 'No Review found') {
          return;
        }
        throw Exception('Unexpected message from API: ${data['message']}');
      }
    } finally {
      client.close();
    }
    setState(() {
      reviews = review;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    print("Initstate");
    getReviewBySubCategory(widget.food.id!.toString());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: ListView(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Text("give_a_review".tr,
                //     style: const TextStyle(
                //       fontSize: 15,
                //       fontWeight: FontWeight.bold,
                //     )),
                RatingBar.builder(
                  itemSize: 30,
                  initialRating: widget.food.rating ?? 3.5,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => const Icon(
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
            const SizedBox(
              height: 10,
            ),
            // Text("give_a_comment".tr,
            //     style: const TextStyle(
            //       fontSize: 15,
            //       fontWeight: FontWeight.bold,
            //     )),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                  return null;
                },
                onSaved: (newValue) {},
                onChanged: (value) {},
                decoration: const InputDecoration(
                  hintText: "Comment",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16.0),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : OutlinedButton(
                    style: const ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Colors.green),
                        foregroundColor: WidgetStatePropertyAll(Colors.white),
                        minimumSize:
                            WidgetStatePropertyAll(Size(double.infinity, 50))),
                    onPressed: () async {
                      setState(() {
                        _isLoading = true;
                      });
                      print("valid");
                      // final review = Review(
                      //
                      // );
                      print("star = $ratingController");
                      print("star = ${commentController.text}");
                      var response = await reviewBySubCategory(
                          widget.food.categoryId,
                          widget.food.id,
                          ratingController.toString(),
                          commentController.text);
                      print("back");
                      print(response);
                      print(response.statusCode);
                      if (response.statusCode == 201) {
                        print(response.statusCode);
                        print(response.body);
                        print("Review Added");
                        setState(() {
                          _isLoading = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("thank_you_for_adding_a_review".tr),
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      } else {
                        setState(() {
                          _isLoading = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("failed_to_add_review".tr),
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 3),
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
                      getReviewBySubCategory(widget.food.id!.toString());
                      print("Back");
                    },
                    child: Text(
                      "add_review".tr,
                      style: const TextStyle(fontSize: 18),
                    )),
            // const SizedBox(height: 5),
            // ListView.builder(
            //   scrollDirection: Axis.vertical,
            //   physics: const BouncingScrollPhysics(),
            //   shrinkWrap: true,
            //   itemCount: reviews.length,
            //   itemBuilder: (context, index) {
            //     return Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       mainAxisAlignment: MainAxisAlignment.start,
            //       children: [
            //         Container(
            //             child: index == 0
            //                 ? Text("other_reviews".tr,
            //                     style: const TextStyle(
            //                       fontSize: 16,
            //                       fontWeight: FontWeight.bold,
            //                     ))
            //                 : const SizedBox(
            //                     height: 0,
            //                   )),
            //         const SizedBox(
            //           height: 5,
            //         ),
            //         const Divider(
            //           height: 2,
            //           thickness: 2,
            //         ),
            //         const SizedBox(
            //           height: 5,
            //         ),
            //         RatingBar.builder(
            //             ignoreGestures: true,
            //             itemSize: 15,
            //             initialRating:
            //                 double.parse(reviews[index].star.toString()),
            //             minRating: 1,
            //             direction: Axis.horizontal,
            //             allowHalfRating: true,
            //             itemCount: 5,
            //             itemPadding:
            //                 const EdgeInsets.symmetric(horizontal: 4.0),
            //             itemBuilder: (context, _) => const Icon(
            //                   Icons.star,
            //                   color: Colors.amber,
            //                 ),
            //             onRatingUpdate: (value) {}),
            //         const SizedBox(
            //           height: 5,
            //         ),
            //         Text(
            //             reviews[index].comment == null ||
            //                     reviews[index].comment == ''
            //                 ? ''
            //                 : reviews[index].comment.toString(),
            //             style: const TextStyle(
            //               fontSize: 15,
            //             )),
            //       ],
            //     );
            //   },
            // )
          ]),
    );
  }
}
