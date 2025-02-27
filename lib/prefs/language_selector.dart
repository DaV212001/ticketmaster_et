import 'dart:async';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/theme_controller.dart';
import 'lang.dart';

class LanguageSelectorButton extends StatefulWidget {
  final Function() onChange;
  const LanguageSelectorButton({super.key, required this.onChange});

  @override
  State<LanguageSelectorButton> createState() => _LanguageSelectorButtonState();
}

class _LanguageSelectorButtonState extends State<LanguageSelectorButton> {
  late Timer timer;
  late bool changed = false;
  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2(
        customButton: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Text(
                ThemeModeController.getLanguage(),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              )
            ],
          ),
        ),
        items: [
          ...Language.languages.map(
            (item) => DropdownMenuItem<Language>(
              value: item,
              child: Text(item.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  )),
            ),
          ),
        ],
        onChanged: (value) {
          setState(() {
            Language.selectedLanguage = value!;
            Get.updateLocale(value.code);
            ThemeModeController.saveLanguage(value.code);
            changed = true;
          });
          widget.onChange();
        },
        dropdownStyleData: DropdownStyleData(
          width: 160,
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
          ),
          offset: const Offset(0, 8),
        ),
        menuItemStyleData: MenuItemStyleData(
          customHeights: List<double>.filled(Language.languages.length, 48),
          padding: const EdgeInsets.only(left: 16, right: 16),
        ),
      ),
    );
  }
}
