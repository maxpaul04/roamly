import 'package:flutter/material.dart';
import 'screens/feed_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'roamly',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepOrangeAccent,
            brightness: Brightness.dark
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const FeedPage(),
      },
    );
  }
}
