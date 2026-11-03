import 'package:shared_preferences/shared_preferences.dart';

class UserPref {
  /// Guarda só o necessário para a sessão local. A senha NÃO é persistida:
  /// o Firebase Auth mantém a sessão sozinho.
  static Future<void> setUser(String name, String email, String uid) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString('NAME', name);
    await pref.setString('EMAIL', email);
    await pref.setString('NODE', uid);
    await pref.setString('TOKEN', uid);
    // instalações antigas guardavam a senha em texto puro: apaga na hora
    await pref.remove('PASSWORD');
  }

  static Future<Map<dynamic, dynamic>> getUser() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.remove('PASSWORD');
    return {
      'NAME': pref.getString('NAME') ?? '',
      'EMAIL': pref.getString('EMAIL') ?? '',
      'NODE': pref.getString('NODE') ?? '',
      'TOKEN': pref.getString('TOKEN') ?? '',
    };
  }

  /// Nome salvo no aparelho (null se nunca houve login).
  static Future<String?> savedName() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString('NAME');
  }

  // Migração do nó das tasks (email -> uid): feita uma vez por conta/aparelho.
  static String _migrationKey(String uid) => 'SYNC_NODE_UID_$uid';

  static Future<bool> isNodeMigrated(String uid) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getBool(_migrationKey(uid)) ?? false;
  }

  static Future<void> markNodeMigrated(String uid) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setBool(_migrationKey(uid), true);
  }
}
