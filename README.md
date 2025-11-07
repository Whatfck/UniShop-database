# 💾 Unishop - Base de Datos

Esta carpeta contiene la configuración, documentación y scripts relacionados con la capa de datos del proyecto Unishop.

---

## 🚀 Tecnología

El proyecto utiliza **PostgreSQL** como sistema de gestión de bases de datos relacional.

### ¿Por qué PostgreSQL?

- **Robustez y Fiabilidad**: Es una de las bases de datos de código abierto más avanzadas y confiables.
- **Escalabilidad**: Soporta grandes volúmenes de datos y concurrencia de usuarios, lo que se alinea con el futuro crecimiento de Unishop.
- **Ecosistema**: Cuenta con un amplio soporte en la comunidad y es el estándar de facto para muchas aplicaciones modernas.
- **Soporte de Tipos de Datos Avanzados**: Ofrece soporte para JSON, datos geoespaciales y más, lo que da flexibilidad para futuras funcionalidades.

---

## 🏗️ Arquitectura de Datos

### Entidades Principales

| Entidad | Descripción | Campos Clave |
|---------|-------------|--------------|
| **Users** | Usuarios del sistema con roles | id, email, name, role, password |
| **Products** | Productos publicados | id, name, description, price, status |
| **Categories** | Categorías de productos | id, name |
| **Favorites** | Lista de favoritos por usuario | userId, productId |
| **Metrics** | Estadísticas de productos | productId, views, contacts |
| **PhoneVerifications** | Verificación de teléfonos | userId, phoneNumber, verificationCode |
| **Contacts** | Registro de contactos | userId, productId, message |

### Relaciones

- **User** → **Product** (1:N) - Un usuario puede tener múltiples productos
- **Product** → **Category** (N:1) - Un producto pertenece a una categoría
- **User** → **Favorite** (1:N) - Un usuario puede tener múltiples favoritos
- **Product** → **Metric** (1:1) - Un producto tiene métricas asociadas

---

## 🔧 Configuración de Conexión

### Desarrollo (Docker)
La base de datos se levanta como un servicio dentro de `docker-compose.yml`. Las credenciales se gestionan a través de variables de entorno.

```bash
# Variables de entorno en .env
DB_HOST=db
DB_PORT=5432
DB_USERNAME=unishop_user
DB_PASSWORD=unishop_password
DB_NAME=unishop_db
```

### Producción
Para entornos de producción, se recomienda:
- Usar variables de entorno seguras
- Configurar connection pooling
- Implementar SSL/TLS
- Configurar backups automáticos

---

## 📊 Gestión de Datos

### Sincronización Automática
En desarrollo, TypeORM maneja automáticamente la creación/modificación de tablas:
```typescript
synchronize: true  // Solo en desarrollo
```

### Migraciones (Producción)
Para producción, se deben crear migraciones manuales:
```bash
npm run migration:generate -- -n InitialSchema
npm run migration:run
```

---

## 🛠️ Scripts y Utilidades

### Próximos a Implementar:
- **Seeds**: Datos iniciales (categorías, usuario admin)
- **Backups**: Scripts de respaldo automático
- **Migrations**: Migraciones de esquema para producción
- **Fixtures**: Datos de prueba para desarrollo

---

## 📈 Rendimiento y Optimización

### Índices Recomendados
```sql
-- Índices para búsquedas rápidas
CREATE INDEX idx_products_status ON products(status);
CREATE INDEX idx_products_category ON products(categoryId);
CREATE INDEX idx_products_user ON products(userId);
CREATE INDEX idx_products_search ON products USING gin(to_tsvector('spanish', name || ' ' || description));
```

### Configuración de Pool
```typescript
poolSize: 10,              // Conexiones en pool
connectionTimeoutMillis: 2000,
query_timeout: 10000,
```

---

## 🔒 Seguridad

- **Conexiones SSL**: Requeridas en producción
- **Variables de Entorno**: Nunca commitear credenciales
- **Roles de BD**: Usuario con permisos mínimos
- **Auditoría**: Logging de consultas sensibles

---

## 📋 Próximos Pasos

1. **Implementar Seeds** para datos iniciales
2. **Crear Migraciones** para control de versiones de esquema
3. **Configurar Backups** automáticos
4. **Añadir Índices** de rendimiento
5. **Implementar Monitoreo** de consultas lentas