import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:ticketmaster_et/controllers/theme_controller.dart';
import 'package:ticketmaster_et/functions/functions.dart';
import 'package:ticketmaster_et/models/newmodels.dart';
import 'package:ticketmaster_et/screens/order/order_summary_view.dart';
import 'package:ticketmaster_et/screens/order/reorder_payment_modal.dart';
import 'package:ticketmaster_et/screens/order/user_orders.dart';

import '../../constants/theme.dart';
import '../../controllers/payment_controller.dart';
import '../../controllers/wallet_controller.dart';
import '../../main_layout_screen.dart';
import '../../prefs/routes.dart';
import '../../provider/loginpersistence.dart';
import '../signup.dart';
import '../wallet/payment_web_view.dart';
import 'order_status_timeline.dart';

class OrderDetailController extends GetxController {
  var isLoading = true.obs;
  var orderItems = <OrderItem>[].obs;

  var onDelivery = false.obs;

  var walletPay = false.obs;

  Map<String, dynamic> convertOrderToJson(Order order) {
    final loginProvider = Get.find<LoginDataProvider>(tag: 'login');
    final customerId = loginProvider.loginData?.id ?? '';

    final items = order.orderItems ?? [];
    final totalPrice = items.fold<double>(
        0.0,
        (sum, item) =>
            sum +
            ((double.tryParse(item.price ?? '0') ?? 0) * (item.quantity ?? 1)));
    final totalQuantity =
        items.fold<int>(0, (sum, item) => sum + (item.quantity ?? 0));

    final uniqueFoods = items.map((e) => e.foodId).toSet().length;

    return {
      "organization_id": int.parse(order.organizationId ?? "0"),
      "customer_id": customerId,
      "meal_type_id": order.mealTypeId ?? '',
      "location": order.location ?? '',
      "date": DateTime.now().toLocal().toString(),
      "payment_type": order.paymentType?.toString() ?? '0',
      "total_quantity": totalQuantity.toString(),
      "total_price": totalPrice.toStringAsFixed(2),
      "total_food": uniqueFoods.toString(),
      "price": items
          .map(
              (e) => (int.parse(e.price ?? '0') * (e.quantity ?? 0)).toString())
          .toList(),
      "quantity": items.map((e) => (e.quantity ?? 0).toString()).toList(),
      "food_id": items.map((e) => e.foodId?.toString() ?? '').toList(),
    };
  }

  Future<void> reorder(Order order, BuildContext context) async {
    if (order.orderItems == null || order.orderItems!.isEmpty) {
      Get.snackbar("Error", "No items found to reorder.",
          backgroundColor: Colors.red[100], colorText: Colors.black);
      return;
    }
    var response;
    bool? selectedPaymentMethod = await Get.bottomSheet<bool>(
      FractionallySizedBox(
        heightFactor: 0.3,
        child: ReorderPaymentModal(),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
    );
    if (selectedPaymentMethod == true) {
      try {
        final jsonBody = jsonEncode(convertOrderToJson(order));
        Logger().i(convertOrderToJson(order));

        await Get.showOverlay(
            asyncFunction: () async {
              response = await http.post(
                Uri.parse("${baseUrlFunc}order-food"),
                headers: {"Content-Type": "application/json"},
                body: jsonBody,
              );
              Logger().i(response.body);

              if (response.statusCode == 200) {
                final data = jsonDecode(response.body);

                if (data['message'] == 'We Accept your order succesfully') {
                  if (onDelivery.value) {
                    final items = order.orderItems ?? [];
                    final totalAmount = items.fold<double>(
                        0.0,
                        (sum, item) =>
                            sum +
                            ((double.tryParse(item.price ?? '0') ?? 0) *
                                (item.quantity ?? 1)));
                    showOrderSuccessDialog(totalAmount.toStringAsFixed(2));
                  } else {
                    var responseData = jsonDecode(response.body);
                    int orderId = responseData['data']['id'];
                    final items = order.orderItems ?? [];
                    final totalAmount = items.fold<double>(
                        0.0,
                        (sum, item) =>
                            sum +
                            ((double.tryParse(item.price ?? '0') ?? 0) *
                                (item.quantity ?? 1)));
                    await handleOnlinePayment(
                        context, orderId, totalAmount.toStringAsFixed(2));
                  }
                  updateUserOrders();
                } else {
                  Get.snackbar(
                    "Error",
                    "Failed to reorder. Please try again.",
                    backgroundColor: Colors.red[100],
                    colorText: Colors.black,
                  );
                }
              } else {
                Get.snackbar(
                  "Error",
                  "Failed to reorder. Server error: ${response.statusCode}",
                  backgroundColor: Colors.red[100],
                  colorText: Colors.black,
                );
              }
            },
            loadingWidget: const Center(
              child: SizedBox(
                  height: 50, width: 50, child: CircularProgressIndicator()),
            ));
      } catch (e, s) {
        Logger().t(e, stackTrace: s);
        Get.snackbar(
          "Error",
          "sth_went_wrong".trParams({'e': e.toString()}),
          backgroundColor: Colors.red[100],
          colorText: Colors.black,
        );
      }
    }
  }

  Future<bool?> showTopUpDialog(BuildContext context) async {
    final amountController = TextEditingController();
    bool topUpSuccess = false;

    return await Get.dialog<bool>(
      AlertDialog(
        title: Text('top_up_wallet'.tr),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'amounto'.tr,
            hintText: 'enter_topup_amount'.tr,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0) {
                topUpSuccess = await topUp(amount);
                Get.back(result: topUpSuccess);
              } else {
                Get.snackbar('error'.tr, 'enter_valid_amount'.tr,
                    backgroundColor: Colors.red, colorText: Colors.white);
              }
            },
            child: Text('proceed'.tr),
          ),
        ],
      ),
    );
  }

  Future<bool> topUp(double amount) async {
    try {
      final userId = Get.find<LoginDataProvider>(tag: 'login').loginData?.id;
      if (userId == null) return false;

      var response;
      await Get.showOverlay(
        asyncFunction: () async {
          response = await http.post(
            Uri.parse('${baseUrlFunc}wallet-payment'),
            body: {
              'user_id': userId.toString(),
              'amount': amount.toString(),
              'date': DateTime.now().toIso8601String(),
            },
          );
        },
        loadingWidget: const Center(
          child: SizedBox(
            height: 50,
            width: 50,
            child: CircularProgressIndicator(),
          ),
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final checkoutUrl = data['data']['checkout_url'];

        if (checkoutUrl != null) {
          var paid = await Get.to<bool>(() => PaymentWebView(url: checkoutUrl));
          if (paid == true) {
            await loadBalance(); // wait for balance refresh
            return true;
          }
        }
      }
    } catch (e, s) {
      Logger().t('Error during top up: $e', stackTrace: s);
      Get.snackbar('error'.tr, 'failed_top_up'.tr,
          backgroundColor: Colors.red, colorText: Colors.white);
    }
    return false;
  }

  Future<void> handleOnlinePayment(
      BuildContext context, int orderId, String totalAmount) async {
    final loginDataProvider = Get.find<LoginDataProvider>(tag: 'login');
    // await loginDataProvider.loadLoginData();
    if (loginDataProvider.loginData == null) {
      Get.to(() => const SignupScreen());
      return;
    }

    var data = {
      "user_id": loginDataProvider.loginData?.id,
      "amount": totalAmount,
      "date": DateTime.now().toString(),
      "food_order_id": orderId,
    };
    if (!walletPay.value) {
      try {
        var loginDataProvider = Get.find<LoginDataProvider>(tag: 'login');
        // loginDataProvider.loadLoginData();

        Logger().i(jsonEncode(data));
        final response = await http.post(
          Uri.parse('${baseUrlFunc}pay-on-chapa'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(data),
        );
        Logger().i(response.body);
        if (response.statusCode == 200 &&
            jsonDecode(response.body)['data']?['checkout_url'] != null) {
          final checkoutUrl = jsonDecode(response.body)['data']['checkout_url'];
          final result = await Get.to(() => PaymentWebView(url: checkoutUrl));
          if (result == true) {
            // orderIdString.value = orderId.toString();
            showSuccessDialog(totalAmount);
            updateUserOrders();
          }
        } else {
          Get.snackbar(
            "error".tr,
            "failed_start_chapa".tr,
            backgroundColor: Colors.red[100],
            colorText: Colors.black,
          );
        }
      } catch (e, s) {
        Logger().t(e, stackTrace: s);
        Get.snackbar("error".tr, "sth_went_wrong".trParams({'e': e.toString()}),
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } else {
      try {
        var loginDataProvider = Get.find<LoginDataProvider>(tag: 'login');
        double currentBalance = double.tryParse(balance.value) ?? 0;
        final requiredAmount = double.parse(totalAmount);
        // If not enough funds, wait for top-up
        if (requiredAmount > currentBalance) {
          bool? toppedUp = await showTopUpDialog(Get.context!);
          if (!(toppedUp ?? false)) {
            Get.snackbar('error'.tr, 'top_up_cancelled_or_failed'.tr,
                backgroundColor: Colors.red, colorText: Colors.white);
            isLoading.value = false;
            return;
          }

          // Reload new balance
          await loadBalance();
          currentBalance = double.tryParse(balance.value) ?? 0;

          if (requiredAmount > currentBalance) {
            Get.snackbar('error'.tr, 'still_not_enough_balance'.tr,
                backgroundColor: Colors.red, colorText: Colors.white);
            isLoading.value = false;
            return;
          }
        }
        // loginDataProvider.loadLoginData();
        Logger().i(data);
        final response = await http.post(
            Uri.parse('${baseUrlFunc}pay-on-wallet'),
            body: jsonEncode(data),
            headers: {
              "Content-Type": "application/json",
            });
        Logger().i(response.body);

        if (response.statusCode == 200 || response.statusCode == 201) {
          showSuccessDialog(totalAmount);
          updateUserOrders();
        } else {
          Get.snackbar(
            "Payment Failed",
            "unable_to_complt_wallet_payment".tr,
            backgroundColor: Colors.red[100],
            colorText: Colors.black,
          );
        }
      } catch (e, s) {
        Logger().t(e, stackTrace: s);
        Get.snackbar("Error", "sth_went_wrong".trParams({'e': e.toString()}),
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    }
  }

  var loadingBalance = false.obs;
  var balance = '0'.obs;

  @override
  void onInit() {
    super.onInit();
    loadBalance(); // fetch balance when controller is created
  }

  Future<void> loadBalance() async {
    final Dio dio = Dio();
    loadingBalance.value = true;
    try {
      var loginDataProvider = Get.find<LoginDataProvider>(tag: 'login');
      // loginDataProvider.loadLoginData();
      final userId = loginDataProvider.loginData?.id;
      if (userId == null) return;

      final response = await dio.get('${baseUrlFunc}my_wallet_amount/$userId');

      if (response.statusCode == 200) {
        final data = response.data;
        balance.value = data['data']?.toString() ?? '0';
        if (Get.isRegistered<WalletController>(tag: WalletController.tag)) {
          Get.find<WalletController>(tag: WalletController.tag).loadBalance();
        }
      }
    } catch (e, s) {
      Logger().t('Error loading balance: $e', stackTrace: s);
      Get.snackbar('Error', 'failed_to_load_balance'.tr,
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      loadingBalance.value = false;
    }
  }

  /// Shows an error snackbar
  void showErrorSnackbar(String message) {
    Get.snackbar("error".tr, message,
        backgroundColor: Colors.red, colorText: Colors.white);
  }

  /// Shows a success dialog
  void showSuccessDialog(String totalAmount) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("food_purchase_successful".tr),
        content: Text("$totalAmount Birr ${"paid_enjoy".tr}"),
        actions: [
          TextButton(
            child: Text("ok".tr),
            onPressed: () {
              GetStorage().erase();
              Get.until((route) => Get.currentRoute == Routes.mainLayoutRoute);

              Get.find<MainLayoutController>(tag: MainLayoutController.tag)
                  .bottomTabController
                  .jumpToTab(3);
              if (Get.isRegistered<UserOrdersController>()) {
                Get.find<UserOrdersController>().tabController.animateTo(1);
              }
            },
          ),
        ],
      ),
    );
  }

  /// Shows a success dialog
  void showOrderSuccessDialog(String totalAmount) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("food_purchase_successful".tr),
        content: Text("ordered_enjoy".tr),
        actions: [
          TextButton(
            child: Text("ok".tr),
            onPressed: () {
              GetStorage().erase();
              Get.until((route) => Get.currentRoute == Routes.mainLayoutRoute);

              Get.find<MainLayoutController>(tag: MainLayoutController.tag)
                  .bottomTabController
                  .jumpToTab(3);
              if (Get.isRegistered<UserOrdersController>()) {
                Get.find<UserOrdersController>().tabController.animateTo(1);
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> showCancelDialog(Order order) async {
    final TextEditingController reasonController = TextEditingController();

    await Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("cancel_order".tr),
        content: TextField(
          controller: reasonController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: "reason".tr,
            hintText: "enter_reason".tr,
            border:
                OutlineInputBorder(borderSide: BorderSide(color: mainColor)),
            enabledBorder:
                OutlineInputBorder(borderSide: BorderSide(color: mainColor)),
            focusedBorder:
                OutlineInputBorder(borderSide: BorderSide(color: mainColor)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("cancel".tr),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            onPressed: () async {
              final reason = reasonController.text.trim();
              if (reason.isEmpty) {
                Get.snackbar("error".tr, "please_enter_a_reason".tr,
                    backgroundColor: Colors.red, colorText: Colors.white);
                return;
              }
              Get.back();
              await cancelOrder(order, reason);
            },
            child: Text("ok".tr),
          ),
        ],
      ),
    );
  }

  Future<void> cancelOrder(Order order, String reason) async {
    final loginProvider = Get.find<LoginDataProvider>(tag: 'login');
    // await loginProvider.loadLoginData();

    final userId = loginProvider.loginData?.id;
    if (userId == null) {
      Get.snackbar("error".tr, "user_not_logged_in".tr,
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    final data = {
      "order_id": order.id,
      "reason": reason,
      "price": order.price?.toStringAsFixed(2) ?? '0',
      "date": DateTime.now().toString(),
      "user_id": userId,
    };

    Logger().i("Cancel Order Data: $data");

    await Get.showOverlay(
      asyncFunction: () async {
        final response = await http.post(
          Uri.parse("https://api.hellomesa6810.com/api/cancel-order"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(data),
        );

        Logger().i("Cancel Order Response: ${response.body}");

        if (response.statusCode == 200 || response.statusCode == 201) {
          final resData = jsonDecode(response.body);
          if (resData['message'].toString().toLowerCase().contains("cancel")) {
            Get.snackbar(
              "success".tr,
              "order_cancelled".tr,
              backgroundColor: Colors.green[100],
              colorText: Colors.black,
            );
            updateUserOrders();
            fetchOrderItems(order);
          } else {
            Get.snackbar(
              "error".tr,
              "unexpected".tr,
              backgroundColor: Colors.red[100],
              colorText: Colors.black,
            );
          }
        } else {
          Get.snackbar(
            "Error",
            "${'failed_to_cancel_order'.tr}. (${response.statusCode})",
            backgroundColor: Colors.red[100],
            colorText: Colors.black,
          );
        }
      },
      loadingWidget: const Center(
        child: SizedBox(
          height: 50,
          width: 50,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  /// Updates user orders
  void updateUserOrders() {
    if (Get.isRegistered<UserOrdersController>()) {
      Get.find<UserOrdersController>().updateOrders();
    }
  }

  var order = Order(id: -1).obs;
  Future<void> fetchOrderItems(Order orderPassed) async {
    if (order.value.id == -1) {
      order.value = orderPassed;
    }
    try {
      isLoading.value = true;
      final response = await http.get(
        Uri.parse("${baseUrlFunc}my_order_detail/${orderPassed.id}"),
      );
      Logger().d(response.body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null) {
          orderItems.value = List<OrderItem>.from(
              data['data'].map((e) => OrderItem.fromJson(e)));
          order.value.orderItems = orderItems;
          Order orderRecieved = Order.fromJson(data['order_status'], '');
          order.value = orderRecieved;
          order.refresh();
        }
      } else {
        Logger().e("Failed to fetch order items: ${response.statusCode}");
      }
    } catch (e) {
      Logger().e("Error fetching order details: $e");
    } finally {
      isLoading.value = false;
    }
  }
}

String paymentTypeConverter(int? type) {
  switch (type) {
    case 4:
      return 'Paid with Chapa';
    case 3:
      return 'Paid with Wallet';
    case 1:
      return 'Paid with Cash';
    default:
      return 'unknown'.tr;
  }
}

String paymentStatusConverter(int? status) {
  return status == 1 ? 'paid'.tr : 'not_paid'.tr;
}

class UserOrderDetails extends StatefulWidget {
  const UserOrderDetails({super.key});

  @override
  State<UserOrderDetails> createState() => _UserOrderDetailsState();
}

class _UserOrderDetailsState extends State<UserOrderDetails>
    with SingleTickerProviderStateMixin {
  late final Order orderPassed = Get.arguments['order'];
  final PaymentController paymentController = Get.put(PaymentController());
  final OrderDetailController orderDetailController =
      Get.put(OrderDetailController());

  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    if (orderPassed.id != null) {
      orderDetailController.fetchOrderItems(orderPassed);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF23981C),
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: ThemeModeController.isDark.value
          ? Theme.of(context).scaffoldBackgroundColor
          : Theme.of(context).cardColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF23981C),
        elevation: 0,
        title: Text(
          'order_details'.tr,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: false,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) async {
              if (value == 'reorder') {
                // Ensure order items are loaded
                if (orderDetailController.orderItems.isEmpty) {
                  await orderDetailController.fetchOrderItems(orderPassed);
                  orderDetailController.order.value.orderItems =
                      orderDetailController.orderItems.toList();
                } else {
                  orderDetailController.order.value.orderItems =
                      orderDetailController.orderItems.toList();
                }

                orderDetailController.reorder(orderPassed, context);
              }

              // ✅ Handle Cancel Order
              else if (value == 'cancel') {
                await orderDetailController.showCancelDialog(orderPassed);
              } else if (value == 'refresh') {
                await orderDetailController.fetchOrderItems(orderPassed);
              }
            },
            itemBuilder: (context) {
              final List<PopupMenuEntry<String>> menuItems = [
                if ((orderDetailController.order.value.status ?? 0) > 3)
                  PopupMenuItem(
                    value: 'reorder',
                    child: Row(
                      children: [
                        const Icon(EneftyIcons.shopping_bag_bold,
                            color: Color(0xFF23981C)),
                        const SizedBox(width: 8),
                        Text("reorder".tr),
                      ],
                    ),
                  ),
              ];
              if ((orderDetailController.order.value.status ?? 0) <= 3) {
                menuItems.add(
                  PopupMenuItem(
                    value: 'refresh',
                    child: Row(
                      children: [
                        const Icon(Icons.refresh, color: Colors.green),
                        const SizedBox(width: 8),
                        Text("refresh".tr),
                      ],
                    ),
                  ),
                );
                if ((orderDetailController.order.value.status ?? 0) < 3) {
                  menuItems.add(
                    PopupMenuItem(
                      value: 'cancel',
                      child: Row(
                        children: [
                          const Icon(Icons.cancel, color: Colors.redAccent),
                          const SizedBox(width: 8),
                          Text("cancel_order".tr),
                        ],
                      ),
                    ),
                  );
                }
              }

              return menuItems;
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFF23981C),
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              tabs: [
                Tab(text: "details".tr),
                Tab(text: "foods".tr),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                buildOrderDetailsView(context), // existing details UI extracted
                buildOrderItemsView(), // new items tab
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildOrderDetailsView(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 🖼 Image Header
          // Obx(
          //   () => orderDetailController.isLoading.value
          //       ? Shimmer.fromColors(
          //           baseColor: Theme.of(context)
          //               .colorScheme
          //               .primary
          //               .withValues(alpha: 0.7),
          //           highlightColor: Theme.of(context)
          //               .colorScheme
          //               .primary
          //               .withValues(alpha: 0.5),
          //           child: Container(
          //             height: MediaQuery.of(context).size.height * 0.3,
          //             width: double.infinity,
          //             color: Colors.green,
          //           ),
          //         )
          //       : SizedBox(
          //           height: MediaQuery.of(context).size.height * 0.3,
          //           width: MediaQuery.of(context).size.width,
          //           child: OrderImageGrid(
          //               items: orderDetailController.orderItems)),
          // ),
          // ClipRRect(
          //   borderRadius: const BorderRadius.only(
          //     bottomLeft: Radius.circular(30),
          //     bottomRight: Radius.circular(30),
          //   ),
          //   child: CachedNetworkImage(
          //     imageUrl: order.image?.trim() ?? '',
          //     height: 220,
          //     width: double.infinity,
          //     fit: BoxFit.cover,
          //     errorWidget: (context, url, error) => Image.asset(
          //       'assets/images/THICKET_MASTER_LOGO.png',
          //       height: 220,
          //       width: double.infinity,
          //       fit: BoxFit.cover,
          //     ),
          //   ),
          // ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'order_details'.tr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Obx(
                          () => _detailItem(
                            icon: Icons.attach_money,
                            title: 'priceo'.tr,
                            value:
                                '${'etb'.tr} ${orderDetailController.order.value.price?.toStringAsFixed(2) ?? '0.00'}',
                          ),
                        ),
                      ),
                      Expanded(
                          child: Obx(
                        () => _detailItem(
                          icon: EneftyIcons.hashtag_2_outline,
                          title: 'order_id'.tr,
                          value: orderDetailController.order.value.id
                                  ?.toString() ??
                              '-',
                        ),
                      )),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Obx(() => _detailItem(
                        icon: Icons.confirmation_number_outlined,
                        title: 'payment_status'.tr,
                        value: paymentStatusConverter(
                            orderDetailController.order.value.paymentStatus ==
                                    true
                                ? 1
                                : 0),
                      )),
                  const SizedBox(height: 10),
                  Obx(() => _detailItem(
                        icon: int.parse(orderDetailController
                                        .order.value.organizationId ??
                                    '0') !=
                                0
                            ? EneftyIcons.more_2_bold
                            : Icons.location_on_outlined,
                        title: int.parse(orderDetailController
                                        .order.value.organizationId ??
                                    '0') !=
                                0
                            ? 'desc'.tr
                            : 'location'.tr,
                        value: orderDetailController.order.value.location ?? "",
                      )),
                ],
              ),
            ),
          ),
          Obx(() => orderDetailController.order.value.paymentStatus != true
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Obx(() {
                        if (paymentController.isLoading.value) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'complete_payment'.tr,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),

                            // 💰 Wallet Balance
                            Row(
                              children: [
                                const Icon(
                                    Icons.account_balance_wallet_outlined,
                                    color: Color(0xFF23981C)),
                                const SizedBox(width: 8),
                                paymentController.loadingBalance.value
                                    ? const SizedBox(
                                        height: 16,
                                        width: 16,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      )
                                    : Text(
                                        "${'wallet_balance'.tr}: ${paymentController.balance.value} Pts",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14),
                                      ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // 🎯 Selectable Payment Chips (Custom Style)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildPaymentOption(
                                  label: "pay_with_chapa".tr,
                                  icon: Icons.payment,
                                  method: "chapa",
                                  controller: paymentController,
                                  onTap: () async {
                                    if (paymentController
                                            .selectedMethod.value ==
                                        "chapa") {
                                      await paymentController.payWithChapa(
                                          orderDetailController.order.value);
                                    } else {
                                      paymentController.selectedMethod.value =
                                          "chapa";
                                      await paymentController.payWithChapa(
                                          orderDetailController.order.value);
                                    }
                                  },
                                ),
                                _buildPaymentOption(
                                  label: "pay_with_wallet".tr,
                                  icon: Icons.account_balance_wallet_outlined,
                                  method: "wallet",
                                  controller: paymentController,
                                  onTap: () async {
                                    if (paymentController
                                            .selectedMethod.value ==
                                        "wallet") {
                                      await paymentController.payWithWallet(
                                          orderDetailController.order.value);
                                    } else {
                                      paymentController.selectedMethod.value =
                                          "wallet";
                                      await paymentController.payWithWallet(
                                          orderDetailController.order.value);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                )
              : const SizedBox.shrink()),

          const SizedBox(height: 20),

          // 🚚 Order Status Timeline
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'order_status'.tr,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Obx(() => _buildStatusTimeline(
                      orderDetailController.order.value.status ?? 0)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required String label,
    required IconData icon,
    required String method,
    required PaymentController controller,
    required VoidCallback onTap,
  }) {
    final bool isSelected = controller.selectedMethod.value == method;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF23981C) : Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF23981C) : Colors.grey.shade300,
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.green.withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : const Color(0xFF23981C),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF23981C),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildOrderItemsView() {
    return Obx(() {
      if (orderDetailController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (orderDetailController.orderItems.isEmpty) {
        return const Center(child: Text("No items found for this order."));
      }

      return OrderSummary(orderItems: orderDetailController.orderItems);
    });
  }

  Widget _detailItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F8),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Center(
                child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(icon, color: const Color(0xFF23981C), size: 22),
            ))),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusTimeline(int currentIndex) {
    final steps = [
      'waiting_acceptance'.tr,
      'order_accepted'.tr,
      'order_preparing'.tr,
      'man_on_the_way'.tr,
      'order_delivered'.tr,
      'order_rejected'.tr,
    ];

    return Obx(() => OrderStatusTimeline(
          shimmering: orderDetailController.isLoading.value,
          steps: steps,
          currentIndex: orderDetailController.order.value.status ?? 0,
        ));
  }
}
