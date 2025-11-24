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
    // Interceptor: Agrega el token automáticamente si existe
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (o, h) async {
          final t = await Session.token;
          if (t != null && t.isNotEmpty) {
            o.headers['Authorization'] = 'Bearer $t';
          }
          h.next(o);
        },
      ),
    );
  }

  // 1. Función Login
  Future<Map<String, dynamic>> login(String email, String pass) async {
    final r = await dio.post(
      '/login',
      data: {'email': email, 'password': pass},
    );
    return r.data as Map<String, dynamic>;
  }

  // 2. NUEVA FUNCIÓN: Esta es la que te faltaba
  Future<void> completeOnboarding() async {
    // Llama a la ruta de Laravel para cambiar estatus a 1
    // No necesitamos headers manuales, el interceptor de arriba ya pone el token
    await dio.post('/onboarding-complete');
  }
}
