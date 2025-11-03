import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:ticketmaster_et/controllers/theme_controller.dart';
import 'package:ticketmaster_et/prefs/language_selector.dart';

import '../functions/functions.dart';
import '../models/newmodels.dart';
import '../provider/loginpersistence.dart';
import '../widgets/phone_input_field.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _firstName, _lastName, _email;
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  bool _isUploading = false;
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      await _uploadProfileImage(_imageFile!);
    }
  }

  Future<void> _uploadProfileImage(File imageFile) async {
    try {
      setState(() {
        _isUploading = true; // Start uploading
      });

      final loginDataProvider = Get.find<LoginDataProvider>(tag: 'login');
      int? userId = loginDataProvider.loginData?.id;

      var request = http.MultipartRequest('POST',
          Uri.parse('https://api.hellomesa6810.com/api/change-profile-image'));
      request.fields['user_id'] = userId.toString();
      request.files
          .add(await http.MultipartFile.fromPath('image', imageFile.path));

      var response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await http.Response.fromStream(response);
        final jsonResponse = json.decode(responseData.body);

        // Update the profile image in LoginData
        LoginData updatedData = LoginData.fromJson(jsonResponse['data']);
        loginDataProvider.updateProfileImage(updatedData.profileImage!);

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text(
                'profile_pic_updated'.tr,
                style: const TextStyle(color: Colors.green),
              ),
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text(
                'failed_pic_update'.tr,
                style: const TextStyle(color: Colors.red),
              ),
            );
          },
        );
      }
    } catch (e) {
      print('Error uploading profile picture: $e');
    } finally {
      setState(() {
        _isUploading = false; // Finish uploading
      });
    }
  }

  final TextEditingController _phoneNumber = TextEditingController(
      text: Get.find<LoginDataProvider>(tag: 'login')
          .loginData
          ?.phone
          ?.replaceFirst('251', ''));

  Future submitForm() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      final accountProvider = Get.find<LoginDataProvider>(tag: 'login');

      int? id = accountProvider.loginData?.id!;
      String? languageCode = ThemeModeController.languageCode.value == 'es'
          ? 'tg'
          : ThemeModeController.languageCode.value == 'it'
              ? 'or'
              : ThemeModeController.languageCode.value == 'fr'
                  ? 'so'
                  : ThemeModeController.languageCode.value;
      UpdatedUser data = UpdatedUser(
          id: id,
          firstName: _firstName,
          lastName: _lastName,
          phone: '251${_phoneNumber.text}',
          email: _email,
          language: languageCode);

      await updateUser(data).then((value) async {
        if (value.message != null) {
          if (value.message == "User Updated successfully") {
            await accountProvider.updateName(_firstName!, _lastName!,
                '251${_phoneNumber.text}', _email ?? '');
            Get.back();
            Get.snackbar('success'.tr, 'success_edit'.tr,
                backgroundColor: Colors.green, colorText: Colors.white);
          }
        } else {
          String errorMessage = "error_update".tr;
          if (value.error!.firstName != null) {
            errorMessage = errorMessageConcatenator(value.error!.firstName!);
          }
          if (value.error!.LastName != null) {
            errorMessage = errorMessageConcatenator(value.error!.LastName!);
          }
          if (value.error!.phone != null) {
            errorMessage = errorMessageConcatenator(value.error!.phone!);
          }
          if (value.error!.email != null) {
            errorMessage = errorMessageConcatenator(value.error!.email!);
          }

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.green),
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
    // final languageChange = Provider.of<SettingsProvider>(context);
    final accountProvider = Get.find<LoginDataProvider>(tag: 'login');
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Change this to your desired color
      statusBarIconBrightness: Brightness.light, // For light icons
      statusBarBrightness: Brightness.dark, // For iOS status bar
    ));

    final profileImage = loginDataProvider.loginData?.profileImage;
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(30.0),
                          child: Column(
                            children: [
                              Center(
                                child: Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: 85,
                                      backgroundImage: profileImage != null
                                          ? NetworkImage(profileImage)
                                          : const AssetImage(
                                                  'assets/images/THICKET_MASTER_LOGO.png')
                                              as ImageProvider,
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: -10,
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.green,
                                          size: 30,
                                        ),
                                        onPressed: _pickImage,
                                      ),
                                    ),
                                    if (_isUploading)
                                      Positioned.fill(
                                        child: Container(
                                          height: 85,
                                          width: 85,
                                          decoration: const BoxDecoration(
                                            color: Colors
                                                .black45, // Semi-transparent overlay
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Center(
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Text(
                                'editprofile'.tr,
                                style: const TextStyle(
                                    fontSize: 25, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 15),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  'first_name'.tr,
                                  style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.04),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
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
                                    hintText:
                                        accountProvider.loginData?.firstName!,
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.all(16.0),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  'last_name'.tr,
                                  style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.04),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
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
                                    hintText:
                                        accountProvider.loginData?.lastName,
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.all(16.0),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  'email'.tr,
                                  style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.04),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15.0),
                                  color: Colors.grey[200], // Background color
                                ),
                                child: TextFormField(
                                  initialValue:
                                      loginDataProvider.loginData?.email,
                                  key: const ValueKey("email"),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "email_empty".tr;
                                    } else if (!value.isEmail) {
                                      return "invalid_email".tr;
                                    }
                                    return null;
                                  },
                                  onSaved: (newValue) {
                                    _email = newValue;
                                  },
                                  onChanged: (value) {
                                    _email = value;
                                  },
                                  decoration: InputDecoration(
                                    hintText: accountProvider.loginData?.email,
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.all(16.0),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              PhoneInputField(
                                controller: _phoneNumber,
                                initialValue: accountProvider.loginData?.phone,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 15, bottom: 15, right: 30, left: 30),
                          child: Column(
                            children: [
                              _isLoading
                                  ? const CircularProgressIndicator()
                                  : ElevatedButton(
                                      style: const ButtonStyle(
                                          backgroundColor:
                                              WidgetStatePropertyAll(
                                                  Colors.green),
                                          foregroundColor:
                                              WidgetStatePropertyAll(
                                                  Colors.white),
                                          minimumSize: WidgetStatePropertyAll(
                                              Size(double.infinity, 50))),
                                      onPressed: () => {
                                            submitForm(),
                                            // Navigator.push(context,
                                            //     MaterialPageRoute(builder: ((context) {
                                            //   return const VerificationScreen();
                                            // })))
                                          },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text('submit'.tr),
                                          const Icon(Icons.arrow_forward)
                                        ],
                                      )),
                            ],
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: 250,
                          alignment: Alignment.topCenter,
                          padding: const EdgeInsets.all(0),
                          transformAlignment: Alignment.topCenter,
                          child: Image(
                              image: const AssetImage(
                                  'assets/images/THICKET_MASTER_PATERN_04.png'),
                              width: MediaQuery.of(context).size.width,
                              fit: BoxFit.fill, // Set the desired width
                              height: MediaQuery.of(context)
                                  .size
                                  .height // Set the desired height
                              ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          )),
    );
  }
}
