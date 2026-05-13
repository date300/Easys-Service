import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

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
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'DEMO_API_KEY',
    appId: 'DEMO_APP_ID',
    messagingSenderId: 'DEMO_SENDER_ID',
    projectId: 'DEMO_PROJECT_ID',
    authDomain: 'DEMO_AUTH_DOMAIN',
    storageBucket: 'DEMO_STORAGE_BUCKET',
    measurementId: 'DEMO_MEASUREMENT_ID',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'DEMO_API_KEY',
    appId: 'DEMO_APP_ID',
    messagingSenderId: 'DEMO_SENDER_ID',
    projectId: 'DEMO_PROJECT_ID',
    storageBucket: 'DEMO_STORAGE_BUCKET',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'DEMO_API_KEY',
    appId: 'DEMO_APP_ID',
    messagingSenderId: 'DEMO_SENDER_ID',
    projectId: 'DEMO_PROJECT_ID',
    storageBucket: 'DEMO_STORAGE_BUCKET',
    iosBundleId: 'com.demo.easyservice',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'DEMO_API_KEY',
    appId: 'DEMO_APP_ID',
    messagingSenderId: 'DEMO_SENDER_ID',
    projectId: 'DEMO_PROJECT_ID',
    storageBucket: 'DEMO_STORAGE_BUCKET',
    iosBundleId: 'com.demo.easyservice',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'DEMO_API_KEY',
    appId: 'DEMO_APP_ID',
    messagingSenderId: 'DEMO_SENDER_ID',
    projectId: 'DEMO_PROJECT_ID',
    authDomain: 'DEMO_AUTH_DOMAIN',
    storageBucket: 'DEMO_STORAGE_BUCKET',
    measurementId: 'DEMO_MEASUREMENT_ID',
  );
}
