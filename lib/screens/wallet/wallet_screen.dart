import 'dart:math';

import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticketmaster_et/prefs/shimmer_wrapper.dart';

import '../../controllers/wallet_controller.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final WalletController walletController =
      Get.find<WalletController>(tag: WalletController.tag);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);
    walletController.loadTransactions();
    walletController.loadWalletData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showTopUpDialog() {
    final amountController = TextEditingController();
    final pointsNotifier = ValueNotifier<double>(0); // For live points update

    amountController.addListener(() {
      final amount = double.tryParse(amountController.text) ?? 0;
      pointsNotifier.value = amount * 1.1; // conversion: 1 Birr = 1.1 Points
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('top_up_wallet'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('1 Birr = 1.1 Point'),
            const SizedBox(height: 8),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'amounto'.tr,
                hintText: 'enter_topup_amount'.tr,
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(color: Colors.green),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(color: Colors.green),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(color: Colors.green),
                ),
              ),
            ),
            const SizedBox(height: 8),
            ValueListenableBuilder<double>(
              valueListenable: pointsNotifier,
              builder: (context, points, _) {
                return Text(
                  'You will get ${points.toStringAsFixed(1)} Pts',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0) {
                Get.back();
                walletController.topUp(amount);
              } else {
                Get.snackbar(
                  'error'.tr,
                  'enter_valid_amount'.tr,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            child: Text('proceed'.tr),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Wallet"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => walletController.loadWalletData(),
          ),
        ],
      ),
      body: Obx(() {
        if (walletController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === WALLET CARD ===
              AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  final offset1 = Offset(
                    sin(_controller.value * 2 * pi) * 20,
                    cos(_controller.value * 2 * pi) * 20,
                  );
                  final offset2 = Offset(
                    cos(_controller.value * 2 * pi) * -15,
                    sin(_controller.value * 2 * pi) * 15,
                  );
                  final shimmerShift =
                      (0.5 + 0.5 * sin(_controller.value * 2 * pi));

                  return Container(
                    width: double.infinity,
                    height: 160,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [
                          Color.lerp(Colors.green.shade700,
                              Colors.green.shade400, shimmerShift)!,
                          Color.lerp(Colors.green.shade400,
                              Colors.green.shade700, shimmerShift)!,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // --- HEXAGON BACKGROUND (Animated) ---
                        Positioned(
                          top: -40 + offset1.dy,
                          right: -30 + offset1.dx,
                          child: Opacity(
                            opacity: 0.15,
                            child: CustomPaint(
                              size: const Size(180, 180),
                              painter: HexagonPainter(color: Colors.white),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -50 + offset2.dy,
                          left: -40 + offset2.dx,
                          child: Opacity(
                            opacity: 0.1,
                            child: CustomPaint(
                              size: const Size(160, 160),
                              painter: HexagonPainter(color: Colors.white),
                            ),
                          ),
                        ),

                        // --- CONTENT ---
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 20, bottom: 20, left: 50, right: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'wallet_balance'.tr,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(bottom: 10.0),
                                    child: Icon(
                                      EneftyIcons.wallet_3_bold,
                                      color: Colors.white,
                                      size: 35,
                                    ),
                                  ),
                                  Obx(() =>
                                      walletController.loadingBalance.value
                                          ? ShimmerWrapper(
                                              isEnabled: true,
                                              baseColor: Colors.white
                                                  .withValues(alpha: 0.7),
                                              highlightColor: Colors.white
                                                  .withValues(alpha: 0.5),
                                              child: const Text(
                                                "500",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 36,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ))
                                          : Text(
                                              walletController.balance.value,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 36,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )),
                                  const Padding(
                                    padding: EdgeInsets.only(bottom: 10.0),
                                    child: Text(
                                      ' Pts',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: SizedBox(
                                    width: 110,
                                    height: 35,
                                    child: ElevatedButton(
                                      onPressed: _showTopUpDialog,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: Colors.green.shade700,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(7),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text('top_up'.tr,
                                              style: const TextStyle(
                                                  fontSize: 12)),
                                          const SizedBox(width: 5),
                                          const Icon(
                                              EneftyIcons.money_recive_outline,
                                              size: 18),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // === TRANSACTION HISTORY ===
              Text(
                'trans_history'.tr,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // === TRANSACTION LIST ===
              Expanded(
                child: Obx(
                  () => walletController.loadingTransactions.value
                      ? ListView.builder(
                          itemCount: 5,
                          itemBuilder: (context, index) {
                            final transaction = Transaction(
                                id: 0,
                                title: 'cabauidvcauv',
                                paymentStatus: '0',
                                paidAt: DateTime.now(),
                                amount: '500');
                            return TransactionTile(
                              transaction: transaction,
                              shimmering: true,
                            );
                          },
                        )
                      : walletController.transactions.isEmpty
                          ? Center(
                              child: Text(
                                'no_trans_history'.tr,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              itemCount: walletController.transactions.length,
                              itemBuilder: (context, index) {
                                final transaction =
                                    walletController.transactions[index];
                                return TransactionTile(
                                    transaction: transaction);
                              },
                            ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// === UPDATED TRANSACTION TILE ===
class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final bool? shimmering;

  const TransactionTile(
      {super.key, required this.transaction, this.shimmering});

  @override
  Widget build(BuildContext context) {
    return ShimmerWrapper(
      isEnabled: shimmering,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: transaction.isSuccessful
                ? Colors.green.shade100
                : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: Icon(
            transaction.isSuccessful
                ? EneftyIcons.money_recive_outline
                : EneftyIcons.money_send_outline,
            color: transaction.isSuccessful ? Colors.green : Colors.red,
            size: 20,
          ),
        ),
        title: Text(
          transaction.title ?? "",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: transaction.isSuccessful ? Colors.black : Colors.red,
          ),
        ),
        subtitle: Text(
          transaction.formattedDate,
          style: TextStyle(
            fontSize: 12,
            color: transaction.isSuccessful ? Colors.grey : Colors.red,
          ),
        ),
        trailing: Text(
          '${transaction.isSuccessful ? '+' : '-'} ${transaction.amount} Pts',
          style: TextStyle(
            color: transaction.isSuccessful ? Colors.green : Colors.red,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// === HEXAGON PAINTER (unchanged) ===
class HexagonPainter extends CustomPainter {
  final Color color;
  HexagonPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final w = size.width;
    final h = size.height;

    path.moveTo(w * 0.5, 0);
    path.lineTo(w, h * 0.25);
    path.lineTo(w, h * 0.75);
    path.lineTo(w * 0.5, h);
    path.lineTo(0, h * 0.75);
    path.lineTo(0, h * 0.25);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
