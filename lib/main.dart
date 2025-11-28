import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app_theme.dart';
import 'screens/splash_screen.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'services/local_photo_service.dart';
import 'providers/auth_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Avoid duplicate initialization when performing hot reload/hot restart
  // or if Firebase is already initialized by other code.
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    }
  } catch (e) {
    // Some environments (or native auto-init) may initialize Firebase already
    // and calling initializeApp again can throw a duplicate-app error.
    // Ignore that specific error and rethrow others.
    final msg = e.toString().toLowerCase();
    if (!(msg.contains('duplicate-app') || msg.contains('already exists') || msg.contains('already-initialized'))) {
      rethrow;
    }
  }
  runApp(const MyTrainerApp());
}

class MyTrainerApp extends StatelessWidget {
  const MyTrainerApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(AuthService())),
        Provider(create: (_) => FirestoreService()),
        Provider(create: (_) => LocalPhotoService()),
      ],
      child: MaterialApp(
        title: 'MyTrainer',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        home: const SplashScreen(),
      ),
    );
  }
}
