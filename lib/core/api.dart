import 'package:dio/dio.dart';
import 'env.dart';
import 'session.dart';

class Api {
  final Dio dio;
  Api()
    : dio = Dio(
        BaseOptions(
          baseUrl: apiBase(),
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {'Accept': 'application/json'},
        ),
      ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (o, h) async {
          final t = await Session.token;
          if (t != null && t.isNotEmpty)
            o.headers['Authorization'] = 'Bearer $t';
          h.next(o);
        },
      ),
    );
  }

  Future<Map<String, dynamic>> login(String email, String pass) async {
    final r = await dio.post(
      '/login',
      data: {'email': email, 'password': pass},
    );
    return r.data as Map<String, dynamic>;
  }
}
