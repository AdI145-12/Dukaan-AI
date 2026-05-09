import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kIsWeb;

/// ASSUMPTION: Temporary placeholder options to keep scaffold compile-ready.
/// Replace this file by running: flutterfire configure --project=<your-project-id>
class DefaultFirebaseOptions {
  const DefaultFirebaseOptions._();

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'placeholder',
    appId: '1:000000000000:web:placeholder',
    messagingSenderId: '000000000000',
    projectId: 'placeholder',
    authDomain: 'placeholder.firebaseapp.com',
    storageBucket: 'placeholder.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDDzkIoNozw1ncZra8V5tQSmoKVrm_NGpI',
    appId: '1:25973964554:android:eae807d270eb90c4ea84f3',
    messagingSenderId: '25973964554',
    projectId: 'dukaanai-68da7',
    storageBucket: 'dukaanai-68da7.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'placeholder',
    appId: '1:000000000000:ios:placeholder',
    messagingSenderId: '000000000000',
    projectId: 'placeholder',
    storageBucket: 'placeholder.appspot.com',
    iosBundleId: 'com.example.dukaanAI',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'placeholder',
    appId: '1:000000000000:macos:placeholder',
    messagingSenderId: '000000000000',
    projectId: 'placeholder',
    storageBucket: 'placeholder.appspot.com',
    iosBundleId: 'com.example.dukaanAI',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'placeholder',
    appId: '1:000000000000:windows:placeholder',
    messagingSenderId: '000000000000',
    projectId: 'placeholder',
    storageBucket: 'placeholder.appspot.com',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'placeholder',
    appId: '1:000000000000:linux:placeholder',
    messagingSenderId: '000000000000',
    projectId: 'placeholder',
    storageBucket: 'placeholder.appspot.com',
  );
}