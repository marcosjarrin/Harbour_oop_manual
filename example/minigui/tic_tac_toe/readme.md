# Tic-Tac-Toe (Tres en Raya) – Harbour + MiniGUI

[English](#english) | [Español](#español)

---

<a name="english"></a>
## English

### Description
A classic **Tic-Tac-Toe** (Noughts and Crosses) game built with **Harbour** and **MiniGUI**. Two players take turns marking X and O on a 3×3 grid. The game detects wins (rows, columns, diagonals) and draws, then offers to restart automatically.

### Features
- Clean graphical interface using MiniGUI buttons.
- Turn indicator (X or O).
- Win/draw detection with message boxes.
- Automatic board reset after game over.

### Requirements
- [Harbour compiler](https://harbour.github.io/) (3.0 or later)
- [MiniGUI library](https://www.hmgextended.com/) (for Harbour)

### How to Compile and Run
```bash
hbmk2 tictactoe.prg -run
```
Or manually:
```bash
harbour tictactoe.prg -n
gcc tictactoe.c -o tictactoe `harbour -gtgui` -lhmg
./tictactoe
```

### Code Structure
The program contains **one class** (`TTicTacToe`) and a **main procedure** (`Main()`).

#### Class `TTicTacToe`
| Method | Description |
|--------|-------------|
| `New(cWinName)` | Constructor – stores the window name. |
| `Play(nPos)` | Processes a move at position 1..9. Updates board, checks win/draw, switches turn. |
| `CheckWinner()` | Returns `.T.` if the current player has three in a row. |
| `Reset()` | Clears the board, resets turn to X, and clears all button captions. |
| `UpdateStatus()` | Refreshes the status label with the current turn. |

#### Main Procedure `Main()`
- Creates a MiniGUI window.
- Defines 9 buttons (3×3 grid) and a status label.
- Instantiates `TTicTacToe` **after** all controls exist (to avoid references to non‑existing controls).
- Starts the event loop.

### License
This project is released under the **GNU General Public License v3.0**. See the [LICENSE](LICENSE) file for details.

---

<a name="español"></a>
## Español

### Descripción
Un clásico juego **Tres en Raya** construido con **Harbour** y **MiniGUI**. Dos jugadores turnan para marcar X y O en una cuadrícula de 3×3. El juego detecta victorias (filas, columnas, diagonales) y empates, y reinicia automáticamente.

### Características
- Interfaz gráfica limpia usando botones de MiniGUI.
- Indicador de turno (X o O).
- Detección de victoria/empate con cuadros de diálogo.
- Reinicio automático del tablero al terminar la partida.

### Requisitos
- [Compilador Harbour](https://harbour.github.io/) (3.0 o posterior)
- [Librería MiniGUI](https://www.hmgextended.com/) para Harbour

### Cómo compilar y ejecutar
```bash
hbmk2 tictactoe.prg -run
```
O manualmente:
```bash
harbour tictactoe.prg -n
gcc tictactoe.c -o tictactoe `harbour -gtgui` -lhmg
./tictactoe
```

### Estructura del código
El programa contiene **una clase** (`TTicTacToe`) y un **procedimiento principal** (`Main()`).

#### Clase `TTicTacToe`
| Método | Descripción |
|--------|-------------|
| `New(cWinName)` | Constructor – almacena el nombre de la ventana. |
| `Play(nPos)` | Procesa un movimiento en la posición 1..9. Actualiza el tablero, verifica victoria/empate y cambia el turno. |
| `CheckWinner()` | Devuelve `.T.` si el jugador actual tiene tres en línea. |
| `Reset()` | Limpia el tablero, reinicia el turno a X y borra todos los botones. |
| `UpdateStatus()` | Actualiza la etiqueta de estado con el turno actual. |

#### Procedimiento principal `Main()`
- Crea una ventana de MiniGUI.
- Define 9 botones (cuadrícula de 3×3) y una etiqueta de estado.
- Instancia `TTicTacToe` **después** de que todos los controles existan (para evitar referencias a controles inexistentes).
- Inicia el bucle de eventos.

### Licencia
Este proyecto se distribuye bajo la **GNU General Public License v3.0**. Para más detalles, consulta el archivo [LICENSE](LICENSE).

---

*¡Disfruta del juego! · Enjoy the game!* 🎮
