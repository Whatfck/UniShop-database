-- =========================================
-- Configuración de pgvector para embeddings
-- =========================================

-- Instalar pgvector (ejecutar como superusuario)
CREATE EXTENSION IF NOT EXISTS vector;

-- Verificar que pgvector esté instalado
SELECT * FROM pg_extension WHERE extname = 'vector';

-- =========================================
-- Funciones de similitud para embeddings
-- =========================================

-- Función para calcular similitud coseno entre embeddings
CREATE OR REPLACE FUNCTION cosine_similarity(a VECTOR, b VECTOR)
RETURNS FLOAT
LANGUAGE plpgsql
IMMUTABLE STRICT
AS $$
BEGIN
    RETURN 1 - (a <=> b);
END;
$$;

-- Función para búsqueda semántica con umbral
CREATE OR REPLACE FUNCTION semantic_search(
    query_embedding VECTOR(1536),
    similarity_threshold FLOAT DEFAULT 0.7,
    max_results INTEGER DEFAULT 10
)
RETURNS TABLE(
    id INTEGER,
    topic VARCHAR(255),
    content TEXT,
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
        cosine_similarity(kb.embedding, query_embedding) as similarity
    FROM knowledge_base kb
    WHERE kb.is_active = true
    AND cosine_similarity(kb.embedding, query_embedding) >= similarity_threshold
    ORDER BY cosine_similarity(kb.embedding, query_embedding) DESC
    LIMIT max_results;
END;
$$;

-- =========================================
-- Generar embeddings de ejemplo (simulados)
-- =========================================

-- Función para generar embeddings aleatorios (para testing)
-- En producción, usarías OpenAI API o similar
CREATE OR REPLACE FUNCTION generate_random_embedding(dimensions INTEGER DEFAULT 1536)
RETURNS VECTOR
LANGUAGE plpgsql
VOLATILE
AS $$
DECLARE
    embedding_values FLOAT[];
    i INTEGER;
BEGIN
    FOR i IN 1..dimensions LOOP
        embedding_values := array_append(embedding_values, random());
    END LOOP;

    RETURN embedding_values::VECTOR;
END;
$$;

-- =========================================
-- Índices optimizados para embeddings
-- =========================================

-- Crear índices IVFFlat para búsquedas aproximadas rápidas
-- (Requiere que la tabla tenga datos)
-- CREATE INDEX CONCURRENTLY idx_knowledge_base_embedding_ivfflat
-- ON knowledge_base USING ivfflat (embedding vector_cosine_ops)
-- WITH (lists = 100);

-- Crear índices HNSW para máxima precisión
-- (Más lento en construcción pero más preciso)
-- CREATE INDEX CONCURRENTLY idx_knowledge_base_embedding_hnsw
-- ON knowledge_base USING hnsw (embedding vector_cosine_ops)
-- WITH (m = 16, ef_construction = 64);

-- =========================================
-- Funciones de mantenimiento
-- =========================================

-- Función para actualizar embeddings (placeholder)
-- En producción, llamar a OpenAI API para generar embeddings reales

CREATE OR REPLACE FUNCTION update_knowledge_base_embeddings()
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    updated_count INTEGER := 0;
    kb_record RECORD;
BEGIN
    FOR kb_record IN SELECT id, content FROM knowledge_base WHERE embedding IS NULL OR embedding = ''::VECTOR LOOP
        -- Aquí iría la llamada a OpenAI API
        -- UPDATE knowledge_base SET embedding = openai_generate_embedding(content) WHERE id = kb_record.id;
        UPDATE knowledge_base SET embedding = generate_random_embedding() WHERE id = kb_record.id;
        updated_count := updated_count + 1;
    END LOOP;

    RETURN updated_count;
END;
$$;

-- Función para verificar integridad de embeddings
CREATE OR REPLACE FUNCTION validate_embeddings()
RETURNS TABLE(
    id INTEGER,
    topic VARCHAR(255),
    embedding_status TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        kb.id,
        kb.topic,
        CASE
            WHEN kb.embedding IS NULL THEN 'NULL'
            WHEN vector_dims(kb.embedding) != 1536 THEN 'INVALID_DIMENSIONS'
            ELSE 'VALID'
        END as embedding_status
    FROM knowledge_base kb;
END;
$$;

-- =========================================
-- Consultas de ejemplo para testing
-- =========================================

-- Buscar contenido similar a un embedding
-- SELECT * FROM semantic_search('[0.1, 0.2, ...]'::VECTOR(1536), 0.8, 5);

-- Encontrar los N vecinos más cercanos
-- SELECT id, topic, cosine_similarity(embedding, '[0.1, 0.2, ...]'::VECTOR) as similarity
-- FROM knowledge_base
-- ORDER BY embedding <=> '[0.1, 0.2, ...]'::VECTOR
-- LIMIT 10;

-- =========================================
-- Configuración de rendimiento
-- =========================================

-- Ajustar parámetros de pgvector para mejor rendimiento
-- ALTER SYSTEM SET ivfflat.probes = 10;
-- ALTER SYSTEM SET hnsw.ef_search = 40;

-- Recargar configuración
-- SELECT pg_reload_conf();