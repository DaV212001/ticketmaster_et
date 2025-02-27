import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:ticketmaster_et/prefs/language_selector.dart';

import '../functions/functions.dart';
import '../models/newmodels.dart';
import '../provider/loginpersistence.dart';
import '../provider/settings_provider.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _firstName, _lastName, _phoneNumber;

  Future submitForm() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      final accountProvider = Get.find<LoginDataProvider>(tag: 'login');

      String? phone = accountProvider.loginData?.phone!;
      UpdatedUser data = UpdatedUser(
        firstName: _firstName,
        lastName: _lastName,
        phone: phone,
      );

      await updateUser(data).then((value) async {
        if (value.message != null) {
          if (value.message == "User Updated successfully") {
            await accountProvider.updateName(_firstName!, _lastName!);
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  content: Text(
                    'Successfully Edited',
                    style: TextStyle(color: Colors.green),
                  ),
                );
              },
            );
          }
        } else {
          String errorMessage = "Error Updating";
          if (value.error!.firstName != null) {
            errorMessage = errorMessageConcatenator(value.error!.firstName!);
          }
          if (value.error!.LastName != null) {
            errorMessage = errorMessageConcatenator(value.error!.LastName!);
          }
          if (value.error!.phone != null) {
            errorMessage = errorMessageConcatenator(value.error!.phone!);
          }

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Text(
                  errorMessage,
                  style: TextStyle(color: Colors.green),
                ),
              );
            },
          );
        }
      });
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginDataProvider = Get.find<LoginDataProvider>(tag: 'login');
    final languageChange = Provider.of<SettingsProvider>(context);
    final accountProvider = Get.find<LoginDataProvider>(tag: 'login');
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF23981C), // Change this to your desired color
      statusBarIconBrightness: Brightness.light, // For light icons
      statusBarBrightness: Brightness.dark, // For iOS status bar
    ));
    return Container(
      color: Colors.grey[100],
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            actions: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.transparent),
                  child: LanguageSelectorButton(onChange: () {}),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const Center(
                            child: Image(
                              image: AssetImage(
                                  'assets/images/THICKET_MASTER_LOGO.png'),
                              width: 170.0, // Set the desired width
                              height: 170.0, // Set the desired height
                            ),
                          ),
                          Text(
                            'editprofile'.tr,
                            style: TextStyle(
                                fontSize: 25, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 15),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'first_name'.tr,
                              style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.04),
                            ),
                          ),
                          Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.0),
                              color: Colors.grey[200], // Background color
                            ),
                            child: TextFormField(
                              initialValue:
                                  loginDataProvider.loginData?.firstName,
                              key: const ValueKey("name"),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "name_empty";
                                } else if (value.length > 40 ||
                                    value.length < 2) {
                                  return "name_short_long";
                                }
                                return null;
                              },
                              onSaved: (newValue) {
                                _firstName = newValue;
                              },
                              onChanged: (value) {
                                _firstName = value;
                              },
                              decoration: InputDecoration(
                                hintText: accountProvider.loginData?.firstName!,
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(16.0),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'last_name'.tr,
                              style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.04),
                            ),
                          ),
                          Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.0),
                              color: Colors.grey[200], // Background color
                            ),
                            child: TextFormField(
                              initialValue:
                                  loginDataProvider.loginData?.lastName,
                              key: const ValueKey("name"),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "name_empty";
                                } else if (value.length > 40 ||
                                    value.length < 2) {
                                  return "name_short_long";
                                }
                                return null;
                              },
                              onSaved: (newValue) {
                                _lastName = newValue;
                              },
                              onChanged: (value) {
                                _lastName = value;
                              },
                              decoration: InputDecoration(
                                hintText: accountProvider.loginData?.lastName,
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(16.0),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                child: Padding(
                  padding:
                      EdgeInsets.only(top: 15, bottom: 15, right: 30, left: 30),
                  child: Column(
                    children: [
                      _isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              style: const ButtonStyle(
                                  backgroundColor:
                                      MaterialStatePropertyAll(Colors.green),
                                  foregroundColor:
                                      MaterialStatePropertyAll(Colors.white),
                                  minimumSize: MaterialStatePropertyAll(
                                      Size(double.infinity, 50))),
                              onPressed: () => {
                                    submitForm(),
                                    // Navigator.push(context,
                                    //     MaterialPageRoute(builder: ((context) {
                                    //   return const VerificationScreen();
                                    // })))
                                  },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('submit'.tr),
                                  Icon(Icons.arrow_forward)
                                ],
                              )),
                    ],
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 250,
                alignment: Alignment.topCenter,
                padding: EdgeInsets.all(0),
                transformAlignment: Alignment.topCenter,
                child: Image(
                    image: AssetImage(
                        'assets/images/THICKET_MASTER_PATERN_04.png'),
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.fill, // Set the desired width
                    height: MediaQuery.of(context)
                        .size
                        .height // Set the desired height
                    ),
              )
            ],
          )),
    );
  }
}
