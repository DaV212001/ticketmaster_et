import 'package:get/get.dart';

import '../constants/app_constants.dart';
import '../functions/functions.dart';
import '../models/newmodels.dart';

class HomeController extends GetxController {
  var ep = <Organizer>[].obs;
  var categories = <Category>[].obs;
  var events = <Event>[].obs;
  var popularevents = <Event>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    updateCategories();
  }

  void updateCategories() async {
    isLoading.value = true;
    var languageCode = Get.locale?.languageCode ?? 'en';

    categories.value = await getCategorySubCategory(languageCode);
    events.value = await getEvents('$apiUrl/event', languageCode);
    ep.value = [];

    popularevents.value = events.where((eve) => eve.isPopular == '1').toList();
    isLoading.value = false;
  }
}
