# 🕰️ TIME MADNESS
**Estrategia, conquista y caos a través del tiempo.**
[Video Funcionalidad](https://youtu.be/SQXkDmZ0ClE)


---

## 🎮 Descripción General

**Time Madness** es un videojuego de **estrategia en tiempo real (RTS) en 3D**, desarrollado en **Godot Engine 4.3+**, inspirado en clásicos como *Warcraft III* y *Age of Empires*. 

En un mundo fracturado por anomalías temporales, tres civilizaciones luchan por la supremacía:

* **🏰 Los Medievales** – Maestros de la magia arcana, dragones y control del terreno
* **🎖️ Los Contemporáneos (WWII)** – *(En desarrollo)* Dominan la industria bélica y la artillería pesada
* **🤖 Los Futuristas** – *(En desarrollo)* Expertos en tecnología avanzada, robots y energía láser

### 🎯 Mecánicas Principales

El juego se estructura en **10 stages** alternados:

1. **⚙️ Stages IMPARES (Base):** Construcción, gestión de recursos, entrenamiento de unidades y planificación estratégica
2. **⚔️ Stages PARES (Battle):** Combate en tiempo real en mapas especializados con sistema de vidas

**Objetivo:** Eliminar a todos los jugadores enemigos destruyendo sus castillos de batalla o sobrevivir hasta el stage 10 con vidas restantes.

---

## 🧩 Características Principales

### ✅ Implementadas

* 🏰 **Civilización Medieval completa** con 10 tipos de unidades y 8 edificios funcionales
* 🎮 **Sistema de stages** alternados (Base/Battle) con timer de 10 segundos
* 👥 **Multijugador local:** 1 humano + hasta 5 bots simultáneos
* 🤖 **IA avanzada** con 12 estados de decisión y 3 niveles de dificultad
* 💰 **Sistema económico:** Oro, recursos, upkeep y workers
* 🏗️ **Sistema de construcción** con validación de terreno y proximidad
* ⚔️ **Sistema de combate táctico:** Daño, críticos, habilidades, formaciones
* 💾 **Gestión de perfiles** con persistencia JSON
* 🎥 **Cámara RTS profesional** con zoom, rotación y límites configurables
* 🖼️ **HUD completo:** UnitHud, TeamHud, PlayerHud, InfoHud, Battle Log
* 🎨 **Sistema de equipos** con colores diferenciados y alianzas
* 💀 **Sistema de vidas en batalla** (6 vidas por jugador)
* 🏆 **Condiciones de victoria/derrota** con pantallas de resultado

### 🚧 En Desarrollo

* 🎖️ **Civilización Contemporánea (WWII)**
  - Unidades: Soldado, Tanque, Artillería, Bombardero
  - Edificios: Bunker, Fábrica de Tanques, Aeródromo
  - Mecánicas únicas: Trincheras, bombardeo aéreo
  
* 🤖 **Civilización Futurista**
  - Unidades: Drones, Mechas, Unidades de energía
  - Edificios: Reactor, Laboratorio, Plataforma orbital
  - Mecánicas únicas: Teletransporte, escudos de energía

* 🌍 **Modo Historia** con campaña narrativa por civilización
* 🌐 **Multijugador en red** (LAN y Online)
* 📊 **Sistema de estadísticas avanzadas** y ranking
* 🎵 **Música y efectos de sonido** ambientales por civilización
* 🗺️ **Generación procedural de mapas** con biomas variados

---

## 🕹️ Modos de Juego

### 1. 🎮 Modo Individual (Implementado)
* Partidas personalizadas contra hasta 5 bots
* Selección de civilización (actualmente solo Medieval)
* Tres niveles de dificultad por bot:
  - **Fácil:** Reacción lenta, estrategia básica
  - **Normal:** Balanceado, uso de formaciones
  - **Difícil:** Agresivo, microgestión avanzada
* Configuración de equipos y alianzas

### 2. 🏆 Modo Historia (En desarrollo)
* Campañas narrativas por civilización
* Misiones con objetivos específicos
* Desbloqueo progresivo de unidades y tecnologías
* Sistema de guardado de progreso

### 3. 🌐 Modo Multijugador (Planificado)
* **Local:** Hotseat y pantalla dividida
* **LAN:** Partidas en red local
* **Online:** Matchmaking y partidas clasificatorias

---

## 🏗️ Arquitectura del Sistema

**Time Madness** está estructurado siguiendo el patrón arquitectónico **por capas** adaptado al desarrollo de videojuegos en Godot Engine:

### 📊 Capas Principales

#### 1. 🌍 Capa Global (Singletons/Autoloads)
Gestiona el estado global del juego y servicios compartidos:
- **GameStarter:** Control de stages, timer, alternancia Base/Battle
- **Datos globales:** UnitStats, UnitCosts, BuildingCosts, Teams
- **Servicios:** FadeLayer (transiciones), GlobalUser (perfiles)

#### 2. 🎮 Capa de Juego (Game Core)
Controla el flujo del juego y coordina sistemas:
- **GameManager:** Máquina de estados (Intro → Preparation → Playing)
- **Mapas:** BaseMap (construcción) y BattleMap (combate)
- **Controllers:** PlayerController (humano) y BotController (IA)

#### 3. 🏰 Capa de Entidades (Game Objects)
Representa elementos interactivos del juego:
- **Units:** 10 tipos con sistemas de combate, movimiento y habilidades
- **Buildings:** 8 tipos con capacidad de producción y entrenamiento

### 📡 Comunicación entre Capas

El sistema utiliza **señales (signals)** de Godot para comunicación basada en eventos:
- Capa Global emite señales (`stage_changed`, `battle_mode_started`)
- Capa de Juego escucha señales y coordina entidades
- Capa de Entidades notifica cambios de estado (`health_changed`, `died`)

Este diseño permite **separación de responsabilidades**, **bajo acoplamiento** y **alta escalabilidad**.

---

## 🎲 Sistemas del Juego

### 1.  👤 Gestión de Perfiles
- ✅ Creación con validación (máx.  20 caracteres alfanuméricos)
- ✅ Auto-incremento de duplicados (Usuario_1, Usuario_2)
- ✅ Almacenamiento persistente en JSON
- ✅ Configuraciones personalizadas (brillo, sensibilidad, fuente, idioma)
- ✅ Selección rápida desde menú principal
- 🚧 Estadísticas de juego (partidas, victorias, tiempo total)

### 2. ⚙️ Sistema de Stages
- ✅ **10 stages totales** de 10 segundos cada uno
- ✅ Alternancia automática Base (impares) / Battle (pares)
- ✅ Battle Log con resumen entre stages
- ✅ Indicadores visuales de progreso
- ✅ Timer visible en HUD

### 3. 💰 Sistema Económico
**Recursos:**
- **Oro:** 1/segundo por worker
- **Recursos:** 0.5/segundo por worker
- **Upkeep:** Consumido por unidades militares
- **MaxUpkeep:** +5 por cada granja construida

**Límites:**
- Máximo 6 unidades militares por stage
- Validación automática de recursos
- Alertas de recursos insuficientes

### 4. 🏗️ Sistema de Construcción
**Edificios disponibles:**
- Castle, Barracks, Farm, Harbor
- Magic School, Shrine, Dragon Lair
- Tower, Smithy

**Mecánicas:**
- Vista previa 3D con validación
- Detección de colisiones
- Verificación de terreno
- Solo en Fase Base

### 5. ⚔️ Sistema de Combate
**Fórmula de daño:**
```
damage = max(1, attack_damage - defense/2)
crítico = 10% probabilidad → daño × 2
```

**Composición de ejércitos:**
- 30% Tanks (Soldier, Golem)
- 40% DPS (Archer, Sorcerer, Dragon)
- 20% Support (Druid)
- 10% Cavalry

**Comandos:**
- Move, Attack, Patrol, Stop, Hold Position
- Selección múltiple con caja de arrastre
- Hasta 100 unidades simultáneas

### 6. 🤖 Inteligencia Artificial
**Estados Base:**
1.  BOOTSTRAP → Economía inicial
2. MILITARY_SETUP → Primera infraestructura militar
3. PRODUCTION → Producción continua
4. TECH_ADVANCE → Edificios avanzados
5.  FINAL_PUSH → Máxima producción

**Estados Battle:**
1. DEPLOY → Despliegue en formación
2. ESTABLISH_DEFENSE → Línea defensiva
3. SCOUT → Exploración
4. ENGAGE → Combate defensivo
5. PUSH_OBJECTIVES → Ataque a castillos
6. RETREAT → Retirada táctica
7. DEFEND_BASE → Defensa total

**Modificadores por dificultad:**
| Parámetro | Fácil | Normal | Difícil |
|-----------|-------|--------|---------|
| Velocidad producción | 0.5× | 1. 0× | 1.5× |
| Tiempo reacción | 3.0s | 1.5s | 0.5s |
| Agresividad | 30% | 40% | 70% |
| Microgestión | ❌ | ✅ | ✅ |
| Formaciones | ❌ | ✅ | ✅ |

### 7. 💀 Sistema de Vidas (Batalla)
- Cada jugador inicia con **6 vidas**
- Pérdida de 1 vida cuando enemigo toca castillo
- Invulnerabilidad temporal (2 segundos)
- Derrota al llegar a 0 vidas
- Barra visual en HUD

### 8. 🏆 Victoria y Derrota
**Victoria:**
- Último equipo vivo
- Sobrevivir hasta stage 10

**Derrota:**
- 0 vidas en batalla
- Eliminación total

**Pantallas:**
- WinScene, LoseScene, DrawScene
- Estadísticas finales

---

## 🎨 Unidades y Edificios

### 🏰 Civilización Medieval (Implementada)

#### Unidades (10 tipos)
| Unidad | Tipo | Costo | Upkeep | Descripción |
|--------|------|-------|--------|-------------|
| Slave | Worker | 50 oro | 1 | Recolector de recursos |
| Soldier | Tank | 100 oro | 1 | Infantería cuerpo a cuerpo |
| Archer | DPS | 100 oro, 25 rec | 1 | Ataque a distancia |
| Cavalry | Móvil | 100 oro, 50 rec | 2 | Alta velocidad |
| Magic Soldier | Híbrido | 100 oro, 60 rec | 2 | Magia + físico |
| Sorcerer | DPS | 100 oro, 80 rec | 3 | Hechicero ofensivo |
| Golem | Tank | 100 oro, 100 rec | 3 | Alta resistencia |
| Druid | Support | 100 oro, 50 rec | 2 | Curación y buffs |
| Dragon | Especial | 100 oro, 200 rec | 5 | Volador, daño masivo |
| Ship | Naval | 200 oro, 100 rec | 2 | Unidad acuática |

#### Edificios (8 tipos)
| Edificio | Costo | Función |
|----------|-------|---------|
| Castle | - | Produce workers |
| Barracks | 300 oro, 100 rec | Entrena Soldier, Archer, Cavalry |
| Farm | 100 oro, 50 rec | +5 MaxUpkeep |
| Harbor | 350 oro, 150 rec | Construye barcos |
| Magic School | 400 oro, 150 rec | Entrena Magic Soldier, Sorcerer |
| Shrine | 350 oro, 125 rec | Invoca Golem, Druid |
| Dragon Lair | 500 oro, 200 rec | Invoca Dragon |
| Tower | 250 oro, 100 rec | Defensa (pasiva) |
| Smithy | 200 oro, 75 rec | Mejoras (en desarrollo) |

---

## 🛠️ Tecnologías Utilizadas

### Motor y Lenguajes
- **Godot Engine:** 4.3+
- **GDScript:** 90.9%
- **GDShader:** 9.1%

### Patrones de Diseño
- **Command Pattern:** Comandos de unidades (MoveCommand, AttackCommand, etc.)
- **Strategy Pattern:** Dificultades de IA (EasyStrategy, MediumStrategy, HardStrategy)
- **State Machine:** Estados de IA y fases de juego
- **Singleton Pattern:** Autoloads (GameStarter, Teams, UnitStats, etc.)
- **Observer Pattern:** Sistema de señales de Godot

### Sistemas Principales
- **GameManager** – Control de flujo y estados del juego
- **PlayerController** – Input, cámara, HUD del jugador humano
- **BotController** – IA con máquina de estados
- **UnitManager** – Gestión de unidades y combate
- **ResourceSystem** – Economía y recursos
- **MapGrid** – Validación de terreno y colisiones
- **SaveSystem** – Persistencia de perfiles en JSON

---

## 📅 Roadmap de Desarrollo

### ✅ Completado (Semanas 1-6)
- [x] Arquitectura base del proyecto
- [x] Sistema de stages con timer
- [x] Civilización Medieval completa
- [x] Sistema económico funcional
- [x] IA con 3 niveles de dificultad
- [x] Sistema de combate y habilidades
- [x] Gestión de perfiles
- [x] HUD y UI completa
- [x] Sistema de vidas en batalla
- [x] Condiciones de victoria/derrota

### 🚧 En Progreso (Semanas 7-12)
- [ ] Civilización Contemporánea (WWII)
  - [ ] 8 unidades únicas
  - [ ] 6 edificios especializados
  - [ ] Mecánicas de trincheras y bombardeo
- [ ] Civilización Futurista
  - [ ] 8 unidades tecnológicas
  - [ ] 6 edificios avanzados
  - [ ] Mecánicas de energía y teletransporte
- [ ] Balance entre civilizaciones
- [ ] Sistema de mejoras (Smithy funcional)
- [ ] Música y efectos de sonido

### 📋 Planificado (Semanas 13-18)
- [ ] Modo Historia con campañas
- [ ] Multijugador en red (LAN)
- [ ] Generación procedural de mapas
- [ ] Sistema de replays
- [ ] Estadísticas y ranking
- [ ] Tutorial interactivo
- [ ] Cinemáticas de introducción

### 🌟 Futuro
- [ ] Multijugador online
- [ ] Editor de mapas
- [ ] Mods y contenido generado por usuarios
- [ ] Torneos y competitivo
- [ ] Versiones para otras plataformas

---

## 🚀 Instalación y Ejecución

### Requisitos del Sistema
- **SO:** Windows 10/11, Linux, macOS
- **RAM:** 4 GB mínimo, 8 GB recomendado
- **GPU:** Compatible con OpenGL 3.3+
- **Espacio:** 500 MB

### Pasos de Instalación

1. **Clonar el repositorio:**
```bash
git clone https://github.com/usuario/time-madness.git
cd time-madness
```

2. **Abrir en Godot Engine:**
   - Descargar [Godot 4.3+](https://godotengine.org/download)
   - Abrir el proyecto desde Godot
   - Esperar importación de assets

3. **Ejecutar:**
   - Presionar F5 o clic en "Play"
   - Crear perfil desde MainMenu
   - ¡Disfrutar! 
   - El ejecutable esta disponible para Windows y Linux en [link](https://drive.google.com/drive/folders/1SGJ8C4vmsJQlhwkx0VbE8UlbhO26IWj_?usp=sharing)

---

## 🎮 Controles

### Cámara
- **WASD** o **Bordes de pantalla** → Mover cámara
- **Q/E** o **Clic medio + arrastre** → Rotar
- **Rueda del mouse** o **+/-** → Zoom
- **R** → Centrar en base

### Unidades
- **Clic izquierdo** → Seleccionar unidad/edificio
- **Arrastre (>100px)** → Selección múltiple
- **Clic derecho** → Mover/Atacar (según contexto)
- **Z** → Mover
- **X** → Atacar
- **C** → Detener
- **V** → Patrullar

### Construcción (Solo Fase Base)
- **Clic en edificio** → Modo construcción
- **Clic izquierdo** → Confirmar ubicación
- **ESC** → Cancelar

---

## 📊 Estructura del Proyecto

```
time-madness/
├── Scenes/
│   ├── GUI/                    # Menús e interfaces
│   │   ├── MainMenu/
│   │   ├── ProfileMenu/
│   │   ├── OptionsMenu/
│   │   ├── StartingOptions/   # Lobby
│   │   └── CreditsMenu/
│   ├── Game/
│   │   ├── Main/
│   │   │   ├── GameScene/     # Escena principal
│   │   │   ├── WinScene/
│   │   │   └── LoseScene/
│   │   ├── buildings/         # 8 edificios medievales
│   │   └── units/             # 10 unidades medievales
│   └── Utils/                 # Utilidades (cursores, barras, etc.)
├── Scripts/
│   ├── Player/
│   │   ├── PlayerController/  # Controlador humano
│   │   └── BotController/     # IA
│   │       ├── BotAction.gd
│   │       └── AIBrain.gd
│   ├── Entities/
│   │   ├── Entity.gd
│   │   ├── Unit.gd
│   │   └── Building.gd
│   └── Autoloads/            # Singletons
│       ├── GameStarter. gd
│       ├── Teams.gd
│       ├── UnitStats.gd
│       └── ... 
├── Assets/
│   ├── Images/
│   │   └── Portraits/        # Retratos de unidades/edificios
│   ├── Models/               # Modelos 3D
│   └── Animations/           # Animaciones
└── addons/                   # Plugins de Godot
```

---

## 🐛 Problemas Conocidos

- [ ] Ocasionalmente unidades quedan atascadas en formación
- [ ] IA Hard puede consumir recursos excesivamente rápido
- [ ] Colisiones entre edificios necesitan mayor precisión
- [ ] Performance baja con >200 unidades simultáneas

---

## 🤝 Contribuciones

Este es un proyecto académico en desarrollo. Si deseas contribuir:

1. **Fork** el repositorio
2.  Crea una rama para tu feature (`git checkout -b feature/NuevaCaracteristica`)
3.  Commit tus cambios (`git commit -m 'Agrega nueva característica'`)
4. Push a la rama (`git push origin feature/NuevaCaracteristica`)
5. Abre un **Pull Request**

### Áreas de Mejora Prioritarias
- 🎨 Arte y modelos 3D adicionales
- 🎵 Música y efectos de sonido
- 🌍 Diseño de mapas
- 🐛 Testing y balance
- 📖 Documentación

---

## 📜 Licencia

Este proyecto es de **uso académico y educativo**. 

Se permite:
- ✅ Uso con fines de aprendizaje
- ✅ Modificación y mejora del código
- ✅ Distribución con atribución al equipo original

**Atribución requerida:**
> Proyecto original desarrollado por David Alfredo Huamani Ollachica y Alvaro Raul Quispe Condori como parte del curso de Tecnología de objetos en la Universidad Nacional de San Agustín de Arequipa, 2025.

---

## 👥 Créditos

### Equipo de Desarrollo

| Nombre | Rol | Participación | Contacto |
|--------|-----|---------------|----------|
| **David Alfredo Huamani Ollachica** | Lead Developer, Game Designer, Programmer | 100% |
| **Alvaro Raul Quispe Condori** | Developer, Systems Architect, AI Programmer | 100% |

### Agradecimientos Especiales
- **Godot Engine Community** por documentación y recursos
- **Universidad Nacional de San Agustín de Arequipa** por el apoyo académico
- Comunidad de RTS fans por inspiración y feedback

---


## 🌟 Apoya el Proyecto

Si te gusta **Time Madness**, considera:
- ⭐ **Dar una estrella** al repositorio
- 🐦 **Compartir** en redes sociales
- 🐛 **Reportar bugs** y sugerencias
- 💡 **Contribuir** con código o assets
- 📢 **Difundir** el proyecto

---
