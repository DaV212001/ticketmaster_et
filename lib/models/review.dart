class Review{
  String? user_id;
  String? sub_category_id;
  String? category_id;
  String? event_id;
  String? organizer_id;
  String? star;
  String? comment;
  Review(
  {
    required this.user_id,
    required this.star,
    this.sub_category_id,
    this.category_id,
    this.event_id,
    this.organizer_id,
    this.comment
});
  Map<String, dynamic> toJson() {
    return {
      'user_id': user_id,
      'sub_category_id': sub_category_id,
      'category_id': category_id,
      'event_id': event_id,
      'organizer_id': organizer_id,
      'star': star,
      'comment': comment
    };
  }



  Review.fromEventJson(Map<String, dynamic> json){
    user_id = json['user_id'];
    event_id = json['event_id'];
    star = json['star'];
    comment = json['comment'];
  }



  Review.fromSubCategoryJson(Map<String, dynamic> json){
    print("fromSubCategoryJson $json");
    user_id = json['user_id'];
    sub_category_id = json['sub_category_id'];
    star = json['star'];
    comment = json['comment'];
  }

  Review.fromOrganizerJson(Map<String, dynamic> json){
    user_id = json['user_id'];
    organizer_id = json['organizer_id'];
    star = json['star'];
    comment = json['comment'];
  }



}