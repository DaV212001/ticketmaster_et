import 'package:dio/dio.dart';

import '../dio_config.dart';
import '../logging_wrapper.dart';

class DioService {
  static Future<void> dioPost({
    required String path,
    Options? options,
    Object? data,
    Function(Response)? onSuccess,
    Function(Object, Response)? onFailure,
  }) async {
    Response response = Response(requestOptions: RequestOptions());
    try {
      response = await DioConfig.dio().post(path, options: options, data: data);
      AppLogger().d(response.data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (onSuccess != null) onSuccess(response);
      } else {
        if (onFailure != null) onFailure(response.statusCode!, response);
      }
    } catch (e, stack) {
      AppLogger().d(path);
      AppLogger().t(e.toString(), stackTrace: stack);
      // print(response.data);
      print(e.toString());
      print(stack);
      if (onFailure != null) onFailure(e, response);
    }
  }

  static Future<void> dioPostFormData({
    required String path,
    required Map<String, dynamic> formDataFields,
    Map<String, MultipartFile>? files,
    Options? options,
    Function(Response)? onSuccess,
    Function(Object, Response)? onFailure,
  }) async {
    Response response = Response(requestOptions: RequestOptions());

    try {
      // Combine fields and files into FormData
      final formData = FormData.fromMap({
        ...formDataFields,
        if (files != null) ...files,
      });

      response = await DioConfig.dio().post(
        path,
        options: options ??
            Options(
              contentType: 'multipart/form-data',
              headers: {'Accept': 'application/json'},
            ),
        data: formData,
      );
      AppLogger().d(response.data);
      AppLogger().d(response.statusCode);
      AppLogger().d(response.statusMessage);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (onSuccess != null) onSuccess(response);
      } else {
        if (onFailure != null) onFailure(response.statusCode!, response);
      }
    } catch (e, stack) {
      AppLogger().d(path);
      AppLogger().t(e.toString(), stackTrace: stack);
      print(e.toString());
      print(stack);
      if (onFailure != null) onFailure(e, response);
    }
  }

  static Future<void> dioGet({
    required String path,
    Options? options,
    Object? data,
    Function(Response)? onSuccess,
    Function(Object, Response)? onFailure,
  }) async {
    AppLogger().d(path);
    Response response = Response(requestOptions: RequestOptions());
    try {
      response = await DioConfig.dio().get(path, options: options, data: data);
      // AppLogger().w("RAW: ${response.data.runtimeType}");
      // AppLogger().w("RAW DATA: ${response.data}");

      print(response.data);
      AppLogger().d(response.data);
      if (response.statusCode == 200) {
        if (onSuccess != null) onSuccess(response);
      } else {
        if (onFailure != null) onFailure(response.statusCode!, response);
      }
    } catch (e, stack) {
      AppLogger().d(path);
      AppLogger().d(response.data);
      AppLogger().t(e.toString(), stackTrace: stack);
      // print(response.data);
      print(e.toString());
      print(stack);
      if (onFailure != null) onFailure(e, response);
    }
  }

  static Future<void> dioDelete({
    required String path,
    Options? options,
    Object? data,
    Function(Response)? onSuccess,
    Function(Object, Response)? onFailure,
  }) async {
    Response response = Response(requestOptions: RequestOptions());
    try {
      response = await DioConfig.dio().delete(
        path,
        options: options,
        data: data,
      );
      print(response.data);
      AppLogger().d(response.data);
      if (response.statusCode == 200) {
        if (onSuccess != null) onSuccess(response);
      } else {
        if (onFailure != null) onFailure(response.statusCode!, response);
      }
    } catch (e, stack) {
      AppLogger().d(path);
      AppLogger().t(e.toString(), stackTrace: stack);
      // print(response.data);
      print(e.toString());
      print(stack);
      if (onFailure != null) onFailure(e, response);
    }
  }

  static Future<void> dioPatch({
    required String path,
    Options? options,
    Object? data,
    Function(Response)? onSuccess,
    Function(Object, Response)? onFailure,
  }) async {
    Response response = Response(requestOptions: RequestOptions());
    try {
      response = await DioConfig.dio().patch(
        path,
        options: options,
        data: data,
      );
      AppLogger().d(response.data);
      if (response.statusCode == 200) {
        if (onSuccess != null) onSuccess(response);
      } else {
        if (onFailure != null) onFailure(response.statusCode!, response);
      }
    } catch (e, stack) {
      AppLogger().d(path);
      AppLogger().t(e.toString(), stackTrace: stack);
      print(e.toString());
      print(stack);
      if (onFailure != null) onFailure(e, response);
    }
  }
}
