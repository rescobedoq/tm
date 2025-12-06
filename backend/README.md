# Gemini AI Backend

Backend con FastAPI para enviar prompts a Gemini 2.0 Flash Live.

## Configuración

1. Copia `.env.example` a `.env` y añade tu API key de Gemini:
```
GEMINI_API_KEY=tu_api_key_aqui
```

2. Instala las dependencias:
```bash
pip install -r requirements.txt
```

3. Ejecuta el servidor:
```bash
python main.py
```

O con uvicorn:
```bash
uvicorn main:app --reload
```

## Documentación API

Una vez el servidor esté corriendo, accede a:
- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

## Endpoints

### GET /
Verificar que la API está funcionando

### GET /health
Health check del servicio

### POST /api/prompt
Enviar un prompt a Gemini

**Request Body:**
```json
{
  "prompt": "Tu pregunta aquí",
  "temperature": 0.7,
  "max_tokens": 1000
}
```

**Response:**
```json
{
  "response": "Respuesta de Gemini",
  "prompt": "Tu pregunta aquí",
  "model": "gemini-2.0-flash-live"
}
```

### POST /api/chat
Endpoint alternativo para chat

## Tecnologías

- FastAPI
- Google Generative AI (Gemini)
- Uvicorn
- Python 3.12+
