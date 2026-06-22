# Arquitectura - Studious Giggle

## Visión General

**Studious Giggle** es una plataforma que conecta huéspedes de Airbnb con servicios locales y información del alojamiento a través de WhatsApp. Los anfitriones comparten información sobre su propiedad y recomendaciones de proveedores; los clientes consultan por WhatsApp y obtienen respuestas automáticas 24/7 mediante un LLM.

### Problema que resuelve

- **Para el anfitrión:** Evita responder preguntas repetitivas ("¿hay WiFi?", "¿dónde como?") y delega a una plataforma automática.
- **Para el cliente:** Acceso inmediato a información del alojamiento y recomendaciones de servicios sin esperar al host.
- **Para el proveedor:** Aparece en recomendaciones sin esfuerzo; opcionalmente ofrece descuentos para aparecer en búsquedas sin recomendación directa.

---

## Stack Técnico

| Capa | Tecnología | Hosting |
|---|---|---|
| Frontend | Nuxt 3 | Vercel |
| Backend | Node.js + Express | Railway |
| Base de datos | PostgreSQL | Railway |
| LLM | Deepseek API | Cloud (Deepseek) |
| Mensajería | WhatsApp Cloud API | Cloud (Meta) |

---

## Arquitectura de Componentes

```mermaid
graph TB
    subgraph Cliente["🌐 Cliente (WhatsApp)"]
        WA["Mensaje WhatsApp"]
    end
    
    subgraph API["WhatsApp Cloud API"]
        WAH["Webhook Handler"]
    end
    
    subgraph Backend["🔧 Backend (Express - Railway)"]
        WE["Webhook Endpoint"]
        EX["Extrae Código + Consulta"]
        DPS["Deepseek Classifier"]
        DB_SEARCH["Busca en BD"]
        RESPOND["Genera Respuesta"]
    end
    
    subgraph Data["💾 Data Layer (PostgreSQL - Railway)"]
        ALO["Alojamientos"]
        INFO["Información Alojamiento"]
        PROV["Proveedores"]
        REC["Recomendaciones"]
    end
    
    subgraph LLM["🤖 Deepseek API"]
        DEEP["LLM Classification"]
    end
    
    subgraph Frontend["🎨 Frontend (Nuxt - Vercel)"]
        PANEL["Panel Anfitrión"]
    end
    
    WA -->|recibe| WAH
    WAH -->|POST| WE
    WE --> EX
    EX --> DPS
    DPS -->|clasifica intención| DEEP
    DEEP -->|responde| DB_SEARCH
    DB_SEARCH -->|consulta| ALO
    DB_SEARCH -->|consulta| INFO
    DB_SEARCH -->|consulta| PROV
    DB_SEARCH -->|consulta| REC
    DB_SEARCH --> RESPOND
    RESPOND -->|responde| WA
    
    PANEL -->|actualiza| ALO
    PANEL -->|ingresa| INFO
    PANEL -->|recomienda| PROV
    PANEL -->|conecta| REC
    
    style Cliente fill:#e1f5ff
    style Backend fill:#f3e5f5
    style Data fill:#e8f5e9
    style LLM fill:#fff3e0
    style Frontend fill:#fce4ec
```

---

## Flujos Principales

### 1. Flujo de Consulta del Cliente (WhatsApp)

```mermaid
sequenceDiagram
    participant Cliente
    participant WhatsApp as WhatsApp Cloud API
    participant Backend
    participant Deepseek
    participant PostgreSQL
    
    Cliente->>WhatsApp: Envía mensaje con código
    WhatsApp->>Backend: Webhook POST
    Backend->>Backend: Extrae código anfitrión + consulta
    Backend->>Deepseek: Clasifica intención de consulta
    Deepseek-->>Backend: { tipo, intención, palabras_clave }
    
    alt Si pregunta sobre alojamiento
        Backend->>PostgreSQL: SELECT * FROM informacion_alojamiento
    else Si pregunta sobre servicios
        Backend->>PostgreSQL: SELECT * FROM proveedores WHERE alojamiento_id=? OR zona=?
    else Si pregunta sobre proveedor específico
        Backend->>PostgreSQL: SELECT * FROM proveedores WHERE nombre ILIKE ?
    end
    
    PostgreSQL-->>Backend: Resultados
    Backend->>Backend: Formatea respuesta + contactos
    Backend->>WhatsApp: Responde con información
    WhatsApp->>Cliente: Recibe respuesta + contactos
```

### 2. Flujo de Configuración del Anfitrión

```mermaid
sequenceDiagram
    participant Anfitrión
    participant Nuxt as Panel Nuxt (Vercel)
    participant Backend
    participant PostgreSQL
    
    Anfitrión->>Nuxt: Abre panel
    Nuxt->>Backend: GET /api/alojamientos/:codigo (validar)
    Backend->>PostgreSQL: SELECT * FROM alojamientos WHERE codigo_unico=?
    PostgreSQL-->>Backend: Datos del alojamiento
    Backend-->>Nuxt: ✓ Autenticado
    Nuxt->>Anfitrión: Muestra dashboard
    
    alt Ingresa información del alojamiento
        Anfitrión->>Nuxt: Escribe WiFi, amenities, reglas
        Nuxt->>Backend: PUT /api/alojamientos/:codigo/informacion
        Backend->>PostgreSQL: INSERT INTO informacion_alojamiento
        PostgreSQL-->>Backend: ✓ Guardado
    else Agrega proveedor recomendado
        Anfitrión->>Nuxt: Agrega restaurante, tour, etc.
        Nuxt->>Backend: POST /api/alojamientos/:codigo/proveedores
        Backend->>PostgreSQL: INSERT INTO proveedores + recomendaciones
        PostgreSQL-->>Backend: ✓ Guardado
    end
```

### 3. Agregación de Múltiples Anfitriones

```mermaid
graph TD
    A["Cliente consulta con código ABC123"]
    B{"¿Qué tipo de servicio?"}
    C["Busca en BD con alojamiento_id=ABC123"]
    D["Encuentra 3 restaurantes recomendados"]
    E["Busca otros en la misma zona"]
    F["Encuentra 2 más de Anfitrión XYZ, 1 de UVW"]
    G["Ordena: ABC123 primero, luego otros"]
    H["Responde con contactos priorizados"]
    
    A --> B
    B -->|restaurantes| C
    C --> D
    D --> E
    E --> F
    F --> G
    G --> H
    
    I["Respuesta final"]
    H --> I
    
    style D fill:#90EE90
    style F fill:#FFB6C1
    style I fill:#87CEEB
```

**Priorización de resultados:**
1. Recomendaciones del anfitrión actual (prioridad 1)
2. Otros proveedores en la zona (prioridad 2)
3. Descuentos (si aplica)

---

## Schema de Base de Datos

### Diagrama ER

```mermaid
erDiagram
    ALOJAMIENTOS ||--o{ INFORMACION_ALOJAMIENTO : tiene
    ALOJAMIENTOS ||--o{ RECOMENDACIONES : "recomienda a"
    PROVEEDORES ||--o{ RECOMENDACIONES : "es recomendado en"
    ALOJAMIENTOS ||--o{ CONVERSACIONES : "recibe consultas en"
    
    ALOJAMIENTOS {
        int id PK
        string codigo_unico UK "UUID corto"
        string nombre
        string propietario_email
        point ubicacion "lat, lon"
        string zona
        timestamp creado_en
    }
    
    INFORMACION_ALOJAMIENTO {
        int id PK
        int alojamiento_id FK
        string tipo "wifi, amenities, reglas, etc"
        text contenido
        timestamp actualizado_en
    }
    
    PROVEEDORES {
        int id PK
        string nombre
        string tipo "restaurante, tour, supermercado, etc"
        string telefono
        text descripcion
        string descuento
        point ubicacion
        string zona
        string creado_por_email
        timestamp creado_en
    }
    
    RECOMENDACIONES {
        int id PK
        int alojamiento_id FK
        int proveedor_id FK
        int prioridad "1=directo, 2=zona"
        timestamp creado_en
    }
    
    CONVERSACIONES {
        int id PK
        int alojamiento_id FK
        string numero_whatsapp_hash
        text mensaje_cliente
        text respuesta_sistema
        timestamp creado_en
    }
```

### Tablas SQL

#### Tabla: `alojamientos`
```sql
CREATE TABLE alojamientos (
  id SERIAL PRIMARY KEY,
  codigo_unico VARCHAR(16) UNIQUE NOT NULL,
  nombre VARCHAR(255),
  descripcion TEXT,
  propietario_email VARCHAR(255),
  ubicacion POINT, -- (lat, lon) para buscar por zona
  zona VARCHAR(100), -- Ciudad/barrio
  creado_en TIMESTAMP DEFAULT NOW(),
  actualizado_en TIMESTAMP DEFAULT NOW()
);
```

### Tabla: `informacion_alojamiento`
```sql
CREATE TABLE informacion_alojamiento (
  id SERIAL PRIMARY KEY,
  alojamiento_id INTEGER NOT NULL REFERENCES alojamientos(id) ON DELETE CASCADE,
  tipo VARCHAR(100), -- "wifi", "amenities", "reglas", "checkout", etc.
  contenido TEXT, -- JSON o texto libre
  actualizado_en TIMESTAMP DEFAULT NOW()
);
```

### Tabla: `proveedores`
```sql
CREATE TABLE proveedores (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(255) NOT NULL,
  tipo VARCHAR(100), -- "restaurante", "tour", "supermercado", etc.
  telefono VARCHAR(20),
  descripcion TEXT,
  descuento VARCHAR(255), -- Ej: "10% si mencionas código XYZ"
  ubicacion POINT, -- (lat, lon)
  zona VARCHAR(100),
  creado_por_email VARCHAR(255), -- Email del proveedor si se registra
  creado_en TIMESTAMP DEFAULT NOW(),
  actualizado_en TIMESTAMP DEFAULT NOW()
);
```

### Tabla: `recomendaciones`
```sql
CREATE TABLE recomendaciones (
  id SERIAL PRIMARY KEY,
  alojamiento_id INTEGER NOT NULL REFERENCES alojamientos(id) ON DELETE CASCADE,
  proveedor_id INTEGER NOT NULL REFERENCES proveedores(id) ON DELETE CASCADE,
  prioridad INTEGER DEFAULT 1, -- 1 = recomendación directa, 2 = otra zona
  creado_en TIMESTAMP DEFAULT NOW()
);
```

### Tabla: `conversaciones` (opcional, para histórico)
```sql
CREATE TABLE conversaciones (
  id SERIAL PRIMARY KEY,
  alojamiento_id INTEGER NOT NULL REFERENCES alojamientos(id),
  numero_whatsapp VARCHAR(20), -- Hash del cliente por privacidad
  mensaje_cliente TEXT,
  respuesta_sistema TEXT,
  creado_en TIMESTAMP DEFAULT NOW()
);
```

---

## Endpoints del Backend

### Autenticación & Configuración del Anfitrión

```
POST /api/alojamientos/registrar
  Body: { email, nombre, descripcion, ubicacion, zona }
  Response: { codigo_unico, token }

GET /api/alojamientos/:codigo
  Autentica con token
  Response: { alojamiento, informacion, proveedores_recomendados }

PUT /api/alojamientos/:codigo/informacion
  Body: { tipo, contenido }
  Ej: { tipo: "wifi", contenido: "50Mbps, contraseña en la puerta" }

POST /api/alojamientos/:codigo/proveedores
  Body: { nombre, tipo, telefono, descripcion }
  Response: { proveedor_id }

DELETE /api/alojamientos/:codigo/proveedores/:proveedor_id
```

### WhatsApp Webhook

```
POST /api/whatsapp/webhook
  Body (from Meta): { messages: [...] }
  Procesa: extrae código, consulta, busca, responde

GET /api/whatsapp/webhook
  Validación de token con Meta
```

### Búsqueda/Consulta (usado por Deepseek + backend)

```
GET /api/busqueda/:codigo
  Query: { tipo, palabra_clave }
  Ej: GET /api/busqueda/ABC123?tipo=alojamiento&palabra_clave=wifi
  Response: { resultados: [...] }

GET /api/busqueda/zona/:zona
  Query: { tipo }
  Obtiene todos los proveedores de una zona (para contexto)
```

---

## Integración con Deepseek

### Flujo de Extracción de Intención

```javascript
// Backend recibe: "¿hay WiFi?"
const consulta = "¿hay WiFi?";
const codigo = "ABC123";

const respuesta = await deepseekAPI.chat({
  model: "deepseek-chat",
  messages: [
    {
      role: "system",
      content: `Eres un asistente que clasifica consultas de huéspedes.
      Extrae: intención (tipo de servicio), palabras clave, y si es sobre el alojamiento o servicios externos.
      Responde en JSON: { tipo: "alojamiento" | "servicio", intención: "...", palabras_clave: [...] }`
    },
    {
      role: "user",
      content: consulta
    }
  ]
});

// Deepseek responde: { tipo: "alojamiento", intención: "wifi", palabras_clave: ["wifi", "internet"] }
// Backend busca en DB con esa información
```

**Costos esperados:** $20 USD = ~2000-5000 consultas (muy holgado para MVP).

---

## Integración con WhatsApp Cloud API

### Setup Inicial

1. **Número de WhatsApp:** Uno único para MVP (después cada anfitrión puede tener el suyo).
2. **Webhook:** El backend expone `POST /api/whatsapp/webhook`.
3. **Token:** Guardado en variables de entorno (`WHATSAPP_TOKEN`, `WHATSAPP_PHONE_ID`).

### Recepción de Mensajes

```javascript
// POST /api/whatsapp/webhook
app.post('/api/whatsapp/webhook', (req, res) => {
  const { entry } = req.body;
  
  entry.forEach(({ changes }) => {
    changes.forEach(({ value }) => {
      const { messages } = value;
      
      messages?.forEach(msg => {
        const { from, text, id } = msg;
        const codigo = extraerCodigoDelMensaje(text.body); // Ej: "ABC123 ¿hay wifi?"
        
        procesarConsulta(codigo, text.body, from);
      });
    });
  });
  
  res.sendStatus(200); // Confirmar a Meta
});
```

### Envío de Respuestas

```javascript
async function responderPorWhatsApp(telefono, mensaje) {
  const response = await fetch('https://graph.instagram.com/v18.0/102.../messages', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${WHATSAPP_TOKEN}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      messaging_product: 'whatsapp',
      recipient_type: 'individual',
      to: telefono,
      type: 'text',
      text: { body: mensaje }
    })
  });
}
```

---

## Panel del Anfitrión (Nuxt)

### Páginas Principales

```
/login
  └─ Ingresa código o email

/dashboard
  ├─ Resumen: código, zona, nº de proveedores
  ├─ Mi código (para compartir con clientes)
  └─ Estadísticas básicas (consultas recibidas, etc.)

/informacion
  ├─ WiFi, amenities, reglas
  ├─ Horarios de checkout, instrucciones
  └─ Guardar/editar

/proveedores
  ├─ Listado de tus recomendaciones
  ├─ Agregar nuevo proveedor
  ├─ Editar/eliminar
  └─ Ver proveedores de la zona (para agregar)

/descuentos (v2)
  └─ Ofrecer descuentos para aparecer en búsquedas
```

---

## Flujo de Desarrollo (Fases)

```mermaid
gantt
    title Roadmap de Desarrollo
    
    section MVP
    Setup Backend :phase1a, 2026-06-21, 3d
    Schema PostgreSQL :phase1b, 2026-06-21, 3d
    Endpoints Básicos :phase1c, after phase1b, 3d
    Webhook WhatsApp :phase1d, after phase1c, 3d
    Integración Deepseek :phase1e, after phase1d, 2d
    Panel Nuxt :phase1f, 2026-06-21, 7d
    Testing & Deploy :phase1g, after phase1e, 2d
    
    section Post-MVP
    Autenticación Robusta :phase2a, after phase1g, 3d
    Estadísticas :phase2b, after phase2a, 3d
    Sistema Descuentos :phase2c, after phase2b, 3d
    Números Individuales :phase2d, after phase2c, 5d
    Histórico & Privacidad :phase2e, after phase2d, 3d
    UI Polish & Tests :phase2f, after phase2e, 5d
```

### MVP (Semana 1-2)
- [ ] Backend básico (Express + PostgreSQL)
- [ ] Tabla: `alojamientos`, `informacion_alojamiento`, `proveedores`, `recomendaciones`
- [ ] Endpoint: registrar anfitrión, agregar proveedores
- [ ] Webhook WhatsApp: recibir mensaje, buscar, responder
- [ ] Integración Deepseek: clasificación básica
- [ ] Panel Nuxt: login, agregar información y proveedores

### Post-MVP (Semana 3+)
- [ ] Autenticación robusta (JWT, sesiones)
- [ ] Estadísticas del anfitrión (consultas, proveedores populares)
- [ ] Sistema de descuentos
- [ ] Cada anfitrión con su número de WhatsApp
- [ ] Histórico de conversaciones (privacidad)
- [ ] UI pulida, tests

---

## Consideraciones de Seguridad & Privacidad

1. **Códigos únicos:** Imposible adivinar; usar UUID v4 acortado.
2. **Números de WhatsApp:** Hash los números de clientes en histórico.
3. **Autenticación:** JWT con expiración; refrescar con refresh token.
4. **CORS:** Restringir a dominio de Vercel.
5. **Rate limiting:** Evitar spam en WhatsApp (máx 10 consultas/min por número).

---

## Arquitectura de Deployment

```mermaid
graph TB
    subgraph Internet["🌍 Internet"]
        USERS["Clientes + Anfitriones"]
    end
    
    subgraph Services["☁️ Servicios Externos"]
        WHATSAPP["WhatsApp Cloud API"]
        DEEPSEEK["Deepseek API"]
    end
    
    subgraph Vercel["Vercel (Frontend)"]
        NUXT["Nuxt App"]
        CERT["HTTPS/Certificado"]
    end
    
    subgraph Railway["Railway (Backend)"]
        NODE["Express Server"]
        PG["PostgreSQL DB"]
        ENV["Env Vars"]
    end
    
    USERS -->|navigates| CERT
    CERT --> NUXT
    USERS -->|WhatsApp messages| WHATSAPP
    WHATSAPP -->|webhook| NODE
    NODE -->|consulta| PG
    NODE -->|API call| DEEPSEEK
    NODE -.->|reads| ENV
    NUXT -->|API calls| NODE
    
    style Vercel fill:#000000,color:#fff
    style Railway fill:#0B0E11,color:#fff
    style Services fill:#FFA500,color:#000
```

## Deployment Checklist

- [ ] Vercel: conectar repo, env vars (DEEPSEEK_API_KEY, WHATSAPP_TOKEN, etc.)
- [ ] Railway: crear app Node.js + PostgreSQL
- [ ] Variables de entorno en ambos (nunca commitear secrets)
- [ ] Webhook de WhatsApp apuntando a `https://tu-backend.railway.app/api/whatsapp/webhook`
- [ ] Dominio personalizado en Vercel (opcional para MVP)
- [ ] HTTPS en todo (obligatorio para WhatsApp)

---

## Próximos Pasos

1. Revisar este documento y ajustar según feedback.
2. Crear repo en studious-giggle con estructura de carpetas.
3. Comenzar con backend y BD.
4. Luego, panel Nuxt.
5. Integración WhatsApp al final (para no romper en el proceso).
