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
    condition VARCHAR(50),
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
INSERT INTO users (email, name, role, password, phone, profile_image, created_at) VALUES
('admin@unishop.com', 'Administrador UniShop', 'ADMIN', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+573001234567', NULL, '2025-09-01 08:00:00'),
-- Ingeniería de Software (4 usuarios)
('sofia.mendoza@campusucc.edu.co', 'Sofía Mendoza', 'USER', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+573007654321', 'https://picsum.photos/200/200?random=100', '2025-09-01 08:00:00'),
('andres.torres@campusucc.edu.co', 'Andrés Torres', 'USER', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+573002468135', NULL, '2025-09-05 10:30:00'),
('valentina.lopez@campusucc.edu.co', 'Valentina López', 'USER', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+573009876543', 'https://picsum.photos/200/200?random=101', '2025-09-10 14:15:00'),
('miguel.aguilar@campusucc.edu.co', 'Miguel Aguilar', 'USER', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+573005432109', NULL, '2025-09-15 16:45:00'),
-- Enfermería (4 usuarios)
('camila.rodriguez@campusucc.edu.co', 'Camila Rodríguez', 'USER', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+573003579246', 'https://picsum.photos/200/200?random=102', '2025-09-03 09:20:00'),
('juan.perez@campusucc.edu.co', 'Juan Pérez', 'USER', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+573008642135', NULL, '2025-09-08 11:10:00'),
('laura.garcia@campusucc.edu.co', 'Laura García', 'USER', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+573004713582', 'https://picsum.photos/200/200?random=103', '2025-09-12 13:25:00'),
('carlos.martinez@campusucc.edu.co', 'Carlos Martínez', 'USER', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+573006985214', NULL, '2025-09-18 15:40:00'),
-- Derecho (4 usuarios)
('ana.sanchez@campusucc.edu.co', 'Ana Sánchez', 'USER', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+573001357924', 'https://picsum.photos/200/200?random=104', '2025-09-02 08:45:00'),
('diego.ramirez@campusucc.edu.co', 'Diego Ramírez', 'USER', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+573007419635', NULL, '2025-09-07 12:00:00'),
('maria.fernandez@campusucc.edu.co', 'María Fernández', 'USER', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+573005826473', 'https://picsum.photos/200/200?random=105', '2025-09-14 14:30:00'),
('luis.gonzalez@campusucc.edu.co', 'Luis González', 'USER', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+573009153728', NULL, '2025-09-20 16:15:00'),
-- Medicina (4 usuarios)
('catalina.herrera@campusucc.edu.co', 'Catalina Herrera', 'USER', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+573004682951', 'https://picsum.photos/200/200?random=106', '2025-09-04 10:00:00'),
('sebastian.castillo@campusucc.edu.co', 'Sebastián Castillo', 'USER', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+573008537419', NULL, '2025-09-09 11:45:00'),
('isabella.morales@campusucc.edu.co', 'Isabella Morales', 'USER', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+573002946817', 'https://picsum.photos/200/200?random=107', '2025-09-16 13:20:00'),
('felipe.ortiz@campusucc.edu.co', 'Felipe Ortiz', 'USER', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+573006713584', NULL, '2025-09-22 15:55:00'),
-- Odontología (4 usuarios)
('paula.diaz@campusucc.edu.co', 'Paula Díaz', 'USER', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+573003825716', 'https://picsum.photos/200/200?random=108', '2025-09-06 09:30:00'),
('nicolas.vargas@campusucc.edu.co', 'Nicolás Vargas', 'USER', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+573007164829', NULL, '2025-09-11 12:15:00'),
('daniela.ruiz@campusucc.edu.co', 'Daniela Ruiz', 'USER', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+573005937462', 'https://picsum.photos/200/200?random=109', '2025-09-17 14:45:00'),
('alejandro.jimenez@campusucc.edu.co', 'Alejandro Jiménez', 'USER', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '+573009428751', NULL, '2025-09-24 16:30:00');

-- Seed products for development (UCC Campus Pasto academic materials)
INSERT INTO products (name, description, price, user_id, category_id, condition, status, created_at) VALUES
-- Ingeniería de Software (Usuarios 2-5)
('Clean Code - Robert C. Martin', 'Libro esencial para desarrollo de software. Edición original, excelente estado.', 85000.00, 2, 1, 'Usado', 'ACTIVE', '2025-09-15 10:00:00'),
('Arduino Starter Kit', 'Kit completo de Arduino UNO con sensores, cables y protoboard. Ideal para proyectos IoT.', 180000.00, 2, 2, 'Nuevo', 'ACTIVE', '2025-10-02 14:30:00'),
('Calculadora Científica Casio FX-991ES Plus', 'Calculadora avanzada para matemáticas e ingeniería. Funciones de cálculo integral y derivadas.', 120000.00, 2, 5, 'Nuevo', 'ACTIVE', '2025-10-18 09:15:00'),
('Design Patterns - Gang of Four', 'Libro fundamental sobre patrones de diseño en programación orientada a objetos.', 95000.00, 2, 1, 'Usado', 'ACTIVE', '2025-11-01 16:45:00'),
('Raspberry Pi 4 Model B', 'Computadora de placa única para proyectos de desarrollo y prototipado.', 250000.00, 2, 2, 'Nuevo', 'ACTIVE', '2025-11-08 11:20:00'),

('Introduction to Algorithms - Cormen', 'Libro de texto fundamental sobre algoritmos y estructuras de datos.', 110000.00, 3, 1, 'Usado', 'ACTIVE', '2025-09-20 08:30:00'),
('Licencia IntelliJ IDEA Ultimate', 'Licencia anual para el IDE profesional de desarrollo Java y Kotlin.', 350000.00, 3, 2, 'Nuevo', 'ACTIVE', '2025-10-05 13:00:00'),
('Database System Concepts - Silberschatz', 'Texto completo sobre sistemas de bases de datos relacionales y NoSQL.', 130000.00, 3, 1, 'Nuevo', 'ACTIVE', '2025-10-22 15:45:00'),
('MacBook Pro M2', 'Laptop profesional para desarrollo de software con chip M2.', 2800000.00, 3, 2, 'Usado', 'ACTIVE', '2025-11-03 10:15:00'),
('Monitor LG 27UL850-W', 'Monitor 4K UHD de 27 pulgadas para desarrollo y diseño.', 450000.00, 3, 2, 'Nuevo', 'ACTIVE', '2025-11-10 12:30:00'),

('Head First Design Patterns', 'Libro práctico sobre patrones de diseño con ejemplos en Java.', 75000.00, 4, 1, 'Usado', 'ACTIVE', '2025-09-25 09:00:00'),
('iPad Pro 12.9"', 'Tablet profesional para diseño UX/UI y desarrollo móvil.', 1800000.00, 4, 2, 'Nuevo', 'ACTIVE', '2025-10-08 14:20:00'),
('The Pragmatic Programmer', 'Guía esencial para desarrolladores de software profesionales.', 65000.00, 4, 1, 'Usado', 'ACTIVE', '2025-10-25 11:10:00'),
('Apple Pencil Pro', 'Lápiz digital para diseño y anotaciones en iPad.', 280000.00, 4, 2, 'Nuevo', 'ACTIVE', '2025-11-05 16:00:00'),
('WebStorm License', 'Licencia anual para el IDE especializado en desarrollo web.', 320000.00, 4, 2, 'Nuevo', 'ACTIVE', '2025-11-11 13:45:00'),

('Refactoring - Martin Fowler', 'Libro sobre técnicas de refactorización de código legacy.', 80000.00, 5, 1, 'Nuevo', 'ACTIVE', '2025-09-28 10:30:00'),
('Dell XPS 13', 'Laptop ultrabook para desarrollo móvil y web.', 2200000.00, 5, 2, 'Usado', 'ACTIVE', '2025-10-12 15:15:00'),
('Effective Java - Joshua Bloch', 'Guía definitiva para escribir código Java de alta calidad.', 70000.00, 5, 1, 'Usado', 'ACTIVE', '2025-10-28 12:00:00'),
('Teclado Mecánico Keychron K8', 'Teclado inalámbrico mecánico para programadores.', 180000.00, 5, 2, 'Nuevo', 'ACTIVE', '2025-11-06 17:30:00'),
('Docker Desktop Pro License', 'Licencia profesional para contenedorización y desarrollo.', 150000.00, 5, 2, 'Nuevo', 'ACTIVE', '2025-11-12 14:20:00'),

-- Enfermería (Usuarios 6-9)
('Fundamentos de Enfermería - Potter & Perry', 'Libro de texto fundamental para enfermería. Edición 2022, muy buen estado, sin subrayados.', 120000.00, 6, 1, 'Usado', 'ACTIVE', '2025-09-18 11:00:00'),
('Estetoscopio Littmann Classic III', 'Estetoscopio profesional para prácticas de enfermería. Excelente estado, incluye diafragma y campana.', 350000.00, 6, 3, 'Nuevo', 'ACTIVE', '2025-10-04 13:45:00'),
('Kit de Venopunción Completo', 'Set completo para práctica de venopunción con maniquí. Estado nuevo.', 45000.00, 6, 3, 'Nuevo', 'ACTIVE', '2025-10-20 10:30:00'),
('Farmacología en Enfermería - Lilley', 'Texto especializado en farmacología para profesionales de enfermería.', 95000.00, 6, 1, 'Usado', 'ACTIVE', '2025-11-02 15:15:00'),
('Esfigmomanómetro Digital', 'Tensiómetro electrónico para medición de presión arterial.', 80000.00, 6, 3, 'Nuevo', 'ACTIVE', '2025-11-09 12:00:00'),

('Semiología Médica - De la Fuente', 'Libro de semiología médica para estudiantes de enfermería.', 85000.00, 7, 1, 'Nuevo', 'ACTIVE', '2025-09-22 08:15:00'),
('Termómetro Digital Profesional', 'Termómetro infrarrojo para medición de temperatura corporal.', 25000.00, 7, 3, 'Nuevo', 'ACTIVE', '2025-10-07 14:00:00'),
('Bioquímica Médica - Devlin', 'Texto de bioquímica aplicado a la medicina y enfermería.', 110000.00, 7, 1, 'Usado', 'ACTIVE', '2025-10-23 11:30:00'),
('Jeringas Desechables 5ml', 'Paquete de jeringas estériles para inyecciones.', 8000.00, 7, 3, 'Nuevo', 'ACTIVE', '2025-11-04 16:45:00'),
('Microscopio Óptico Básico', 'Microscopio binocular para laboratorio de microbiología.', 180000.00, 7, 3, 'Usado', 'ACTIVE', '2025-11-10 13:15:00'),

('Psicología en Enfermería', 'Libro sobre aspectos psicológicos del cuidado de enfermería.', 65000.00, 8, 1, 'Usado', 'ACTIVE', '2025-09-26 09:45:00'),
('Maniquí de Práctica Adulto', 'Maniquí anatómico para prácticas de enfermería básica.', 280000.00, 8, 3, 'Nuevo', 'ACTIVE', '2025-10-10 15:20:00'),
('Microbiología Médica - Murray', 'Texto completo de microbiología médica para enfermería.', 125000.00, 8, 1, 'Nuevo', 'ACTIVE', '2025-10-26 12:10:00'),
('Guantes de Nitrito Estériles', 'Caja de guantes quirúrgicos para prácticas médicas.', 15000.00, 8, 3, 'Nuevo', 'ACTIVE', '2025-11-05 17:00:00'),
('Balanza Digital Médica', 'Balanza electrónica de precisión para pesaje de pacientes.', 45000.00, 8, 3, 'Usado', 'ACTIVE', '2025-11-11 14:30:00'),

('Cuidado de Enfermería al Adulto Mayor', 'Especialización en gerontología y cuidado geriátrico.', 78000.00, 9, 1, 'Nuevo', 'ACTIVE', '2025-09-30 10:15:00'),
('Oxímetro de Pulso', 'Dispositivo para medición de saturación de oxígeno en sangre.', 35000.00, 9, 3, 'Nuevo', 'ACTIVE', '2025-10-14 13:30:00'),
('Vigilancia Epidemiológica', 'Libro sobre epidemiología y salud pública para enfermería.', 72000.00, 9, 1, 'Usado', 'ACTIVE', '2025-10-29 11:45:00'),
('Alcohol Gel Antibacterial', 'Galón de alcohol en gel para higiene hospitalaria.', 12000.00, 9, 3, 'Nuevo', 'ACTIVE', '2025-11-06 16:20:00'),
('Carro de Paro', 'Carro de emergencias con desfibrilador y equipos de reanimación.', 450000.00, 9, 3, 'Usado', 'ACTIVE', '2025-11-12 15:00:00'),

-- Derecho (Usuarios 10-13)
('Teoría del Estado - Hans Kelsen', 'Texto fundamental de teoría constitucional y del estado.', 65000.00, 10, 1, 'Usado', 'ACTIVE', '2025-09-19 08:30:00'),
('Derecho Constitucional - Manuel Aragón', 'Libro de texto sobre derecho constitucional colombiano.', 95000.00, 10, 1, 'Nuevo', 'ACTIVE', '2025-10-03 14:15:00'),
('Código Civil Colombiano', 'Edición oficial del Código Civil colombiano actualizado.', 45000.00, 10, 1, 'Nuevo', 'ACTIVE', '2025-10-19 11:00:00'),
('Derecho Procesal Civil', 'Texto sobre procedimiento civil y práctica judicial.', 78000.00, 10, 1, 'Usado', 'ACTIVE', '2025-11-01 15:30:00'),
('Gaceta Judicial Digital', 'Suscripción anual a base de datos jurídica colombiana.', 120000.00, 10, 2, 'Nuevo', 'ACTIVE', '2025-11-08 12:45:00'),

('Derecho Penal - Eugenio Zaffaroni', 'Tratado completo de derecho penal sustantivo.', 110000.00, 11, 1, 'Nuevo', 'ACTIVE', '2025-09-23 09:15:00'),
('Derecho Internacional Humanitario', 'Texto sobre derecho internacional de los conflictos armados.', 85000.00, 11, 1, 'Usado', 'ACTIVE', '2025-10-06 13:45:00'),
('Software Jurídico SAP', 'Licencia del sistema de análisis procesal para abogados.', 250000.00, 11, 2, 'Nuevo', 'ACTIVE', '2025-10-24 10:20:00'),
('Derecho Laboral y Seguridad Social', 'Especialización en derecho del trabajo colombiano.', 92000.00, 11, 1, 'Nuevo', 'ACTIVE', '2025-11-03 16:10:00'),
('Grabadora Digital Profesional', 'Dispositivo para grabación de audiencias judiciales.', 80000.00, 11, 2, 'Usado', 'ACTIVE', '2025-11-09 14:00:00'),

('Derechos Humanos y DIH', 'Libro sobre derechos humanos y derecho internacional humanitario.', 72000.00, 12, 1, 'Usado', 'ACTIVE', '2025-09-27 10:00:00'),
('Tablet Samsung Galaxy Tab S8', 'Tablet para investigación jurídica y lectura de documentos.', 650000.00, 12, 2, 'Nuevo', 'ACTIVE', '2025-10-11 15:30:00'),
('Derecho Administrativo', 'Texto sobre derecho público administrativo colombiano.', 88000.00, 12, 1, 'Nuevo', 'ACTIVE', '2025-10-27 12:15:00'),
('Base de Datos Jurídicas', 'Acceso a plataforma digital de jurisprudencia colombiana.', 180000.00, 12, 2, 'Nuevo', 'ACTIVE', '2025-11-05 17:45:00'),
('Maletín Profesional de Abogado', 'Maletín de cuero para transporte de documentos legales.', 45000.00, 12, 5, 'Usado', 'ACTIVE', '2025-11-11 13:20:00'),

('Sociología Jurídica', 'Estudio sociológico del derecho y las instituciones.', 68000.00, 13, 1, 'Nuevo', 'ACTIVE', '2025-09-29 08:45:00'),
('Derecho Comercial Colombiano', 'Texto sobre derecho mercantil y empresarial.', 95000.00, 13, 1, 'Usado', 'ACTIVE', '2025-10-13 14:20:00'),
('Licencia Microsoft Office 365', 'Suscripción anual para suite ofimática jurídica.', 150000.00, 13, 2, 'Nuevo', 'ACTIVE', '2025-10-30 11:35:00'),
('Derecho de Familia', 'Especialización en derecho civil familiar colombiano.', 76000.00, 13, 1, 'Nuevo', 'ACTIVE', '2025-11-06 16:50:00'),
('Impresora Multifuncional HP', 'Impresora láser para documentos legales y contratos.', 220000.00, 13, 2, 'Usado', 'ACTIVE', '2025-11-12 15:10:00'),

-- Medicina (Usuarios 14-17)
('Harrison Principles of Internal Medicine', 'Tratado fundamental de medicina interna.', 280000.00, 14, 1, 'Usado', 'ACTIVE', '2025-09-21 09:30:00'),
('Estetoscopio Littmann Cardiology IV', 'Estetoscopio premium para cardiología y medicina interna.', 450000.00, 14, 3, 'Nuevo', 'ACTIVE', '2025-10-05 13:15:00'),
('Guyton y Hall - Fisiología Médica', 'Texto completo de fisiología humana médica.', 160000.00, 14, 1, 'Nuevo', 'ACTIVE', '2025-10-21 10:45:00'),
('Otoscopio Profesional', 'Instrumento para examen otorrinolaringológico.', 120000.00, 14, 3, 'Usado', 'ACTIVE', '2025-11-02 15:20:00'),
('Esfigmomanómetro de Mercurio', 'Tensiómetro tradicional para medición precisa.', 65000.00, 14, 3, 'Nuevo', 'ACTIVE', '2025-11-09 12:35:00'),

('Patología General - Robbins', 'Libro de patología general para estudiantes de medicina.', 140000.00, 15, 1, 'Usado', 'ACTIVE', '2025-09-24 10:15:00'),
('Oftalmoscopio PanOptic', 'Oftalmoscopio avanzado para examen ocular completo.', 180000.00, 15, 3, 'Nuevo', 'ACTIVE', '2025-10-08 14:30:00'),
('Farmacología Básica y Clínica - Katzung', 'Texto fundamental de farmacología médica.', 130000.00, 15, 1, 'Nuevo', 'ACTIVE', '2025-10-24 11:20:00'),
('Kit de Diagnóstico Básico', 'Set completo de instrumentos para examen físico.', 95000.00, 15, 3, 'Usado', 'ACTIVE', '2025-11-04 16:40:00'),
('Balanza Digital de Precisión', 'Balanza médica para pesaje clínico de pacientes.', 55000.00, 15, 3, 'Nuevo', 'ACTIVE', '2025-11-10 13:50:00'),

('Semiología Médica - De la Fuente', 'Libro de semiología médica y propedéutica.', 95000.00, 16, 1, 'Nuevo', 'ACTIVE', '2025-09-25 08:20:00'),
('Maniquí de Anatomía Humana', 'Modelo anatómico completo para estudio de anatomía.', 320000.00, 16, 3, 'Usado', 'ACTIVE', '2025-10-09 15:10:00'),
('Bioquímica Médica Aplicada', 'Texto de bioquímica clínica para medicina.', 115000.00, 16, 1, 'Usado', 'ACTIVE', '2025-10-25 12:40:00'),
('Microscopio Binocular Profesional', 'Microscopio óptico para laboratorio de histología.', 280000.00, 16, 3, 'Nuevo', 'ACTIVE', '2025-11-05 17:15:00'),
('Termómetro Clínico Digital', 'Termómetro electrónico para medición de temperatura.', 20000.00, 16, 3, 'Nuevo', 'ACTIVE', '2025-11-11 14:25:00'),

('Deontología Médica', 'Ética médica y principios bioéticos para profesionales.', 72000.00, 17, 1, 'Nuevo', 'ACTIVE', '2025-09-28 09:40:00'),
('Campímetro de Prentice', 'Instrumento para medición de agudeza visual.', 85000.00, 17, 3, 'Usado', 'ACTIVE', '2025-10-12 13:55:00'),
('Inglés Médico para Profesionales', 'Libro de inglés técnico médico especializado.', 58000.00, 17, 1, 'Usado', 'ACTIVE', '2025-10-28 11:05:00'),
('Linterna Oftalmológica', 'Linterna LED para examen pupilar y reflejos.', 25000.00, 17, 3, 'Nuevo', 'ACTIVE', '2025-11-06 16:30:00'),
('Glucometro Digital', 'Dispositivo para medición de glucosa en sangre.', 45000.00, 17, 3, 'Nuevo', 'ACTIVE', '2025-11-12 15:40:00'),

-- Odontología (Usuarios 18-21)
('Patología Oral y Maxilofacial - Neville', 'Tratado completo de patología oral para odontólogos.', 150000.00, 18, 1, 'Usado', 'ACTIVE', '2025-09-26 10:25:00'),
('Turbina Dental NSK Ti-Max X95L', 'Turbina dental de alta velocidad con acoplamiento LED.', 450000.00, 18, 3, 'Nuevo', 'ACTIVE', '2025-10-10 14:40:00'),
('Periodoncia - Carranza', 'Texto fundamental de periodoncia e implantes.', 135000.00, 18, 1, 'Nuevo', 'ACTIVE', '2025-10-26 11:55:00'),
('Micromotor Eléctrico NSK', 'Micromotor endodóntico con contrángulo integrado.', 380000.00, 18, 3, 'Usado', 'ACTIVE', '2025-11-05 16:05:00'),
('Radiográfico Portátil Carestream', 'Equipo de rayos X dental portátil para diagnóstico.', 650000.00, 18, 3, 'Nuevo', 'ACTIVE', '2025-11-11 13:35:00'),

('Endodoncia - Ingle', 'Libro de endodoncia clínica y tratamientos.', 125000.00, 19, 1, 'Usado', 'ACTIVE', '2025-09-29 09:10:00'),
('Instrumental Odontológico Completo', 'Set completo de instrumental quirúrgico odontológico.', 280000.00, 19, 3, 'Nuevo', 'ACTIVE', '2025-10-13 15:25:00'),
('Ortodoncia - Proffit', 'Texto completo de ortodoncia y ortopedia maxilar.', 145000.00, 19, 1, 'Nuevo', 'ACTIVE', '2025-10-29 12:50:00'),
('Esterilizador Autoclave', 'Autoclave dental para esterilización de instrumental.', 220000.00, 19, 3, 'Usado', 'ACTIVE', '2025-11-06 17:20:00'),
('Amalgamador Dental', 'Equipo para preparación de amalgamas dentales.', 95000.00, 19, 3, 'Nuevo', 'ACTIVE', '2025-11-12 14:45:00'),

('Cirugía Oral y Maxilofacial - Peterson', 'Tratado de cirugía oral y procedimientos quirúrgicos.', 165000.00, 20, 1, 'Nuevo', 'ACTIVE', '2025-09-30 08:55:00'),
('Unidad Dental Completa', 'Silla odontológica con todos los equipos integrados.', 850000.00, 20, 3, 'Usado', 'ACTIVE', '2025-10-14 13:40:00'),
('Cariología Restauradora', 'Texto sobre técnicas de restauración dental.', 98000.00, 20, 1, 'Usado', 'ACTIVE', '2025-10-30 11:25:00'),
('Ultrasonido Periodontal', 'Equipo de ultrasonido para limpieza dental profunda.', 150000.00, 20, 3, 'Nuevo', 'ACTIVE', '2025-11-06 16:55:00'),
('Software de Planificación Dental', 'Licencia de software CAD/CAM para prótesis dentales.', 320000.00, 20, 2, 'Nuevo', 'ACTIVE', '2025-11-12 15:30:00'),

('Anatomía Dental - Berkovitz', 'Libro de anatomía dental y desarrollo odontológico.', 115000.00, 21, 1, 'Usado', 'ACTIVE', '2025-10-01 10:40:00'),
('Fresadora Dental CEREC', 'Equipo CAD/CAM para restauraciones cerámicas in-office.', 1200000.00, 21, 3, 'Nuevo', 'ACTIVE', '2025-10-15 14:50:00'),
('Farmacoterapia Odontológica', 'Texto sobre medicamentos en odontología.', 85000.00, 21, 1, 'Nuevo', 'ACTIVE', '2025-10-31 12:15:00'),
('Láser Dental Diode', 'Láser de diodo para procedimientos periodontales.', 280000.00, 21, 3, 'Usado', 'ACTIVE', '2025-11-07 17:40:00'),
('Sistema de Blanqueamiento Dental', 'Kit profesional para blanqueamiento dental.', 65000.00, 21, 3, 'Nuevo', 'ACTIVE', '2025-11-12 16:05:00');

-- Seed favorites for development (sample user favorites - randomly distributed)
INSERT INTO favorites (user_id, product_id) VALUES
-- Sofía Mendoza (user_id: 2) - Ingeniería Software
(2, 25), -- Producto de Enfermería
(2, 45), -- Producto de Derecho
(2, 65), -- Producto de Medicina
(2, 85), -- Producto de Odontología

-- Andrés Torres (user_id: 3) - Ingeniería Software
(3, 26), -- Producto de Enfermería
(3, 46), -- Producto de Derecho
(3, 66), -- Producto de Medicina
(3, 86), -- Producto de Odontología

-- Valentina López (user_id: 4) - Ingeniería Software
(4, 27), -- Producto de Enfermería
(4, 47), -- Producto de Derecho
(4, 67), -- Producto de Medicina
(4, 87), -- Producto de Odontología

-- Miguel Aguilar (user_id: 5) - Ingeniería Software
(5, 28), -- Producto de Enfermería
(5, 48), -- Producto de Derecho
(5, 68), -- Producto de Medicina
(5, 88), -- Producto de Odontología

-- Camila Rodríguez (user_id: 6) - Enfermería
(6, 1), -- Producto de Ingeniería Software
(6, 41), -- Producto de Derecho
(6, 61), -- Producto de Medicina
(6, 81), -- Producto de Odontología

-- Juan Pérez (user_id: 7) - Enfermería
(7, 2), -- Producto de Ingeniería Software
(7, 42), -- Producto de Derecho
(7, 62), -- Producto de Medicina
(7, 82), -- Producto de Odontología

-- Laura García (user_id: 8) - Enfermería
(8, 3), -- Producto de Ingeniería Software
(8, 43), -- Producto de Derecho
(8, 63), -- Producto de Medicina
(8, 83), -- Producto de Odontología

-- Carlos Martínez (user_id: 9) - Enfermería
(9, 4), -- Producto de Ingeniería Software
(9, 44), -- Producto de Derecho
(9, 64), -- Producto de Medicina
(9, 84), -- Producto de Odontología

-- Ana Sánchez (user_id: 10) - Derecho
(10, 5), -- Producto de Ingeniería Software
(10, 21), -- Producto de Enfermería
(10, 71), -- Producto de Medicina
(10, 91), -- Producto de Odontología

-- Diego Ramírez (user_id: 11) - Derecho
(11, 6), -- Producto de Ingeniería Software
(11, 22), -- Producto de Enfermería
(11, 72), -- Producto de Medicina
(11, 92), -- Producto de Odontología

-- María Fernández (user_id: 12) - Derecho
(12, 7), -- Producto de Ingeniería Software
(12, 23), -- Producto de Enfermería
(12, 73), -- Producto de Medicina
(12, 93), -- Producto de Odontología

-- Luis González (user_id: 13) - Derecho
(13, 8), -- Producto de Ingeniería Software
(13, 24), -- Producto de Enfermería
(13, 74), -- Producto de Medicina
(13, 94), -- Producto de Odontología

-- Catalina Herrera (user_id: 14) - Medicina
(14, 9), -- Producto de Ingeniería Software
(14, 29), -- Producto de Enfermería
(14, 49), -- Producto de Derecho
(14, 89), -- Producto de Odontología

-- Sebastián Castillo (user_id: 15) - Medicina
(15, 10), -- Producto de Ingeniería Software
(15, 30), -- Producto de Enfermería
(15, 50), -- Producto de Derecho
(15, 90), -- Producto de Odontología

-- Isabella Morales (user_id: 16) - Medicina
(16, 11), -- Producto de Ingeniería Software
(16, 31), -- Producto de Enfermería
(16, 51), -- Producto de Derecho
(16, 95), -- Producto de Odontología

-- Felipe Ortiz (user_id: 17) - Medicina
(17, 12), -- Producto de Ingeniería Software
(17, 32), -- Producto de Enfermería
(17, 52), -- Producto de Derecho
(17, 96), -- Producto de Odontología

-- Paula Díaz (user_id: 18) - Odontología
(18, 13), -- Producto de Ingeniería Software
(18, 33), -- Producto de Enfermería
(18, 53), -- Producto de Derecho
(18, 73), -- Producto de Medicina

-- Nicolás Vargas (user_id: 19) - Odontología
(19, 14), -- Producto de Ingeniería Software
(19, 34), -- Producto de Enfermería
(19, 54), -- Producto de Derecho
(19, 74), -- Producto de Medicina

-- Daniela Ruiz (user_id: 20) - Odontología
(20, 15), -- Producto de Ingeniería Software
(20, 35), -- Producto de Enfermería
(20, 55), -- Producto de Derecho
(20, 75), -- Producto de Medicina

-- Alejandro Jiménez (user_id: 21) - Odontología
(21, 16), -- Producto de Ingeniería Software
(21, 36), -- Producto de Enfermería
(21, 56), -- Producto de Derecho
(21, 76); -- Producto de Medicina

-- Product images (5 images per product - academic context)
-- All 100 products have 5 images each with unique random numbers
INSERT INTO product_images (product_id, image_url, is_primary, order_index) VALUES
-- Ingeniería de Software (Products 1-20)
(1, 'https://picsum.photos/400/300?random=200', true, 0),
(1, 'https://picsum.photos/400/300?random=201', false, 1),
(1, 'https://picsum.photos/400/300?random=202', false, 2),
(1, 'https://picsum.photos/400/300?random=203', false, 3),
(1, 'https://picsum.photos/400/300?random=204', false, 4),
(2, 'https://picsum.photos/400/300?random=205', true, 0),
(2, 'https://picsum.photos/400/300?random=206', false, 1),
(2, 'https://picsum.photos/400/300?random=207', false, 2),
(2, 'https://picsum.photos/400/300?random=208', false, 3),
(2, 'https://picsum.photos/400/300?random=209', false, 4),
(3, 'https://picsum.photos/400/300?random=210', true, 0),
(3, 'https://picsum.photos/400/300?random=211', false, 1),
(3, 'https://picsum.photos/400/300?random=212', false, 2),
(3, 'https://picsum.photos/400/300?random=213', false, 3),
(3, 'https://picsum.photos/400/300?random=214', false, 4),
(4, 'https://picsum.photos/400/300?random=215', true, 0),
(4, 'https://picsum.photos/400/300?random=216', false, 1),
(4, 'https://picsum.photos/400/300?random=217', false, 2),
(4, 'https://picsum.photos/400/300?random=218', false, 3),
(4, 'https://picsum.photos/400/300?random=219', false, 4),
(5, 'https://picsum.photos/400/300?random=220', true, 0),
(5, 'https://picsum.photos/400/300?random=221', false, 1),
(5, 'https://picsum.photos/400/300?random=222', false, 2),
(5, 'https://picsum.photos/400/300?random=223', false, 3),
(5, 'https://picsum.photos/400/300?random=224', false, 4),
(6, 'https://picsum.photos/400/300?random=225', true, 0),
(6, 'https://picsum.photos/400/300?random=226', false, 1),
(6, 'https://picsum.photos/400/300?random=227', false, 2),
(6, 'https://picsum.photos/400/300?random=228', false, 3),
(6, 'https://picsum.photos/400/300?random=229', false, 4);

-- Images for products 7-20 (completing the first 20 products)
INSERT INTO product_images (product_id, image_url, is_primary, order_index) VALUES
(7, 'https://picsum.photos/400/300?random=230', true, 0),
(7, 'https://picsum.photos/400/300?random=231', false, 1),
(7, 'https://picsum.photos/400/300?random=232', false, 2),
(7, 'https://picsum.photos/400/300?random=233', false, 3),
(7, 'https://picsum.photos/400/300?random=234', false, 4),
(8, 'https://picsum.photos/400/300?random=235', true, 0),
(8, 'https://picsum.photos/400/300?random=236', false, 1),
(8, 'https://picsum.photos/400/300?random=237', false, 2),
(8, 'https://picsum.photos/400/300?random=238', false, 3),
(8, 'https://picsum.photos/400/300?random=239', false, 4),
(9, 'https://picsum.photos/400/300?random=240', true, 0),
(9, 'https://picsum.photos/400/300?random=241', false, 1),
(9, 'https://picsum.photos/400/300?random=242', false, 2),
(9, 'https://picsum.photos/400/300?random=243', false, 3),
(9, 'https://picsum.photos/400/300?random=244', false, 4),
(10, 'https://picsum.photos/400/300?random=245', true, 0),
(10, 'https://picsum.photos/400/300?random=246', false, 1),
(10, 'https://picsum.photos/400/300?random=247', false, 2),
(10, 'https://picsum.photos/400/300?random=248', false, 3),
(10, 'https://picsum.photos/400/300?random=249', false, 4),
(11, 'https://picsum.photos/400/300?random=250', true, 0),
(11, 'https://picsum.photos/400/300?random=251', false, 1),
(11, 'https://picsum.photos/400/300?random=252', false, 2),
(11, 'https://picsum.photos/400/300?random=253', false, 3),
(11, 'https://picsum.photos/400/300?random=254', false, 4),
(12, 'https://picsum.photos/400/300?random=255', true, 0),
(12, 'https://picsum.photos/400/300?random=256', false, 1),
(12, 'https://picsum.photos/400/300?random=257', false, 2),
(12, 'https://picsum.photos/400/300?random=258', false, 3),
(12, 'https://picsum.photos/400/300?random=259', false, 4),
(13, 'https://picsum.photos/400/300?random=260', true, 0),
(13, 'https://picsum.photos/400/300?random=261', false, 1),
(13, 'https://picsum.photos/400/300?random=262', false, 2),
(13, 'https://picsum.photos/400/300?random=263', false, 3),
(13, 'https://picsum.photos/400/300?random=264', false, 4),
(14, 'https://picsum.photos/400/300?random=265', true, 0),
(14, 'https://picsum.photos/400/300?random=266', false, 1),
(14, 'https://picsum.photos/400/300?random=267', false, 2),
(14, 'https://picsum.photos/400/300?random=268', false, 3),
(14, 'https://picsum.photos/400/300?random=269', false, 4),
(15, 'https://picsum.photos/400/300?random=270', true, 0),
(15, 'https://picsum.photos/400/300?random=271', false, 1),
(15, 'https://picsum.photos/400/300?random=272', false, 2),
(15, 'https://picsum.photos/400/300?random=273', false, 3),
(15, 'https://picsum.photos/400/300?random=274', false, 4),
(16, 'https://picsum.photos/400/300?random=275', true, 0),
(16, 'https://picsum.photos/400/300?random=276', false, 1),
(16, 'https://picsum.photos/400/300?random=277', false, 2),
(16, 'https://picsum.photos/400/300?random=278', false, 3),
(16, 'https://picsum.photos/400/300?random=279', false, 4),
(17, 'https://picsum.photos/400/300?random=280', true, 0),
(17, 'https://picsum.photos/400/300?random=281', false, 1),
(17, 'https://picsum.photos/400/300?random=282', false, 2),
(17, 'https://picsum.photos/400/300?random=283', false, 3),
(17, 'https://picsum.photos/400/300?random=284', false, 4),
(18, 'https://picsum.photos/400/300?random=285', true, 0),
(18, 'https://picsum.photos/400/300?random=286', false, 1),
(18, 'https://picsum.photos/400/300?random=287', false, 2),
(18, 'https://picsum.photos/400/300?random=288', false, 3),
(18, 'https://picsum.photos/400/300?random=289', false, 4),
(19, 'https://picsum.photos/400/300?random=290', true, 0),
(19, 'https://picsum.photos/400/300?random=291', false, 1),
(19, 'https://picsum.photos/400/300?random=292', false, 2),
(19, 'https://picsum.photos/400/300?random=293', false, 3),
(19, 'https://picsum.photos/400/300?random=294', false, 4),
(20, 'https://picsum.photos/400/300?random=295', true, 0),
(20, 'https://picsum.photos/400/300?random=296', false, 1),
(20, 'https://picsum.photos/400/300?random=297', false, 2),
(20, 'https://picsum.photos/400/300?random=298', false, 3),
(20, 'https://picsum.photos/400/300?random=299', false, 4);

-- Images for products 21-40 (Enfermería continued)
INSERT INTO product_images (product_id, image_url, is_primary, order_index) VALUES
(21, 'https://picsum.photos/400/300?random=300', true, 0),
(21, 'https://picsum.photos/400/300?random=301', false, 1),
(21, 'https://picsum.photos/400/300?random=302', false, 2),
(21, 'https://picsum.photos/400/300?random=303', false, 3),
(21, 'https://picsum.photos/400/300?random=304', false, 4),
(22, 'https://picsum.photos/400/300?random=305', true, 0),
(22, 'https://picsum.photos/400/300?random=306', false, 1),
(22, 'https://picsum.photos/400/300?random=307', false, 2),
(22, 'https://picsum.photos/400/300?random=308', false, 3),
(22, 'https://picsum.photos/400/300?random=309', false, 4),
(23, 'https://picsum.photos/400/300?random=310', true, 0),
(23, 'https://picsum.photos/400/300?random=311', false, 1),
(23, 'https://picsum.photos/400/300?random=312', false, 2),
(23, 'https://picsum.photos/400/300?random=313', false, 3),
(23, 'https://picsum.photos/400/300?random=314', false, 4),
(24, 'https://picsum.photos/400/300?random=315', true, 0),
(24, 'https://picsum.photos/400/300?random=316', false, 1),
(24, 'https://picsum.photos/400/300?random=317', false, 2),
(24, 'https://picsum.photos/400/300?random=318', false, 3),
(24, 'https://picsum.photos/400/300?random=319', false, 4),
(25, 'https://picsum.photos/400/300?random=320', true, 0),
(25, 'https://picsum.photos/400/300?random=321', false, 1),
(25, 'https://picsum.photos/400/300?random=322', false, 2),
(25, 'https://picsum.photos/400/300?random=323', false, 3),
(25, 'https://picsum.photos/400/300?random=324', false, 4),
(26, 'https://picsum.photos/400/300?random=325', true, 0),
(26, 'https://picsum.photos/400/300?random=326', false, 1),
(26, 'https://picsum.photos/400/300?random=327', false, 2),
(26, 'https://picsum.photos/400/300?random=328', false, 3),
(26, 'https://picsum.photos/400/300?random=329', false, 4),
(27, 'https://picsum.photos/400/300?random=330', true, 0),
(27, 'https://picsum.photos/400/300?random=331', false, 1),
(27, 'https://picsum.photos/400/300?random=332', false, 2),
(27, 'https://picsum.photos/400/300?random=333', false, 3),
(27, 'https://picsum.photos/400/300?random=334', false, 4),
(28, 'https://picsum.photos/400/300?random=335', true, 0),
(28, 'https://picsum.photos/400/300?random=336', false, 1),
(28, 'https://picsum.photos/400/300?random=337', false, 2),
(28, 'https://picsum.photos/400/300?random=338', false, 3),
(28, 'https://picsum.photos/400/300?random=339', false, 4),
(29, 'https://picsum.photos/400/300?random=340', true, 0),
(29, 'https://picsum.photos/400/300?random=341', false, 1),
(29, 'https://picsum.photos/400/300?random=342', false, 2),
(29, 'https://picsum.photos/400/300?random=343', false, 3),
(29, 'https://picsum.photos/400/300?random=344', false, 4),
(30, 'https://picsum.photos/400/300?random=345', true, 0),
(30, 'https://picsum.photos/400/300?random=346', false, 1),
(30, 'https://picsum.photos/400/300?random=347', false, 2),
(30, 'https://picsum.photos/400/300?random=348', false, 3),
(30, 'https://picsum.photos/400/300?random=349', false, 4),
(31, 'https://picsum.photos/400/300?random=350', true, 0),
(31, 'https://picsum.photos/400/300?random=351', false, 1),
(31, 'https://picsum.photos/400/300?random=352', false, 2),
(31, 'https://picsum.photos/400/300?random=353', false, 3),
(31, 'https://picsum.photos/400/300?random=354', false, 4),
(32, 'https://picsum.photos/400/300?random=355', true, 0),
(32, 'https://picsum.photos/400/300?random=356', false, 1),
(32, 'https://picsum.photos/400/300?random=357', false, 2),
(32, 'https://picsum.photos/400/300?random=358', false, 3),
(32, 'https://picsum.photos/400/300?random=359', false, 4),
(33, 'https://picsum.photos/400/300?random=360', true, 0),
(33, 'https://picsum.photos/400/300?random=361', false, 1),
(33, 'https://picsum.photos/400/300?random=362', false, 2),
(33, 'https://picsum.photos/400/300?random=363', false, 3),
(33, 'https://picsum.photos/400/300?random=364', false, 4),
(34, 'https://picsum.photos/400/300?random=365', true, 0),
(34, 'https://picsum.photos/400/300?random=366', false, 1),
(34, 'https://picsum.photos/400/300?random=367', false, 2),
(34, 'https://picsum.photos/400/300?random=368', false, 3),
(34, 'https://picsum.photos/400/300?random=369', false, 4),
(35, 'https://picsum.photos/400/300?random=370', true, 0),
(35, 'https://picsum.photos/400/300?random=371', false, 1),
(35, 'https://picsum.photos/400/300?random=372', false, 2),
(35, 'https://picsum.photos/400/300?random=373', false, 3),
(35, 'https://picsum.photos/400/300?random=374', false, 4),
(36, 'https://picsum.photos/400/300?random=375', true, 0),
(36, 'https://picsum.photos/400/300?random=376', false, 1),
(36, 'https://picsum.photos/400/300?random=377', false, 2),
(36, 'https://picsum.photos/400/300?random=378', false, 3),
(36, 'https://picsum.photos/400/300?random=379', false, 4),
(37, 'https://picsum.photos/400/300?random=380', true, 0),
(37, 'https://picsum.photos/400/300?random=381', false, 1),
(37, 'https://picsum.photos/400/300?random=382', false, 2),
(37, 'https://picsum.photos/400/300?random=383', false, 3),
(37, 'https://picsum.photos/400/300?random=384', false, 4),
(38, 'https://picsum.photos/400/300?random=385', true, 0),
(38, 'https://picsum.photos/400/300?random=386', false, 1),
(38, 'https://picsum.photos/400/300?random=387', false, 2),
(38, 'https://picsum.photos/400/300?random=388', false, 3),
(38, 'https://picsum.photos/400/300?random=389', false, 4),
(39, 'https://picsum.photos/400/300?random=390', true, 0),
(39, 'https://picsum.photos/400/300?random=391', false, 1),
(39, 'https://picsum.photos/400/300?random=392', false, 2),
(39, 'https://picsum.photos/400/300?random=393', false, 3),
(39, 'https://picsum.photos/400/300?random=394', false, 4),
(40, 'https://picsum.photos/400/300?random=395', true, 0),
(40, 'https://picsum.photos/400/300?random=396', false, 1),
(40, 'https://picsum.photos/400/300?random=397', false, 2),
(40, 'https://picsum.photos/400/300?random=398', false, 3),
(40, 'https://picsum.photos/400/300?random=399', false, 4);

-- Images for products 41-60 (Derecho)
INSERT INTO product_images (product_id, image_url, is_primary, order_index) VALUES
(41, 'https://picsum.photos/400/300?random=400', true, 0),
(41, 'https://picsum.photos/400/300?random=401', false, 1),
(41, 'https://picsum.photos/400/300?random=402', false, 2),
(41, 'https://picsum.photos/400/300?random=403', false, 3),
(41, 'https://picsum.photos/400/300?random=404', false, 4),
(42, 'https://picsum.photos/400/300?random=405', true, 0),
(42, 'https://picsum.photos/400/300?random=406', false, 1),
(42, 'https://picsum.photos/400/300?random=407', false, 2),
(42, 'https://picsum.photos/400/300?random=408', false, 3),
(42, 'https://picsum.photos/400/300?random=409', false, 4),
(43, 'https://picsum.photos/400/300?random=410', true, 0),
(43, 'https://picsum.photos/400/300?random=411', false, 1),
(43, 'https://picsum.photos/400/300?random=412', false, 2),
(43, 'https://picsum.photos/400/300?random=413', false, 3),
(43, 'https://picsum.photos/400/300?random=414', false, 4),
(44, 'https://picsum.photos/400/300?random=415', true, 0),
(44, 'https://picsum.photos/400/300?random=416', false, 1),
(44, 'https://picsum.photos/400/300?random=417', false, 2),
(44, 'https://picsum.photos/400/300?random=418', false, 3),
(44, 'https://picsum.photos/400/300?random=419', false, 4),
(45, 'https://picsum.photos/400/300?random=420', true, 0),
(45, 'https://picsum.photos/400/300?random=421', false, 1),
(45, 'https://picsum.photos/400/300?random=422', false, 2),
(45, 'https://picsum.photos/400/300?random=423', false, 3),
(45, 'https://picsum.photos/400/300?random=424', false, 4),
(46, 'https://picsum.photos/400/300?random=425', true, 0),
(46, 'https://picsum.photos/400/300?random=426', false, 1),
(46, 'https://picsum.photos/400/300?random=427', false, 2),
(46, 'https://picsum.photos/400/300?random=428', false, 3),
(46, 'https://picsum.photos/400/300?random=429', false, 4),
(47, 'https://picsum.photos/400/300?random=430', true, 0),
(47, 'https://picsum.photos/400/300?random=431', false, 1),
(47, 'https://picsum.photos/400/300?random=432', false, 2),
(47, 'https://picsum.photos/400/300?random=433', false, 3),
(47, 'https://picsum.photos/400/300?random=434', false, 4),
(48, 'https://picsum.photos/400/300?random=435', true, 0),
(48, 'https://picsum.photos/400/300?random=436', false, 1),
(48, 'https://picsum.photos/400/300?random=437', false, 2),
(48, 'https://picsum.photos/400/300?random=438', false, 3),
(48, 'https://picsum.photos/400/300?random=439', false, 4),
(49, 'https://picsum.photos/400/300?random=440', true, 0),
(49, 'https://picsum.photos/400/300?random=441', false, 1),
(49, 'https://picsum.photos/400/300?random=442', false, 2),
(49, 'https://picsum.photos/400/300?random=443', false, 3),
(49, 'https://picsum.photos/400/300?random=444', false, 4),
(50, 'https://picsum.photos/400/300?random=445', true, 0),
(50, 'https://picsum.photos/400/300?random=446', false, 1),
(50, 'https://picsum.photos/400/300?random=447', false, 2),
(50, 'https://picsum.photos/400/300?random=448', false, 3),
(50, 'https://picsum.photos/400/300?random=449', false, 4),
(51, 'https://picsum.photos/400/300?random=450', true, 0),
(51, 'https://picsum.photos/400/300?random=451', false, 1),
(51, 'https://picsum.photos/400/300?random=452', false, 2),
(51, 'https://picsum.photos/400/300?random=453', false, 3),
(51, 'https://picsum.photos/400/300?random=454', false, 4),
(52, 'https://picsum.photos/400/300?random=455', true, 0),
(52, 'https://picsum.photos/400/300?random=456', false, 1),
(52, 'https://picsum.photos/400/300?random=457', false, 2),
(52, 'https://picsum.photos/400/300?random=458', false, 3),
(52, 'https://picsum.photos/400/300?random=459', false, 4),
(53, 'https://picsum.photos/400/300?random=460', true, 0),
(53, 'https://picsum.photos/400/300?random=461', false, 1),
(53, 'https://picsum.photos/400/300?random=462', false, 2),
(53, 'https://picsum.photos/400/300?random=463', false, 3),
(53, 'https://picsum.photos/400/300?random=464', false, 4),
(54, 'https://picsum.photos/400/300?random=465', true, 0),
(54, 'https://picsum.photos/400/300?random=466', false, 1),
(54, 'https://picsum.photos/400/300?random=467', false, 2),
(54, 'https://picsum.photos/400/300?random=468', false, 3),
(54, 'https://picsum.photos/400/300?random=469', false, 4),
(55, 'https://picsum.photos/400/300?random=470', true, 0),
(55, 'https://picsum.photos/400/300?random=471', false, 1),
(55, 'https://picsum.photos/400/300?random=472', false, 2),
(55, 'https://picsum.photos/400/300?random=473', false, 3),
(55, 'https://picsum.photos/400/300?random=474', false, 4),
(56, 'https://picsum.photos/400/300?random=475', true, 0),
(56, 'https://picsum.photos/400/300?random=476', false, 1),
(56, 'https://picsum.photos/400/300?random=477', false, 2),
(56, 'https://picsum.photos/400/300?random=478', false, 3),
(56, 'https://picsum.photos/400/300?random=479', false, 4),
(57, 'https://picsum.photos/400/300?random=480', true, 0),
(57, 'https://picsum.photos/400/300?random=481', false, 1),
(57, 'https://picsum.photos/400/300?random=482', false, 2),
(57, 'https://picsum.photos/400/300?random=483', false, 3),
(57, 'https://picsum.photos/400/300?random=484', false, 4),
(58, 'https://picsum.photos/400/300?random=485', true, 0),
(58, 'https://picsum.photos/400/300?random=486', false, 1),
(58, 'https://picsum.photos/400/300?random=487', false, 2),
(58, 'https://picsum.photos/400/300?random=488', false, 3),
(58, 'https://picsum.photos/400/300?random=489', false, 4),
(59, 'https://picsum.photos/400/300?random=490', true, 0),
(59, 'https://picsum.photos/400/300?random=491', false, 1),
(59, 'https://picsum.photos/400/300?random=492', false, 2),
(59, 'https://picsum.photos/400/300?random=493', false, 3),
(59, 'https://picsum.photos/400/300?random=494', false, 4),
(60, 'https://picsum.photos/400/300?random=495', true, 0),
(60, 'https://picsum.photos/400/300?random=496', false, 1),
(60, 'https://picsum.photos/400/300?random=497', false, 2),
(60, 'https://picsum.photos/400/300?random=498', false, 3),
(60, 'https://picsum.photos/400/300?random=499', false, 4);

-- Images for products 61-80 (Medicina)
INSERT INTO product_images (product_id, image_url, is_primary, order_index) VALUES
(61, 'https://picsum.photos/400/300?random=500', true, 0),
(61, 'https://picsum.photos/400/300?random=501', false, 1),
(61, 'https://picsum.photos/400/300?random=502', false, 2),
(61, 'https://picsum.photos/400/300?random=503', false, 3),
(61, 'https://picsum.photos/400/300?random=504', false, 4),
(62, 'https://picsum.photos/400/300?random=505', true, 0),
(62, 'https://picsum.photos/400/300?random=506', false, 1),
(62, 'https://picsum.photos/400/300?random=507', false, 2),
(62, 'https://picsum.photos/400/300?random=508', false, 3),
(62, 'https://picsum.photos/400/300?random=509', false, 4),
(63, 'https://picsum.photos/400/300?random=510', true, 0),
(63, 'https://picsum.photos/400/300?random=511', false, 1),
(63, 'https://picsum.photos/400/300?random=512', false, 2),
(63, 'https://picsum.photos/400/300?random=513', false, 3),
(63, 'https://picsum.photos/400/300?random=514', false, 4),
(64, 'https://picsum.photos/400/300?random=515', true, 0),
(64, 'https://picsum.photos/400/300?random=516', false, 1),
(64, 'https://picsum.photos/400/300?random=517', false, 2),
(64, 'https://picsum.photos/400/300?random=518', false, 3),
(64, 'https://picsum.photos/400/300?random=519', false, 4),
(65, 'https://picsum.photos/400/300?random=520', true, 0),
(65, 'https://picsum.photos/400/300?random=521', false, 1),
(65, 'https://picsum.photos/400/300?random=522', false, 2),
(65, 'https://picsum.photos/400/300?random=523', false, 3),
(65, 'https://picsum.photos/400/300?random=524', false, 4),
(66, 'https://picsum.photos/400/300?random=525', true, 0),
(66, 'https://picsum.photos/400/300?random=526', false, 1),
(66, 'https://picsum.photos/400/300?random=527', false, 2),
(66, 'https://picsum.photos/400/300?random=528', false, 3),
(66, 'https://picsum.photos/400/300?random=529', false, 4),
(67, 'https://picsum.photos/400/300?random=530', true, 0),
(67, 'https://picsum.photos/400/300?random=531', false, 1),
(67, 'https://picsum.photos/400/300?random=532', false, 2),
(67, 'https://picsum.photos/400/300?random=533', false, 3),
(67, 'https://picsum.photos/400/300?random=534', false, 4),
(68, 'https://picsum.photos/400/300?random=535', true, 0),
(68, 'https://picsum.photos/400/300?random=536', false, 1),
(68, 'https://picsum.photos/400/300?random=537', false, 2),
(68, 'https://picsum.photos/400/300?random=538', false, 3),
(68, 'https://picsum.photos/400/300?random=539', false, 4),
(69, 'https://picsum.photos/400/300?random=540', true, 0),
(69, 'https://picsum.photos/400/300?random=541', false, 1),
(69, 'https://picsum.photos/400/300?random=542', false, 2),
(69, 'https://picsum.photos/400/300?random=543', false, 3),
(69, 'https://picsum.photos/400/300?random=544', false, 4),
(70, 'https://picsum.photos/400/300?random=545', true, 0),
(70, 'https://picsum.photos/400/300?random=546', false, 1),
(70, 'https://picsum.photos/400/300?random=547', false, 2),
(70, 'https://picsum.photos/400/300?random=548', false, 3),
(70, 'https://picsum.photos/400/300?random=549', false, 4),
(71, 'https://picsum.photos/400/300?random=550', true, 0),
(71, 'https://picsum.photos/400/300?random=551', false, 1),
(71, 'https://picsum.photos/400/300?random=552', false, 2),
(71, 'https://picsum.photos/400/300?random=553', false, 3),
(71, 'https://picsum.photos/400/300?random=554', false, 4),
(72, 'https://picsum.photos/400/300?random=555', true, 0),
(72, 'https://picsum.photos/400/300?random=556', false, 1),
(72, 'https://picsum.photos/400/300?random=557', false, 2),
(72, 'https://picsum.photos/400/300?random=558', false, 3),
(72, 'https://picsum.photos/400/300?random=559', false, 4),
(73, 'https://picsum.photos/400/300?random=560', true, 0),
(73, 'https://picsum.photos/400/300?random=561', false, 1),
(73, 'https://picsum.photos/400/300?random=562', false, 2),
(73, 'https://picsum.photos/400/300?random=563', false, 3),
(73, 'https://picsum.photos/400/300?random=564', false, 4),
(74, 'https://picsum.photos/400/300?random=565', true, 0),
(74, 'https://picsum.photos/400/300?random=566', false, 1),
(74, 'https://picsum.photos/400/300?random=567', false, 2),
(74, 'https://picsum.photos/400/300?random=568', false, 3),
(74, 'https://picsum.photos/400/300?random=569', false, 4),
(75, 'https://picsum.photos/400/300?random=570', true, 0),
(75, 'https://picsum.photos/400/300?random=571', false, 1),
(75, 'https://picsum.photos/400/300?random=572', false, 2),
(75, 'https://picsum.photos/400/300?random=573', false, 3),
(75, 'https://picsum.photos/400/300?random=574', false, 4),
(76, 'https://picsum.photos/400/300?random=575', true, 0),
(76, 'https://picsum.photos/400/300?random=576', false, 1),
(76, 'https://picsum.photos/400/300?random=577', false, 2),
(76, 'https://picsum.photos/400/300?random=578', false, 3),
(76, 'https://picsum.photos/400/300?random=579', false, 4),
(77, 'https://picsum.photos/400/300?random=580', true, 0),
(77, 'https://picsum.photos/400/300?random=581', false, 1),
(77, 'https://picsum.photos/400/300?random=582', false, 2),
(77, 'https://picsum.photos/400/300?random=583', false, 3),
(77, 'https://picsum.photos/400/300?random=584', false, 4),
(78, 'https://picsum.photos/400/300?random=585', true, 0),
(78, 'https://picsum.photos/400/300?random=586', false, 1),
(78, 'https://picsum.photos/400/300?random=587', false, 2),
(78, 'https://picsum.photos/400/300?random=588', false, 3),
(78, 'https://picsum.photos/400/300?random=589', false, 4),
(79, 'https://picsum.photos/400/300?random=590', true, 0),
(79, 'https://picsum.photos/400/300?random=591', false, 1),
(79, 'https://picsum.photos/400/300?random=592', false, 2),
(79, 'https://picsum.photos/400/300?random=593', false, 3),
(79, 'https://picsum.photos/400/300?random=594', false, 4),
(80, 'https://picsum.photos/400/300?random=595', true, 0),
(80, 'https://picsum.photos/400/300?random=596', false, 1),
(80, 'https://picsum.photos/400/300?random=597', false, 2),
(80, 'https://picsum.photos/400/300?random=598', false, 3),
(80, 'https://picsum.photos/400/300?random=599', false, 4);

-- Images for products 81-100 (Odontología)
INSERT INTO product_images (product_id, image_url, is_primary, order_index) VALUES
(81, 'https://picsum.photos/400/300?random=600', true, 0),
(81, 'https://picsum.photos/400/300?random=601', false, 1),
(81, 'https://picsum.photos/400/300?random=602', false, 2),
(81, 'https://picsum.photos/400/300?random=603', false, 3),
(81, 'https://picsum.photos/400/300?random=604', false, 4),
(82, 'https://picsum.photos/400/300?random=605', true, 0),
(82, 'https://picsum.photos/400/300?random=606', false, 1),
(82, 'https://picsum.photos/400/300?random=607', false, 2),
(82, 'https://picsum.photos/400/300?random=608', false, 3),
(82, 'https://picsum.photos/400/300?random=609', false, 4),
(83, 'https://picsum.photos/400/300?random=610', true, 0),
(83, 'https://picsum.photos/400/300?random=611', false, 1),
(83, 'https://picsum.photos/400/300?random=612', false, 2),
(83, 'https://picsum.photos/400/300?random=613', false, 3),
(83, 'https://picsum.photos/400/300?random=614', false, 4),
(84, 'https://picsum.photos/400/300?random=615', true, 0),
(84, 'https://picsum.photos/400/300?random=616', false, 1),
(84, 'https://picsum.photos/400/300?random=617', false, 2),
(84, 'https://picsum.photos/400/300?random=618', false, 3),
(84, 'https://picsum.photos/400/300?random=619', false, 4),
(85, 'https://picsum.photos/400/300?random=620', true, 0),
(85, 'https://picsum.photos/400/300?random=621', false, 1),
(85, 'https://picsum.photos/400/300?random=622', false, 2),
(85, 'https://picsum.photos/400/300?random=623', false, 3),
(85, 'https://picsum.photos/400/300?random=624', false, 4),
(86, 'https://picsum.photos/400/300?random=625', true, 0),
(86, 'https://picsum.photos/400/300?random=626', false, 1),
(86, 'https://picsum.photos/400/300?random=627', false, 2),
(86, 'https://picsum.photos/400/300?random=628', false, 3),
(86, 'https://picsum.photos/400/300?random=629', false, 4),
(87, 'https://picsum.photos/400/300?random=630', true, 0),
(87, 'https://picsum.photos/400/300?random=631', false, 1),
(87, 'https://picsum.photos/400/300?random=632', false, 2),
(87, 'https://picsum.photos/400/300?random=633', false, 3),
(87, 'https://picsum.photos/400/300?random=634', false, 4),
(88, 'https://picsum.photos/400/300?random=635', true, 0),
(88, 'https://picsum.photos/400/300?random=636', false, 1),
(88, 'https://picsum.photos/400/300?random=637', false, 2),
(88, 'https://picsum.photos/400/300?random=638', false, 3),
(88, 'https://picsum.photos/400/300?random=639', false, 4),
(89, 'https://picsum.photos/400/300?random=640', true, 0),
(89, 'https://picsum.photos/400/300?random=641', false, 1),
(89, 'https://picsum.photos/400/300?random=642', false, 2),
(89, 'https://picsum.photos/400/300?random=643', false, 3),
(89, 'https://picsum.photos/400/300?random=644', false, 4),
(90, 'https://picsum.photos/400/300?random=645', true, 0),
(90, 'https://picsum.photos/400/300?random=646', false, 1),
(90, 'https://picsum.photos/400/300?random=647', false, 2),
(90, 'https://picsum.photos/400/300?random=648', false, 3),
(90, 'https://picsum.photos/400/300?random=649', false, 4),
(91, 'https://picsum.photos/400/300?random=650', true, 0),
(91, 'https://picsum.photos/400/300?random=651', false, 1),
(91, 'https://picsum.photos/400/300?random=652', false, 2),
(91, 'https://picsum.photos/400/300?random=653', false, 3),
(91, 'https://picsum.photos/400/300?random=654', false, 4),
(92, 'https://picsum.photos/400/300?random=655', true, 0),
(92, 'https://picsum.photos/400/300?random=656', false, 1),
(92, 'https://picsum.photos/400/300?random=657', false, 2),
(92, 'https://picsum.photos/400/300?random=658', false, 3),
(92, 'https://picsum.photos/400/300?random=659', false, 4),
(93, 'https://picsum.photos/400/300?random=660', true, 0),
(93, 'https://picsum.photos/400/300?random=661', false, 1),
(93, 'https://picsum.photos/400/300?random=662', false, 2),
(93, 'https://picsum.photos/400/300?random=663', false, 3),
(93, 'https://picsum.photos/400/300?random=664', false, 4),
(94, 'https://picsum.photos/400/300?random=665', true, 0),
(94, 'https://picsum.photos/400/300?random=666', false, 1),
(94, 'https://picsum.photos/400/300?random=667', false, 2),
(94, 'https://picsum.photos/400/300?random=668', false, 3),
(94, 'https://picsum.photos/400/300?random=669', false, 4),
(95, 'https://picsum.photos/400/300?random=670', true, 0),
(95, 'https://picsum.photos/400/300?random=671', false, 1),
(95, 'https://picsum.photos/400/300?random=672', false, 2),
(95, 'https://picsum.photos/400/300?random=673', false, 3),
(95, 'https://picsum.photos/400/300?random=674', false, 4),
(96, 'https://picsum.photos/400/300?random=675', true, 0),
(96, 'https://picsum.photos/400/300?random=676', false, 1),
(96, 'https://picsum.photos/400/300?random=677', false, 2),
(96, 'https://picsum.photos/400/300?random=678', false, 3),
(96, 'https://picsum.photos/400/300?random=679', false, 4),
(97, 'https://picsum.photos/400/300?random=680', true, 0),
(97, 'https://picsum.photos/400/300?random=681', false, 1),
(97, 'https://picsum.photos/400/300?random=682', false, 2),
(97, 'https://picsum.photos/400/300?random=683', false, 3),
(97, 'https://picsum.photos/400/300?random=684', false, 4),
(98, 'https://picsum.photos/400/300?random=685', true, 0),
(98, 'https://picsum.photos/400/300?random=686', false, 1),
(98, 'https://picsum.photos/400/300?random=687', false, 2),
(98, 'https://picsum.photos/400/300?random=688', false, 3),
(98, 'https://picsum.photos/400/300?random=689', false, 4),
(99, 'https://picsum.photos/400/300?random=690', true, 0),
(99, 'https://picsum.photos/400/300?random=691', false, 1),
(99, 'https://picsum.photos/400/300?random=692', false, 2),
(99, 'https://picsum.photos/400/300?random=693', false, 3),
(99, 'https://picsum.photos/400/300?random=694', false, 4),
(100, 'https://picsum.photos/400/300?random=695', true, 0),
(100, 'https://picsum.photos/400/300?random=696', false, 1),
(100, 'https://picsum.photos/400/300?random=697', false, 2),
(100, 'https://picsum.photos/400/300?random=698', false, 3),
(100, 'https://picsum.photos/400/300?random=699', false, 4);