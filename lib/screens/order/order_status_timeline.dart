import 'package:flutter/material.dart';
import 'package:ticketmaster_et/prefs/shimmer_wrapper.dart';

class OrderStatusTimeline extends StatelessWidget {
  const OrderStatusTimeline({
    super.key,
    required this.steps,
    required this.currentIndex,
    required this.shimmering,
  });

  final List<String> steps;
  final int currentIndex;
  final bool shimmering;

  @override
  Widget build(BuildContext context) {
    return ShimmerWrapper(
      isEnabled: shimmering,
      child: Column(
        children: List.generate(steps.length, (index) {
          final bool isRejected = currentIndex == 5;
          final bool isDone = index <= currentIndex;
          final bool isLast = index == steps.length - 1;
          final bool lineCompleted = index < currentIndex;

          // --- Determine icon & color ---
          IconData icon;
          Color iconColor;

          if (isRejected) {
            if (index == 5) {
              icon = Icons.check_circle;
              iconColor = Colors.red;
            } else {
              icon = Icons.radio_button_unchecked;
              iconColor = Colors.grey;
            }
          } else if (isDone) {
            icon = Icons.check_circle;
            iconColor = const Color(0xFF23981C);
          } else {
            icon = Icons.radio_button_unchecked;
            iconColor = Colors.grey;
          }

          // --- Determine line color ---
          final Color lineColor = (lineCompleted && !isRejected)
              ? const Color(0xFF23981C)
              : Colors.grey[300]!;

          // --- Text style ---
          final TextStyle textStyle = TextStyle(
            color: isDone
                ? isRejected && index != 5
                    ? Colors.grey
                    : Theme.of(context).primaryColor
                : Colors.grey[500],
            fontWeight: isDone ? FontWeight.w600 : FontWeight.normal,
          );

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Icon(icon, color: iconColor),
                  if (!isLast)
                    Container(
                      width: 3,
                      height: 30,
                      color: lineColor,
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(steps[index], style: textStyle),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
