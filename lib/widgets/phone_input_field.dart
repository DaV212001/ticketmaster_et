import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';

class PhoneInputField extends StatelessWidget {
  final TextEditingController? controller;
  final void Function(PhoneNumber)? onChanged;
  final double height;
  final bool? validate;
  final String? initialValue;
  final GlobalKey<FormState>? formKey;

  const PhoneInputField(
      {super.key,
      this.controller,
      this.height = 85,
      this.validate,
      this.formKey,
      this.initialValue,
      this.onChanged});

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      // key: widget.formKey,
      builder: (validationState) {
        return IntlPhoneField(
          // key: widget.formKey,
          initialValue: initialValue,
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[200],
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.transparent, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.transparent, width: 1),
            ),
            prefixIcon: const Icon(CupertinoIcons.phone),
            labelText: "phone_number".tr,
            labelStyle: const TextStyle(fontSize: 13),
            errorText:
                validationState.hasError ? validationState.errorText : null,
            // border: OutlineInputBorder(),
          ),
          initialCountryCode: 'ET',
          // onSubmitted: (value) {
          //   validationState.didChange(value);
          // },
          onChanged: (phone) {
            validationState.didChange(phone.number);
            onChanged != null ? onChanged!(phone) : null;
          },
          pickerDialogStyle: PickerDialogStyle(
              searchFieldInputDecoration: InputDecoration(
            labelText: "search_country".tr,
          )),
          invalidNumberMessage: "invalid_phone_number".tr,
          // disableLengthCheck: true,
          // autovalidateMode: AutovalidateMode.always,
        );
      },
      // autovalidateMode: AutovalidateMode.always,
      validator: (value) {
        print('Validation CC: ${value == null}');
        if (value == null || value.isEmpty) {
          print('Validation cc: ${(value == null || value.isEmpty)}');
          return "phone_number_required".tr;
        }
        return null;
      },
    );
  }
}

// InternationalPhoneNumberInput(
//   controller: widget.controller,
//   onInputChanged: (value) {
//     print('CHECKING PHONE INPUT: ${value.dial_code + value.dial_code + value.code}');
//     },
//
//   initCountry: CountryCodeModel(
//       name: "Ethiopia", dial_code: "+251", code: "ET"),
//   phoneConfig: PhoneConfig(
//     hintText: "phone_number".tr(),
//     labelText: "phone_number".tr(),
//     borderWidth: 0
//   ),
//   validator: (value) {
//     if (value.number.isEmpty) {
//       return "phone_number_required".tr();
//     }
//     return null;
//   },
// )
// TextFormField(
//   maxLength: 9,
//   controller: controller,
//   keyboardType: TextInputType.phone,
//   decoration: InputDecoration(
//     prefixIcon: Icon(CupertinoIcons.phone),
//     labelText: "phone_number".tr(),
//     prefixText: '+251'
//     // border: OutlineInputBorder(),
//   ),
//   validator: (value) {
//     if (value == null || value.isEmpty) {
//       return "phone_number_required".tr();
//     } else if (value.length != 9 ||
//         !RegExp(r'^[0-9]+$').hasMatch(value)) {
//       return "invalid_phone_number".tr();
//     }
//     return null;
//   },
// ),
