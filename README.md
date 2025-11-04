# 🕰️ TIME MADNESS
**Estrategia, conquista y caos a través del tiempo.**

---

## 🎮 Descripción General

**Time Madness** es un videojuego de **estrategia en tiempo real en 3D**, desarrollado en **Unity (C#)**, inspirado en clásicos como *Warcraft III* y *Civilization*. El jugador asume el mando de una de tres civilizaciones que coexisten en un mundo utópico fracturado por el tiempo:

* **Los Medievales** – Maestros de la magia y el control del terreno.
* **Los Contemporáneos (WWII)** – Dominan la industria y la masa.
* **Los Futuristas** – Expertos en tecnología, precisión y movilidad.

El juego se divide en **dos fases principales**:

1. **Fase de Preparación:** el jugador gestiona recursos, construye edificios y entrena unidades.
2. **Fase de Combate:** las tropas se enfrentan en un mapa dividido en cuadrículas con distintos tipos de terreno (agua, montaña, llanura, bosque, playa, etc.).

El objetivo es **conseguir cinco “invasores”** (unidades que llegan a casillas colindantes con el reino enemigo) para obtener la victoria.

---

## 🧩 Características Principales

* 🌍 **Tres civilizaciones** con mecánicas y estilos de juego diferenciados.
* 🕹️ **Modo multijugador local** (versus) y **modo un jugador vs IA**.
* ⚙️ **Sistema de gestión de recursos y edificios.**
* ⚔️ **Batallas tácticas en tiempo real** en un mapa dinámico por cuadrículas.
* 💾 **Guardado y carga de partidas** mediante archivos.
* 💡 **Diseño modular y orientado a objetos.**
* 🧠 **IA adaptable** que aprende de los patrones del jugador.
* 🎨 **Gráficos 3D** con cámara variable (rotación, zoom y altura ajustable).

---

## 🧠 Game Design Document (GDD)
### 1. Concepto Central
Time Madness combina estrategia, administración de recursos y combate táctico en un entorno donde las eras temporales colisionan. El jugador debe equilibrar crecimiento económico, producción militar y control territorial, aprovechando las ventajas únicas de su civilización.

---
### 2. Historia y Ambientación
En un futuro distante, una falla temporal fractura el continuo espacio-tiempo. Tres eras se superponen sobre un mismo mundo utópico:
* Los **Medievales**, fieles a la magia y la tradición.
* Los **Contemporáneos**, hijos de la guerra industrial.
* Los **Futuristas**, que manipulan la energía cuántica y la inteligencia artificial.
Cada civilización busca dominar el nuevo orden temporal, reclamando los territorios de las demás para establecer su supremacía.

---
### 3. Mecánicas de Juego
#### a) Fase de Preparación
* Recolección de recursos (oro, madera, energía).
* Construcción de edificios: cuarteles, talleres, laboratorios, torres defensivas.
* Entrenamiento de unidades.
* Posicionamiento inicial del ejército.

#### b) Fase de Combate

* Sistema **en tiempo real**, donde cada jugador mueve sus unidades en un tablero cuadriculado.
* Cada tipo de terreno afecta el movimiento y ataque (ej. montañas = defensa +, agua = movilidad -).
* Validación de movimientos y ataques mediante reglas predefinidas.
* El combate se gana al lograr **5 invasores** junto al territorio enemigo.

#### c) Tipos de Unidades (ejemplo)

| Facción    | Unidad Base | Unidad Especial | Ventaja                            |
| ---------- | ----------- | --------------- | ---------------------------------- |
| Medievales | Caballero   | Hechicero       | Magia de área y control de terreno |
| WWII       | Soldado     | Tanque          | Daño masivo y resistencia          |
| Futuristas | Drone       | Mecha           | Alta movilidad y precisión         |

---

### 4. Interfaz de Usuario (UI/UX)

* **Panel lateral** con recursos, turnos y botones de acción (mover, atacar, construir).
* **Minimapa** con vista global del campo.
* **Indicadores visuales** de movimiento, ataque y alcance.
* **Ventanas modales** para guardado/carga de partidas y configuración.

---

### 5. Estilo Visual y Sonoro

* **Estilo gráfico:** semi-realista con estética 3D estilizada.
* **Paleta de colores:** tonos cálidos para Medievales, grises industriales para WWII, neones azules y púrpuras para Futuristas.
* **Música:** ambiental por era (orquestal, bélica, electrónica).
* **Efectos de sonido:** golpes, explosiones, energía.

---

### 6. Arquitectura Técnica

* **Motor:** Unity 2023.x o superior
* **Lenguaje:** C#
* **Patrón de diseño:** MVC.
* **Sistemas principales:**

  * `GameManager` – control general de turnos y estado.
  * `UnitManager` – gestión de unidades y sus acciones.
  * `ResourceSystem` – administración de recursos y economía.
  * `MapGrid` – generación del mapa y validación de movimientos.
  * `SaveSystem` – guardado/carga mediante archivos JSON o binarios.
  * `AIController` – inteligencia artificial basada en heurísticas de decisión (ataque, defensa, recursos).

---


## 📅 Plan de Acción (6 Semanas)

| Semana | Objetivos Principales                                                                      | Entregables                                                 |
| ------ | ------------------------------------------------------------------------------------------ | ----------------------------------------------------------- |
| **1**  | Planificación y estructura del proyecto en Unity. <br> Diseño del mapa base y grid system. | Proyecto Unity configurado, escena inicial, mapa prototipo. |
| **2**  | Implementar sistema de recursos, edificios y entrenamiento de unidades.                    | Scripts funcionales, UI de recursos.                        |
| **3**  | Implementar movimiento y combate por turnos. <br> Sistema de validación de acciones.       | Turnos funcionales, unidades interactivas.                  |
| **4**  | Desarrollo de IA básica (ataque, defensa, movimiento). <br> Modo multijugador local.       | IA inicial y modo 2 jugadores local.                        |
| **5**  | Implementar guardado/carga de partidas. <br> Mejorar UI y efectos visuales.                | Sistema de guardado estable, interfaz refinada.             |
| **6**  | Testing, balance de facciones, optimización y presentación final.                          | Versión jugable completa, demo final.                       |

---


## 📜 Licencia

Proyecto académico/desarrollo independiente.
Uso libre con atribución al equipo original de *Time Madness*.

---

## 👥 Créditos

**Equipo de Desarrollo:**

* *David Alfredo Huamani Ollachica* 
* *Alvaro Raul Quispe Condori*

