import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // kDebugMode
import 'package:dio/dio.dart';

import '../core/api.dart';
import '../core/session.dart';
import 'theme/app_colors.dart'; // Importamos tus colores

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  final _api = Api();

  @override
  void initState() {
    super.initState();
    // Prefill en modo debug para probar rápido
    if (kDebugMode) {
      _emailCtrl.text = '';
      _passCtrl.text = '';
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _doLogin() async {
    debugPrint('>>> _doLogin PRESSED');
    if (!_formKey.currentState!.validate()) {
      debugPrint('>>> _doLogin: form inválido');
      return;
    }

    // Oculta el teclado
    FocusScope.of(context).unfocus();

    setState(() => _loading = true);
    try {
      debugPrint('>>> Haciendo POST /api/login ...');
      
      // 1. LLAMADA A LA API
      final data = await _api.login(_emailCtrl.text.trim(), _passCtrl.text);
      debugPrint('>>> Respuesta login: $data');

      final token = data['token'] as String?;
      final userMap = data['user'] as Map<String, dynamic>?;

      if (token == null || token.isEmpty) {
        throw Exception('Token vacío');
      }
      
      // Validamos que venga el estatus
      if (userMap == null) { // A veces userMap puede ser null si la API falla
         throw Exception('Datos de usuario no disponibles');
      }
      
      // Obtenemos el estatus (si no viene, asumimos 0 por seguridad)
      final int userStatus = userMap['estatus'] is int ? userMap['estatus'] : 0;

      // 2. GUARDAR TOKEN
      await Session.saveToken(token);

      // 3. LÓGICA DE USUARIO NUEVO
      // Si el usuario tiene estatus 0, significa que acaba de entrar por primera vez.
      // Le avisamos a Laravel que actualice su estatus a 1 para que no vuelva a ver la bienvenida.
      if (userStatus == 0) {
        debugPrint('>>> Usuario Nuevo (Estatus 0). Actualizando a 1...');
        try {
          await _api.completeOnboarding();
        } catch (e) {
          // Si falla esto no es crítico, dejamos pasar al usuario
          debugPrint('>>> Error actualizando estatus: $e');
        }
      }

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('¡Bienvenido!')));

      // 4. NAVEGACIÓN AL HOME
      // Usamos pushNamedAndRemoveUntil para borrar el historial.
      // Así, si le dan "atrás" en el Home, se salen de la app en vez de volver al Login.
      try {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      } catch (e) {
        debugPrint('>>> Error navegando a /home: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ruta /home no registrada')),
        );
      }

    } on DioException catch (e) {
      final code = e.response?.statusCode;
      final serverMsg =
          (e.response?.data is Map &&
              (e.response!.data as Map).containsKey('message'))
          ? e.response!.data['message'].toString()
          : null;
      final msg =
          serverMsg ??
          (code == 401
              ? 'Correo o contraseña incorrectos'
              : 'No se pudo iniciar sesión');
      debugPrint('>>> DioException: code=$code body=${e.response?.data}');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      debugPrint('>>> Error inesperado: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Error inesperado')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          FocusScope.of(context).unfocus(), // cerrar teclado al tocar fuera
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Flecha de retroceso
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                    onPressed: () {
                      // Si vienes de la pantalla de bienvenida, esto te regresa a ella
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Título principal
                  const Text(
                    'Inicia sesión',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Campo de correo electrónico
                  const Text(
                    'Correo electrónico',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      hintText: 'ejemplo@gmail.com',
                      filled: true,
                      fillColor: AppColors.grisBajito, // USANDO APP COLORS
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (v) {
                      final value = v?.trim() ?? '';
                      if (value.isEmpty) return 'Ingresa tu correo';
                      final ok = RegExp(
                        r'^[^@]+@[^@]+\.[^@]+$',
                      ).hasMatch(value);
                      return ok ? null : 'Correo inválido';
                    },
                  ),
                  const SizedBox(height: 16),

                  // Campo de contraseña
                  const Text(
                    'Contraseña',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _passCtrl,
                    obscureText: _obscure,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _loading ? null : _doLogin(),
                    decoration: InputDecoration(
                      hintText: 'Contraseña',
                      filled: true,
                      fillColor: AppColors.grisBajito, // USANDO APP COLORS
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.grisOscuro, // Icono en gris oscuro
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'Ingresa tu contraseña'
                        : null,
                  ),
                  const SizedBox(height: 28),

                  // Botón "Iniciar sesión"
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors
                            .azul, // USANDO APP COLORS (Azul corporativo)
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: _loading
                          ? null
                          : () async {
                              debugPrint('>>> Botón "Iniciar sesión" PRESSED');
                              await _doLogin();
                            },
                      child: _loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Iniciar sesión',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Registro en recepción
                  const SizedBox(height: 1),
                  Center(
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                        children: [
                          TextSpan(
                            text: '¿Aún no tienes cuenta? ',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                          TextSpan(
                            text: 'Regístrate en recepción.',
                            style: TextStyle(color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}