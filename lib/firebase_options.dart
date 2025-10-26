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
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyD2lhQlTNBTHrJTGyMsBv4kdUvEJn96inE',
    appId: '1:958060515112:web:012d77e69f34d81247ca1d',
    messagingSenderId: '958060515112',
    projectId: 'biblioteca-digital-1738f',
    authDomain: 'biblioteca-digital-1738f.firebaseapp.com',
    storageBucket: 'biblioteca-digital-1738f.firebasestorage.app',
    measurementId: 'G-P8CC9HQC92',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD2lhQlTNBTHrJTGyMsBv4kdUvEJn96inE',
    appId: '1:958060515112:android:PLACEHOLDER',
    messagingSenderId: '958060515112',
    projectId: 'biblioteca-digital-1738f',
    storageBucket: 'biblioteca-digital-1738f.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD2lhQlTNBTHrJTGyMsBv4kdUvEJn96inE',
    appId: '1:958060515112:ios:PLACEHOLDER',
    messagingSenderId: '958060515112',
    projectId: 'biblioteca-digital-1738f',
    storageBucket: 'biblioteca-digital-1738f.firebasestorage.app',
    iosBundleId: 'com.biblioteca.digital',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD2lhQlTNBTHrJTGyMsBv4kdUvEJn96inE',
    appId: '1:958060515112:ios:PLACEHOLDER',
    messagingSenderId: '958060515112',
    projectId: 'biblioteca-digital-1738f',
    storageBucket: 'biblioteca-digital-1738f.firebasestorage.app',
    iosBundleId: 'com.biblioteca.digital',
  );
}