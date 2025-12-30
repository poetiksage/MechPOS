import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiClient {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: dotenv.env["API_BASE_URL"]!.trim(),
      headers: {"Content-Type": "application/json"},
      validateStatus: (status) => status != null && status < 500,
    ),
  );

  static bool _initialized = false;

  static void _init() {
    if (_initialized) return;

    _dio.interceptors.add(CookieManager(CookieJar()));

    _initialized = true;
  }

  static Future<Map<String, dynamic>> get(String endpoint) async {
    _init();
    final res = await _dio.get("/$endpoint");
    return _handle(res);
  }

  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    _init();
    final res = await _dio.post("/$endpoint", data: body);
    return _handle(res);
  }

  static Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    _init();
    final res = await _dio.put("/$endpoint", data: body);
    return _handle(res);
  }

  static Future<Map<String, dynamic>> delete(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    _init();
    final res = await _dio.delete("/$endpoint", data: body);
    return _handle(res);
  }

  static Map<String, dynamic> _handle(Response res) {
    if (res.data == null) {
      throw Exception("Empty response from server");
    }

    if (res.statusCode == 401) {
      throw Exception("Unauthorized");
    }

    if (res.statusCode != null && res.statusCode! >= 400) {
      final msg = res.data["message"] ?? "Request failed";
      throw Exception(msg);
    }

    return res.data;
  }
}
