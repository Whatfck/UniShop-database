FROM postgres:15-alpine

# Copy initialization scripts
COPY setup-pgvector.sql /docker-entrypoint-initdb.d/01-setup-pgvector.sql
COPY mvp-schema.sql /docker-entrypoint-initdb.d/02-mvp-schema.sql

# Set environment variables
ENV POSTGRES_DB=unishop_db
ENV POSTGRES_USER=unishop_user
ENV POSTGRES_PASSWORD=unishop_password

# Expose port
EXPOSE 5432

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
  CMD pg_isready -U unishop_user -d unishop_db

# Default command
CMD ["postgres"]