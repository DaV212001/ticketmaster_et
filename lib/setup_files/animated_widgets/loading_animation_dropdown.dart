import 'package:flutter/material.dart';

import 'loading_animation_button.dart';

class LoadingAnimatedDropdown<T> extends StatefulWidget {
  final Duration duration;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final double width;
  final double height;

  final Color color;
  final double borderRadius;
  final Color borderColor;
  final double borderWidth;
  final String hintText;

  const LoadingAnimatedDropdown({
    super.key,
    required this.items,
    required this.onChanged,
    this.value,
    this.width = 200,
    this.height = 50,
    this.color = Colors.indigo,
    this.borderColor = Colors.white,
    this.borderRadius = 15.0,
    this.borderWidth = 3.0,
    this.duration = const Duration(milliseconds: 1500),
    this.hintText = "Select an option",
  });

  @override
  State<LoadingAnimatedDropdown<T>> createState() =>
      _LoadingAnimatedDropdownState<T>();
}

class _LoadingAnimatedDropdownState<T> extends State<LoadingAnimatedDropdown<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: LoadingPainter(
        animation: _animationController,
        borderColor: widget.borderColor,
        borderRadius: widget.borderRadius,
        borderWidth: widget.borderWidth,
        color: widget.color,
      ),
      child: Container(
        width: widget.width,
        height: widget.height,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        alignment: Alignment.center,
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: widget.value,
            hint: Text(widget.hintText),
            isExpanded: true,
            items: widget.items,
            onChanged: widget.onChanged,
          ),
        ),
      ),
    );
  }
}
