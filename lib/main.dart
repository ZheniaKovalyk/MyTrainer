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
import 'package:flutter/services.dart';


void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    }
  } catch (e) {
    final msg = e.toString().toLowerCase();
    if (!(msg.contains('duplicate-app') || msg.contains('already exists') || msg.contains('already-initialized'))) {
      rethrow;
    }
  }
 final authService = AuthService();
  await authService.init();
  try {
    final current = authService.currentUser;
    debugPrint('main: FirebaseAuth.currentUser after init -> ${current?.uid}');
  } catch (e) {
    debugPrint('main: FirebaseAuth.currentUser read ERROR: $e');
  }

  runApp(MyTrainerApp(authService: authService));
}

class MyTrainerApp extends StatelessWidget {
  final AuthService authService;
  const MyTrainerApp({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(authService)),
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
