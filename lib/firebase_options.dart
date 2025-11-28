// Placeholder: замінити через `flutterfire configure`
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return const FirebaseOptions(
          apiKey: 'AIzaSyA0eBCK-wH1LDkACUpkbw5Lx_DCjQ0tFuo',
          appId: '1:362207324240:android:REPLACE_ME',
          messagingSenderId: '362207324240',
          projectId: 'fitflow-6ce21',
        );
      case TargetPlatform.iOS:
        return const FirebaseOptions(
          apiKey: 'AIzaSyA0eBCK-wH1LDkACUpkbw5Lx_DCjQ0tFuo',
          appId: '1:362207324240:ios:REPLACE_ME',
          messagingSenderId: '362207324240',
          projectId: 'fitflow-6ce21',
          iosBundleId: 'REPLACE_ME',
        );
      default:
        return const FirebaseOptions(
          apiKey: 'AIzaSyA0eBCK-wH1LDkACUpkbw5Lx_DCjQ0tFuo',
          appId: '1:362207324240:web:ff236de31ff23a6222c955',
          messagingSenderId: '362207324240',
          projectId: 'fitflow-6ce21',
        );
    }
  }
}
