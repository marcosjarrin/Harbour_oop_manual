/*

 BadaSystem
 Class         : Basic Calculator Application
 File          : calculator.prg
 Compiler      : Harbour MiniGUI Extended
 Compiler-C    : BCC
 Author        : Marcos Jarrin
 Email         : marvijarrin@gmail.com
 Date          : 11/07/2026
 Description   : A fully functional basic calculator implemented using
                 Harbour native OOP syntax and MiniGUI Extended UI engine.
 Version       : 1.0.0
 License       : MIT

MIT License

Copyright (c) 2026 Marcos Jarrin

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.


Licencia MIT

Derechos de autor (c) 2026 Marcos Jarrin

Por la presente se concede permiso, libre de cargo, a cualquier persona que obtenga una copia
de este software y los archivos de documentación asociados (el "Software"), para utilizar
el Software sin restricción, incluyendo sin limitación los derechos de uso, copia, modificación,
fusión, publicación, distribución, sublicencia y/o venta de copias del Software, y para
permitir que las personas a quienes se les proporcione el Software lo hagan, sujeto a las
siguientes condiciones:

El aviso de derechos de autor anterior y este aviso de permiso deberán incluirse en todas
las copias o partes sustanciales del Software.

*/

/*
 * ============================================================
 * DESCARGO DE RESPONSABILIDAD / DISCLAIMER OF LIABILITY
 * ============================================================
 *
 * ESPAÑOL:
 * EL SOFTWARE SE PROPORCIONA "TAL CUAL", SIN GARANTÍA DE NINGÚN TIPO.
 * EL AUTOR NO ES RESPONSABLE POR DAÑOS DIRECTOS, INDIRECTOS, PÉRDIDA
 * DE DATOS, INTERRUPCIÓN DEL NEGOCIO O CUALQUIER OTRA PÉRDIDA DERIVADA
 * DEL USO DE ESTE SOFTWARE. EL USUARIO ASUBE TODA LA RESPONSABILIDAD.
 *
 * ENGLISH:
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
 * THE AUTHOR IS NOT LIABLE FOR ANY DIRECT, INDIRECT DAMAGES, LOSS OF
 * DATA, BUSINESS INTERRUPTION, OR ANY OTHER LOSS ARISING FROM THE USE
 * OF THIS SOFTWARE. THE USER ASSUMES ALL RESPONSIBILITY.
 * ============================================================
 */

#include "minigui.ch"
#include "hbclass.ch"

/**
 * @class TCalculator
 * @brief A basic calculator application class using Harbour OOP and MiniGUI Extended.
 *
 * This class encapsulates the entire calculator logic, UI construction, and
 * event handling. It provides standard arithmetic operations including addition,
 * subtraction, multiplication, and division, with full decimal support and
 * division-by-zero protection.
 *
 * @author Marcos Jarrin
 * @version 1.0.0
 * @see DEFINE WINDOW, DEFINE BUTTON, DEFINE TEXTBOX
 */
CLASS TCalculator

    /**
     * @data cWinName
     * @brief The name of the main calculator window as a string.
     *
     * Used for SetProperty/GetProperty calls. The actual window definition
     * uses this name via macro substitution with a local variable.
     */
    DATA cWinName

    /**
     * @data cDisplayName
     * @brief The name of the display text box control as a string.
     *
     * Used for SetProperty/GetProperty calls.
     */
    DATA cDisplayName

    /**
     * @data cCurrentValue
     * @brief The string representation of the value currently being entered.
     *
     * Accumulates digit and decimal point input before an operator is pressed.
     */
    DATA cCurrentValue

    /**
     * @data nStoredValue
     * @brief The numeric value stored from the previous operation.
     *
     * Holds the result of the last completed operation or the first operand
     * in a multi-step calculation.
     */
    DATA nStoredValue

    /**
     * @data cPendingOperator
     * @brief The arithmetic operator waiting to be applied.
     *
     * Valid values: "+", "-", "*", "/", or empty string "" if none pending.
     */
    DATA cPendingOperator

    /**
     * @data lNewEntry
     * @brief Flag indicating whether the next digit starts a new number.
     *
     * When .T., pressing a digit will clear the display and start fresh
     * rather than appending to the current value.
     */
    DATA lNewEntry

    /**
     * @data lHasDecimal
     * @brief Flag indicating whether the current entry contains a decimal point.
     *
     * Prevents multiple decimal points in a single number entry.
     */
    DATA lHasDecimal

    /**
     * @data lErrorState
     * @brief Flag indicating whether the calculator is in an error state.
     *
     * When .T., most operations are blocked until the user clears the calculator.
     */
    DATA lErrorState

    /**
     * @data nButtonWidth
     * @brief The width in pixels of each calculator button.
     */
    DATA nButtonWidth

    /**
     * @data nButtonHeight
     * @brief The height in pixels of each calculator button.
     */
    DATA nButtonHeight

    /**
     * @data nDisplayHeight
     * @brief The height in pixels of the display text box.
     */
    DATA nDisplayHeight

    /**
     * @data nMargin
     * @brief The margin in pixels between UI elements and window borders.
     */
    DATA nMargin

    /**
     * @data nWindowWidth
     * @brief The total width in pixels of the calculator window.
     */
    DATA nWindowWidth

    /**
     * @data nWindowHeight
     * @brief The total height in pixels of the calculator window.
     */
    DATA nWindowHeight

    /**
     * @method New()
     * @brief Class constructor. Initializes all data members and builds the UI.
     *
     * Sets default dimensions, initializes calculator state variables,
     * and invokes the window creation method.
     *
     * @return Self (TCalculator instance)
     * @see BuildWindow(), ResetState()
     */
    METHOD New()

    /**
     * @method BuildWindow()
     * @brief Constructs the main application window and all child controls.
     *
     * Uses MiniGUI Extended DEFINE WINDOW syntax to create the main form,
     * the read-only display text box, and the full button grid layout.
     *
     * @return Self
     * @see BuildButtonGrid()
     */
    METHOD BuildWindow()

    /**
     * @method BuildButtonGrid()
     * @brief Creates the calculator button grid layout.
     *
     * Defines all digit buttons (0-9), operator buttons (+, -, *, /),
     * the equals button (=), and the clear button (C) in a standard
     * 4-column grid arrangement.
     *
     * @return Self
     * @see BuildWindow()
     */
    METHOD BuildButtonGrid()

    /**
     * @method ResetState()
     * @brief Resets the calculator to its initial default state.
     *
     * Clears the current value, stored value, pending operator, and all
     * internal flags. Updates the display to show "0".
     *
     * @return Self
     * @see UpdateDisplay()
     */
    METHOD ResetState()

    /**
     * @method UpdateDisplay()
     * @brief Refreshes the display text box with the current value.
     *
     * Sets the display control's value to cCurrentValue. If the current
     * value is empty, displays "0".
     *
     * @return Self
     * @see cCurrentValue
     */
    METHOD UpdateDisplay()

    /**
     * @method InputDigit()
     * @brief Handles digit button press events (0-9).
     *
     * Appends the pressed digit to the current value. If lNewEntry is .T.,
     * starts a new number. Respects the error state flag.
     *
     * @param cDigit STRING The digit character ("0" through "9") to input.
     * @return Self
     * @see InputDecimal(), InputOperator()
     */
    METHOD InputDigit( cDigit )

    /**
     * @method InputDecimal()
     * @brief Handles the decimal point button press event.
     *
     * Adds a decimal point to the current value if one is not already present.
     * If starting a new entry, begins with "0.".
     *
     * @return Self
     * @see InputDigit(), lHasDecimal
     */
    METHOD InputDecimal()

    /**
     * @method InputOperator()
     * @brief Handles arithmetic operator button press events (+, -, *, /).
     *
     * If a pending operator exists, executes it first. Then stores the
     * current value and sets the new pending operator.
     *
     * @param cOperator STRING The operator character: "+", "-", "*", or "/".
     * @return Self
     * @see CalculateResult(), cPendingOperator
     */
    METHOD InputOperator( cOperator )

    /**
     * @method CalculateResult()
     * @brief Executes the pending arithmetic operation and displays the result.
     *
     * Performs the calculation using nStoredValue, cPendingOperator, and
     * the current value. Handles division by zero with a graceful error
     * message and resets the calculator state.
     *
     * @return Self
     * @see InputOperator(), ResetState()
     */
    METHOD CalculateResult()

    /**
     * @method ClearAll()
     * @brief Handles the Clear (C) button press event.
     *
     * Completely resets the calculator to its initial state.
     *
     * @return Self
     * @see ResetState()
     */
    METHOD ClearAll()

    /**
     * @method Run()
     * @brief Activates the calculator window and starts the event loop.
     *
     * Calls the MiniGUI Extended ACTIVATE WINDOW command to display the
     * form and process user interactions.
     *
     * @return NIL
     * @see BuildWindow()
     */
    METHOD Run()

ENDCLASS


/* ============================================================================
 * METHOD IMPLEMENTATIONS
 * ============================================================================ */

/**
 * @method New
 * @memberof TCalculator
 * @brief Class constructor. Initializes all data members and builds the UI.
 *
 * @return Self (TCalculator instance)
 */
METHOD New() CLASS TCalculator

    ::cWinName       := "WinCalculator"
    ::cDisplayName   := "DisplayBox"
    ::nButtonWidth   := 60
    ::nButtonHeight  := 45
    ::nDisplayHeight := 50
    ::nMargin        := 10
    ::nWindowWidth   := 4 * ::nButtonWidth + 5 * ::nMargin
    ::nWindowHeight  := ::nDisplayHeight + 5 * ::nButtonHeight + 7 * ::nMargin + 30

    ::cCurrentValue   := "0"
    ::nStoredValue    := 0
    ::cPendingOperator:= ""
    ::lNewEntry       := .T.
    ::lHasDecimal     := .F.
    ::lErrorState     := .F.

    ::BuildWindow()

RETURN Self


/**
 * @method BuildWindow
 * @memberof TCalculator
 * @brief Constructs the main application window and all child controls.
 *
 * Creates a fixed-size, non-resizable window with a title bar. The window
 * contains a read-only display text box at the top and a button grid below.
 *
 * Uses local variables for window/control names to ensure macro substitution
 * works correctly with MiniGUI Extended directives.
 *
 * @return Self
 */
METHOD BuildWindow() CLASS TCalculator

    LOCAL cWinName    := ::cWinName
    LOCAL cDisplayName:= ::cDisplayName
    LOCAL nMargin   := ::nMargin
    LOCAL nWinWidth := ::nWindowWidth
    LOCAL nDispHeight:= ::nDisplayHeight

    DEFINE WINDOW &cWinName ;
        AT 0, 0 ;
        WIDTH  nWinWidth ;
        HEIGHT ::nWindowHeight ;
        TITLE "Basic Calculator" ;
        MAIN ;
        NOMAXIMIZE ;
        NOSIZE

        DEFINE TEXTBOX &cDisplayName
            ROW    nMargin
            COL    nMargin
            WIDTH  nWinWidth - 2 * nMargin - 10
            HEIGHT nDispHeight
            VALUE  "0"
            FONTNAME "Consolas"
            FONTSIZE 18
            NUMERIC .F.
            READONLY .T.
            RIGHTALIGN .T.
        END TEXTBOX

        ::BuildButtonGrid()

    END WINDOW

    ::ResetState()

RETURN Self


/**
 * @method BuildButtonGrid
 * @memberof TCalculator
 * @brief Creates the calculator button grid layout.
 *
 * Arranges buttons in a standard 4-column grid:
 * Row 1: [ 7 ] [ 8 ] [ 9 ] [ / ]
 * Row 2: [ 4 ] [ 5 ] [ 6 ] [ * ]
 * Row 3: [ 1 ] [ 2 ] [ 3 ] [ - ]
 * Row 4: [ C ] [ 0 ] [ . ] [ + ]
 * Row 5: [     =     ] (spans 4 columns)
 *
 * Uses local variables for layout calculations to ensure compatibility.
 *
 * @return Self
 */
METHOD BuildButtonGrid() CLASS TCalculator

    LOCAL nStartRow := ::nMargin + ::nDisplayHeight + ::nMargin
    LOCAL nBtnW     := ::nButtonWidth
    LOCAL nBtnH     := ::nButtonHeight
    LOCAL nMargin   := ::nMargin
    LOCAL nBaseRow, nBaseCol

    /* Row 1: 7, 8, 9, / */
    nBaseRow := nStartRow

    nBaseCol := nMargin
    DEFINE BUTTON Btn7
        ROW    nBaseRow
        COL    nBaseCol
        WIDTH  nBtnW
        HEIGHT nBtnH
        CAPTION "7"
        ACTION ::InputDigit( "7" )
        FONTSIZE 14
    END BUTTON

    nBaseCol := nMargin + 1 * ( nBtnW + nMargin )
    DEFINE BUTTON Btn8
        ROW    nBaseRow
        COL    nBaseCol
        WIDTH  nBtnW
        HEIGHT nBtnH
        CAPTION "8"
        ACTION ::InputDigit( "8" )
        FONTSIZE 14
    END BUTTON

    nBaseCol := nMargin + 2 * ( nBtnW + nMargin )
    DEFINE BUTTON Btn9
        ROW    nBaseRow
        COL    nBaseCol
        WIDTH  nBtnW
        HEIGHT nBtnH
        CAPTION "9"
        ACTION ::InputDigit( "9" )
        FONTSIZE 14
    END BUTTON

    nBaseCol := nMargin + 3 * ( nBtnW + nMargin )
    DEFINE BUTTON BtnDiv
        ROW    nBaseRow
        COL    nBaseCol
        WIDTH  nBtnW
        HEIGHT nBtnH
        CAPTION "/"
        ACTION ::InputOperator( "/" )
        FONTSIZE 14
        FONTBOLD .T.
    END BUTTON

    /* Row 2: 4, 5, 6, * */
    nBaseRow := nStartRow + 1 * ( nBtnH + nMargin )

    nBaseCol := nMargin
    DEFINE BUTTON Btn4
        ROW    nBaseRow
        COL    nBaseCol
        WIDTH  nBtnW
        HEIGHT nBtnH
        CAPTION "4"
        ACTION ::InputDigit( "4" )
        FONTSIZE 14
    END BUTTON

    nBaseCol := nMargin + 1 * ( nBtnW + nMargin )
    DEFINE BUTTON Btn5
        ROW    nBaseRow
        COL    nBaseCol
        WIDTH  nBtnW
        HEIGHT nBtnH
        CAPTION "5"
        ACTION ::InputDigit( "5" )
        FONTSIZE 14
    END BUTTON

    nBaseCol := nMargin + 2 * ( nBtnW + nMargin )
    DEFINE BUTTON Btn6
        ROW    nBaseRow
        COL    nBaseCol
        WIDTH  nBtnW
        HEIGHT nBtnH
        CAPTION "6"
        ACTION ::InputDigit( "6" )
        FONTSIZE 14
    END BUTTON

    nBaseCol := nMargin + 3 * ( nBtnW + nMargin )
    DEFINE BUTTON BtnMul
        ROW    nBaseRow
        COL    nBaseCol
        WIDTH  nBtnW
        HEIGHT nBtnH
        CAPTION "*"
        ACTION ::InputOperator( "*" )
        FONTSIZE 14
        FONTBOLD .T.
    END BUTTON

    /* Row 3: 1, 2, 3, - */
    nBaseRow := nStartRow + 2 * ( nBtnH + nMargin )

    nBaseCol := nMargin
    DEFINE BUTTON Btn1
        ROW    nBaseRow
        COL    nBaseCol
        WIDTH  nBtnW
        HEIGHT nBtnH
        CAPTION "1"
        ACTION ::InputDigit( "1" )
        FONTSIZE 14
    END BUTTON

    nBaseCol := nMargin + 1 * ( nBtnW + nMargin )
    DEFINE BUTTON Btn2
        ROW    nBaseRow
        COL    nBaseCol
        WIDTH  nBtnW
        HEIGHT nBtnH
        CAPTION "2"
        ACTION ::InputDigit( "2" )
        FONTSIZE 14
    END BUTTON

    nBaseCol := nMargin + 2 * ( nBtnW + nMargin )
    DEFINE BUTTON Btn3
        ROW    nBaseRow
        COL    nBaseCol
        WIDTH  nBtnW
        HEIGHT nBtnH
        CAPTION "3"
        ACTION ::InputDigit( "3" )
        FONTSIZE 14
    END BUTTON

    nBaseCol := nMargin + 3 * ( nBtnW + nMargin )
    DEFINE BUTTON BtnSub
        ROW    nBaseRow
        COL    nBaseCol
        WIDTH  nBtnW
        HEIGHT nBtnH
        CAPTION "-"
        ACTION ::InputOperator( "-" )
        FONTSIZE 14
        FONTBOLD .T.
    END BUTTON

    /* Row 4: C, 0, ., + */
    nBaseRow := nStartRow + 3 * ( nBtnH + nMargin )

    nBaseCol := nMargin
    DEFINE BUTTON BtnClear
        ROW    nBaseRow
        COL    nBaseCol
        WIDTH  nBtnW
        HEIGHT nBtnH
        CAPTION "C"
        ACTION ::ClearAll()
        FONTSIZE 14
        FONTBOLD .T.
    END BUTTON

    nBaseCol := nMargin + 1 * ( nBtnW + nMargin )
    DEFINE BUTTON Btn0
        ROW    nBaseRow
        COL    nBaseCol
        WIDTH  nBtnW
        HEIGHT nBtnH
        CAPTION "0"
        ACTION ::InputDigit( "0" )
        FONTSIZE 14
    END BUTTON

    nBaseCol := nMargin + 2 * ( nBtnW + nMargin )
    DEFINE BUTTON BtnDot
        ROW    nBaseRow
        COL    nBaseCol
        WIDTH  nBtnW
        HEIGHT nBtnH
        CAPTION "."
        ACTION ::InputDecimal()
        FONTSIZE 14
        FONTBOLD .T.
    END BUTTON

    nBaseCol := nMargin + 3 * ( nBtnW + nMargin )
    DEFINE BUTTON BtnAdd
        ROW    nBaseRow
        COL    nBaseCol
        WIDTH  nBtnW
        HEIGHT nBtnH
        CAPTION "+"
        ACTION ::InputOperator( "+" )
        FONTSIZE 14
        FONTBOLD .T.
    END BUTTON

    /* Row 5: Equals button spans full width */
    nBaseRow := nStartRow + 4 * ( nBtnH + nMargin )
    DEFINE BUTTON BtnEquals
        ROW    nBaseRow
        COL    nMargin
        WIDTH  4 * nBtnW + 3 * nMargin
        HEIGHT nBtnH
        CAPTION "="
        ACTION ::CalculateResult()
        FONTSIZE 14
        FONTBOLD .T.
    END BUTTON

RETURN Self


/**
 * @method ResetState
 * @memberof TCalculator
 * @brief Resets the calculator to its initial default state.
 *
 * Clears all internal state variables and refreshes the display to "0".
 *
 * @return Self
 */
METHOD ResetState() CLASS TCalculator

    ::cCurrentValue    := "0"
    ::nStoredValue     := 0
    ::cPendingOperator := ""
    ::lNewEntry        := .T.
    ::lHasDecimal      := .F.
    ::lErrorState      := .F.

    ::UpdateDisplay()

RETURN Self


/**
 * @method UpdateDisplay
 * @memberof TCalculator
 * @brief Refreshes the display text box with the current value.
 *
 * If the current value string is empty, displays "0" to ensure the
 * display never appears blank.
 *
 * @return Self
 */
METHOD UpdateDisplay() CLASS TCalculator

    LOCAL cDisplayValue := ::cCurrentValue

    IF EMPTY( cDisplayValue )
        cDisplayValue := "0"
    ENDIF

    SetProperty( ::cWinName, ::cDisplayName, "VALUE", cDisplayValue )

RETURN Self


/**
 * @method InputDigit
 * @memberof TCalculator
 * @brief Handles digit button press events (0-9).
 *
 * If the calculator is in an error state, the input is ignored.
 * If lNewEntry is .T., the display is cleared and the new digit becomes
 * the current value. Otherwise, the digit is appended.
 *
 * @param cDigit STRING The digit character ("0" through "9") to input.
 * @return Self
 */
METHOD InputDigit( cDigit ) CLASS TCalculator

    IF ::lErrorState
        RETURN Self
    ENDIF

    IF ::lNewEntry
        ::cCurrentValue := cDigit
        ::lNewEntry     := .F.
        ::lHasDecimal   := .F.
    ELSE
        IF ::cCurrentValue == "0"
            ::cCurrentValue := cDigit
        ELSE
            ::cCurrentValue := ::cCurrentValue + cDigit
        ENDIF
    ENDIF

    ::UpdateDisplay()

RETURN Self


/**
 * @method InputDecimal
 * @memberof TCalculator
 * @brief Handles the decimal point button press event.
 *
 * If the calculator is in an error state, the input is ignored.
 * If starting a new entry, begins with "0.". If a decimal point is
 * already present in the current value, the input is ignored.
 *
 * @return Self
 */
METHOD InputDecimal() CLASS TCalculator

    IF ::lErrorState
        RETURN Self
    ENDIF

    IF ::lNewEntry
        ::cCurrentValue := "0."
        ::lNewEntry     := .F.
        ::lHasDecimal   := .T.
    ELSEIF ! ::lHasDecimal
        ::cCurrentValue := ::cCurrentValue + "."
        ::lHasDecimal   := .T.
    ENDIF

    ::UpdateDisplay()

RETURN Self


/**
 * @method InputOperator
 * @memberof TCalculator
 * @brief Handles arithmetic operator button press events (+, -, *, /).
 *
 * If the calculator is in an error state, the input is ignored.
 * If a pending operator already exists, the current calculation is
 * executed first. The current value is then stored and the new operator
 * is set as pending. The lNewEntry flag is set to prepare for the next operand.
 *
 * @param cOperator STRING The operator character: "+", "-", "*", or "/".
 * @return Self
 */
METHOD InputOperator( cOperator ) CLASS TCalculator

    IF ::lErrorState
        RETURN Self
    ENDIF

    IF ! EMPTY( ::cPendingOperator ) .AND. ! ::lNewEntry
        ::CalculateResult()
    ENDIF

    ::nStoredValue     := VAL( ::cCurrentValue )
    ::cPendingOperator := cOperator
    ::lNewEntry        := .T.
    ::lHasDecimal      := .F.

RETURN Self


/**
 * @method CalculateResult
 * @memberof TCalculator
 * @brief Executes the pending arithmetic operation and displays the result.
 *
 * If no pending operator exists, the method returns without action.
 * Performs the calculation based on cPendingOperator using nStoredValue
 * and the current value. Division by zero is detected and handled by
 * displaying an error message and resetting the calculator.
 *
 * @return Self
 */
METHOD CalculateResult() CLASS TCalculator

    LOCAL nCurrent := VAL( ::cCurrentValue )
    LOCAL nResult  := 0
    LOCAL cResultStr

    IF EMPTY( ::cPendingOperator )
        RETURN Self
    ENDIF

    IF ::lErrorState
        RETURN Self
    ENDIF

    DO CASE
        CASE ::cPendingOperator == "+"
            nResult := ::nStoredValue + nCurrent

        CASE ::cPendingOperator == "-"
            nResult := ::nStoredValue - nCurrent

        CASE ::cPendingOperator == "*"
            nResult := ::nStoredValue * nCurrent

        CASE ::cPendingOperator == "/"
            IF nCurrent == 0
                ::cCurrentValue    := "Error: Div by 0"
                ::lErrorState      := .T.
                ::cPendingOperator := ""
                ::UpdateDisplay()
                RETURN Self
            ENDIF
            nResult := ::nStoredValue / nCurrent
    ENDCASE

    /* Format result to avoid excessive decimal places */
    cResultStr := ALLTRIM( STR( nResult, 16, 10 ) )
    cResultStr := RTRIM( cResultStr )
    cResultStr := RTRIM( cResultStr)
    cResultStr := RTRIM( cResultStr)

    IF EMPTY( cResultStr )
        cResultStr := "0"
    ENDIF

    ::cCurrentValue    := cResultStr
    ::nStoredValue     := nResult
    ::cPendingOperator := ""
    ::lNewEntry        := .T.
    ::lHasDecimal      := "." $ cResultStr

    ::UpdateDisplay()

RETURN Self


/**
 * @method ClearAll
 * @memberof TCalculator
 * @brief Handles the Clear (C) button press event.
 *
 * Delegates to ResetState() to fully clear the calculator.
 *
 * @return Self
 */
METHOD ClearAll() CLASS TCalculator

    ::ResetState()

RETURN Self


/**
 * @method Run
 * @memberof TCalculator
 * @brief Activates the calculator window and starts the event loop.
 *
 * Centers the window on screen and enters the MiniGUI Extended event loop.
 *
 * @return NIL
 */
METHOD Run() CLASS TCalculator

    LOCAL cWinName := ::cWinName

    CENTER WINDOW &cWinName
    ACTIVATE WINDOW &cWinName

RETURN NIL


/* ============================================================================
 * MAIN PROGRAM ENTRY POINT
 * ============================================================================ */

/**
 * @brief Main program entry point.
 *
 * Creates an instance of TCalculator and runs the application.
 */
FUNCTION Main()

    LOCAL oCalc

    SET CENTURY ON
    SET DATE FORMAT "YYYY-MM-DD"

    oCalc := TCalculator():New()
    oCalc:Run()

RETURN NIL
