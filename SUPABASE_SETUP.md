# Setup Supabase - 100% Gratis

## 1. Crear cuenta Supabase
1. Ve a https://supabase.com
2. Sign up (gratis, sin tarjeta)
3. Create new project
4. Nombre: "biblioteca-digital"

## 2. Obtener credenciales
1. Settings > API
2. Copia:
   - Project URL
   - anon public key

## 3. Configurar en Flutter
En main.dart reemplaza Firebase.initializeApp() con:

```dart
await Supabase.initialize(
  url: 'TU_PROJECT_URL',
  anonKey: 'TU_ANON_KEY',
);
```

## 4. Crear tabla users
En Supabase Dashboard > SQL Editor:

```sql
CREATE TABLE users (
  id UUID PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  role TEXT DEFAULT 'user',
  created_at TIMESTAMP DEFAULT NOW()
);
```

## 5. Habilitar RLS
```sql
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own data" ON users
FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can insert own data" ON users
FOR INSERT WITH CHECK (auth.uid() = id);
```

## Ventajas Supabase:
- ✅ 100% gratis sin tarjeta
- ✅ 500MB base de datos
- ✅ 2GB transferencia
- ✅ Authentication incluido
- ✅ Compatible con Netlify