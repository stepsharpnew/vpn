import 'package:flutter/material.dart';
import 'package:test_app/constants/app_colors.dart';
import 'home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VPN',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.darkBackground,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.neonBlue,
          secondary: AppColors.neonPurple,
          surface: AppColors.darkSurface,
          background: AppColors.darkBackground,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
