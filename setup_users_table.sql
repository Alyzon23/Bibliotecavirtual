-- Script para crear y configurar la tabla users
-- Ejecutar en Supabase SQL Editor

-- 1. Crear tabla users si no existe
CREATE TABLE IF NOT EXISTS users (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  email VARCHAR(255) NOT NULL UNIQUE,
  name VARCHAR(255) NOT NULL,
  role VARCHAR(50) DEFAULT 'lector' CHECK (role IN ('admin', 'bibliotecario', 'profesor', 'lector')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Habilitar RLS (Row Level Security)
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- 3. Eliminar políticas existentes si existen
DROP POLICY IF EXISTS "Users can view own profile" ON users;
DROP POLICY IF EXISTS "Users can update own profile" ON users;
DROP POLICY IF EXISTS "Admins can view all users" ON users;
DROP POLICY IF EXISTS "Admins can update all users" ON users;
DROP POLICY IF EXISTS "Public can view users" ON users;

-- 4. Crear políticas de seguridad

-- Política para que los usuarios vean su propio perfil
CREATE POLICY "Users can view own profile" ON users
  FOR SELECT USING (auth.uid() = id);

-- Política para que los usuarios actualicen su propio perfil
CREATE POLICY "Users can update own profile" ON users
  FOR UPDATE USING (auth.uid() = id);

-- Política para que los admins vean todos los usuarios
CREATE POLICY "Admins can view all users" ON users
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM users 
      WHERE users.id = auth.uid() 
      AND users.role IN ('admin', 'bibliotecario')
    )
  );

-- Política para que los admins actualicen todos los usuarios
CREATE POLICY "Admins can update all users" ON users
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM users 
      WHERE users.id = auth.uid() 
      AND users.role IN ('admin', 'bibliotecario')
    )
  );

-- Política para que los admins eliminen usuarios
CREATE POLICY "Admins can delete users" ON users
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM users 
      WHERE users.id = auth.uid() 
      AND users.role = 'admin'
    )
  );

-- 5. Función para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 6. Trigger para actualizar updated_at
DROP TRIGGER IF EXISTS update_users_updated_at ON users;
CREATE TRIGGER update_users_updated_at 
    BEFORE UPDATE ON users 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- 7. Función para crear automáticamente un registro en users cuando se registra un usuario
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, email, name, role)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'name', 'Usuario'),
    'lector'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 8. Trigger para ejecutar la función cuando se crea un nuevo usuario
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 9. Insertar usuarios de prueba si no existen
INSERT INTO users (id, email, name, role, created_at) 
SELECT 
  gen_random_uuid(),
  'admin@biblioteca.com',
  'Administrador',
  'admin',
  NOW()
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'admin@biblioteca.com');

INSERT INTO users (id, email, name, role, created_at) 
SELECT 
  gen_random_uuid(),
  'bibliotecario@biblioteca.com',
  'Bibliotecario',
  'bibliotecario',
  NOW()
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'bibliotecario@biblioteca.com');

INSERT INTO users (id, email, name, role, created_at) 
SELECT 
  gen_random_uuid(),
  'profesor@biblioteca.com',
  'Profesor',
  'profesor',
  NOW()
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'profesor@biblioteca.com');

-- 10. Función RPC para crear la tabla (para usar desde Flutter)
CREATE OR REPLACE FUNCTION create_users_table()
RETURNS TEXT AS $$
BEGIN
  -- Esta función ya no es necesaria ya que la tabla se crea arriba
  -- Pero la mantenemos para compatibilidad
  RETURN 'Tabla users ya existe y está configurada correctamente';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;