import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:roamly/services/mock_user_service.dart';
import 'package:roamly/services/sqflite_city_repository.dart';
import 'package:roamly/services/sqflite_user_repository.dart';
import 'firebase_options.dart';
import 'main_navigation.dart';
import 'themes/app_theme.dart';
import 'utils/continent_mapper.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  //Load mocked user profiles on first call of the app
  await MockUserService(
    userRepository: SqfliteUserRepository(),
    cityRepository: SqfliteCityRepository(),
  ).seedIfNeeded();
  
  // Load the country-to-continent mapping for autofilling city data
  await ContinentMapper.loadMapping();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, ThemeMode currentMode, _) {
        return MaterialApp(
          title: 'roamly',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          home: const MainNavigation(),
        );
      }
    );
  }
}
