-- Función para incrementar las vistas de un libro
-- Ejecutar este SQL en el editor SQL de Supabase

CREATE OR REPLACE FUNCTION increment_book_views(book_id UUID)
RETURNS void AS $$
BEGIN
  -- Insertar o actualizar las estadísticas del libro
  INSERT INTO book_stats (book_id, open_count, created_at, updated_at)
  VALUES (book_id, 1, NOW(), NOW())
  ON CONFLICT (book_id)
  DO UPDATE SET 
    open_count = book_stats.open_count + 1,
    updated_at = NOW();
END;
$$ LANGUAGE plpgsql;

-- Crear tabla de favoritos si no existe
CREATE TABLE IF NOT EXISTS favorites (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  book_id UUID REFERENCES books(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, book_id)
);

-- Habilitar RLS (Row Level Security) para favoritos
ALTER TABLE favorites ENABLE ROW LEVEL SECURITY;

-- Política para que los usuarios solo vean sus propios favoritos
CREATE POLICY "Users can view own favorites" ON favorites
  FOR SELECT USING (auth.uid() = user_id);

-- Política para que los usuarios puedan insertar sus propios favoritos
CREATE POLICY "Users can insert own favorites" ON favorites
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Política para que los usuarios puedan eliminar sus propios favoritos
CREATE POLICY "Users can delete own favorites" ON favorites
  FOR DELETE USING (auth.uid() = user_id);