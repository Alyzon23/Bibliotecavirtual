-- Usuarios de prueba para la biblioteca digital
-- Ejecutar estos comandos en Supabase SQL Editor

-- 1. Bibliotecario
INSERT INTO auth.users (
  id,
  email,
  encrypted_password,
  email_confirmed_at,
  created_at,
  updated_at,
  raw_app_meta_data,
  raw_user_meta_data,
  is_super_admin,
  role
) VALUES (
  gen_random_uuid(),
  'bibliotecario@yavirac.edu.ec',
  crypt('biblio123', gen_salt('bf')),
  now(),
  now(),
  now(),
  '{"provider": "email", "providers": ["email"]}',
  '{}',
  false,
  'authenticated'
);

-- 2. Admin
INSERT INTO auth.users (
  id,
  email,
  encrypted_password,
  email_confirmed_at,
  created_at,
  updated_at,
  raw_app_meta_data,
  raw_user_meta_data,
  is_super_admin,
  role
) VALUES (
  gen_random_uuid(),
  'admin@yavirac.edu.ec',
  crypt('admin123', gen_salt('bf')),
  now(),
  now(),
  now(),
  '{"provider": "email", "providers": ["email"]}',
  '{}',
  false,
  'authenticated'
);

-- 3. Profesor
INSERT INTO auth.users (
  id,
  email,
  encrypted_password,
  email_confirmed_at,
  created_at,
  updated_at,
  raw_app_meta_data,
  raw_user_meta_data,
  is_super_admin,
  role
) VALUES (
  gen_random_uuid(),
  'profesor@yavirac.edu.ec',
  crypt('profe123', gen_salt('bf')),
  now(),
  now(),
  now(),
  '{"provider": "email", "providers": ["email"]}',
  '{}',
  false,
  'authenticated'
);

-- Ahora insertar en la tabla users (después de ejecutar los comandos de arriba)
-- Obtener los IDs de los usuarios creados y reemplazar en los INSERT de abajo

-- Insertar datos en tabla users
INSERT INTO users (id, email, name, role, created_at) VALUES
((SELECT id FROM auth.users WHERE email = 'bibliotecario@yavirac.edu.ec'), 'bibliotecario@yavirac.edu.ec', 'Bibliotecario Yavirac', 'bibliotecario', now()),
((SELECT id FROM auth.users WHERE email = 'admin@yavirac.edu.ec'), 'admin@yavirac.edu.ec', 'Administrador Yavirac', 'admin', now()),
((SELECT id FROM auth.users WHERE email = 'profesor@yavirac.edu.ec'), 'profesor@yavirac.edu.ec', 'Profesor Yavirac', 'profesor', now());