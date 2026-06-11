import 'dart:async';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';

import '../models/work_time.dart';

class TimeController extends GetxController {
  static String tag = 'time_controller';

  final box = GetStorage();

  final closedHours = true.obs;
  final workTimes = <int, WorkTime>{}.obs;

  Timer? _timer;

  static const _cacheKey = 'work_times';

  @override
  void onInit() {
    super.onInit();
    loadWorkTimes();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  var isLoadingWorkTimes = false.obs;
  Future<void> loadWorkTimes() async {
    isLoadingWorkTimes.value = true;
    isLoadingWorkTimes.refresh();
    try {
      final response = await Dio().get(
        'https://api.hellomesa6810.com/api/work-time',
      );

      final List data = response.data['data'];
      Logger().d(data);

      box.write(_cacheKey, data);
      _applyData(data);
    } catch (_) {
      final cachedData = box.read(_cacheKey);
      if (cachedData != null) {
        _applyData(cachedData);
      } else {
        closedHours.value = true;
        closedHours.refresh();
      }
    } finally {
      _checkClosedHours();
      _timer = Timer.periodic(
        const Duration(seconds: 1),
        (_) => _checkClosedHours(),
      );
      isLoadingWorkTimes.value = false;
      isLoadingWorkTimes.refresh();
    }
  }

  void _applyData(List data) {
    workTimes.clear();
    for (final item in data) {
      final wt = WorkTime.fromJson(item);
      workTimes[wt.dayNum] = wt;
    }
  }

  void _checkClosedHours() {
    final now = DateTime.now();
    final today = now.weekday;

    final todayWorkTime = workTimes[today];
    if (todayWorkTime == null) {
      closedHours.value = true;
      return;
    }

    final from = _parseTime(todayWorkTime.fromTime, now);
    final to = _parseTime(todayWorkTime.toTime, now);

    closedHours.value = now.isBefore(from) || now.isAfter(to);
  }

  DateTime _parseTime(String time, DateTime base) {
    final parts = time.split(':');
    return DateTime(
      base.year,
      base.month,
      base.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }
}
