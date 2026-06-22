-- Studious Giggle Database Schema

-- Tabla de alojamientos
CREATE TABLE IF NOT EXISTS alojamientos (
  id SERIAL PRIMARY KEY,
  codigo_unico VARCHAR(16) UNIQUE NOT NULL,
  nombre VARCHAR(255) NOT NULL,
  descripcion TEXT,
  propietario_email VARCHAR(255),
  ubicacion POINT,
  zona VARCHAR(100),
  creado_en TIMESTAMP DEFAULT NOW(),
  actualizado_en TIMESTAMP DEFAULT NOW()
);

-- Tabla de información del alojamiento
CREATE TABLE IF NOT EXISTS informacion_alojamiento (
  id SERIAL PRIMARY KEY,
  alojamiento_id INTEGER NOT NULL REFERENCES alojamientos(id) ON DELETE CASCADE,
  tipo VARCHAR(100),
  contenido TEXT,
  actualizado_en TIMESTAMP DEFAULT NOW()
);

-- Tabla de proveedores
CREATE TABLE IF NOT EXISTS proveedores (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(255) NOT NULL,
  tipo VARCHAR(100),
  telefono VARCHAR(20),
  descripcion TEXT,
  descuento VARCHAR(255),
  ubicacion POINT,
  zona VARCHAR(100),
  creado_por_email VARCHAR(255),
  creado_en TIMESTAMP DEFAULT NOW(),
  actualizado_en TIMESTAMP DEFAULT NOW()
);

-- Tabla de recomendaciones
CREATE TABLE IF NOT EXISTS recomendaciones (
  id SERIAL PRIMARY KEY,
  alojamiento_id INTEGER NOT NULL REFERENCES alojamientos(id) ON DELETE CASCADE,
  proveedor_id INTEGER NOT NULL REFERENCES proveedores(id) ON DELETE CASCADE,
  prioridad INTEGER DEFAULT 1,
  creado_en TIMESTAMP DEFAULT NOW()
);

-- Tabla de conversaciones
CREATE TABLE IF NOT EXISTS conversaciones (
  id SERIAL PRIMARY KEY,
  alojamiento_id INTEGER NOT NULL REFERENCES alojamientos(id) ON DELETE CASCADE,
  numero_whatsapp VARCHAR(20),
  mensaje_cliente TEXT,
  respuesta_sistema TEXT,
  creado_en TIMESTAMP DEFAULT NOW()
);

-- Índices para optimizar búsquedas
CREATE INDEX IF NOT EXISTS idx_alojamientos_codigo ON alojamientos(codigo_unico);
CREATE INDEX IF NOT EXISTS idx_alojamientos_zona ON alojamientos(zona);
CREATE INDEX IF NOT EXISTS idx_informacion_alojamiento ON informacion_alojamiento(alojamiento_id);
CREATE INDEX IF NOT EXISTS idx_proveedores_zona ON proveedores(zona);
CREATE INDEX IF NOT EXISTS idx_proveedores_tipo ON proveedores(tipo);
CREATE INDEX IF NOT EXISTS idx_recomendaciones_alojamiento ON recomendaciones(alojamiento_id);
CREATE INDEX IF NOT EXISTS idx_recomendaciones_proveedor ON recomendaciones(proveedor_id);
CREATE INDEX IF NOT EXISTS idx_conversaciones_alojamiento ON conversaciones(alojamiento_id);
