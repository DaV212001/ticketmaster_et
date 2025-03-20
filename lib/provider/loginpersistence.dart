import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ticketmaster_et/prefs/config_preferences.dart';

import '../models/newmodels.dart';

class LoginDataProvider extends GetxController {
  Rxn<LoginData> loginDataObs = Rxn<LoginData>();

  LoginData? get loginData => loginDataObs.value;

  Future<void> setLoginData(LoginData loginData) async {
    loginDataObs.value = loginData;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('loginData', json.encode(loginData.toJson()));
  }

  Future<void> loadLoginData() async {
    final prefs = ConfigPreference.getStorage();
    final storedLoginData = prefs.getString('loginData');
    Logger().d(storedLoginData);

    if (storedLoginData != null) {
      loginDataObs.value = LoginData.fromJson(json.decode(storedLoginData));
    }
  }

  Future<void> updateName(
      String firstName, String lastName, String phone, String email) async {
    if (loginDataObs.value != null) {
      loginDataObs.value = loginDataObs.value!.copyWith(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        email: email,
      );
      loginDataObs.refresh();
      await setLoginData(loginDataObs.value!);
    }
  }

  Future<void> updateProfileImage(String image) async {
    if (loginDataObs.value != null) {
      loginDataObs.value = loginDataObs.value!.copyWith(
        profileImage: image,
      );
      loginDataObs.refresh();
      await setLoginData(loginDataObs.value!);
    }
  }

  Future<void> clear() async {
    loginDataObs.value = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('loginData');
  }

  Future<bool> get isUserRegistered async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isUserRegistered') ?? false;
  }

  Future<void> setUserRegistered(bool isRegistered) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isUserRegistered', isRegistered);
  }

  Future<bool> get isUserLoggedIn async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isUserLoggedIn') ?? false;
  }

  Future<void> setUserLoggedIn(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isUserLoggedIn', isLoggedIn);
  }

  @override
  void onInit() {
    loadLoginData();
    super.onInit();
  }
}

class CommentsModel extends ChangeNotifier {
  List<Comment> _comments = [];

  List<Comment> get comments => _comments;

  void addComment(Comment comment) {
    _comments.add(comment);
    notifyListeners();
  }

  void addAllComments(List<Comment> newComments) {
    _comments.addAll(newComments);
    notifyListeners();
  }
}
