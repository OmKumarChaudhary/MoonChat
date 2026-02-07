import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:moonchat/screens/onboard/onboarding_screen.dart';
import 'package:moonchat/screens/auth/login_screen.dart';
import 'package:moonchat/screens/auth/signup_screen.dart';
import 'package:moonchat/screens/profile/profile_setup_screen.dart';
import 'package:moonchat/screens/home_screen.dart';
import 'package:moonchat/screens/profile/account_settings_screen.dart';
import 'package:moonchat/screens/profile/linked_accounts_screen.dart';
import 'package:moonchat/services/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Enable Firestore offline persistence
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final ChatService _chatService = ChatService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _chatService.updateUserStatus(true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _chatService.updateUserStatus(true);
    } else {
      _chatService.updateUserStatus(false);
    }
  }

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
        '/profile_setup': (context) => const ProfileSetupScreen(),
        '/home': (context) => const HomeScreen(),
        '/account_settings': (context) => const AccountSettingsScreen(),
        '/linked_accounts': (context) => const LinkedAccountsScreen(),
      },
    );
  }
}
