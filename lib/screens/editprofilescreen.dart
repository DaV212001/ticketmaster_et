import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/fields.dart';
import '../functions/functions.dart';
import '../main_layout_screen.dart';
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
  String? _firstName, _lastName,
      _phoneNumber;

  Future submitForm() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {

      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      final accountProvider = Provider.of<LoginDataProvider>(context, listen: false);

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
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) {
                  return const TicketMatserHomePage(title: 'title');
                }));
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
                content: Text(errorMessage, style: TextStyle(color: Colors.green),),
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
    final languageChange = Provider.of<SettingsProvider>(context);
    final accountProvider = Provider.of<LoginDataProvider>(context, listen: false);
    return Container(
      decoration: BoxDecoration(
          color:Colors.grey[100],
          image: const DecorationImage(
              image: AssetImage("assets/images/THICKET_MASTER_PATERN_04.png"),
              fit: BoxFit.cover)
      ),
      child: SafeArea(
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
                        color: Colors.transparent
                    ),
                    child:  DropdownButton(
                        value: languageChange.languageCode,
                        items: const [
                          DropdownMenuItem(
                              value: 'en', child: Text('English')),
                          DropdownMenuItem(
                              value: 'am', child: Text('Amharic')),
                          DropdownMenuItem(
                              value: 'en-AU', child: Text('Afaan Oromo')),

                        ],
                        onChanged: (String? value) {
                          setState(() async {
                            languageChange.languageCode = value!;
                            List<String> codes = languageChange.languageCode.split('-');
                            String langCode = codes[0];
                            String countryCode = codes.length > 1 ? codes[1] : '';

                            // Save langCode and countryCode in shared preferences
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            await prefs.setString('langCode', langCode);
                            if (countryCode.isNotEmpty) {
                              await prefs.setString('countryCode', countryCode);
                            } else {
                              await prefs.remove('countryCode');
                            }

                            // Set locale for EasyLocalization
                            if (countryCode.isNotEmpty) {
                              EasyLocalization.of(context)!.setLocale(Locale(langCode, countryCode));
                            } else {
                              EasyLocalization.of(context)!.setLocale(Locale(langCode));
                            }
                          });
                        }
                    ),
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


                            Image(
                              image: AssetImage('assets/images/THICKET_MASTER_LOGO.png'),
                              width: 300.0, // Set the desired width
                              height: 300.0, // Set the desired height
                            ),
                            Text(
                              tr('editprofile'),
                              style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                            const SizedBox(height: 15),
                            Align(
                              alignment: Alignment.topLeft,
                              child: Text(tr('first_name'), style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.04),),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15.0),
                                color: Colors.grey[200], // Background color
                              ),
                              child: TextFormField(
                                key: const ValueKey("name"),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "name_empty";
                                  } else if (value.length > 40 || value.length < 2) {
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
                              child: Text(tr('last_name'), style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.04),),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15.0),
                                color: Colors.grey[200], // Background color
                              ),
                              child: TextFormField(
                                key: const ValueKey("name"),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "name_empty";
                                  } else if (value.length > 40 || value.length < 2) {
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
                              height: 25,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  child: Padding(
                    padding: EdgeInsets.only(top: 15, bottom: 15, right: 30, left: 30),
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
                                Text(tr('submit')),
                                Icon(Icons.arrow_forward)
                              ],
                            )),

                      ],
                    ),
                  ),
                )
              ],
            )),
      ),
    );
  }
}