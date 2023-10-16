import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

class InputWidget extends StatelessWidget {
  const InputWidget({
    super.key,
    required this.headerName,
    required this.labelText,
  });

  final String headerName, labelText;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InputHeader(headerName: headerName),
        const SizedBox(
          height: 10,
        ),
        UserInput(labelText: labelText),
        const SizedBox(
          height: 25,
        )
      ],
    );
  }
}

class InputHeader extends StatelessWidget {
  const InputHeader({super.key, required this.headerName});

  final String headerName;

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.centerLeft,
        child: Text(headerName, style: TextStyle(fontSize: 17)));
  }
}

class UserInput extends StatelessWidget {
  const UserInput({
    super.key,
    required this.labelText,
  });

  final String labelText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        color: Colors.grey[200], // Background color
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: labelText,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16.0),
        ),
      ),
    );
  }
}