import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:to_do_app/data/notifications/notification_service.dart';
import 'package:to_do_app/res/routes/app_routes.dart';
import 'package:to_do_app/res/translations/app_translations.dart';
import 'package:to_do_app/res/translations/language_service.dart';

// Sem projeto Firebase real: usa o Firebase Emulator local
// (npx firebase-tools emulators:start --project demo-tasksync)
const bool useFirebaseEmulator = true;

void main()async{
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (useFirebaseEmulator) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'demo-api-key',
          appId: '1:123456789012:ios:1234567890abcdef123456',
          messagingSenderId: '123456789',
          projectId: 'demo-tasksync',
          databaseURL: 'http://127.0.0.1:9000?ns=demo-tasksync-default-rtdb',
        ),
      );
      await FirebaseAuth.instance.useAuthEmulator('127.0.0.1', 9099);
      FirebaseDatabase.instance.useDatabaseEmulator('127.0.0.1', 9000);
    } else {
      await Firebase.initializeApp();
    }
  } catch (e) {
    debugPrint('Firebase não inicializado: $e');
  }
  await NotificationService.init();
  await initializeDateFormatting();
  final locale = await LanguageService.savedLocale();
  runApp(MyApp(initialLocale: locale));
}
class MyApp extends StatelessWidget {
  final Locale initialLocale;
  const MyApp({super.key, this.initialLocale = AppTranslations.fallback});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      translations: AppTranslations(),
      locale: initialLocale,
      fallbackLocale: AppTranslations.fallback,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      getPages: AppRoutes.routes(),
    );
  }
}

