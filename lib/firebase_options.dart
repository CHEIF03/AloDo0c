import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB1sYNLggu2MAqi6aOpsVY1LeeLFzFM1ug',
    appId: '1:42140892607:web:055f1072ff23b15cb7b50a',
    messagingSenderId: '42140892607',
    projectId: 'alodoc-8a399',
    authDomain: 'alodoc-8a399.firebaseapp.com',
    storageBucket: 'alodoc-8a399.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB1sYNLggu2MAqi6aOpsVY1LeeLFzFM1ug',
    appId: '1:42140892607:android:a9ea68c83386d409b7b50a',
    messagingSenderId: '42140892607',
    projectId: 'alodoc-8a399',
    storageBucket: 'alodoc-8a399.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB1sYNLggu2MAqi6aOpsVY1LeeLFzFM1ug',
    appId: '1:42140892607:ios:YOUR_IOS_APP_ID',
    messagingSenderId: '42140892607',
    projectId: 'alodoc-8a399',
    storageBucket: 'alodoc-8a399.firebasestorage.app',
    iosBundleId: 'com.alodoc',
  );
}