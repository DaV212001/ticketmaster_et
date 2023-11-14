import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/newmodels.dart';

class LoginDataProvider with ChangeNotifier {
  LoginData? _loginData;

  LoginData? get loginData => _loginData;

  Future<void> setLoginData(LoginData loginData) async {
    _loginData = loginData;

    // Convert loginData to JSON and save it in SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('loginData', json.encode(loginData.toJson()));

    notifyListeners();
  }

  Future<void> loadLoginData() async {
    // Load loginData from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final storedLoginData = prefs.getString('loginData');

    if (storedLoginData != null) {
      _loginData = LoginData.fromJson(json.decode(storedLoginData));
      notifyListeners();
    }
  }

  Future<void> updateName(String firstName, String lastName) async {
    _loginData = LoginData(
        id: _loginData?.id,
        email: _loginData?.email,
        password: _loginData?.password,
        firstName: firstName,
        lastName: lastName,
        profileImage: _loginData?.profileImage,
        phone: _loginData?.phone,
        cityId:_loginData?.cityId,
        emailVerifiedAt:_loginData?.emailVerifiedAt,
        roleId:_loginData?.roleId,
        lang:_loginData?.lang,
        darkMode:_loginData?.darkMode,
        promocode:_loginData?.promocode,
        token:_loginData?.token,
        createdAt:_loginData?.createdAt,
        updatedAt:_loginData?.updatedAt
    );
    if (_loginData != null) {
      await setLoginData(_loginData!);
    }
    notifyListeners();
  }



  Future<void> clear() async {
    _loginData = null;

    // Clear login data from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('loginData');

    notifyListeners();
  }

  Future<bool> get isUserRegistered async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isUserRegistered') ?? false;
  }

  Future<void> setUserRegistered(bool isRegistered) async {
    // Save isUserRegistered to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isUserRegistered', isRegistered);

    notifyListeners();
  }

  Future<bool> get isUserLoggedIn async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isUserLoggedIn') ?? false;
  }

  Future<void> setUserLoggedIn(bool isLoggedIn) async {
    // Save isUserLoggedIn to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isUserLoggedIn', isLoggedIn);

    notifyListeners();
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
