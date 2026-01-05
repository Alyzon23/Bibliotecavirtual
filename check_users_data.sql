-- Verificar si hay usuarios en la base de datos
SELECT COUNT(*) as total_users FROM users;

-- Ver todos los usuarios
SELECT id, email, name, role, created_at FROM users;