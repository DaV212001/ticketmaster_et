class WorkTime {
  final int dayNum;
  final String fromTime;
  final String toTime;

  WorkTime({
    required this.dayNum,
    required this.fromTime,
    required this.toTime,
  });

  factory WorkTime.fromJson(Map<String, dynamic> json) {
    return WorkTime(
      dayNum: int.parse(json['day_num'].toString()),
      fromTime: json['from_time'],
      toTime: json['to_time'],
    );
  }
}
