import 'dart:async';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ticketmaster_et/provider/loginpersistence.dart';

import '../controllers/theme_controller.dart';
import '../functions/functions.dart';
import '../models/newmodels.dart';
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
        onChanged: (value) async {
          var loginDataProvider = Get.find<LoginDataProvider>(tag: 'login');
          var loginData = loginDataProvider.loginDataObs.value;
          setState(() {
            Language.selectedLanguage = value!;
            Get.updateLocale(value.code);
            ThemeModeController.saveLanguage(value.code);
            changed = true;
          });
          widget.onChange();
          String? languageCode = ThemeModeController.languageCode.value == 'es'
              ? 'tg'
              : ThemeModeController.languageCode.value == 'it'
                  ? 'or'
                  : ThemeModeController.languageCode.value == 'fr'
                      ? 'so'
                      : ThemeModeController.languageCode.value;
          UpdatedUser data = UpdatedUser(
              id: loginData?.id,
              firstName: loginData?.firstName,
              lastName: loginData?.lastName,
              phone: '${loginData?.phone}',
              email: loginData?.email,
              language: languageCode);

          await updateUser(data).then((updateUserResponse) async {
            if (updateUserResponse.message != null) {
              if (updateUserResponse.message == "User Updated successfully") {}
            } else {
              String errorMessage = "error_update".tr;
              if (updateUserResponse.error!.firstName != null) {
                errorMessage = errorMessageConcatenator(
                    updateUserResponse.error!.firstName!);
              }
              if (updateUserResponse.error!.LastName != null) {
                errorMessage = errorMessageConcatenator(
                    updateUserResponse.error!.LastName!);
              }
              if (updateUserResponse.error!.phone != null) {
                errorMessage =
                    errorMessageConcatenator(updateUserResponse.error!.phone!);
              }
              if (updateUserResponse.error!.email != null) {
                errorMessage =
                    errorMessageConcatenator(updateUserResponse.error!.email!);
              }
            }
          });
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
