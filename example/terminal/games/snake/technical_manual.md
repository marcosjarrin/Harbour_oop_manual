# 📘 Snake Harbour — Technical Architecture Manual
## Manual Técnico de Arquitectura

---

## 🇬🇧 ENGLISH VERSION

### 1. Introduction
This document details the Object-Oriented Programming (OOP) architecture of the **Snake Harbour** terminal game. It describes the rationale behind each class, its internal state (Data), and its behaviors (Methods), following the BadaSystem Harbour-Doc standards.

### 2. Inheritance and Relationship Diagram
In this project, **no custom inheritance** was implemented (no class uses the `FROM` keyword). All classes implicitly inherit from Harbour's base `HBObject`. 

The architecture relies heavily on **Composition** and **Value Objects** to ensure high cohesion and low coupling.

```text
┌─────────────────────────────────────────────────────────────┐
│                     HARBOUR BASE CLASS                      │
│                        (HBObject)                           │
└──────────────────────────────┬──────────────────────────────┘
                               │ (Implicit Inheritance)
           ┌───────────────────┼───────────────────┐
           │                   │                   │
    ┌──────▼──────┐     ┌──────▼──────┐     ┌──────▼──────┐
    │ TCoordinate │     │   TScreen   │     │    TFood    │
    │ (Value Obj) │     │   (View)    │     │   (Model)   │
    └──────┬──────┘     └─────────────┘     └──────┬──────
           │ Uses                                    │ Uses
           │                                         │
           ▼                                         ▼
    ┌──────────────┐                         ┌──────────────┐
    │    TSnake    │◄────────────────────────│ TSnakeGame   │
    │   (Model)    │      Composes           │ (Controller) │
    └──────────────┘                         └──────────────┘
```

**Relationships:**
*   **Composition:** `TSnakeGame` owns and manages the lifecycle of `TSnake`, `TFood`, and `TScreen`.
*   **Association/Usage:** `TSnake` and `TFood` heavily rely on `TCoordinate` to track positions.

---

### 3. Detailed Class Breakdown

#### 3.1 `TCoordinate` (Value Object)
**Purpose:** Represents an immutable 2D position (row, col) on the terminal grid. It prevents primitive obsession and encapsulates grid math.
*   **Data:** `nRow` (Numeric), `nCol` (Numeric).
*   **Methods:**
    *   `New( nRow, nCol )`: Constructor. Initializes coordinates.
    *   `Clone()`: Returns a new instance with the same values.
    *   `Equals( oOther )`: Compares two coordinates. Includes defensive `HB_IsObject()` checks to prevent BASE/1004.
    *   `MoveUp/Down/Left/Right()`: Returns a *new* `TCoordinate` shifted by 1 cell. Ensures immutability.
    *   `IsValid( nMaxRow, nMaxCol )`: Checks if the coordinate is within the playable area.

#### 3.2 `TSnake` (Entity / Model)
**Purpose:** Manages the snake's body, direction, and collision logic.
*   **Data:** 
    *   `aBody` (Array of `TCoordinate`): The snake's segments.
    *   `nDirection` (Numeric): Current heading (ASCII arrow codes).
    *   `nPendingGrowth` (Numeric): Counter for segments to add.
*   **Methods:**
    *   `New( oHeadCoord )`: Builds the initial 5-segment body.
    *   `GetHead()`, `GetTail()`, `GetSegment( nIndex )`: Encapsulated accessors. Prevents direct external modification of `aBody`.
    *   `Move()`: Reconstructs the body array cleanly to avoid `NIL` holes. Handles growth logic.
    *   `Grow()`: Increments the pending growth counter.
    *   `ChangeDirection( nNewDir )`: Validates input and prevents 180° reversals.
    *   `CollidesWithSelf()`, `CollidesWith( oCoord )`: Collision detection. Starts loop at index 2 to avoid false positives (head vs. head).

#### 3.3 `TFood` (Entity / Model)
**Purpose:** Handles the random spawning of food, ensuring it never overlaps the snake.
*   **Data:** `oPosition` (`TCoordinate`), `nMaxRow`, `nMaxCol`.
*   **Methods:**
    *   `New( nMaxRow, nMaxCol )`: Initializes boundaries.
    *   `Spawn( oSnake )`: Generates random coordinates. Uses a retry loop (max 500 attempts) and calls `oSnake:CollidesWith()` to ensure valid placement.
    *   `GetPosition()`: Safe accessor for the food's location.

#### 3.4 `TScreen` (View / Rendering)
**Purpose:** Wraps Harbour's terminal drawing primitives (`@ SAY`).
*   **Data:** `nRows`, `nCols`.
*   **Methods:**
    *   `New( nRows, nCols )`: Sets screen dimensions.
    *   `Clear()`: Full `CLS`.
    *   `ClearPlayfield()`: Selective clearing (rows 2 to nRows-1) to reduce flickering.
    *   `DrawBorder()`: Draws the double-line frame.
    *   `DrawSnake( oSnake )`, `DrawFood( oFood )`: Iterates through models and renders characters (`@`, `*`, `#`).
    *   `DrawHUD( nScore, nHighScore, nLength )`: Renders the bottom status bar.

#### 3.5 `TSnakeGame` (Controller / Orchestrator)
**Purpose:** The main loop. Manages game state, input, and timing.
*   **Data:** Instances of `TSnake`, `TFood`, `TScreen`. Game state variables (`nScore`, `nSpeed`, `nInitialSpeed`, `lRunning`).
*   **Methods:**
    *   `Run()`: Top-level menu loop.
    *   `InitRound()`: Resets state and draws the initial frame.
    *   `GameLoop()`: The core loop. Uses `Inkey( ::nSpeed )` to create a natural timing delay while capturing input.
    *   `HandleInput( nKey )`: Maps virtual keys to direction changes.
    *   `Update()`: Moves the snake and checks for food consumption.
    *   `CheckCollisions()`: Evaluates wall and self-collisions.
    *   `Render()`: Calls `TScreen` methods to update the display.

---

### 4. Design Decisions & Patterns
1.  **Immutability:** `TCoordinate` operations return new objects, preventing side effects.
2.  **Encapsulation:** `TSnake` hides its `aBody` array. External classes must use `GetSegment()`.
3.  **Timing over Sleep:** The game loop uses `Inkey( timeout )` instead of `hb_IdleSleep()`. This is the classic xBase pattern for smooth, interruptible game loops.
4.  **Defensive Programming:** All `:Equals()` and `:CollidesWith()` calls are guarded with `HB_IsObject()` to prevent runtime BASE/1004 errors.

---

## 🇸 VERSIÓN EN ESPAÑOL

### 1. Introducción
Este documento detalla la arquitectura de Programación Orientada a Objetos (POO) del juego de terminal **Snake Harbour**. Describe la justificación detrás de cada clase, su estado interno (Datos) y sus comportamientos (Métodos), siguiendo los estándares Harbour-Doc de BadaSystem.

### 2. Diagrama de Herencia y Relaciones
En este proyecto, **no se implementó herencia personalizada** (ninguna clase utiliza la palabra clave `FROM`). Todas las clases heredan implícitamente de la clase base `HBObject` de Harbour.

La arquitectura se basa fuertemente en **Composición** y **Objetos Valor** para garantizar alta cohesión y bajo acoplamiento.

```text
─────────────────────────────────────────────────────────────┐
│                   CLASE BASE DE HARBOUR                     │
│                        (HBObject)                           │
└──────────────────────────────┬──────────────────────────────┘
                               │ (Herencia Implícita)
           ┌───────────────────┼───────────────────┐
           │                   │                   │
    ┌──────▼──────┐     ┌──────▼──────┐     ┌──────▼──────┐
    │ TCoordinate │     │   TScreen   │     │    TFood    │
    │ (Obj Valor) │     │   (Vista)   │     │  (Modelo)   │
    └──────┬──────┘     └─────────────┘     ──────┬──────┘
           │ Usa                                    │ Usa
           │                                        │
           ▼                                        ▼
    ┌──────────────┐                         ┌──────────────┐
    │    TSnake    │◄────────────────────────│ TSnakeGame   │
    │   (Modelo)   │      Compone            │ (Controlador)│
    └──────────────                         └──────────────┘
```

**Relaciones:**
*   **Composición:** `TSnakeGame` posee y gestiona el ciclo de vida de `TSnake`, `TFood` y `TScreen`.
*   **Asociación/Uso:** `TSnake` y `TFood` dependen de `TCoordinate` para rastrear posiciones.

---

### 3. Desglose Detallado de Clases

#### 3.1 `TCoordinate` (Objeto Valor)
**Propósito:** Representa una posición 2D inmutable (fila, columna) en la cuadrícula de la terminal. Evita la obsesión por primitivos y encapsula las matemáticas de la cuadrícula.
*   **Datos:** `nRow` (Numérico), `nCol` (Numérico).
*   **Métodos:**
    *   `New( nRow, nCol )`: Constructor. Inicializa las coordenadas.
    *   `Clone()`: Retorna una nueva instancia con los mismos valores.
    *   `Equals( oOther )`: Compara dos coordenadas. Incluye validaciones defensivas `HB_IsObject()` para prevenir errores BASE/1004.
    *   `MoveUp/Down/Left/Right()`: Retorna un *nuevo* `TCoordinate` desplazado 1 celda. Garantiza inmutabilidad.
    *   `IsValid( nMaxRow, nMaxCol )`: Verifica si la coordenada está dentro del área jugable.

#### 3.2 `TSnake` (Entidad / Modelo)
**Propósito:** Gestiona el cuerpo de la serpiente, su dirección y la lógica de colisiones.
*   **Datos:** 
    *   `aBody` (Array de `TCoordinate`): Los segmentos de la serpiente.
    *   `nDirection` (Numérico): Dirección actual (códigos ASCII de flechas).
    *   `nPendingGrowth` (Numérico): Contador de segmentos a añadir.
*   **Métodos:**
    *   `New( oHeadCoord )`: Construye el cuerpo inicial de 5 segmentos.
    *   `GetHead()`, `GetTail()`, `GetSegment( nIndex )`: Acceso encapsulado. Previene la modificación externa directa de `aBody`.
    *   `Move()`: Reconstruye el array del cuerpo limpiamente para evitar huecos `NIL`. Maneja la lógica de crecimiento.
    *   `Grow()`: Incrementa el contador de crecimiento pendiente.
    *   `ChangeDirection( nNewDir )`: Valida la entrada y previene giros de 180°.
    *   `CollidesWithSelf()`, `CollidesWith( oCoord )`: Detección de colisiones. El bucle inicia en el índice 2 para evitar falsos positivos (cabeza contra cabeza).

#### 3.3 `TFood` (Entidad / Modelo)
**Propósito:** Maneja el spawn aleatorio de la comida, asegurando que nunca se superponga con la serpiente.
*   **Datos:** `oPosition` (`TCoordinate`), `nMaxRow`, `nMaxCol`.
*   **Métodos:**
    *   `New( nMaxRow, nMaxCol )`: Inicializa los límites.
    *   `Spawn( oSnake )`: Genera coordenadas aleatorias. Usa un bucle de reintentos (máx 500) y llama a `oSnake:CollidesWith()` para asegurar una colocación válida.
    *   `GetPosition()`: Acceso seguro a la ubicación de la comida.

#### 3.4 `TScreen` (Vista / Renderizado)
**Propósito:** Envuelve las primitivas de dibujo de terminal de Harbour (`@ SAY`).
*   **Datos:** `nRows`, `nCols`.
*   **Métodos:**
    *   `New( nRows, nCols )`: Establece las dimensiones de la pantalla.
    *   `Clear()`: `CLS` completo.
    *   `ClearPlayfield()`: Limpieza selectiva (filas 2 a nRows-1) para reducir el parpadeo.
    *   `DrawBorder()`: Dibuja el marco de doble línea.
    *   `DrawSnake( oSnake )`, `DrawFood( oFood )`: Itera sobre los modelos y renderiza los caracteres (`@`, `*`, `#`).
    *   `DrawHUD( nScore, nHighScore, nLength )`: Renderiza la barra de estado inferior.

#### 3.5 `TSnakeGame` (Controlador / Orquestador)
**Propósito:** El bucle principal. Gestiona el estado del juego, la entrada y el tiempo.
*   **Datos:** Instancias de `TSnake`, `TFood`, `TScreen`. Variables de estado (`nScore`, `nSpeed`, `nInitialSpeed`, `lRunning`).
*   **Métodos:**
    *   `Run()`: Bucle de menú de nivel superior.
    *   `InitRound()`: Reinicia el estado y dibuja el frame inicial.
    *   `GameLoop()`: El bucle central. Usa `Inkey( ::nSpeed )` para crear un retraso de tiempo natural mientras captura la entrada.
    *   `HandleInput( nKey )`: Mapea las teclas virtuales a los cambios de dirección.
    *   `Update()`: Mueve la serpiente y verifica el consumo de comida.
    *   `CheckCollisions()`: Evalúa colisiones con paredes y consigo misma.
    *   `Render()`: Llama a los métodos de `TScreen` para actualizar la pantalla.

---

### 4. Decisiones de Diseño y Patrones
1.  **Inmutabilidad:** Las operaciones de `TCoordinate` retornan nuevos objetos, previniendo efectos secundarios.
2.  **Encapsulamiento:** `TSnake` oculta su array `aBody`. Las clases externas deben usar `GetSegment()`.
3.  **Tiempo sobre Sleep:** El bucle del juego usa `Inkey( timeout )` en lugar de `hb_IdleSleep()`. Este es el patrón clásico de xBase para bucles de juego suaves e interrumpibles.
4.  **Programación Defensiva:** Todas las llamadas a `:Equals()` y `:CollidesWith()` están protegidas con `HB_IsObject()` para prevenir errores en tiempo de ejecución BASE/1004.

---

📧 **Contact:** marvijarrin@gmail.com | 🌐 **Web:** badasystem.com  
📅 **Last updated:** September 28, 2026