-- CONFIGURACIÓN POSTGRESQL LOCAL
-- Ejecutar después de instalar PostgreSQL

-- 1. CREAR BASE DE DATOS
CREATE DATABASE biblioteca_virtual;

-- 2. CONECTAR A LA BASE DE DATOS
\c biblioteca_virtual;

-- 3. CREAR EXTENSIONES NECESARIAS
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 4. CREAR ESQUEMAS
CREATE SCHEMA IF NOT EXISTS auth;
CREATE SCHEMA IF NOT EXISTS storage;

-- 5. CREAR TABLA DE USUARIOS (simplificada)
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    role VARCHAR(50) DEFAULT 'lector',
    name VARCHAR(255),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. CREAR TABLAS PRINCIPALES
CREATE TABLE books (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(255) NOT NULL,
    author VARCHAR(255),
    description TEXT,
    pdf_url TEXT,
    cover_url TEXT,
    category VARCHAR(100),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE videos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    video_url TEXT,
    thumbnail_url TEXT,
    category VARCHAR(100),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. INSERTAR USUARIO ADMIN
INSERT INTO users (email, password_hash, role, name) VALUES 
('admin@yavirac.edu.ec', crypt('admin123', gen_salt('bf')), 'admin', 'Administrador');

-- 8. INSERTAR DATOS DE EJEMPLO
INSERT INTO books (title, author, description, category) VALUES 
('Fundamentos de Programación', 'Juan Pérez', 'Libro básico de programación', 'Tecnología'),
('Historia del Ecuador', 'María González', 'Historia completa del Ecuador', 'Historia');

INSERT INTO videos (title, description, category) VALUES 
('Introducción a Flutter', 'Tutorial básico de Flutter', 'Tecnología'),
('Patrimonio Cultural', 'Documentos sobre patrimonio', 'Cultura');