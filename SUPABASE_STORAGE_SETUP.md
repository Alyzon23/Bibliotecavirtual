# Configurar Supabase Storage

## 1. Crear buckets en Supabase
Ve a Storage en tu dashboard y crea:

```sql
-- Crear buckets
INSERT INTO storage.buckets (id, name, public) VALUES 
('books', 'books', true),
('covers', 'covers', true);

-- Políticas para books
CREATE POLICY "Anyone can view books" ON storage.objects
FOR SELECT USING (bucket_id = 'books');

CREATE POLICY "Admins can upload books" ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'books' AND 
  EXISTS (
    SELECT 1 FROM users 
    WHERE users.id = auth.uid() 
    AND users.role = 'admin'
  )
);

-- Políticas para covers
CREATE POLICY "Anyone can view covers" ON storage.objects
FOR SELECT USING (bucket_id = 'covers');

CREATE POLICY "Admins can upload covers" ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'covers' AND 
  EXISTS (
    SELECT 1 FROM users 
    WHERE users.id = auth.uid() 
    AND users.role = 'admin'
  )
);
```

## 2. Límites gratuitos Storage
- 1GB almacenamiento
- 2GB transferencia/mes
- Perfecto para biblioteca pequeña