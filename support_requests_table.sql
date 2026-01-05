-- Tabla para solicitudes de soporte
-- Ejecutar en Supabase SQL Editor

CREATE TABLE IF NOT EXISTS support_requests (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  description TEXT NOT NULL,
  type VARCHAR(50) DEFAULT 'ayuda' CHECK (type IN ('ayuda', 'configuracion', 'reporte', 'otro')),
  status VARCHAR(50) DEFAULT 'pendiente' CHECK (status IN ('pendiente', 'resuelto')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  resolved_at TIMESTAMP WITH TIME ZONE,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Habilitar RLS (Row Level Security)
ALTER TABLE support_requests ENABLE ROW LEVEL SECURITY;

-- Política para que los usuarios vean sus propias solicitudes
CREATE POLICY "Users can view own requests" ON support_requests
  FOR SELECT USING (auth.uid() = user_id);

-- Política para que los usuarios puedan crear solicitudes
CREATE POLICY "Users can insert own requests" ON support_requests
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Política para que los admins vean todas las solicitudes
CREATE POLICY "Admins can view all requests" ON support_requests
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM users 
      WHERE users.id = auth.uid() 
      AND users.role = 'admin'
    )
  );

-- Política para que los admins puedan actualizar solicitudes
CREATE POLICY "Admins can update requests" ON support_requests
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM users 
      WHERE users.id = auth.uid() 
      AND users.role = 'admin'
    )
  );

-- Política para que los admins puedan eliminar solicitudes
CREATE POLICY "Admins can delete requests" ON support_requests
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM users 
      WHERE users.id = auth.uid() 
      AND users.role = 'admin'
    )
  );

-- Función para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger para actualizar updated_at
CREATE TRIGGER update_support_requests_updated_at 
    BEFORE UPDATE ON support_requests 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();