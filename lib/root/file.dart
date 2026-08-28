import 'package:shared_preferences/shared_preferences.dart';

abstract class GerenciarArquivo {
  static const String _chave = 'abastecimentos_registros';

  static Future<void> salvar(String texto) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chave, texto);
  }

  static Future<String> abrir() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_chave) ?? '';
  }
}
