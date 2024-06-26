// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyATLaGIprr5FGyOHzaCU1bONGLVxOVQ_Fc',
    appId: '1:809804152493:web:12ac50a1a75d4315985024',
    messagingSenderId: '809804152493',
    projectId: 'tfg-final-3a2f8',
    authDomain: 'tfg-final-3a2f8.firebaseapp.com',
    storageBucket: 'tfg-final-3a2f8.appspot.com',
    measurementId: 'G-8Q4TLXDCNE',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA_o-qtg3r9XWjurC8beO0FI9o7dI9v1b4',
    appId: '1:809804152493:android:614dd408ffda223d985024',
    messagingSenderId: '809804152493',
    projectId: 'tfg-final-3a2f8',
    storageBucket: 'tfg-final-3a2f8.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB8xMgrqVavpHJ_8VrW1anbqBmQP5MoxMU',
    appId: '1:809804152493:ios:a26dfd29c0913d1e985024',
    messagingSenderId: '809804152493',
    projectId: 'tfg-final-3a2f8',
    storageBucket: 'tfg-final-3a2f8.appspot.com',
    iosBundleId: 'com.example.prueba2',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB8xMgrqVavpHJ_8VrW1anbqBmQP5MoxMU',
    appId: '1:809804152493:ios:a26dfd29c0913d1e985024',
    messagingSenderId: '809804152493',
    projectId: 'tfg-final-3a2f8',
    storageBucket: 'tfg-final-3a2f8.appspot.com',
    iosBundleId: 'com.example.prueba2',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyATLaGIprr5FGyOHzaCU1bONGLVxOVQ_Fc',
    appId: '1:809804152493:web:0852808056024b32985024',
    messagingSenderId: '809804152493',
    projectId: 'tfg-final-3a2f8',
    authDomain: 'tfg-final-3a2f8.firebaseapp.com',
    storageBucket: 'tfg-final-3a2f8.appspot.com',
    measurementId: 'G-XS2SZLPLFY',
  );
}
