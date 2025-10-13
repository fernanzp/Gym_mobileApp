import 'dart:io';

String apiBase() {
  if (Platform.isAndroid) return 'http://10.0.2.2:8000/api'; // emulador Android
  return 'http://127.0.0.1:8000/api';                       // iOS sim / desktop
  // Físico: return 'http://<IP_DE_TU_PC>:8000/api';
}
