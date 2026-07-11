# Basic Calculator — Harbour MiniGUI Extended Edition

A fully functional, object-oriented basic calculator built with Harbour and MiniGUI Extended Edition. This application demonstrates native Harbour OOP syntax combined with MiniGUI Extended UI directives to create a clean, robust desktop calculator.

- [English](#english) | [Español](#español)
---

## English

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Requirements](#requirements)
- [Project Structure](#project-structure)
- [Architecture & Design](#architecture--design)
  - [Object-Oriented Design](#object-oriented-design)
  - [Class Diagram](#class-diagram)
  - [Data Members](#data-members)
  - [Methods](#methods)
- [MiniGUI Extended UI Construction](#minigui-extended-ui-construction)
  - [Window Definition](#window-definition)
  - [Control Definitions](#control-definitions)
  - [Macro Substitution for Dynamic Names](#macro-substitution-for-dynamic-names)
- [Calculator Logic](#calculator-logic)
  - [State Machine](#state-machine)
  - [Arithmetic Engine](#arithmetic-engine)
  - [Decimal Handling](#decimal-handling)
  - [Error Handling](#error-handling)
- [Build & Run](#build--run)
- [License](#license)

---

## Overview

This calculator is implemented as a single Harbour class (`TCalculator`) that encapsulates:

- **UI construction** via MiniGUI Extended `DEFINE WINDOW`, `DEFINE BUTTON`, and `DEFINE TEXTBOX` directives.
- **Event handling** through Harbour OOP methods bound to button `ACTION` clauses.
- **Arithmetic logic** with decimal precision, chained operations, and division-by-zero protection.
- **State management** using Harbour logical flags and instance variables.

The entire application is self-contained in one `.prg` file with no external dependencies beyond the standard Harbour + MiniGUI Extended distribution.

---

## Features

| Feature | Description |
|---------|-------------|
| **Standard Arithmetic** | Addition (`+`), Subtraction (`-`), Multiplication (`*`), Division (`/`) |
| **Decimal Support** | Full floating-point decimal arithmetic with duplicate-decimal prevention |
| **Chained Operations** | Allows sequential operations (e.g., `5 + 3 + 2 =`) without pressing `=` between each |
| **Division by Zero** | Graceful error message (`Error: Div by 0`) with state lock until cleared |
| **Clear Function** | `C` button resets all state to initial defaults |
| **Result Formatting** | Trims unnecessary trailing zeros |
| **Fixed Layout** | Non-resizable window with consistent button grid |
| **Read-Only Display** | Right-aligned text box prevents manual input corruption |

---

## Requirements

| Component | Version |
|-----------|---------|
| Harbour Compiler | 3.2.x or compatible |
| MiniGUI Extended | 26.x or compatible |
| C/C++ Compiler | Borland C++ 5.8.2, MinGW, or MSVC |
| Platform | Windows (32-bit or 64-bit) |

---

## Project Structure

```
calculator/
├── calculator.prg      # Main application source (single file)
├── README.md           # This documentation
└── (compiled output)
    ├── calculator.exe  # Windows executable
    └── ErrorLog.htm    # Runtime error log (if generated)
```

---

## Architecture & Design

### Object-Oriented Design

Harbour provides native OOP support through the `CLASS...ENDCLASS` syntax, compatible with Class(y) and TopClass dialects. The calculator leverages this to encapsulate all behavior within a single class.

```harbour
CLASS TCalculator
    DATA cWinName
    DATA cDisplayName
    DATA cCurrentValue
    DATA nStoredValue
    DATA cPendingOperator
    DATA lNewEntry
    DATA lHasDecimal
    DATA lErrorState
    /* ... dimension data members ... */

    METHOD New()
    METHOD BuildWindow()
    METHOD BuildButtonGrid()
    METHOD ResetState()
    METHOD UpdateDisplay()
    METHOD InputDigit( cDigit )
    METHOD InputDecimal()
    METHOD InputOperator( cOperator )
    METHOD CalculateResult()
    METHOD ClearAll()
    METHOD Run()
ENDCLASS
```

#### Key OOP Concepts Used

| Concept | Implementation |
|---------|----------------|
| **Encapsulation** | All UI, logic, and state isolated within `TCalculator` |
| **Instance Variables** | `DATA` members store per-object state |
| **Self-Reference** | `::` (shorthand for `Self:`) accesses current object members |
| **Constructor** | `New()` initializes defaults and triggers UI build |
| **Method Binding** | Button `ACTION` clauses reference `::MethodName()` directly |

---

### Class Diagram

```
+------------------------------------------------------------------+
|                          TCalculator                             |
+------------------------------------------------------------------+
|  cWinName         : Character   # Window identifier string       |
|  cDisplayName     : Character   # TextBox identifier string      |
|  cCurrentValue    : Character   # Active display string          |
|  nStoredValue     : Numeric     # Left operand accumulator       |
|  cPendingOperator : Character   # Pending arithmetic operator    |
|  lNewEntry        : Logical     # Flag: start new number?        |
|  lHasDecimal      : Logical     # Flag: decimal already used?    |
|  lErrorState      : Logical     # Flag: error lock active?       |
|  nButtonWidth     : Numeric     # Button width (px)              |
|  nButtonHeight    : Numeric     # Button height (px)             |
|  nDisplayHeight   : Numeric     # TextBox height (px)          |
|  nMargin          : Numeric     # UI spacing (px)                |
|  nWindowWidth     : Numeric     # Total window width (px)        |
|  nWindowHeight    : Numeric     # Total window height (px)       |
+------------------------------------------------------------------+
|  New()              -> Constructor & initializer                 |
|  BuildWindow()      -> Creates main window & display               |
|  BuildButtonGrid()  -> Creates 4x5 button layout                   |
|  ResetState()       -> Clears all state to defaults                |
|  UpdateDisplay()    -> Syncs display TextBox with cCurrentValue  |
|  InputDigit()       -> Handles 0-9 button presses                |
|  InputDecimal()     -> Handles decimal point button              |
|  InputOperator()    -> Handles +, -, *, / button presses         |
|  CalculateResult()  -> Executes pending operation                |
|  ClearAll()         -> Handles C button (delegates to ResetState)|
|  Run()              -> Centers & activates window                |
+------------------------------------------------------------------+
```

---

### Data Members

All data members are declared with `DATA` inside the `CLASS...ENDCLASS` block. They are initialized in the `New()` constructor method.

#### Window & Control Identifiers

| Member | Type | Purpose |
|--------|------|---------|
| `cWinName` | `Character` | Name string for the main window. Used with `SetProperty()` / `GetProperty()` and macro substitution (`&`) in `DEFINE WINDOW`. |
| `cDisplayName` | `Character` | Name string for the read-only TextBox display. Used with `SetProperty()` to update the displayed value. |

> **Important:** MiniGUI Extended's `DEFINE WINDOW` and `DEFINE TEXTBOX` directives require macro substitution (`&`) to use dynamic names. However, the macro operator in Harbour only works with simple variables, not with `::` (self-reference) expressions. Therefore, local variables are assigned from data members before use in `DEFINE` directives.

#### Calculator State

| Member | Type | Purpose |
|--------|------|---------|
| `cCurrentValue` | `Character` | The active number being entered or displayed. Stored as a string to preserve leading zeros and decimal formatting before conversion to numeric. |
| `nStoredValue` | `Numeric` | The left operand of a pending operation. Stored as a numeric to avoid repeated `VAL()` conversions during chained operations. |
| `cPendingOperator` | `Character` | The arithmetic operator (`+`, `-`, `*`, `/`) waiting for the right operand. Empty string when no operation is pending. |
| `lNewEntry` | `Logical` | When `.T.`, the next digit pressed starts a new number rather than appending to the current display value. |
| `lHasDecimal` | `Logical` | Prevents multiple decimal points in a single number entry. Reset on each new number. |
| `lErrorState` | `Logical` | When `.T.`, blocks all input except `ClearAll()`. Set on division by zero. |

#### Layout Dimensions

| Member | Type | Default | Purpose |
|--------|------|---------|---------|
| `nButtonWidth` | `Numeric` | `60` | Width of each calculator button in pixels. |
| `nButtonHeight` | `Numeric` | `45` | Height of each calculator button in pixels. |
| `nDisplayHeight` | `Numeric` | `50` | Height of the display TextBox in pixels. |
| `nMargin` | `Numeric` | `10` | Padding between controls and window borders in pixels. |
| `nWindowWidth` | `Numeric` | `290` | Computed total window width (`4 * nButtonWidth + 5 * nMargin`). |
| `nWindowHeight` | `Numeric` | `345` | Computed total window height (display + 5 button rows + margins + title bar). |

---

### Methods

#### `New()` — Constructor

```harbour
METHOD New() CLASS TCalculator
```

**Purpose:** Initializes all data members to their default values and triggers UI construction.

**Flow:**
1. Sets window/control name strings (`cWinName`, `cDisplayName`).
2. Calculates layout dimensions based on button grid geometry.
3. Initializes calculator state to defaults (`"0"`, `0`, `""`, `.T.`, `.F.`, `.F.`).
4. Calls `BuildWindow()` to construct the UI.

**Returns:** `Self` (the newly created object instance).

---

#### `BuildWindow()` — Main Window Construction

```harbour
METHOD BuildWindow() CLASS TCalculator
```

**Purpose:** Defines the main application window and its display control using MiniGUI Extended directives.

**Key Implementation Detail — Macro Substitution:**

MiniGUI Extended requires literal names in `DEFINE WINDOW` and `DEFINE TEXTBOX`. To use the names stored in data members, local variables are created first:

```harbour
LOCAL cWinName     := ::cWinName       // Copy from data member to local
LOCAL cDisplayName := ::cDisplayName

DEFINE WINDOW &cWinName              // &cWinName -> "WinCalculator"
    /* ... window clauses ... */
    DEFINE TEXTBOX &cDisplayName     // &cDisplayName -> "DisplayBox"
        /* ... textbox clauses ... */
    END TEXTBOX
END WINDOW
```

> **Why locals?** The Harbour macro operator `&` resolves simple variable names at runtime. It cannot resolve `::cWinName` (a method-scoped object reference). Using locals bridges this gap.

**Window Clauses:**

| Clause | Value | Purpose |
|--------|-------|---------|
| `AT 0, 0` | Top-left corner | Window position on screen. |
| `WIDTH` / `HEIGHT` | Computed dimensions | Fixed-size window. |
| `TITLE` | `"Basic Calculator"` | Window caption. |
| `MAIN` | — | Designates this as the application's main window. |
| `NOMAXIMIZE` | — | Disables the maximize button. |
| `NOSIZE` | — | Prevents user resizing. |

**Display TextBox Properties:**

| Property | Value | Purpose |
|----------|-------|---------|
| `FONTNAME "Consolas"` | Monospace font | Ensures digit alignment. |
| `FONTSIZE 18` | Large font | Readability. |
| `NUMERIC .F.` | Non-numeric mode | Allows decimal points and error strings. |
| `READONLY .T.` | Read-only | Prevents keyboard input corruption. |
| `RIGHTALIGN .T.` | Right-aligned | Standard calculator display behavior. |

After `END WINDOW`, `ResetState()` is called to initialize the display.

---

#### `BuildButtonGrid()` — Button Layout

```harbour
METHOD BuildButtonGrid() CLASS TCalculator
```

**Purpose:** Creates all 17 calculator buttons in a standard 4-column grid.

**Layout:**

```
+-----+-----+-----+-----+
|  7  |  8  |  9  |  /  |  <- Row 1
+-----+-----+-----+-----+
|  4  |  5  |  6  |  *  |  <- Row 2
+-----+-----+-----+-----+
|  1  |  2  |  3  |  -  |  <- Row 3
+-----+-----+-----+-----+
|  C  |  0  |  .  |  +  |  <- Row 4
+-----+-----+-----+-----+
|           =           |  <- Row 5 (spans 4 columns)
+-----------------------+
```

**Button Definitions:**

Each button uses `DEFINE BUTTON` with:
- **Static name** (e.g., `Btn7`, `BtnDiv`, `BtnClear`) — required because macro substitution with `&` does not work reliably for control names inside class methods.
- **Computed `ROW`/`COL`** — based on `nStartRow`, button dimensions, and margin spacing.
- **`ACTION`** — bound directly to the class method handling that button's function.
- **`FONTSIZE 14`** — consistent sizing; operators use `FONTBOLD .T.` for visual distinction.

**Button-to-Method Mapping:**

| Button | Name | Action | Method Called |
|--------|------|--------|---------------|
| `0-9` | `Btn0`-`Btn9` | `ACTION ::InputDigit("0")` ... | Appends digit to current value |
| `.` | `BtnDot` | `ACTION ::InputDecimal()` | Adds decimal point |
| `+` | `BtnAdd` | `ACTION ::InputOperator("+")` | Sets pending addition |
| `-` | `BtnSub` | `ACTION ::InputOperator("-")` | Sets pending subtraction |
| `*` | `BtnMul` | `ACTION ::InputOperator("*")` | Sets pending multiplication |
| `/` | `BtnDiv` | `ACTION ::InputOperator("/")` | Sets pending division |
| `=` | `BtnEquals` | `ACTION ::CalculateResult()` | Executes pending operation |
| `C` | `BtnClear` | `ACTION ::ClearAll()` | Resets all state |

---

#### `ResetState()` — State Initialization

```harbour
METHOD ResetState() CLASS TCalculator
```

**Purpose:** Resets all calculator state variables to their initial defaults.

**State Reset Values:**

| Variable | Reset Value | Meaning |
|----------|-------------|---------|
| `cCurrentValue` | `"0"` | Display shows zero |
| `nStoredValue` | `0` | No accumulated result |
| `cPendingOperator` | `""` | No pending operation |
| `lNewEntry` | `.T.` | Next digit starts fresh |
| `lHasDecimal` | `.F.` | No decimal in current number |
| `lErrorState` | `.F.` | Calculator is operational |

Calls `UpdateDisplay()` to refresh the UI.

---

#### `UpdateDisplay()` — Display Synchronization

```harbour
METHOD UpdateDisplay() CLASS TCalculator
```

**Purpose:** Syncs the visual display with the internal `cCurrentValue` state.

**Implementation:**
```harbour
SetProperty( ::cWinName, ::cDisplayName, "VALUE", cDisplayValue )
```

Uses MiniGUI Extended's `SetProperty()` function to update the TextBox control at runtime. The window name (`::cWinName`) and control name (`::cDisplayName`) are passed as strings.

---

#### `InputDigit( cDigit )` — Digit Input

```harbour
METHOD InputDigit( cDigit ) CLASS TCalculator
```

**Purpose:** Handles presses of digit buttons `0` through `9`.

**Logic:**
1. If `lErrorState` is `.T.`, ignore input.
2. If `lNewEntry` is `.T.`, replace display with the new digit and clear flags.
3. If `lNewEntry` is `.F.`, append the digit to `cCurrentValue`.
4. Special case: if current value is `"0"`, replace it instead of appending (prevents leading zeros like `"05"`).

---

#### `InputDecimal()` — Decimal Point Input

```harbour
METHOD InputDecimal() CLASS TCalculator
```

**Purpose:** Handles the decimal point (`.`) button.

**Logic:**
1. If `lErrorState` is `.T.`, ignore input.
2. If `lNewEntry` is `.T.`, start with `"0."`.
3. If `lHasDecimal` is `.F.`, append `.` and set flag.
4. If `lHasDecimal` is `.T.`, ignore (prevents `"5..3"`).

---

#### `InputOperator( cOperator )` — Operator Input

```harbour
METHOD InputOperator( cOperator ) CLASS TCalculator
```

**Purpose:** Handles `+`, `-`, `*`, `/` button presses.

**Logic:**
1. If `lErrorState` is `.T.`, ignore input.
2. If a pending operator exists and the user is not starting a new entry, execute the pending calculation first (chained operations).
3. Store the current display value as numeric in `nStoredValue`.
4. Set `cPendingOperator` to the new operator.
5. Set `lNewEntry` to `.T.` so the next digit starts a new number.

---

#### `CalculateResult()` — Execute Operation

```harbour
METHOD CalculateResult() CLASS TCalculator
```

**Purpose:** Executes the pending arithmetic operation when `=` is pressed.

**Logic:**
1. If no pending operator exists, return immediately.
2. If in error state, return immediately.
3. Convert `cCurrentValue` to numeric using `VAL()`.
4. Perform the operation based on `cPendingOperator`:
   - `+` : Addition
   - `-` : Subtraction
   - `*` : Multiplication
   - `/` : Division (with zero-check)
5. **Division by Zero:** If divisor is `0`, set `cCurrentValue` to `"Error: Div by 0"`, set `lErrorState` to `.T.`, clear pending operator, update display, and return.
6. Format the result by trimming trailing zeros from the string representation.
7. Update `cCurrentValue`, `nStoredValue`, clear `cPendingOperator`, set `lNewEntry` to `.T.`.
8. Update display.

**Result Formatting:**
```harbour
cResultStr := ALLTRIM( STR( nResult, 16, 10 ) )
cResultStr := RTRIM( cResultStr )
cResultStr := RTRIM( cResultStr, "0" )
cResultStr := RTRIM( cResultStr, "." )
```

This ensures results like `5.5000000000` are displayed as `5.5`, and `7.0000000000` as `7`.

---

#### `ClearAll()` — Full Reset

```harbour
METHOD ClearAll() CLASS TCalculator
```

**Purpose:** Handles the `C` (Clear) button.

Simply delegates to `ResetState()` to clear all state and refresh the display.

---

#### `Run()` — Event Loop Entry

```harbour
METHOD Run() CLASS TCalculator
```

**Purpose:** Centers the window on screen and starts the MiniGUI Extended event loop.

**Implementation:**
```harbour
LOCAL cWinName := ::cWinName
CENTER WINDOW &cWinName
ACTIVATE WINDOW &cWinName
```

> Note: The local variable `cWinName` is required for the macro operator `&` to work correctly with `CENTER WINDOW` and `ACTIVATE WINDOW`.

---

## MiniGUI Extended UI Construction

### Window Definition

MiniGUI Extended uses declarative `DEFINE WINDOW` blocks to create forms. The calculator uses:

```harbour
DEFINE WINDOW WinCalculator
    AT 0, 0
    WIDTH  290
    HEIGHT 345
    TITLE "Basic Calculator"
    MAIN
    NOMAXIMIZE
    NOSIZE
END WINDOW
```

| Clause | Description |
|--------|-------------|
| `DEFINE WINDOW <name>` | Begins window definition. Name is used with `SetProperty()`, `GetProperty()`, and window management functions. |
| `AT <row>, <col>` | Window position in pixels. |
| `WIDTH` / `HEIGHT` | Window dimensions in pixels. |
| `TITLE` | Caption bar text. |
| `MAIN` | Designates the primary application window. Closing it terminates the application. |
| `NOMAXIMIZE` | Removes the maximize button from the title bar. |
| `NOSIZE` | Prevents the user from resizing the window by dragging borders. |

### Control Definitions

#### TextBox (Display)

```harbour
DEFINE TEXTBOX DisplayBox
    ROW    10
    COL    10
    WIDTH  270
    HEIGHT 50
    VALUE  "0"
    FONTNAME "Consolas"
    FONTSIZE 18
    NUMERIC .F.
    READONLY .T.
    RIGHTALIGN .T.
END TEXTBOX
```

| Clause | Description |
|--------|-------------|
| `DEFINE TEXTBOX <name>` | Creates a single-line text input control. |
| `ROW` / `COL` | Position relative to the window client area. |
| `WIDTH` / `HEIGHT` | Control dimensions in pixels. |
| `VALUE` | Initial text content. |
| `FONTNAME` / `FONTSIZE` | Typography settings. |
| `NUMERIC` | When `.T.`, restricts input to numbers only. Set to `.F.` to allow decimals and error text. |
| `READONLY` | When `.T.`, prevents user editing (but allows programmatic updates via `SetProperty`). |
| `RIGHTALIGN` | Aligns text to the right edge of the control. |

#### Button

```harbour
DEFINE BUTTON Btn7
    ROW    70
    COL    10
    WIDTH  60
    HEIGHT 45
    CAPTION "7"
    ACTION ::InputDigit( "7" )
    FONTSIZE 14
END BUTTON
```

| Clause | Description |
|--------|-------------|
| `DEFINE BUTTON <name>` | Creates a push button control. |
| `CAPTION` | Button label text. |
| `ACTION` | Code block or method call executed on click. In OOP context, `::MethodName()` binds to the current object. |
| `FONTSIZE` / `FONTBOLD` | Typography styling. |

### Macro Substitution for Dynamic Names

A critical compatibility pattern used throughout this application:

```harbour
/* INCORRECT: & does not resolve ::cWinName */
DEFINE WINDOW &::cWinName     // ERROR: Variable does not exist

/* CORRECT: Copy to local first, then use & */
LOCAL cWinName := ::cWinName
DEFINE WINDOW &cWinName       // OK: Resolves to "WinCalculator"
```

This pattern is required because:
1. MiniGUI Extended directives (`DEFINE WINDOW`, `DEFINE TEXTBOX`, etc.) expect literal names or macro-resolved names.
2. Harbour's macro operator `&` only resolves simple variable names (local, private, public, field), not object member references (`::`).
3. The `::` prefix is syntactic sugar for `Self:` and is evaluated at runtime through the object context, not the macro compiler.

---

## Calculator Logic

### State Machine

The calculator operates as a simple state machine with two primary states:

| State | `lNewEntry` | `cPendingOperator` | Behavior |
|-------|-------------|-------------------|----------|
| **Entry** | `.T.` | Any | Next digit replaces display |
| **Accumulation** | `.F.` | Any | Next digit appends to display |
| **Idle** | `.T.` | `""` | No operation pending, display shows result |
| **Pending** | `.T.` | `+,-,*,/` | Waiting for right operand |
| **Error** | Any | Any | All input blocked except Clear |

**State Transitions:**

```
[Idle] --digit--> [Accumulation]
[Accumulation] --operator--> [Pending]  (stores left operand)
[Pending] --digit--> [Accumulation]     (enters right operand)
[Accumulation] --=--> [Idle]          (calculates and displays)
[Any] --C--> [Idle]                    (full reset)
[Any] --div_by_zero--> [Error]         (blocks input)
[Error] --C--> [Idle]                  (reset to operational)
```

### Arithmetic Engine

Operations are performed using Harbour's native numeric types (double-precision floating point).

**Chained Operations Example:**
```
User presses: 5 + 3 + 2 =

Step 1: "5" -> InputDigit("5") -> cCurrentValue = "5"
Step 2: "+" -> InputOperator("+") -> nStoredValue = 5, cPendingOperator = "+"
Step 3: "3" -> InputDigit("3") -> cCurrentValue = "3"
Step 4: "+" -> InputOperator("+") -> CalculateResult() -> 5+3=8
                                      -> nStoredValue = 8, cPendingOperator = "+"
Step 5: "2" -> InputDigit("2") -> cCurrentValue = "2"
Step 6: "=" -> CalculateResult() -> 8+2=10
                                      -> cCurrentValue = "10"
```

### Decimal Handling

Decimals are tracked via the `lHasDecimal` flag:

- **New number:** `lHasDecimal` starts as `.F.`
- **First `.` press:** Appends `.`, sets `lHasDecimal` to `.T.`
- **Subsequent `.` presses:** Ignored while `lHasDecimal` is `.T.`
- **New entry started:** `lHasDecimal` reset to `.F.`

This prevents invalid input like `5.3.7`.

### Error Handling

The only error condition handled is **division by zero**:

```harbour
CASE ::cPendingOperator == "/"
    IF nCurrent == 0
        ::cCurrentValue    := "Error: Div by 0"
        ::lErrorState      := .T.
        ::cPendingOperator := ""
        ::UpdateDisplay()
        RETURN Self
    ENDIF
    nResult := ::nStoredValue / nCurrent
```

When `lErrorState` is `.T.`:
- `InputDigit()` returns immediately (ignores all digits).
- `InputDecimal()` returns immediately.
- `InputOperator()` returns immediately.
- Only `ClearAll()` (the `C` button) can reset the calculator to operational state.

---

## Build & Run

### Using hbmk2 (Recommended)

```bash
hbmk2 calculator.prg -w3 -es2
```

### Manual Compilation

```bash
# Compile Harbour source to C
harbour calculator.prg /n /w /es2

# Compile C to object
bcc32 -c calculator.c

# Link with MiniGUI Extended libraries
# (adjust library paths for your installation)
ilink32 calculator.obj, calculator.exe, , minigui.lib hbvm.lib hbrtl.lib
```

### Run

```bash
calculator.exe
```

---

## License

MIT License. See source file header for details.

---

## References

- [Harbour Project](https://harbour.github.io/)
- [MiniGUI Extended Edition](https://hmgextended.com/)
- Harbour OOP Documentation: `CLASS`, `DATA`, `METHOD`, `ENDCLASS`
- MiniGUI Extended API: `DEFINE WINDOW`, `DEFINE BUTTON`, `DEFINE TEXTBOX`, `SetProperty()`, `GetProperty()`

## Español

# Calculadora Básica — Harbour MiniGUI Extended Edition

Una calculadora básica completamente funcional y orientada a objetos, construida con [Harbour](https://harbour.github.io/) y [MiniGUI Extended Edition](https://hmgextended.com/). Esta aplicación demuestra la sintaxis nativa OOP de Harbour combinada con las directivas de interfaz de MiniGUI Extended para crear una calculadora de escritorio limpia y robusta.

---

## Tabla de Contenidos

- [Descripción General](#descripción-general)
- [Características](#características)
- [Requisitos](#requisitos)
- [Estructura del Proyecto](#estructura-del-proyecto)
- [Arquitectura y Diseño](#arquitectura-y-diseño)
  - [Diseño Orientado a Objetos](#diseño-orientado-a-objetos)
  - [Diagrama de Clases](#diagrama-de-clases)
  - [Miembros de Datos (Variables de Instancia)](#miembros-de-datos-variables-de-instancia)
  - [Métodos](#métodos)
- [Construcción de la Interfaz con MiniGUI Extended](#construcción-de-la-interfaz-con-minigui-extended)
  - [Definición de la Ventana](#definición-de-la-ventana)
  - [Definición de Controles](#definición-de-controles)
  - [Sustitución de Macros para Nombres Dinámicos](#sustitución-de-macros-para-nombres-dinámicos)
- [Lógica de la Calculadora](#lógica-de-la-calculadora)
  - [Máquina de Estados](#máquina-de-estados)
  - [Motor Aritmético](#motor-aritmético)
  - [Manejo de Decimales](#manejo-de-decimales)
  - [Manejo de Errores](#manejo-de-errores)
- [Compilación y Ejecución](#compilación-y-ejecución)
- [Licencia](#licencia)

---

## Descripción General

Esta calculadora está implementada como una única clase de Harbour (`TCalculator`) que encapsula:

- **Construcción de la interfaz** mediante las directivas `DEFINE WINDOW`, `DEFINE BUTTON` y `DEFINE TEXTBOX` de MiniGUI Extended.
- **Manejo de eventos** a través de métodos OOP de Harbour vinculados a las cláusulas `ACTION` de los botones.
- **Lógica aritmética** con precisión decimal, operaciones encadenadas y protección contra división por cero.
- **Gestión de estado** utilizando banderas lógicas y variables de instancia de Harbour.

Toda la aplicación está contenida en un único archivo `.prg` sin dependencias externas más allá de la distribución estándar de Harbour + MiniGUI Extended.

---

## Características

| Característica | Descripción |
|----------------|-------------|
| **Aritmética Estándar** | Suma (`+`), Resta (`-`), Multiplicación (`*`), División (`/`) |
| **Soporte Decimal** | Aritmética decimal de punto flotante completa con prevención de decimales duplicados |
| **Operaciones Encadenadas** | Permite operaciones secuenciales (ej. `5 + 3 + 2 =`) sin presionar `=` entre cada una |
| **División por Cero** | Mensaje de error elegante (`Error: Div by 0`) con bloqueo de estado hasta que se limpie |
| **Función Limpiar** | El botón `C` restablece todo el estado a los valores iniciales |
| **Formato de Resultados** | Elimina ceros finales innecesarios (ej. `5.5000000000` -> `5.5`) |
| **Diseño Fijo** | Ventana no redimensionable con cuadrícula de botones consistente |
| **Pantalla de Solo Lectura** | Cuadro de texto alineado a la derecha que previene la corrupción por entrada manual |

---

## Requisitos

| Componente | Versión |
|------------|---------|
| Compilador Harbour | 3.2.x o compatible |
| MiniGUI Extended | 26.x o compatible |
| Compilador C/C++ | Borland C++ 5.8.2, MinGW o MSVC |
| Plataforma | Windows (32-bit o 64-bit) |

---

## Estructura del Proyecto

```
calculator/
├── calculator.prg      # Código fuente principal (archivo único)
├── README.md           # Esta documentación
└── (salida compilada)
    ├── calculator.exe  # Ejecutable de Windows
    └── ErrorLog.htm    # Registro de errores en tiempo de ejecución (si se genera)
```

---

## Arquitectura y Diseño

### Diseño Orientado a Objetos

Harbour proporciona soporte nativo para OOP a través de la sintaxis `CLASS...ENDCLASS`, compatible con los dialectos Class(y) y TopClass. La calculadora aprovecha esto para encapsular todo el comportamiento dentro de una única clase.

```harbour
CLASS TCalculator
    DATA cWinName
    DATA cDisplayName
    DATA cCurrentValue
    DATA nStoredValue
    DATA cPendingOperator
    DATA lNewEntry
    DATA lHasDecimal
    DATA lErrorState
    /* ... miembros de datos de dimensiones ... */

    METHOD New()
    METHOD BuildWindow()
    METHOD BuildButtonGrid()
    METHOD ResetState()
    METHOD UpdateDisplay()
    METHOD InputDigit( cDigit )
    METHOD InputDecimal()
    METHOD InputOperator( cOperator )
    METHOD CalculateResult()
    METHOD ClearAll()
    METHOD Run()
ENDCLASS
```

#### Conceptos OOP Clave Utilizados

| Concepto | Implementación |
|----------|----------------|
| **Encapsulamiento** | Toda la interfaz, lógica y estado aislados dentro de `TCalculator` |
| **Variables de Instancia** | Los miembros `DATA` almacenan el estado por objeto |
| **Auto-referencia** | `::` (atajo para `Self:`) accede a los miembros del objeto actual |
| **Constructor** | `New()` inicializa los valores predeterminados y activa la construcción de la interfaz |
| **Vinculación de Métodos** | Las cláusulas `ACTION` de los botones referencian `::MethodName()` directamente |

---

### Diagrama de Clases

```
+------------------------------------------------------------------+
|                          TCalculator                             |
+------------------------------------------------------------------+
|  cWinName         : Character   # Cadena identificadora de ventana|
|  cDisplayName     : Character   # Cadena identificadora de TextBox|
|  cCurrentValue    : Character   # Cadena de visualización activa  |
|  nStoredValue     : Numeric     # Acumulador del operando izquierdo|
|  cPendingOperator : Character   # Operador aritmético pendiente   |
|  lNewEntry        : Logical     # Bandera: iniciar nuevo número?  |
|  lHasDecimal      : Logical     # Bandera: decimal ya usado?      |
|  lErrorState      : Logical     # Bandera: bloqueo de error activo?|
|  nButtonWidth     : Numeric     # Ancho de botón (px)             |
|  nButtonHeight    : Numeric     # Alto de botón (px)              |
|  nDisplayHeight   : Numeric     # Alto del TextBox (px)           |
|  nMargin          : Numeric     # Espaciado de interfaz (px)      |
|  nWindowWidth     : Numeric     # Ancho total de ventana (px)     |
|  nWindowHeight    : Numeric     # Alto total de ventana (px)      |
+------------------------------------------------------------------+
|  New()              -> Constructor e inicializador                |
|  BuildWindow()      -> Crea ventana principal y pantalla          |
|  BuildButtonGrid()  -> Crea diseño de botones 4x5                 |
|  ResetState()       -> Limpia todo el estado a valores predeterminados|
|  UpdateDisplay()    -> Sincroniza TextBox con cCurrentValue       |
|  InputDigit()       -> Maneja pulsaciones de botones 0-9          |
|  InputDecimal()     -> Maneja botón de punto decimal              |
|  InputOperator()    -> Maneja pulsaciones de +, -, *, /           |
|  CalculateResult()  -> Ejecuta operación pendiente                |
|  ClearAll()         -> Maneja botón C (delega a ResetState)       |
|  Run()              -> Centra y activa la ventana                 |
+------------------------------------------------------------------+
```

---

### Miembros de Datos (Variables de Instancia)

Todos los miembros de datos se declaran con `DATA` dentro del bloque `CLASS...ENDCLASS`. Se inicializan en el método constructor `New()`.

#### Identificadores de Ventana y Control

| Miembro | Tipo | Propósito |
|---------|------|-----------|
| `cWinName` | `Character` | Cadena de nombre para la ventana principal. Se usa con `SetProperty()` / `GetProperty()` y sustitución de macros (`&`) en `DEFINE WINDOW`. |
| `cDisplayName` | `Character` | Cadena de nombre para la pantalla TextBox de solo lectura. Se usa con `SetProperty()` para actualizar el valor mostrado. |

> **Importante:** Las directivas `DEFINE WINDOW` y `DEFINE TEXTBOX` de MiniGUI Extended requieren sustitución de macros (`&`) para usar nombres dinámicos. Sin embargo, el operador de macro en Harbour solo funciona con variables simples, no con expresiones `::` (auto-referencia). Por lo tanto, se asignan variables locales desde los miembros de datos antes de usarlas en las directivas `DEFINE`.

#### Estado de la Calculadora

| Miembro | Tipo | Propósito |
|---------|------|-----------|
| `cCurrentValue` | `Character` | El número activo que se está ingresando o mostrando. Se almacena como cadena para preservar los ceros iniciales y el formato decimal antes de la conversión a numérico. |
| `nStoredValue` | `Numeric` | El operando izquierdo de una operación pendiente. Se almacena como numérico para evitar conversiones repetidas de `VAL()` durante operaciones encadenadas. |
| `cPendingOperator` | `Character` | El operador aritmético (`+`, `-`, `*`, `/`) esperando el operando derecho. Cadena vacía cuando no hay operación pendiente. |
| `lNewEntry` | `Logical` | Cuando es `.T.`, el siguiente dígito presionado inicia un nuevo número en lugar de agregarse al valor de visualización actual. |
| `lHasDecimal` | `Logical` | Previene múltiples puntos decimales en una sola entrada de número. Se reinicia en cada nuevo número. |
| `lErrorState` | `Logical` | Cuando es `.T.`, bloquea toda la entrada excepto `ClearAll()`. Se activa en división por cero. |

#### Dimensiones del Diseño

| Miembro | Tipo | Predeterminado | Propósito |
|---------|------|----------------|-----------|
| `nButtonWidth` | `Numeric` | `60` | Ancho de cada botón de la calculadora en píxeles. |
| `nButtonHeight` | `Numeric` | `45` | Alto de cada botón de la calculadora en píxeles. |
| `nDisplayHeight` | `Numeric` | `50` | Alto del TextBox de visualización en píxeles. |
| `nMargin` | `Numeric` | `10` | Relleno entre controles y bordes de ventana en píxeles. |
| `nWindowWidth` | `Numeric` | `290` | Ancho total de ventana calculado (`4 * nButtonWidth + 5 * nMargin`). |
| `nWindowHeight` | `Numeric` | `345` | Alto total de ventana calculado (pantalla + 5 filas de botones + márgenes + barra de título). |

---

### Métodos

#### `New()` — Constructor

```harbour
METHOD New() CLASS TCalculator
```

**Propósito:** Inicializa todos los miembros de datos a sus valores predeterminados y activa la construcción de la interfaz.

**Flujo:**
1. Establece las cadenas de nombre de ventana/control (`cWinName`, `cDisplayName`).
2. Calcula las dimensiones del diseño basándose en la geometría de la cuadrícula de botones.
3. Inicializa el estado de la calculadora a los valores predeterminados (`"0"`, `0`, `""`, `.T.`, `.F.`, `.F.`).
4. Llama a `BuildWindow()` para construir la interfaz.

**Retorna:** `Self` (la instancia del objeto recién creado).

---

#### `BuildWindow()` — Construcción de la Ventana Principal

```harbour
METHOD BuildWindow() CLASS TCalculator
```

**Propósito:** Define la ventana principal de la aplicación y su control de visualización usando las directivas de MiniGUI Extended.

**Detalle Clave de Implementación — Sustitución de Macros:**

MiniGUI Extended requiere nombres literales en `DEFINE WINDOW` y `DEFINE TEXTBOX`. Para usar los nombres almacenados en los miembros de datos, primero se crean variables locales:

```harbour
LOCAL cWinName     := ::cWinName       // Copiar de miembro de datos a local
LOCAL cDisplayName := ::cDisplayName

DEFINE WINDOW &cWinName              // &cWinName -> "WinCalculator"
    /* ... cláusulas de ventana ... */
    DEFINE TEXTBOX &cDisplayName     // &cDisplayName -> "DisplayBox"
        /* ... cláusulas de textbox ... */
    END TEXTBOX
END WINDOW
```

> **Por qué locales?** El operador de macro `&` de Harbour resuelve nombres de variables simples en tiempo de ejecución. No puede resolver `::cWinName` (una referencia de objeto con alcance de método). Usar variables locales salva esta brecha.

**Cláusulas de Ventana:**

| Cláusula | Valor | Propósito |
|----------|-------|-----------|
| `AT 0, 0` | Esquina superior izquierda | Posición de la ventana en pantalla. |
| `WIDTH` / `HEIGHT` | Dimensiones calculadas | Ventana de tamaño fijo. |
| `TITLE` | `"Basic Calculator"` | Texto de la barra de título. |
| `MAIN` | — | Designa esta como la ventana principal de la aplicación. |
| `NOMAXIMIZE` | — | Desactiva el botón de maximizar. |
| `NOSIZE` | — | Evita que el usuario redimensione la ventana. |

**Propiedades del TextBox de Visualización:**

| Propiedad | Valor | Propósito |
|-----------|-------|-----------|
| `FONTNAME "Consolas"` | Fuente monoespaciada | Asegura la alineación de dígitos. |
| `FONTSIZE 18` | Fuente grande | Legibilidad. |
| `NUMERIC .F.` | Modo no numérico | Permite puntos decimales y cadenas de error. |
| `READONLY .T.` | Solo lectura | Previene la corrupción por entrada de teclado. |
| `RIGHTALIGN .T.` | Alineado a la derecha | Comportamiento estándar de pantalla de calculadora. |

Después de `END WINDOW`, se llama a `ResetState()` para inicializar la pantalla.

---

#### `BuildButtonGrid()` — Diseño de Botones

```harbour
METHOD BuildButtonGrid() CLASS TCalculator
```

**Propósito:** Crea los 17 botones de la calculadora en una cuadrícula estándar de 4 columnas.

**Diseño:**

```
+-----+-----+-----+-----+
|  7  |  8  |  9  |  /  |  <- Fila 1
+-----+-----+-----+-----+
|  4  |  5  |  6  |  *  |  <- Fila 2
+-----+-----+-----+-----+
|  1  |  2  |  3  |  -  |  <- Fila 3
+-----+-----+-----+-----+
|  C  |  0  |  .  |  +  |  <- Fila 4
+-----+-----+-----+-----+
|           =           |  <- Fila 5 (abarca 4 columnas)
+-----------------------+
```

**Definiciones de Botones:**

Cada botón usa `DEFINE BUTTON` con:
- **Nombre estático** (ej. `Btn7`, `BtnDiv`, `BtnClear`) — requerido porque la sustitución de macros con `&` no funciona de manera confiable para nombres de controles dentro de métodos de clase.
- **`ROW`/`COL` calculados** — basados en `nStartRow`, dimensiones de botones y espaciado de márgenes.
- **`ACTION`** — vinculado directamente al método de clase que maneja la función de ese botón.
- **`FONTSIZE 14`** — tamaño consistente; los operadores usan `FONTBOLD .T.` para distinción visual.

**Mapeo Botón-a-Método:**

| Botón | Nombre | Acción | Método Llamado |
|-------|--------|--------|----------------|
| `0-9` | `Btn0`-`Btn9` | `ACTION ::InputDigit("0")` ... | Agrega dígito al valor actual |
| `.` | `BtnDot` | `ACTION ::InputDecimal()` | Agrega punto decimal |
| `+` | `BtnAdd` | `ACTION ::InputOperator("+")` | Establece suma pendiente |
| `-` | `BtnSub` | `ACTION ::InputOperator("-")` | Establece resta pendiente |
| `*` | `BtnMul` | `ACTION ::InputOperator("*")` | Establece multiplicación pendiente |
| `/` | `BtnDiv` | `ACTION ::InputOperator("/")` | Establece división pendiente |
| `=` | `BtnEquals` | `ACTION ::CalculateResult()` | Ejecuta operación pendiente |
| `C` | `BtnClear` | `ACTION ::ClearAll()` | Restablece todo el estado |

---

#### `ResetState()` — Inicialización de Estado

```harbour
METHOD ResetState() CLASS TCalculator
```

**Propósito:** Restablece todas las variables de estado de la calculadora a sus valores iniciales predeterminados.

**Valores de Reinicio de Estado:**

| Variable | Valor de Reinicio | Significado |
|----------|-------------------|-------------|
| `cCurrentValue` | `"0"` | La pantalla muestra cero |
| `nStoredValue` | `0` | No hay resultado acumulado |
| `cPendingOperator` | `""` | No hay operación pendiente |
| `lNewEntry` | `.T.` | El siguiente dígito comienza de nuevo |
| `lHasDecimal` | `.F.` | No hay decimal en el número actual |
| `lErrorState` | `.F.` | La calculadora está operativa |

Llama a `UpdateDisplay()` para refrescar la interfaz.

---

#### `UpdateDisplay()` — Sincronización de Pantalla

```harbour
METHOD UpdateDisplay() CLASS TCalculator
```

**Propósito:** Sincroniza la pantalla visual con el estado interno `cCurrentValue`.

**Implementación:**
```harbour
SetProperty( ::cWinName, ::cDisplayName, "VALUE", cDisplayValue )
```

Usa la función `SetProperty()` de MiniGUI Extended para actualizar el control TextBox en tiempo de ejecución. El nombre de ventana (`::cWinName`) y el nombre de control (`::cDisplayName`) se pasan como cadenas.

---

#### `InputDigit( cDigit )` — Entrada de Dígitos

```harbour
METHOD InputDigit( cDigit ) CLASS TCalculator
```

**Propósito:** Maneja las pulsaciones de los botones de dígitos `0` a `9`.

**Lógica:**
1. Si `lErrorState` es `.T.`, ignora la entrada.
2. Si `lNewEntry` es `.T.`, reemplaza la pantalla con el nuevo dígito y limpia las banderas.
3. Si `lNewEntry` es `.F.`, agrega el dígito a `cCurrentValue`.
4. Caso especial: si el valor actual es `"0"`, lo reemplaza en lugar de agregar (previene ceros iniciales como `"05"`).

---

#### `InputDecimal()` — Entrada de Punto Decimal

```harbour
METHOD InputDecimal() CLASS TCalculator
```

**Propósito:** Maneja el botón de punto decimal (`.`).

**Lógica:**
1. Si `lErrorState` es `.T.`, ignora la entrada.
2. Si `lNewEntry` es `.T.`, comienza con `"0."`.
3. Si `lHasDecimal` es `.F.`, agrega `.` y activa la bandera.
4. Si `lHasDecimal` es `.T.`, ignora (previene `"5..3"`).

---

#### `InputOperator( cOperator )` — Entrada de Operador

```harbour
METHOD InputOperator( cOperator ) CLASS TCalculator
```

**Propósito:** Maneja las pulsaciones de los botones `+`, `-`, `*`, `/`.

**Lógica:**
1. Si `lErrorState` es `.T.`, ignora la entrada.
2. Si existe un operador pendiente y el usuario no está iniciando una nueva entrada, ejecuta primero el cálculo pendiente (operaciones encadenadas).
3. Almacena el valor actual de la pantalla como numérico en `nStoredValue`.
4. Establece `cPendingOperator` al nuevo operador.
5. Establece `lNewEntry` a `.T.` para que el siguiente dígito inicie un nuevo número.

---

#### `CalculateResult()` — Ejecutar Operación

```harbour
METHOD CalculateResult() CLASS TCalculator
```

**Propósito:** Ejecuta la operación aritmética pendiente cuando se presiona `=`.

**Lógica:**
1. Si no existe operador pendiente, retorna inmediatamente.
2. Si está en estado de error, retorna inmediatamente.
3. Convierte `cCurrentValue` a numérico usando `VAL()`.
4. Realiza la operación basada en `cPendingOperator`:
   - `+` : Suma
   - `-` : Resta
   - `*` : Multiplicación
   - `/` : División (con verificación de cero)
5. **División por Cero:** Si el divisor es `0`, establece `cCurrentValue` a `"Error: Div by 0"`, `lErrorState` a `.T.`, limpia el operador pendiente, actualiza la pantalla y retorna.
6. Formatea el resultado eliminando los ceros finales de la representación de cadena.
7. Actualiza `cCurrentValue`, `nStoredValue`, limpia `cPendingOperator`, establece `lNewEntry` a `.T.`.
8. Actualiza la pantalla.

**Formateo de Resultados:**
```harbour
cResultStr := ALLTRIM( STR( nResult, 16, 10 ) )
cResultStr := RTRIM( cResultStr )
cResultStr := RTRIM( cResultStr, "0" )
cResultStr := RTRIM( cResultStr, "." )
```

Esto asegura que resultados como `5.5000000000` se muestren como `5.5`, y `7.0000000000` como `7`.

---

#### `ClearAll()` — Reinicio Completo

```harbour
METHOD ClearAll() CLASS TCalculator
```

**Propósito:** Maneja el botón `C` (Limpiar).

Simplemente delega a `ResetState()` para limpiar todo el estado y refrescar la pantalla.

---

#### `Run()` — Entrada al Bucle de Eventos

```harbour
METHOD Run() CLASS TCalculator
```

**Propósito:** Centra la ventana en pantalla e inicia el bucle de eventos de MiniGUI Extended.

**Implementación:**
```harbour
LOCAL cWinName := ::cWinName
CENTER WINDOW &cWinName
ACTIVATE WINDOW &cWinName
```

> Nota: La variable local `cWinName` es requerida para que el operador de macro `&` funcione correctamente con `CENTER WINDOW` y `ACTIVATE WINDOW`.

---

## Construcción de la Interfaz con MiniGUI Extended

### Definición de la Ventana

MiniGUI Extended usa bloques declarativos `DEFINE WINDOW` para crear formularios. La calculadora usa:

```harbour
DEFINE WINDOW WinCalculator
    AT 0, 0
    WIDTH  290
    HEIGHT 345
    TITLE "Basic Calculator"
    MAIN
    NOMAXIMIZE
    NOSIZE
END WINDOW
```

| Cláusula | Descripción |
|----------|-------------|
| `DEFINE WINDOW <nombre>` | Inicia la definición de ventana. El nombre se usa con `SetProperty()`, `GetProperty()` y funciones de gestión de ventanas. |
| `AT <fila>, <columna>` | Posición de la ventana en píxeles. |
| `WIDTH` / `HEIGHT` | Dimensiones de la ventana en píxeles. |
| `TITLE` | Texto de la barra de título. |
| `MAIN` | Designa la ventana principal de la aplicación. Cerrarla termina la aplicación. |
| `NOMAXIMIZE` | Elimina el botón de maximizar de la barra de título. |
| `NOSIZE` | Previene que el usuario redimensione la ventana arrastrando los bordes. |

### Definición de Controles

#### TextBox (Pantalla)

```harbour
DEFINE TEXTBOX DisplayBox
    ROW    10
    COL    10
    WIDTH  270
    HEIGHT 50
    VALUE  "0"
    FONTNAME "Consolas"
    FONTSIZE 18
    NUMERIC .F.
    READONLY .T.
    RIGHTALIGN .T.
END TEXTBOX
```

| Cláusula | Descripción |
|----------|-------------|
| `DEFINE TEXTBOX <nombre>` | Crea un control de entrada de texto de una sola línea. |
| `ROW` / `COL` | Posición relativa al área cliente de la ventana. |
| `WIDTH` / `HEIGHT` | Dimensiones del control en píxeles. |
| `VALUE` | Contenido de texto inicial. |
| `FONTNAME` / `FONTSIZE` | Configuración tipográfica. |
| `NUMERIC` | Cuando es `.T.`, restringe la entrada solo a números. Se establece `.F.` para permitir decimales y texto de error. |
| `READONLY` | Cuando es `.T.`, previene la edición del usuario (pero permite actualizaciones programáticas vía `SetProperty`). |
| `RIGHTALIGN` | Alinea el texto al borde derecho del control. |

#### Botón

```harbour
DEFINE BUTTON Btn7
    ROW    70
    COL    10
    WIDTH  60
    HEIGHT 45
    CAPTION "7"
    ACTION ::InputDigit( "7" )
    FONTSIZE 14
END BUTTON
```

| Cláusula | Descripción |
|----------|-------------|
| `DEFINE BUTTON <nombre>` | Crea un control de botón pulsador. |
| `CAPTION` | Texto de la etiqueta del botón. |
| `ACTION` | Bloque de código o llamada a método ejecutado al hacer clic. En contexto OOP, `::MethodName()` se vincula al objeto actual. |
| `FONTSIZE` / `FONTBOLD` | Estilo tipográfico. |

### Sustitución de Macros para Nombres Dinámicos

Un patrón de compatibilidad crítico usado a lo largo de esta aplicación:

```harbour
/* INCORRECTO: & no resuelve ::cWinName */
DEFINE WINDOW &::cWinName     // ERROR: Variable no existe

/* CORRECTO: Copiar a local primero, luego usar & */
LOCAL cWinName := ::cWinName
DEFINE WINDOW &cWinName       // OK: Se resuelve a "WinCalculator"
```

Este patrón es necesario porque:
1. Las directivas de MiniGUI Extended (`DEFINE WINDOW`, `DEFINE TEXTBOX`, etc.) esperan nombres literales o nombres resueltos por macro.
2. El operador de macro `&` de Harbour solo resuelve nombres de variables simples (local, private, public, field), no referencias a miembros de objeto (`::`).
3. El prefijo `::` es azúcar sintáctica para `Self:` y se evalúa en tiempo de ejecución a través del contexto del objeto, no del compilador de macros.

---

## Lógica de la Calculadora

### Máquina de Estados

La calculadora opera como una máquina de estados simple con dos estados principales:

| Estado | `lNewEntry` | `cPendingOperator` | Comportamiento |
|--------|-------------|-------------------|----------------|
| **Entrada** | `.T.` | Cualquiera | El siguiente dígito reemplaza la pantalla |
| **Acumulación** | `.F.` | Cualquiera | El siguiente dígito se agrega a la pantalla |
| **Inactivo** | `.T.` | `""` | No hay operación pendiente, la pantalla muestra el resultado |
| **Pendiente** | `.T.` | `+,-,*,/` | Esperando el operando derecho |
| **Error** | Cualquiera | Cualquiera | Toda la entrada bloqueada excepto Limpiar |

**Transiciones de Estado:**

```
[Inactivo] --dígito--> [Acumulación]
[Acumulación] --operador--> [Pendiente]  (almacena operando izquierdo)
[Pendiente] --dígito--> [Acumulación]     (ingresa operando derecho)
[Acumulación] --=--> [Inactivo]          (calcula y muestra)
[Cualquiera] --C--> [Inactivo]            (reinicio completo)
[Cualquiera] --div_por_cero--> [Error]    (bloquea entrada)
[Error] --C--> [Inactivo]                 (reinicio a operativo)
```

### Motor Aritmético

Las operaciones se realizan usando los tipos numéricos nativos de Harbour (punto flotante de doble precisión).

**Ejemplo de Operaciones Encadenadas:**
```
Usuario presiona: 5 + 3 + 2 =

Paso 1: "5" -> InputDigit("5") -> cCurrentValue = "5"
Paso 2: "+" -> InputOperator("+") -> nStoredValue = 5, cPendingOperator = "+"
Paso 3: "3" -> InputDigit("3") -> cCurrentValue = "3"
Paso 4: "+" -> InputOperator("+") -> CalculateResult() -> 5+3=8
                                      -> nStoredValue = 8, cPendingOperator = "+"
Paso 5: "2" -> InputDigit("2") -> cCurrentValue = "2"
Paso 6: "=" -> CalculateResult() -> 8+2=10
                                      -> cCurrentValue = "10"
```

### Manejo de Decimales

Los decimales se rastrean mediante la bandera `lHasDecimal`:

- **Nuevo número:** `lHasDecimal` comienza como `.F.`
- **Primera pulsación de `.`:** Agrega `.`, establece `lHasDecimal` a `.T.`
- **Pulsaciones subsecuentes de `.`:** Ignoradas mientras `lHasDecimal` es `.T.`
- **Nueva entrada iniciada:** `lHasDecimal` se reinicia a `.F.`

Esto previene entrada inválida como `5.3.7`.

### Manejo de Errores

La única condición de error manejada es **división por cero**:

```harbour
CASE ::cPendingOperator == "/"
    IF nCurrent == 0
        ::cCurrentValue    := "Error: Div by 0"
        ::lErrorState      := .T.
        ::cPendingOperator := ""
        ::UpdateDisplay()
        RETURN Self
    ENDIF
    nResult := ::nStoredValue / nCurrent
```

Cuando `lErrorState` es `.T.`:
- `InputDigit()` retorna inmediatamente (ignora todos los dígitos).
- `InputDecimal()` retorna inmediatamente.
- `InputOperator()` retorna inmediatamente.
- Solo `ClearAll()` (el botón `C`) puede reiniciar la calculadora a estado operativo.

---

## Compilación y Ejecución

### Usando hbmk2 (Recomendado)

```bash
hbmk2 calculator.prg -w3 -es2
```

### Compilación Manual

```bash
# Compilar fuente Harbour a C
harbour calculator.prg /n /w /es2

# Compilar C a objeto
bcc32 -c calculator.c

# Enlazar con bibliotecas de MiniGUI Extended
# (ajustar rutas de bibliotecas para tu instalación)
ilink32 calculator.obj, calculator.exe, , minigui.lib hbvm.lib hbrtl.lib
```

### Ejecutar

```bash
calculator.exe
```

---

## Licencia

Licencia MIT. Ver el encabezado del archivo fuente para más detalles.

---

## Referencias

- [Proyecto Harbour](https://harbour.github.io/)
- [MiniGUI Extended Edition](https://hmgextended.com/)
- Documentación OOP de Harbour: `CLASS`, `DATA`, `METHOD`, `ENDCLASS`
- API de MiniGUI Extended: `DEFINE WINDOW`, `DEFINE BUTTON`, `DEFINE TEXTBOX`, `SetProperty()`, `GetProperty()`
