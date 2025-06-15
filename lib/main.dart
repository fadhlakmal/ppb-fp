import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:myapp/app/configs/firebase_options.dart';
import 'package:myapp/app/screens/main_screen.dart';
import 'package:myapp/app/screens/login_screen.dart';
import 'package:myapp/app/screens/recipe_list_screen.dart';
import 'package:myapp/app/screens/register_screen.dart';
import 'package:myapp/app/screens/add_ingredient_screen.dart';
import 'package:myapp/app/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  await NotificationService.initializeNotification();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      initialRoute: 'main',
      routes: {
        'main': (context) => const MainScreen(),
        'login': (context) => const LoginScreen(),
        'register': (context) => const RegisterScreen(),
        'add_ingredient': (context) => const AddIngredientScreen(),
        'recipe': (context) => const RecipeListScreen(),
      },
    );
  }
}
