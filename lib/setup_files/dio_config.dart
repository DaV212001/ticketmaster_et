import 'package:dio/dio.dart';
import 'package:get/get.dart' as g;
import 'package:ticketmaster_et/functions/functions.dart';
import 'package:ticketmaster_et/prefs/routes.dart';

import '../prefs/config_preferences.dart';
import 'logging_wrapper.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    AppLogger().i({
      'url': options.uri.toString(),
      'method': options.method,
      'headers': options.headers,
      'body': options.data,
    });
    super.onRequest(options, handler);
  }
}

class AuthInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.statusCode == 401 &&
            (response.data['message'] as String).contains('Unauthorized') ||
        (response.data['message'] as String).contains('Unauthenticated')) {
      g.Get.toNamed(Routes.loginRoute);
      ConfigPreference.clear();
    }
    super.onResponse(response, handler);
  }
}

class DioConfig {
  static Dio dio() {
    Dio dio = Dio(
      BaseOptions(
        baseUrl: baseUrlFunc,
        validateStatus: (status) => true,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 120),
      ),
    );
    dio.interceptors.addAll([
      LoggingInterceptor(),
    ]);
    return dio;
  }

  static String convertDioError(DioException e) {
    String errorMessage = 'Unknown error occurred';
    switch (e.type) {
      case DioExceptionType.cancel:
        errorMessage = 'Request cancelled';
        break;
      case DioExceptionType.connectionTimeout:
        errorMessage = 'Connection timeout';
        break;
      case DioExceptionType.sendTimeout:
        errorMessage = 'Send timeout';
        break;
      case DioExceptionType.receiveTimeout:
        errorMessage = 'Receive timeout';
        break;
      case DioExceptionType.badResponse:
        errorMessage =
            'HTTP error ${e.response!.statusCode}: ${e.response!.statusMessage}';
        break;
      case DioExceptionType.unknown:
        errorMessage = 'Other Dio error occurred';
        break;
      case DioExceptionType.badCertificate:
        errorMessage = 'Bad certificate, try switching devices';
      case DioExceptionType.connectionError:
        errorMessage = 'Connection error, check your internet';
    }
    return errorMessage;
  }
}
