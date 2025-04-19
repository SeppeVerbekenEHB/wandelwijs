import 'package:flutter/material.dart';
// Remove the flutter_dotenv import
import 'routes/app_routes.dart';
import 'screens/login/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/register/register_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/missions/missions_screen.dart';
import 'screens/album/album_screen.dart';
import 'screens/scan/scan_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/widget_tree.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Remove the dotenv.load line
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WandelWijs',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'RetroChild', // Set default font family
      ),
      home: const WidgetTree(),
      routes: {
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.register: (context) => const RegisterScreen(),
        AppRoutes.home: (context) => const HomeScreen(),
        AppRoutes.profile: (context) => const ProfileScreen(),
        AppRoutes.missions: (context) => const MissionsScreen(),
        AppRoutes.album: (context) => const AlbumScreen(),
        AppRoutes.scan: (context) => const ScanScreen(),
      },
    );
  }
}