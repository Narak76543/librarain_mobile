import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_router.dart';
import 'core/theme/app_color.dart';
import 'core/theme/app_text_style.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'providers/app_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  final preferences = await SharedPreferences.getInstance();
  final isLoggedIn = preferences.getBool('is_logged_in') ?? false;

  runApp(
    MultiProvider(
      providers: appProviders,
      child: MyApp(isLoggedIn: isLoggedIn),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.isLoggedIn = false});

  final bool isLoggedIn;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: createAppRouter(isLoggedIn: isLoggedIn),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        fontFamily: AppTextStyle.fontFamily,
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
      ),
    );
  }
}
