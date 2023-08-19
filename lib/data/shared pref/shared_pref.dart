import 'package:shared_preferences/shared_preferences.dart';

class UserPref{
  static Future<void> setUser(String name,String email,String password,String node,String token) async {

    SharedPreferences pref=await SharedPreferences.getInstance();
    pref.setString('NAME', name);
    pref.setString('EMAIL', email);
    pref.setString('PASSWORD', password);
    pref.setString('NODE', node);
    pref.setString('TOKEN', token);


    // print(name);
    // print(email);
    // print(password);
    // print(node);
    // print(token);


  }

  static Future<Map<dynamic,dynamic>> getUser() async {
    SharedPreferences pref=await SharedPreferences.getInstance();
    return {
      'NAME' : pref.getString('NAME')!,
      'EMAIL' : pref.getString('EMAIL')!,
      'PASSWORD' : pref.getString('PASSWORD')!,
      'NODE' : pref.getString('NODE')!,
      'TOKEN' : pref.getString('TOKEN')!,
    };
  }



}