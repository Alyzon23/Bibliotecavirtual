-- Solución: Agregar política para que admins vean todos los usuarios
-- Ejecutar en Supabase SQL Editor

-- Crear política para que admins y bibliotecarios vean todos los usuarios
CREATE POLICY "Admins can view all users" ON users
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM users 
      WHERE users.id = auth.uid() 
      AND users.role IN ('admin', 'bibliotecario')
    )
  );

-- Crear política para que admins actualicen todos los usuarios  
CREATE POLICY "Admins can update all users" ON users
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM users 
      WHERE users.id = auth.uid() 
      AND users.role IN ('admin', 'bibliotecario')
    )
  );