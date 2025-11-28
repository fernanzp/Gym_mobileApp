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
          if (t != null && t.isNotEmpty) {
            o.headers['Authorization'] = 'Bearer $t';
          }
          h.next(o);
        },
      ),
    );
  }

  Future<Map<String, dynamic>> login(String email, String pass) async {
    final r = await dio.post('/login', data: {'email': email, 'password': pass});
    if (r.data['token'] != null) {
      // Guardamos con tu método
      await Session.saveToken(r.data['token']);
    }
    return r.data as Map<String, dynamic>;
  }

  Future<void> completeOnboarding() async {
    await dio.post('/onboarding-complete');
  }

  Future<Map<String, dynamic>> getAforo() async {
    final r = await dio.get('/aforo');
    return r.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getHeaderData() async {
    final r = await dio.get('/header-data');
    return r.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    final r = await dio.get('/user-profile');
    return r.data as Map<String, dynamic>;
  }

  Future<void> logout() async {
    try { await dio.post('/logout'); } catch (_) {}
    await Session.clear();
  }

  Future<Map<String, dynamic>> getBusynessStats() async {
    final r = await dio.get('/gym-stats');
    return r.data as Map<String, dynamic>;
  }
  
}