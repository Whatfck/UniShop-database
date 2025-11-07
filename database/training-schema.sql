-- =========================================
-- Unishop Chatbot Training Database Schema
-- =========================================

-- Extension para soporte de vectores (embeddings)
CREATE EXTENSION IF NOT EXISTS vector;

-- Tabla de datos de entrenamiento del chatbot
CREATE TABLE training_data (
    id SERIAL PRIMARY KEY,
    question TEXT NOT NULL,
    answer TEXT NOT NULL,
    category VARCHAR(100),
    intent VARCHAR(100),
    entities JSONB DEFAULT '[]'::jsonb,
    confidence_score DECIMAL(3,2) DEFAULT 0.8,
    usage_count INTEGER DEFAULT 0,
    last_used TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de conversaciones para análisis y fine-tuning
CREATE TABLE conversations (
    id SERIAL PRIMARY KEY,
    session_id VARCHAR(255),
    user_id VARCHAR(255),
    user_message TEXT NOT NULL,
    bot_response TEXT NOT NULL,
    intent_detected VARCHAR(100),
    entities_extracted JSONB DEFAULT '[]'::jsonb,
    response_time_ms INTEGER,
    user_feedback INTEGER CHECK (user_feedback BETWEEN 1 AND 5),
    was_helpful BOOLEAN,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Base de conocimientos del dominio Unishop
CREATE TABLE knowledge_base (
    id SERIAL PRIMARY KEY,
    topic VARCHAR(255) UNIQUE NOT NULL,
    content TEXT NOT NULL,
    category VARCHAR(100),
    tags TEXT[] DEFAULT '{}',
    embedding VECTOR(1536), -- Para embeddings de OpenAI (1536 dimensiones)
    source VARCHAR(255), -- 'manual', 'faq', 'docs', etc.
    priority INTEGER DEFAULT 1, -- 1-5, mayor = más importante
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Intents y patrones de reconocimiento
CREATE TABLE intents (
    id SERIAL PRIMARY KEY,
    intent_name VARCHAR(255) UNIQUE NOT NULL,
    description TEXT,
    training_examples TEXT[] DEFAULT '{}',
    response_templates TEXT[] DEFAULT '{}',
    follow_up_questions TEXT[] DEFAULT '{}',
    priority INTEGER DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Entities reconocidas por el sistema
CREATE TABLE entities (
    id SERIAL PRIMARY KEY,
    entity_name VARCHAR(255) NOT NULL,
    entity_type VARCHAR(100) NOT NULL, -- 'product', 'category', 'price', etc.
    entity_value TEXT NOT NULL,
    synonyms TEXT[] DEFAULT '{}',
    confidence DECIMAL(3,2) DEFAULT 1.0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Métricas de rendimiento del chatbot
CREATE TABLE chatbot_metrics (
    id SERIAL PRIMARY KEY,
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    total_conversations INTEGER DEFAULT 0,
    successful_responses INTEGER DEFAULT 0,
    average_response_time DECIMAL(6,2),
    average_user_satisfaction DECIMAL(3,2),
    top_intents JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(date)
);

-- Feedback de usuarios para mejora continua
CREATE TABLE user_feedback (
    id SERIAL PRIMARY KEY,
    conversation_id INTEGER REFERENCES conversations(id),
    user_id VARCHAR(255),
    rating INTEGER CHECK (rating BETWEEN 1 AND 5),
    comments TEXT,
    suggested_improvement TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =========================================
-- Índices para optimización
-- =========================================

-- Índices para búsquedas rápidas
CREATE INDEX idx_training_data_category ON training_data(category);
CREATE INDEX idx_training_data_intent ON training_data(intent);
CREATE INDEX idx_conversations_session ON conversations(session_id);
CREATE INDEX idx_conversations_timestamp ON conversations(timestamp);
CREATE INDEX idx_knowledge_base_topic ON knowledge_base(topic);
CREATE INDEX idx_knowledge_base_tags ON knowledge_base USING gin(tags);
CREATE INDEX idx_intents_name ON intents(intent_name);

-- Índice de similitud para embeddings (requiere pgvector)
CREATE INDEX idx_knowledge_base_embedding ON knowledge_base USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);

-- Índice de búsqueda de texto completo
CREATE INDEX idx_training_data_search ON training_data USING gin(to_tsvector('spanish', question || ' ' || answer));
CREATE INDEX idx_knowledge_base_search ON knowledge_base USING gin(to_tsvector('spanish', content));

-- =========================================
-- Funciones útiles
-- =========================================

-- Función para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers para updated_at
CREATE TRIGGER update_training_data_updated_at BEFORE UPDATE ON training_data FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_knowledge_base_updated_at BEFORE UPDATE ON knowledge_base FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Función para búsqueda semántica usando embeddings
CREATE OR REPLACE FUNCTION find_similar_content(query_embedding VECTOR(1536), match_threshold FLOAT DEFAULT 0.8, match_count INT DEFAULT 5)
RETURNS TABLE(
    id INTEGER,
    topic VARCHAR(255),
    content TEXT,
    category VARCHAR(100),
    tags TEXT[],
    similarity FLOAT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        kb.id,
        kb.topic,
        kb.content,
        kb.category,
        kb.tags,
        1 - (kb.embedding <=> query_embedding) AS similarity
    FROM knowledge_base kb
    WHERE kb.is_active = true
    AND 1 - (kb.embedding <=> query_embedding) > match_threshold
    ORDER BY kb.embedding <=> query_embedding
    LIMIT match_count;
END;
$$;

-- Función para actualizar métricas diarias
CREATE OR REPLACE FUNCTION update_chatbot_metrics(target_date DATE DEFAULT CURRENT_DATE)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    conv_count INTEGER;
    success_count INTEGER;
    avg_response_time DECIMAL(6,2);
    avg_satisfaction DECIMAL(3,2);
    top_intents_data JSONB;
BEGIN
    -- Contar conversaciones del día
    SELECT COUNT(*) INTO conv_count
    FROM conversations
    WHERE DATE(timestamp) = target_date;

    -- Contar respuestas exitosas (feedback >= 4)
    SELECT COUNT(*) INTO success_count
    FROM conversations
    WHERE DATE(timestamp) = target_date AND user_feedback >= 4;

    -- Calcular tiempo promedio de respuesta
    SELECT AVG(response_time_ms) INTO avg_response_time
    FROM conversations
    WHERE DATE(timestamp) = target_date AND response_time_ms IS NOT NULL;

    -- Calcular satisfacción promedio
    SELECT AVG(user_feedback) INTO avg_satisfaction
    FROM conversations
    WHERE DATE(timestamp) = target_date AND user_feedback IS NOT NULL;

    -- Obtener top intents
    SELECT jsonb_object_agg(intent, count) INTO top_intents_data
    FROM (
        SELECT intent_detected as intent, COUNT(*) as count
        FROM conversations
        WHERE DATE(timestamp) = target_date AND intent_detected IS NOT NULL
        GROUP BY intent_detected
        ORDER BY count DESC
        LIMIT 5
    ) top_intents;

    -- Insertar o actualizar métricas
    INSERT INTO chatbot_metrics (date, total_conversations, successful_responses, average_response_time, average_user_satisfaction, top_intents)
    VALUES (target_date, conv_count, success_count, avg_response_time, avg_satisfaction, COALESCE(top_intents_data, '{}'::jsonb))
    ON CONFLICT (date) DO UPDATE SET
        total_conversations = EXCLUDED.total_conversations,
        successful_responses = EXCLUDED.successful_responses,
        average_response_time = EXCLUDED.average_response_time,
        average_user_satisfaction = EXCLUDED.average_user_satisfaction,
        top_intents = EXCLUDED.top_intents;
END;
$$;

-- =========================================
-- Datos iniciales de ejemplo
-- =========================================

-- Insertar algunos intents básicos
INSERT INTO intents (intent_name, description, training_examples, response_templates) VALUES
('saludar', 'Saludos iniciales del usuario',
 '{"hola", "buenos días", "buenas tardes", "qué tal", "hey"}',
 '{"¡Hola! ¿En qué puedo ayudarte con Unishop?", "¡Buen día! ¿Qué necesitas saber sobre nuestros productos?", "¡Hola! Soy el asistente de Unishop. ¿Cómo puedo ayudarte?"}'),

('buscar_producto', 'Usuario quiere buscar productos',
 '{"busco", "quiero encontrar", "necesito", "estoy buscando", "tienen"}',
 '{"¿Qué tipo de producto estás buscando? Puedo ayudarte a encontrar libros, materiales de laboratorio, equipos de arquitectura, etc.", "¡Claro! ¿Me puedes decir qué producto necesitas? Tengo información sobre libros, tecnología, materiales universitarios y más."}'),

('informacion_contacto', 'Usuario pide información de contacto',
 '{"cómo contacto", "quiero contactar", "número de teléfono", "whatsapp", "correo"}',
 '{"Para contactar a un vendedor, simplemente haz clic en el botón Contactar del producto que te interesa. Se abrirá WhatsApp con un mensaje predefinido.", "Cada producto tiene un botón Contactar que te lleva directamente al WhatsApp del vendedor."}');

-- Insertar algunas entidades básicas
INSERT INTO entities (entity_name, entity_type, entity_value, synonyms) VALUES
('libros', 'category', 'Libros', '{"libro", "texto", "material de estudio", "apuntes"}'),
('tecnologia', 'category', 'Tecnología', '{"computador", "laptop", "ordenador", "equipo", "pc"}'),
('laboratorio', 'category', 'Material de Laboratorio', '{"química", "física", "biología", "experimentos", "reactivos"}'),
('arquitectura', 'category', 'Material de Arquitectura', '{"dibujo técnico", "autocad", "planos", "regla t", "compás"}');

-- Insertar datos de entrenamiento iniciales
INSERT INTO training_data (question, answer, category, intent) VALUES
('¿Cómo puedo vender un producto?', 'Para vender un producto: 1) Regístrate con tu correo institucional, 2) Verifica tu número de teléfono, 3) Haz clic en "Vender", 4) Completa el formulario con fotos y descripción, 5) Espera la aprobación del moderador.', 'ventas', 'informacion_venta'),
('¿Cuánto cuesta publicar?', 'Publicar productos en Unishop es completamente gratis. Solo necesitas verificar tu teléfono.', 'precios', 'informacion_general'),
('¿Cómo contacto a un vendedor?', 'Cada producto tiene un botón "Contactar" que abre WhatsApp con un mensaje predefinido al vendedor.', 'contacto', 'informacion_contacto'),
('¿Qué productos puedo vender?', 'Puedes vender libros, materiales de laboratorio, equipos de tecnología, materiales de arquitectura, útiles escolares y otros artículos universitarios.', 'productos', 'informacion_general');

-- Insertar contenido inicial en knowledge base
INSERT INTO knowledge_base (topic, content, category, tags, source, priority) VALUES
('registro_usuarios', 'Los usuarios deben registrarse con correos institucionales terminados en @campusucc.edu.co. El proceso requiere nombre, correo y contraseña. La foto de perfil es opcional.', 'usuarios', '{"registro", "correo", "institucional"}', 'docs', 5),
('verificacion_telefono', 'Para publicar productos, los usuarios deben verificar su número de teléfono mediante un código enviado por WhatsApp o SMS. Esta verificación es obligatoria para vendedores.', 'seguridad', '{"telefono", "verificacion", "seguridad"}', 'docs', 5),
('moderacion_contenido', 'Todas las publicaciones pasan por moderación automática y manual. Se rechazan productos con información de contacto en la descripción o contenido inapropiado.', 'moderacion', '{"contenido", "reglas", "moderacion"}', 'docs', 4),
('sistema_favoritos', 'Los usuarios pueden guardar productos en una lista de favoritos para acceder fácilmente después. Los productos marcados como vendidos aparecen como "Publicación inactiva".', 'funcionalidades', '{"favoritos", "guardar", "lista"}', 'docs', 3);