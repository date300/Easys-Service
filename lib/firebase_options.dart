import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform, kIsWeb;

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
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC786WSjnhlWcebz_niVba0USi5HbPJa2Q',
    appId: '1:753217579632:android:1bd1cda362b9afd3c2e2b5',
    messagingSenderId: '753217579632',
    projectId: 'easyservice-86513',
    storageBucket: 'easyservice-86513.firebasestorage.app',
  );

  // Web, iOS, macOS, Windows এর জন্য আলাদা app যোগ করা হয়নি।
  // প্রয়োজন হলে Firebase Console থেকে যোগ করুন।
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC786WSjnhlWcebz_niVba0USi5HbPJa2Q',
    appId: '1:753217579632:android:1bd1cda362b9afd3c2e2b5',
    messagingSenderId: '753217579632',
    projectId: 'easyservice-86513',
    storageBucket: 'easyservice-86513.firebasestorage.app',
    authDomain: 'easyservice-86513.firebaseapp.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC786WSjnhlWcebz_niVba0USi5HbPJa2Q',
    appId: '1:753217579632:android:1bd1cda362b9afd3c2e2b5',
    messagingSenderId: '753217579632',
    projectId: 'easyservice-86513',
    storageBucket: 'easyservice-86513.firebasestorage.app',
    iosBundleId: 'com.easyservice.easyservice',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC786WSjnhlWcebz_niVba0USi5HbPJa2Q',
    appId: '1:753217579632:android:1bd1cda362b9afd3c2e2b5',
    messagingSenderId: '753217579632',
    projectId: 'easyservice-86513',
    storageBucket: 'easyservice-86513.firebasestorage.app',
    iosBundleId: 'com.easyservice.easyservice',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC786WSjnhlWcebz_niVba0USi5HbPJa2Q',
    appId: '1:753217579632:android:1bd1cda362b9afd3c2e2b5',
    messagingSenderId: '753217579632',
    projectId: 'easyservice-86513',
    storageBucket: 'easyservice-86513.firebasestorage.app',
    authDomain: 'easyservice-86513.firebaseapp.com',
  );
}
