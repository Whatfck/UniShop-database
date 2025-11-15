-- =========================================
-- Unishop MVP Database Schema
-- =========================================

-- Users table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    role VARCHAR(50) DEFAULT 'USER',
    password VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    profile_image VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Categories table
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Products table
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2),
    status VARCHAR(50) DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'SOLD', 'DELETED')),
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    category_id INTEGER REFERENCES categories(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Favorites table
CREATE TABLE favorites (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES products(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, product_id)
);

-- Metrics table
CREATE TABLE metrics (
    product_id INTEGER PRIMARY KEY REFERENCES products(id) ON DELETE CASCADE,
    views INTEGER DEFAULT 0,
    contacts INTEGER DEFAULT 0,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- Product images table
CREATE TABLE product_images (
    id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES products(id) ON DELETE CASCADE,
    image_url VARCHAR(500) NOT NULL,
    is_primary BOOLEAN DEFAULT FALSE,
    order_index INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Phone verifications table
CREATE TABLE phone_verifications (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    phone_number VARCHAR(20) NOT NULL,
    verification_code VARCHAR(10) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- Indexes for performance
CREATE INDEX idx_products_status ON products(status);
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_products_user ON products(user_id);
CREATE INDEX idx_products_search ON products USING gin(to_tsvector('spanish', name || ' ' || COALESCE(description, '')));
CREATE INDEX idx_product_images_product ON product_images(product_id);
CREATE INDEX idx_product_images_primary ON product_images(product_id, is_primary);

-- Function to update updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON products FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_metrics_updated_at BEFORE UPDATE ON metrics FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Initial categories
INSERT INTO categories (name) VALUES
('Libros'),
('Tecnología'),
('Material de Laboratorio'),
('Arquitectura'),
('Útiles Escolares'),
('Otros');

-- Seed users for development (UCC Campus Pasto students)
-- Password for all users: "password" (BCrypt hashed)
INSERT INTO users (email, name, role, password, phone, profile_image) VALUES
('admin@unishop.com', 'Administrador UCC', 'USER', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+573001234567', NULL),
('sofia.mendoza@campusucc.edu.co', 'Sofía Mendoza', 'USER', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+573007654321', 'https://picsum.photos/200/200?random=100'),
('andres.torres@campusucc.edu.co', 'Andrés Torres', 'USER', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+573002468135', NULL),
('valentina.lopez@campusucc.edu.co', 'Valentina López', 'USER', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+573009876543', 'https://picsum.photos/200/200?random=101'),
('miguel.aguilar@campusucc.edu.co', 'Miguel Aguilar', 'USER', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+573005432109', NULL);

-- Seed products for development (UCC Campus Pasto academic materials)
INSERT INTO products (name, description, price, user_id, category_id, status) VALUES
-- Sofía Mendoza (user_id: 2) - Estudiante Enfermería
('Estetoscopio Littmann Classic III', 'Estetoscopio profesional para prácticas de enfermería. Excelente estado, incluye diafragma y campana.', 350000.00, 2, 3, 'ACTIVE'),
('Fundamentos de Enfermería - Potter & Perry', 'Libro de texto fundamental para enfermería. Edición 2022, muy buen estado, sin subrayados.', 120000.00, 2, 1, 'ACTIVE'),
('Kit de Venopunción', 'Set completo para práctica de venopunción: torniquete, jeringas, agujas, alcohol. Estado nuevo.', 45000.00, 2, 3, 'ACTIVE'),

-- Andrés Torres (user_id: 3) - Estudiante Ingeniería Software
('Clean Code - Robert C. Martin', 'Libro esencial para desarrollo de software. Edición original, excelente estado.', 85000.00, 3, 1, 'ACTIVE'),
('Arduino Starter Kit', 'Kit completo de Arduino UNO con sensores, cables y protoboard. Ideal para proyectos IoT.', 180000.00, 3, 2, 'ACTIVE'),
('Calculadora Científica Casio FX-991ES Plus', 'Calculadora avanzada para matemáticas e ingeniería. Funciones de cálculo integral y derivadas.', 120000.00, 3, 5, 'ACTIVE'),

-- Valentina López (user_id: 4) - Estudiante Derecho
('Teoría del Estado - Hans Kelsen', 'Texto fundamental de teoría constitucional. Edición 2020, muy buen estado.', 65000.00, 4, 1, 'ACTIVE'),
('Derecho Constitucional - Manuel Aragón', 'Libro de texto para derecho constitucional colombiano. Edición actualizada.', 95000.00, 4, 1, 'ACTIVE'),
('Código Penal Colombiano 2024', 'Edición oficial del Código Penal colombiano. Indispensable para estudiantes de derecho.', 45000.00, 4, 1, 'ACTIVE'),

-- Miguel Aguilar (user_id: 5) - Estudiante Odontología
('Instrumental Odontológico Básico', 'Set de instrumental odontológico: pinzas, excavadores, curetas. Marca Hu-Friedy, excelente estado.', 280000.00, 5, 3, 'ACTIVE'),
('Patología Oral y Maxilofacial - Neville', 'Libro de texto fundamental para odontología. Edición 2022, muy buen estado.', 150000.00, 5, 1, 'ACTIVE'),
('Turbina Dental NSK', 'Turbina dental de alta velocidad con acoplamiento. Perfecta para prácticas odontológicas.', 450000.00, 5, 3, 'ACTIVE'),

-- Admin UCC (user_id: 1) - Administrador plataforma
('Microscopio Óptico binocular', 'Microscopio profesional para laboratorio de biología y medicina. 400x-1000x aumentos.', 750000.00, 1, 3, 'ACTIVE'),
('Proyector Epson EB-S41', 'Proyector SVGA de 3200 lúmenes para aulas. Perfecto para presentaciones académicas.', 850000.00, 1, 2, 'ACTIVE'),
('Diccionario Oxford de Ingeniería', 'Diccionario técnico especializado en ingeniería. Edición 2023, nuevo.', 120000.00, 1, 1, 'ACTIVE');

-- Product images (3 images per product - academic context)
INSERT INTO product_images (product_id, image_url, is_primary, order_index) VALUES
-- Sofía Mendoza products (Enfermería - products 1-3)
(1, 'https://picsum.photos/400/300?random=10', true, 0),
(1, 'https://picsum.photos/400/300?random=11', false, 1),
(1, 'https://picsum.photos/400/300?random=12', false, 2),
(2, 'https://picsum.photos/400/300?random=13', true, 0),
(2, 'https://picsum.photos/400/300?random=14', false, 1),
(2, 'https://picsum.photos/400/300?random=15', false, 2),
(3, 'https://picsum.photos/400/300?random=16', true, 0),
(3, 'https://picsum.photos/400/300?random=17', false, 1),
(3, 'https://picsum.photos/400/300?random=18', false, 2),

-- Andrés Torres products (Ingeniería Software - products 4-6)
(4, 'https://picsum.photos/400/300?random=19', true, 0),
(4, 'https://picsum.photos/400/300?random=20', false, 1),
(4, 'https://picsum.photos/400/300?random=21', false, 2),
(5, 'https://picsum.photos/400/300?random=22', true, 0),
(5, 'https://picsum.photos/400/300?random=23', false, 1),
(5, 'https://picsum.photos/400/300?random=24', false, 2),
(6, 'https://picsum.photos/400/300?random=25', true, 0),
(6, 'https://picsum.photos/400/300?random=26', false, 1),
(6, 'https://picsum.photos/400/300?random=27', false, 2),

-- Valentina López products (Derecho - products 7-9)
(7, 'https://picsum.photos/400/300?random=28', true, 0),
(7, 'https://picsum.photos/400/300?random=29', false, 1),
(7, 'https://picsum.photos/400/300?random=30', false, 2),
(8, 'https://picsum.photos/400/300?random=31', true, 0),
(8, 'https://picsum.photos/400/300?random=32', false, 1),
(8, 'https://picsum.photos/400/300?random=33', false, 2),
(9, 'https://picsum.photos/400/300?random=34', true, 0),
(9, 'https://picsum.photos/400/300?random=35', false, 1),
(9, 'https://picsum.photos/400/300?random=36', false, 2),

-- Miguel Aguilar products (Odontología - products 10-12)
(10, 'https://picsum.photos/400/300?random=37', true, 0),
(10, 'https://picsum.photos/400/300?random=38', false, 1),
(10, 'https://picsum.photos/400/300?random=39', false, 2),
(11, 'https://picsum.photos/400/300?random=40', true, 0),
(11, 'https://picsum.photos/400/300?random=41', false, 1),
(11, 'https://picsum.photos/400/300?random=42', false, 2),
(12, 'https://picsum.photos/400/300?random=43', true, 0),
(12, 'https://picsum.photos/400/300?random=44', false, 1),
(12, 'https://picsum.photos/400/300?random=45', false, 2),

-- Admin UCC products (products 13-15)
(13, 'https://picsum.photos/400/300?random=46', true, 0),
(13, 'https://picsum.photos/400/300?random=47', false, 1),
(13, 'https://picsum.photos/400/300?random=48', false, 2),
(14, 'https://picsum.photos/400/300?random=49', true, 0),
(14, 'https://picsum.photos/400/300?random=50', false, 1),
(14, 'https://picsum.photos/400/300?random=51', false, 2),
(15, 'https://picsum.photos/400/300?random=52', true, 0),
(15, 'https://picsum.photos/400/300?random=53', false, 1),
(15, 'https://picsum.photos/400/300?random=54', false, 2);

-- Seed favorites for development (sample user favorites - randomly distributed)
INSERT INTO favorites (user_id, product_id) VALUES
-- Sofía Mendoza (user_id: 2) - Enfermería student
(2, 4), -- Clean Code book
(2, 5), -- Arduino kit
(2, 8), -- Derecho Constitucional
(2, 12), -- Turbina Dental

-- Andrés Torres (user_id: 3) - Software Engineering student
(3, 1), -- Estetoscopio
(3, 7), -- Teoría del Estado
(3, 9), -- Código Penal
(3, 11), -- Patología Oral

-- Valentina López (user_id: 4) - Law student
(4, 5), -- Arduino kit
(4, 13), -- Microscopio
(4, 2), -- Fundamentos de Enfermería
(4, 6), -- Calculadora Científica

-- Miguel Aguilar (user_id: 5) - Dentistry student
(5, 3), -- Kit de Venopunción
(5, 4), -- Clean Code
(5, 8), -- Derecho Constitucional
(5, 14), -- Proyector Epson

-- Admin UCC (user_id: 1) - Platform administrator
(1, 6), -- Calculadora Científica
(1, 10), -- Instrumental Odontológico
(1, 15); -- Diccionario Oxford