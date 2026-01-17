# 🔄 Guía de Migración - Base de Datos Supabase

## 📋 Opciones de Migración

### **Opción 1: Migrar a otra cuenta Supabase**

#### 1. Exportar desde Supabase origen
```sql
-- En SQL Editor de Supabase origen, ejecutar:
-- Ver archivo: export_supabase.sql
```

#### 2. Crear nuevo proyecto Supabase
- Ir a https://supabase.com
- Crear nuevo proyecto
- Copiar nueva URL y API Key

#### 3. Importar en Supabase destino
- Ejecutar scripts generados en paso 1
- Subir archivos CSV a las tablas

### **Opción 2: PostgreSQL Local**

#### 1. Instalar PostgreSQL
```bash
# Windows
# Descargar desde: https://www.postgresql.org/download/windows/

# Configurar:
# Usuario: postgres
# Password: tu_password
# Puerto: 5432
```

#### 2. Configurar base de datos
```bash
# Ejecutar archivo: setup_local_postgres.sql
psql -U postgres -f migration/setup_local_postgres.sql
```

#### 3. Actualizar conexión en Flutter
```dart
// En lib/main.dart cambiar:
await Supabase.initialize(
  url: 'postgresql://postgres:password@localhost:5432/biblioteca_virtual',
  anonKey: 'tu_clave_local', // No necesaria para PostgreSQL directo
);
```

### **Opción 3: Docker PostgreSQL (Recomendado)**

#### 1. Crear docker-compose.yml
```yaml
version: '3.8'
services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: biblioteca_virtual
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: admin123
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./migration:/docker-entrypoint-initdb.d
volumes:
  postgres_data:
```

#### 2. Ejecutar
```bash
docker-compose up -d
```

## 🛠️ Herramientas de Migración

### **pg_dump (Recomendado)**
```bash
# Exportar desde Supabase
pg_dump "postgresql://postgres:[PASSWORD]@db.[PROJECT].supabase.co:5432/postgres" > backup.sql

# Importar a PostgreSQL local
psql -U postgres -d biblioteca_virtual -f backup.sql
```

### **Supabase CLI**
```bash
# Instalar
npm install -g supabase

# Exportar
supabase db dump --db-url "postgresql://..." > dump.sql

# Importar
supabase db reset --db-url "postgresql://..."
```

## 📝 Pasos Detallados

### 1. **Backup Completo Supabase**
```bash
# Obtener URL de conexión desde Supabase Dashboard > Settings > Database
pg_dump "postgresql://postgres:[PASSWORD]@db.[PROJECT].supabase.co:5432/postgres" \
  --schema=public \
  --data-only \
  --inserts > data_backup.sql

pg_dump "postgresql://postgres:[PASSWORD]@db.[PROJECT].supabase.co:5432/postgres" \
  --schema=public \
  --schema-only > schema_backup.sql
```

### 2. **Migrar Storage/Archivos**
```bash
# Descargar archivos de Supabase Storage
# Usar Supabase Dashboard o API para descargar
# Subir a nuevo destino o servidor local
```

### 3. **Actualizar Configuración Flutter**
```dart
// Para PostgreSQL local
class DatabaseConfig {
  static const String host = 'localhost';
  static const int port = 5432;
  static const String database = 'biblioteca_virtual';
  static const String username = 'postgres';
  static const String password = 'admin123';
}
```

## ⚡ Migración Rápida (Recomendada)

### Usar pg_dump + Docker
```bash
# 1. Exportar Supabase
pg_dump "tu_url_supabase" > backup.sql

# 2. Levantar PostgreSQL local
docker run --name postgres-biblioteca \
  -e POSTGRES_DB=biblioteca_virtual \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=admin123 \
  -p 5432:5432 \
  -d postgres:15

# 3. Importar datos
docker exec -i postgres-biblioteca psql -U postgres -d biblioteca_virtual < backup.sql
```

## 🔧 Configurar Conexión Local

Crear archivo `lib/config/database_config.dart`:
```dart
class DatabaseConfig {
  static const bool useSupabase = false; // Cambiar a false para local
  
  // Supabase
  static const String supabaseUrl = 'https://tu-proyecto.supabase.co';
  static const String supabaseKey = 'tu-clave';
  
  // PostgreSQL Local
  static const String localHost = 'localhost';
  static const int localPort = 5432;
  static const String localDatabase = 'biblioteca_virtual';
  static const String localUser = 'postgres';
  static const String localPassword = 'admin123';
}
```

¿Qué opción prefieres? Te ayudo a implementarla paso a paso.