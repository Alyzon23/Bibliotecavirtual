-- Mostrar estructura actual de la base de datos
-- Ejecutar en Supabase SQL Editor para ver las tablas existentes

-- Ver todas las tablas
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public';

-- Ver estructura de la tabla users si existe
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_name = 'users' AND table_schema = 'public'
ORDER BY ordinal_position;

-- Ver datos de usuarios existentes
SELECT id, email, name, role, created_at 
FROM users 
ORDER BY created_at DESC;

-- Ver usuarios de auth.users
SELECT id, email, created_at, email_confirmed_at
FROM auth.users 
ORDER BY created_at DESC;

-- Ver políticas RLS de la tabla users
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
FROM pg_policies 
WHERE tablename = 'users';