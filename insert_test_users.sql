-- Insertar usuarios de prueba si la tabla está vacía
INSERT INTO users (id, email, name, role, created_at) VALUES
(gen_random_uuid(), 'admin@biblioteca.com', 'Administrador', 'admin', NOW()),
(gen_random_uuid(), 'bibliotecario@biblioteca.com', 'Bibliotecario', 'bibliotecario', NOW()),
(gen_random_uuid(), 'profesor@biblioteca.com', 'Profesor', 'profesor', NOW()),
(gen_random_uuid(), 'estudiante@biblioteca.com', 'Estudiante', 'lector', NOW());