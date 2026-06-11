import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

class PaymentWebView extends StatefulWidget {
  final String url;
  final bool? fromOnboarding;
  final bool? fromStatus;
  final bool? dontShowConfirmation;
  const PaymentWebView(
      {super.key,
      required this.url,
      this.fromOnboarding,
      this.fromStatus,
      this.dontShowConfirmation});

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late InAppWebViewController webViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(widget.url)),
        onWebViewCreated: (controller) {
          webViewController = controller;
        },
        onLoadStart: (controller, url) async {
          if (url.toString().contains("receipt")) {
            // await Future.delayed(const Duration(seconds: 3));
            Get.back(result: true);
          }
        },
        onLoadStop: (controller, url) async {
          // Check if the loaded URL matches the receipt page URL
          if (url.toString().contains("receipt")) {
            await Future.delayed(const Duration(seconds: 3));
            Get.back(result: true);
          }
        },
      ),
    );
  }
}
