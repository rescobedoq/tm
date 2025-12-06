from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional
import google.generativeai as genai
import os
from dotenv import load_dotenv

# Cargar variables de entorno
load_dotenv()

# Configurar Gemini
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
GEMINI_MODEL = os.getenv("GEMINI_MODEL", "gemini-2.0-flash")

if not GEMINI_API_KEY:
    raise ValueError("GEMINI_API_KEY no está configurada en el archivo .env")

genai.configure(api_key=GEMINI_API_KEY)

# Contexto del juego TimeMadness
GAME_SYSTEM_CONTEXT = """Eres un bot del juego TimeMadness. A continuación se presenta el contexto completo del juego:

## 🏗️ COSTOS DE EDIFICIOS

- **Castle**: 0 gold, 0 resources, 0 upkeep
- **Barracks**: 150 gold, 50 resources, 0 upkeep
- **Dragon**: 500 gold, 300 resources, 0 upkeep
- **Farm**: 50 gold, 20 resources, 0 upkeep
- **Harbor**: 200 gold, 100 resources, 0 upkeep
- **Magic**: 300 gold, 150 resources, 0 upkeep
- **Shrine**: 150 gold, 80 resources, 0 upkeep
- **Smithy**: 120 gold, 60 resources, 0 upkeep
- **Tower**: 200 gold, 100 resources, 0 upkeep

## ⚔️ COSTOS DE UNIDADES

- **Train Slave**: 100 gold, 0 resources, 1 upkeep
- **Train Soldier**: 100 gold, 0 resources, 1 upkeep
- **Train Archer**: 100 gold, 25 resources, 1 upkeep
- **Train Cavalry**: 100 gold, 50 resources, 2 upkeep
- **Train Dragon**: 100 gold, 200 resources, 5 upkeep
- **Train Druid**: 100 gold, 50 resources, 2 upkeep
- **Train Golem**: 100 gold, 100 resources, 3 upkeep
- **Train Magic Soldier**: 100 gold, 60 resources, 2 upkeep
- **Train Sorcerer**: 100 gold, 80 resources, 3 upkeep
- **Build Ship**: 200 gold, 100 resources, 2 upkeep
- **Build Ship Kraken**: 500 gold, 300 resources, 4 upkeep
- **Build Ship Ghost**: 400 gold, 250 resources, 3 upkeep

## 📊 ESTADÍSTICAS DE UNIDADES

### Medieval Dragon
- Health: 200/200
- Attack: 25 | Defense: 10
- Speed: 50 | Range: 40
- Magic: 1000
- Abilities: Fireball

### Medieval Druid
- Health: 200/200
- Attack: 25 | Defense: 10
- Speed: 20 | Range: 30
- Magic: 1000
- Abilities: Root Unit, Steal Life

### Medieval Golem
- Health: 350/350
- Attack: 40 | Defense: 20
- Speed: 10 | Range: 10
- Magic: 1000
- Abilities: Punch, Spawn

### Medieval Soldier
- Health: 150/150
- Attack: 15 | Defense: 5
- Speed: 25 | Range: 10
- Magic: 1000
- Abilities: Charge

### Medieval Archer
- Health: 120/120
- Attack: 12 | Defense: 3
- Speed: 20 | Range: 50
- Magic: 1000
- Abilities: Arrows, Trap

### Medieval Cavalry
- Health: 180/180
- Attack: 25 | Defense: 8
- Speed: 40 | Range: 15
- Magic: 1000
- Abilities: Thrust

### Medieval Sorcerer
- Health: 200/200
- Attack: 25 | Defense: 10
- Speed: 7 | Range: 30
- Magic: 1000
- Abilities: Area Defense, Heal, Mental Control

### Medieval Magic Soldier
- Health: 180/180
- Attack: 20 | Defense: 8
- Speed: 15 | Range: 25
- Magic: 1000
- Abilities: Magic Ball

### Medieval Ship Ghost
- Health: 250/250
- Attack: 30 | Defense: 10
- Speed: 15 | Range: 35
- Magic: 1000
- Abilities: None

### Medieval Ship Kraken
- Health: 400/400
- Attack: 50 | Defense: 20
- Speed: 10 | Range: 30
- Magic: 1000
- Abilities: None

### Medieval Ship Normal
- Health: 300/300
- Attack: 20 | Defense: 12
- Speed: 12 | Range: 25
- Magic: 1000
- Abilities: Ghost Ship, Kraken Ship

## 🏛️ HABILIDADES DE EDIFICIOS

### Barracks
- **Train Soldier**: Trains a basic infantry soldier
- **Train Archer**: Trains a basic ranged archer
- **Train Cavalry**: Trains a light cavalry unit

### Castle
- **Train Slave**: Trains a worker unit for gathering gold and resources

### Harbor
- **Build Ship**: Builds a basic ship for attack and exploration

### Dragon
- **Summon Dragon**: Summons a powerful flying dragon

### Magic
- **Train Magic Soldier**: Trains a soldier using both physical and magical combat
- **Train Sorcerer**: Trains an offensive magic sorcerer

### Shrine
- **Summon Golem**: Summons a durable brute-force golem
- **Train Druid**: Trains a druid with natural magic abilities
"""

# Crear la aplicación FastAPI
app = FastAPI(
    title="Gemini AI Backend - TimeMadness",
    description="API para enviar prompts a Gemini con contexto del juego TimeMadness",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# Configurar CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Modelos Pydantic
class GamePromptRequest(BaseModel):
    """
    Modelo para la solicitud de prompt del juego TimeMadness
    """
    game_context: str
    available_actions: str
    temperature: Optional[float] = 0.7
    max_tokens: Optional[int] = 1000
    
    class Config:
        json_schema_extra = {
            "example": {
                "game_context": "Player has 500 gold, 200 resources. Castle and Barracks built.",
                "available_actions": "Train Soldier, Train Archer, Build Farm",
                "temperature": 0.7,
                "max_tokens": 1000
            }
        }

class PromptRequest(BaseModel):
    """
    Modelo para la solicitud de prompt genérica
    """
    prompt: str
    temperature: Optional[float] = 0.7
    max_tokens: Optional[int] = 1000
    
    class Config:
        json_schema_extra = {
            "example": {
                "prompt": "Explica qué es la inteligencia artificial",
                "temperature": 0.7,
                "max_tokens": 1000
            }
        }

class PromptResponse(BaseModel):
    """
    Modelo para la respuesta del prompt
    """
    response: str
    prompt: str
    model: str
    
    class Config:
        json_schema_extra = {
            "example": {
                "response": "La inteligencia artificial es...",
                "prompt": "Explica qué es la inteligencia artificial",
                "model": "gemini-2.0-flash"
            }
        }

@app.get("/", tags=["Health"])
async def root():
    """
    Endpoint raíz para verificar que la API está funcionando
    """
    return {
        "message": "Gemini AI Backend - TimeMadness está funcionando correctamente",
        "version": "1.0.0",
        "model": GEMINI_MODEL
    }

@app.get("/health", tags=["Health"])
async def health_check():
    """
    Endpoint de health check
    """
    return {
        "status": "healthy",
        "api_configured": bool(GEMINI_API_KEY)
    }

@app.post("/api/game/prompt", response_model=PromptResponse, tags=["TimeMadness"])
async def send_game_prompt(request: GamePromptRequest):
    """
    Envía un prompt del juego TimeMadness a Gemini con contexto completo del juego
    
    - **game_context**: Contexto actual del juego (oro, recursos, edificios, unidades)
    - **available_actions**: Acciones disponibles para el jugador
    - **temperature**: Controla la aleatoriedad (0.0 - 1.0). Valores más altos = más creatividad
    - **max_tokens**: Número máximo de tokens en la respuesta
    """
    try:
        # Construir el prompt completo con el contexto del juego
        full_prompt = f"""{GAME_SYSTEM_CONTEXT}

## CONTEXTO ACTUAL DEL JUEGO
{request.game_context}

## ACCIONES DISPONIBLES
{request.available_actions}

Basándote en el contexto del juego y las acciones disponibles, proporciona una recomendación estratégica para el jugador.
"""
        
        # Configurar el modelo
        generation_config = {
            "temperature": request.temperature,
            "max_output_tokens": request.max_tokens,
        }
        
        model = genai.GenerativeModel(
            model_name=GEMINI_MODEL,
            generation_config=generation_config
        )
        
        # Generar la respuesta
        response = model.generate_content(full_prompt)
        
        return PromptResponse(
            response=response.text,
            prompt=full_prompt,
            model=GEMINI_MODEL
        )
        
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Error al procesar el prompt: {str(e)}"
        )

@app.post("/api/prompt", response_model=PromptResponse, tags=["AI"])
async def send_prompt(request: PromptRequest):
    """
    Envía un prompt genérico a Gemini 2.0 Flash Live y retorna la respuesta
    
    - **prompt**: El texto del prompt a enviar a la IA
    - **temperature**: Controla la aleatoriedad (0.0 - 1.0). Valores más altos = más creatividad
    - **max_tokens**: Número máximo de tokens en la respuesta
    """
    try:
        # Configurar el modelo
        generation_config = {
            "temperature": request.temperature,
            "max_output_tokens": request.max_tokens,
        }
        
        model = genai.GenerativeModel(
            model_name=GEMINI_MODEL,
            generation_config=generation_config
        )
        
        # Generar la respuesta
        response = model.generate_content(request.prompt)
        
        return PromptResponse(
            response=response.text,
            prompt=request.prompt,
            model=GEMINI_MODEL
        )
        
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Error al procesar el prompt: {str(e)}"
        )

@app.post("/api/chat", tags=["AI"])
async def chat(request: PromptRequest):
    """
    Endpoint alternativo para chat con Gemini
    """
    try:
        generation_config = {
            "temperature": request.temperature,
            "max_output_tokens": request.max_tokens,
        }
        
        model = genai.GenerativeModel(
            model_name=GEMINI_MODEL,
            generation_config=generation_config
        )
        
        chat_session = model.start_chat(history=[])
        response = chat_session.send_message(request.prompt)
        
        return {
            "response": response.text,
            "prompt": request.prompt,
            "model": GEMINI_MODEL
        }
        
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Error en el chat: {str(e)}"
        )

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
