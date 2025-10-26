# Configuración de Firebase

## 1. Crear proyecto en Firebase Console
1. Ve a https://console.firebase.google.com/
2. Crea un nuevo proyecto llamado "biblioteca-digital"
3. Habilita Authentication y Firestore Database

## 2. Configurar Authentication
1. En Authentication > Sign-in method
2. Habilita "Email/Password"

## 3. Configurar Firestore
1. En Firestore Database > Create database
2. Selecciona "Start in test mode"
3. Elige una ubicación cercana

## 4. Obtener configuración web
1. En Project Settings > General
2. Scroll down a "Your apps"
3. Click en el ícono web (</>)
4. Registra tu app con nombre "biblioteca-digital-web"
5. Copia la configuración y reemplaza en main.dart:

```dart
await Firebase.initializeApp(
  options: const FirebaseOptions(
    apiKey: 'TU_API_KEY',
    appId: 'TU_APP_ID', 
    messagingSenderId: 'TU_SENDER_ID',
    projectId: 'TU_PROJECT_ID',
  ),
);
```

## 5. Para crear admin inicial
Registra un usuario normal y luego en Firestore:
1. Ve a la colección 'users'
2. Encuentra tu usuario
3. Cambia el campo 'role' de 'user' a 'admin'

## 6. Deploy en Netlify
```bash
flutter build web
# Sube la carpeta build/web a Netlify
```