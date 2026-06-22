# Studious Giggle

WhatsApp AI assistant for Airbnb hosts. Guests ask questions, AI answers with personalized recommendations.

## Quick Start

### Prerequisites
- Node.js 18+
- PostgreSQL 12+
- Deepseek API key (free tier available)
- WhatsApp Business Account (optional for MVP)

### Setup

1. **Clone the repo**
```bash
git clone https://github.com/yourusername/studious-giggle.git
cd studious-giggle
```

2. **Install dependencies**
```bash
# Backend
cd backend
npm install

# Frontend
cd ../frontend
npm install
```

3. **Configure environment**
```bash
cp .env.example .env
# Edit .env with your actual values
```

4. **Create database**
```bash
# PostgreSQL
createdb studious_giggle
psql studious_giggle < schema.sql  # When schema is ready
```

5. **Run development servers**

Backend:
```bash
cd backend
npm run dev
```

Frontend:
```bash
cd frontend
npm run dev
```

Visit:
- Backend: http://localhost:3000
- Frontend: http://localhost:3000 (Nuxt)

## Project Structure

```
studious-giggle/
├── backend/              # Express API
│   ├── src/
│   │   ├── config/      # Configuration (DB, env)
│   │   ├── routes/      # API routes
│   │   ├── models/      # Database models
│   │   ├── services/    # Business logic
│   │   └── middlewares/ # Custom middlewares
│   └── package.json
├── frontend/             # Nuxt app
│   ├── pages/
│   ├── components/
│   └── package.json
├── ARCHITECTURE.md       # Detailed architecture
└── README.md
```

## Architecture

See [ARCHITECTURE.md](./ARCHITECTURE.md) for complete architecture details, including:
- System design
- Database schema
- API endpoints
- Deployment strategy

## Development

### Backend
- Express.js for API
- PostgreSQL for data
- Deepseek API for LLM

### Frontend
- Nuxt 3 for UI
- TailwindCSS for styling (optional)

## API Endpoints (WIP)

See ARCHITECTURE.md for complete endpoint specification.

## Contributing

1. Create a feature branch
2. Make your changes
3. Commit with clear messages
4. Push and open a PR

## License

MIT
