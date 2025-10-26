# Setup Firebase - Web y Android

## 🔥 Configuración Automática (Recomendado)

### 1. Instalar FlutterFire CLI
```bash
dart pub global activate flutterfire_cli
```

### 2. Configurar Firebase automáticamente
```bash
flutterfire configure
```
- Selecciona/crea proyecto "biblioteca-digital"
- Selecciona plataformas: **Web** y **Android**
- Esto genera automáticamente toda la configuración

### 3. Instalar dependencias
```bash
flutter pub get
```

## 📱 Build para ambas plataformas

### Web (Netlify)
```bash
flutter build web
# Sube carpeta build/web a Netlify
```

### Android APK
```bash
flutter build apk
# APK en build/app/outputs/flutter-apk/
```

## 👤 Crear primer admin
1. Ejecuta la app y regístrate
2. Ve a Firebase Console > Firestore
3. Encuentra tu usuario en colección 'users'
4. Cambia campo 'role' de 'user' a 'admin'

## ✅ Listo para usar
- Registro/Login funcional
- Base de datos real
- Compatible web y móvil