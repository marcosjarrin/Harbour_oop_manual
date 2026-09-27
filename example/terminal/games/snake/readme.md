# 📘 Snake Harbour — Terminal OOP Edition
## User Manual / Manual de Usuario

---

## 🇬🇧 ENGLISH VERSION

### 1. Introduction
**Snake Harbour** is a modern, object-oriented (OOP) port of the classic Clipper Snake game, rebuilt for the Harbour 3.2+ compiler in terminal/console mode. It features a robust architecture, delta-rendering for flicker-free gameplay, and a classic xBase game loop for smooth, automatic movement.

Developed by **BadaSystem** (Marcos Jarrín, 2026).

### 2. System Requirements
- **Operating System:** Windows, Linux, or macOS (Terminal/Console).
- **Runtime:** Pre-compiled executable (`.exe` or binary) OR Harbour 3.2.0dev+ with `hbmk2` build system.
- **Display:** Minimum 80x24 character terminal window.

### 3. Installation & Compilation
#### Option A: Pre-compiled (Recommended)
Simply run the provided executable:
- Windows: `snake_harbour.exe`
- Linux/macOS: `./snake_harbour`

#### Option B: Compile from Source
1. Ensure Harbour 3.2+ and `hbmk2` are installed and in your system PATH.
2. Open your terminal and navigate to the project folder:
   ```bash
   cd snake_harbour
   ```
3. Clean any previous build artifacts (critical to avoid linker errors):
   ```bash
   # Windows
   rmdir /s /q obj
   # Linux/macOS
   rm -rf obj
   ```
4. Compile the project:
   ```bash
   hbmk2 build.hbp
   ```

### 4. How to Play
1. **Start the Game:** Launch the application. The Main Menu will appear.
2. **Navigate Menus:** Use the `↑` and `↓` arrow keys to highlight an option, then press `Enter` to select.
3. **Controls During Gameplay:**
   - `↑` (Up Arrow): Move Up
   - `↓` (Down Arrow): Move Down
   - `←` (Left Arrow): Move Left
   - `→` (Right Arrow): Move Right
   - `ESC`: Abort current game and return to menu.
4. **Objective:** Guide the snake (`@` is the head, `*` is the body) to eat the food (`#`). Each piece of food increases your score by 100 points, grows the snake by 1 segment, and slightly increases the game speed.
5. **Game Over Conditions:** 
   - The snake's head collides with the outer border.
   - The snake's head collides with its own body.

### 5. Menu Options
- **Play Game:** Starts a new round with the currently selected speed.
- **Speed:** Configure the initial movement speed before playing:
  - *1 - Slow:* Relaxed pace, ideal for beginners.
  - *2 - Normal:* Standard balanced pace.
  - *3 - Fast:* Challenging speed.
  - *4 - Insane:* For expert players (progressive speed-up is aggressive).
- **Credits:** Displays version, author, and build information.
- **Exit:** Closes the application safely.

### 6. Troubleshooting & FAQ
**Q: The game flickers when the snake moves.**  
*A:* Ensure you are using version 2.1 or later, which implements delta-rendering (screen buffering) to eliminate flicker. If the issue persists, maximize your terminal window.

**Q: I get a "BASE/1004 No exported method" error.**  
*A:* This occurs if old compiled files are cached. Delete the `obj` folder completely and recompile with `hbmk2 build.hbp`.

**Q: The snake doesn't move automatically.**  
*A:* The game uses a timing-based loop. Ensure your terminal is the active window and you are not holding down a key, which can interrupt the `Inkey()` timeout cycle.

---

## 🇪🇸 VERSIÓN EN ESPAÑOL

### 1. Introducción
**Snake Harbour** es un port moderno y orientado a objetos (OOP) del clásico juego Snake de Clipper, reconstruido para el compilador Harbour 3.2+ en modo terminal/consola. Cuenta con una arquitectura robusta, renderizado delta para eliminar el parpadeo de pantalla y un bucle de juego xBase clásico para un movimiento automático y fluido.

Desarrollado por **BadaSystem** (Marcos Jarrín, 2026).

### 2. Requisitos del Sistema
- **Sistema Operativo:** Windows, Linux o macOS (Terminal/Consola).
- **Ejecución:** Ejecutable precompilado (`.exe` o binario) O compilador Harbour 3.2.0dev+ con el sistema de compilación `hbmk2`.
- **Pantalla:** Ventana de terminal con un mínimo de 80x24 caracteres.

### 3. Instalación y Compilación
#### Opción A: Precompilado (Recomendado)
Simplemente ejecute el archivo proporcionado:
- Windows: `snake_harbour.exe`
- Linux/macOS: `./snake_harbour`

#### Opción B: Compilar desde el Código Fuente
1. Asegúrese de que Harbour 3.2+ y `hbmk2` estén instalados y en el PATH del sistema.
2. Abra su terminal y navegue hasta la carpeta del proyecto:
   ```bash
   cd snake_harbour
   ```
3. Limpie cualquier artefacto de compilación anterior (crítico para evitar errores de enlazador):
   ```bash
   # Windows
   rmdir /s /q obj
   # Linux/macOS
   rm -rf obj
   ```
4. Compile el proyecto:
   ```bash
   hbmk2 build.hbp
   ```

### 4. Cómo Jugar
1. **Iniciar el Juego:** Ejecute la aplicación. Aparecerá el Menú Principal.
2. **Navegar por los Menús:** Use las teclas de flecha `↑` y `↓` para resaltar una opción, luego presione `Enter` para seleccionar.
3. **Controles durante el Juego:**
   - `↑` (Flecha Arriba): Mover hacia arriba.
   - `↓` (Flecha Abajo): Mover hacia abajo.
   - `←` (Flecha Izquierda): Mover hacia la izquierda.
   - `→` (Flecha Derecha): Mover hacia la derecha.
   - `ESC`: Abortar la partida actual y volver al menú.
4. **Objetivo:** Guíe a la serpiente (`@` es la cabeza, `*` es el cuerpo) para comer la comida (`#`). Cada pieza de comida aumenta su puntuación en 100 puntos, hace crecer a la serpiente en 1 segmento y aumenta ligeramente la velocidad del juego.
5. **Condiciones de Fin de Juego:** 
   - La cabeza de la serpiente choca con el borde exterior.
   - La cabeza de la serpiente choca con su propio cuerpo.

### 5. Opciones del Menú
- **Play Game (Jugar):** Inicia una nueva ronda con la velocidad actualmente seleccionada.
- **Speed (Velocidad):** Configure la velocidad inicial de movimiento antes de jugar:
  - *1 - Slow (Lenta):* Ritmo relajado, ideal para principiantes.
  - *2 - Normal (Normal):* Ritmo estándar y equilibrado.
  - *3 - Fast (Rápida):* Velocidad desafiante.
  - *4 - Insane (Insana):* Para jugadores expertos (el aumento progresivo de velocidad es agresivo).
- **Credits (Créditos):** Muestra la versión, el autor y la información de compilación.
- **Exit (Salir):** Cierra la aplicación de forma segura.

### 6. Solución de Problemas y Preguntas Frecuentes (FAQ)
**P: La pantalla parpadea cuando la serpiente se mueve.**  
*R:* Asegúrese de estar utilizando la versión 2.1 o posterior, que implementa renderizado delta (búfer de pantalla) para eliminar el parpadeo. Si el problema persiste, maximice la ventana de su terminal.

**P: Obtengo un error "BASE/1004 No exported method".**  
*R:* Esto ocurre si hay archivos compilados antiguos en caché. Elimine completamente la carpeta `obj` y vuelva a compilar con `hbmk2 build.hbp`.

**P: La serpiente no se mueve automáticamente.**  
*R:* El juego utiliza un bucle basado en temporización. Asegúrese de que su terminal sea la ventana activa y de no mantener presionada una tecla, ya que esto puede interrumpir el ciclo de tiempo de espera de `Inkey()`.

---

**CREDITS**
**Snake Harbour - Terminal OOP Edition**  
**Original Clipper version : Andre Martins**  
**Harbour OOP              : Marcos Jarrin**  
**Website                  : badasystem.com**  
**Date                     : September 2026**  

📧 **Contact / Contacto:** marvijarrin@gmail.com | 🌐 **Web:** badasystem.com  
📅 **Last updated / Última actualización:** September 28, 2026  
