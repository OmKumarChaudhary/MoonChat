import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:moonchat/screens/onboard/onboarding_screen.dart';
import 'package:moonchat/screens/auth/login_screen.dart';
import 'package:moonchat/screens/auth/signup_screen.dart';
import 'package:moonchat/screens/home_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MoonChat',
      theme: ThemeData(
        fontFamily: 'Mulish',
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: const Color(0xFF151522),
      ),
      home: const OnboardingScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
