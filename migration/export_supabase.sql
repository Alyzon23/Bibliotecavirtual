-- MIGRACIÓN SUPABASE - EXPORTAR DATOS
-- Ejecutar en SQL Editor de Supabase origen

-- 1. EXPORTAR ESTRUCTURA DE TABLAS
SELECT 
    'CREATE TABLE ' || table_name || ' (' ||
    string_agg(
        column_name || ' ' || 
        CASE 
            WHEN data_type = 'character varying' THEN 'VARCHAR(' || character_maximum_length || ')'
            WHEN data_type = 'text' THEN 'TEXT'
            WHEN data_type = 'integer' THEN 'INTEGER'
            WHEN data_type = 'bigint' THEN 'BIGINT'
            WHEN data_type = 'boolean' THEN 'BOOLEAN'
            WHEN data_type = 'timestamp with time zone' THEN 'TIMESTAMPTZ'
            WHEN data_type = 'uuid' THEN 'UUID'
            ELSE data_type
        END ||
        CASE WHEN is_nullable = 'NO' THEN ' NOT NULL' ELSE '' END ||
        CASE WHEN column_default IS NOT NULL THEN ' DEFAULT ' || column_default ELSE '' END
        , ', '
    ) || ');'
FROM information_schema.columns 
WHERE table_schema = 'public' 
GROUP BY table_name;

-- 2. EXPORTAR POLÍTICAS RLS
SELECT 
    'ALTER TABLE ' || tablename || ' ENABLE ROW LEVEL SECURITY;'
FROM pg_tables 
WHERE schemaname = 'public';

SELECT 
    'CREATE POLICY "' || policyname || '" ON ' || tablename ||
    ' FOR ' || cmd || 
    CASE WHEN roles != '{public}' THEN ' TO ' || array_to_string(roles, ', ') ELSE '' END ||
    CASE WHEN qual IS NOT NULL THEN ' USING (' || qual || ')' ELSE '' END ||
    CASE WHEN with_check IS NOT NULL THEN ' WITH CHECK (' || with_check || ')' ELSE '' END || ';'
FROM pg_policies 
WHERE schemaname = 'public';

-- 3. EXPORTAR DATOS (copiar resultado y ejecutar en destino)
-- Para cada tabla, ejecutar:
-- COPY (SELECT * FROM books) TO STDOUT WITH CSV HEADER;
-- COPY (SELECT * FROM videos) TO STDOUT WITH CSV HEADER;
-- COPY (SELECT * FROM users) TO STDOUT WITH CSV HEADER;