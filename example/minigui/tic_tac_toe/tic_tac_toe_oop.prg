/*

 BadaSystem
 Class         : TTicTacToe
 Module        : main
 Compiler      : MINIGUI - Harbour Win32 GUI
 Compiler-C    : BCC 32 bit
 Author        : Marcos Jarrin
 Email         : marvijarrin@gmail.com
 Date          : 13/04/2026
 Purpose       : Implements the logic of a Tic-Tac-Toe game.
                 Manages the board, turns, win/draw detection, and UI updates.
 Description   : GAME TTicTacToe
 Rev           : 1.0


 ============================================================
 Class: TTicTacToe
 Purpose: Implements the logic of a Tic-Tac-Toe game.
          Manages the board, turns, win/draw detection, and UI updates.
 ============================================================

 ----------------------------------------------------------------------
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program. If not, see <https://www.gnu.org/licenses/>.
 ----------------------------------------------------------------------

 */

//============================================================
// Class: TTicTacToe
// Purpose: Implements the logic of a Tic-Tac-Toe game.
//          Manages the board, turns, win/draw detection, and UI updates.
// ============================================================
*
#include "hbclass.ch"
#include <minigui.ch>

CLASS TTicTacToe
   DATA cTurn INIT 'X'                                      // Current player: 'X' or 'O'
   DATA aBoard INIT { '', '', '', '', '', '', '', '', '' }  // 3x3 board stored as a 9‑element array
   DATA cWindowName                        // Name of the MiniGUI window that contains the board buttons

   METHOD New( cWinName )                  // Constructor: stores the window name (controls may not exist yet)
   METHOD Play( nPos )                     // Processes a move at board position nPos (1..9)
   METHOD CheckWinner()                    // Returns .T. if the current player has won, .F. otherwise
   METHOD Reset()                          // Resets the board and turn to start a new game
   METHOD UpdateStatus()                   // Refreshes the status label with the current player's turn
ENDCLASS

// ------------------------------------------------------------
// METHOD New( cWinName )
// ------------------------------------------------------------
METHOD New( cWinName ) CLASS TTicTacToe
   ::cWindowName := cWinName
   // We do NOT call UpdateStatus() here because the GUI controls may not exist yet.
RETURN Self

// ------------------------------------------------------------
// METHOD Play( nPos )
// ------------------------------------------------------------
METHOD Play( nPos ) CLASS TTicTacToe
   LOCAL cBtn := "Btn" + AllTrim( Str( nPos ) )

   // Only allow a move if the chosen cell is empty
   IF Empty( ::aBoard[ nPos ] )
      ::aBoard[ nPos ] := ::cTurn
      SetProperty( ::cWindowName, cBtn, 'Caption', ::cTurn )

      IF ::CheckWinner()
         MsgInfo( 'Player ' + ::cTurn + ' has won!', 'Game Over' )
         ::Reset()
      ELSEIF !( AScan( ::aBoard, {|x| Empty( x ) } ) > 0 )
         MsgInfo( 'It is a draw!', 'Game Over' )
         ::Reset()
      ELSE
         ::cTurn := IF( ::cTurn == 'X', 'O', 'X' )
         ::UpdateStatus()
      ENDIF
   ENDIF
RETURN Nil

// ------------------------------------------------------------
// METHOD CheckWinner()
// ------------------------------------------------------------
METHOD CheckWinner() CLASS TTicTacToe
   LOCAL aLines := { ;
        {1,2,3}, {4,5,6}, {7,8,9}, ;   // rows
        {1,4,7}, {2,5,8}, {3,6,9}, ;   // columns
        {1,5,9}, {3,5,7} }             // diagonals
   LOCAL i

   FOR i := 1 TO Len( aLines )
      IF !Empty( ::aBoard[ aLines[ i, 1 ] ] ) .AND. ;
         ::aBoard[ aLines[ i, 1 ] ] == ::aBoard[ aLines[ i, 2 ] ] .AND. ;
         ::aBoard[ aLines[ i, 2 ] ] == ::aBoard[ aLines[ i, 3 ] ]
         RETURN .T.
      ENDIF
   NEXT
RETURN .F.

// ------------------------------------------------------------
// METHOD Reset()
// ------------------------------------------------------------
METHOD Reset() CLASS TTicTacToe
   LOCAL i, cBtn

   ::aBoard := { '', '', '', '', '', '', '', '', '' }
   ::cTurn := 'X'

   FOR i := 1 TO 9
      cBtn := "Btn" + AllTrim( Str( i ) )
      SetProperty( ::cWindowName, cBtn, 'Caption', '' )
   NEXT

   ::UpdateStatus()
RETURN Nil

// ------------------------------------------------------------
// METHOD UpdateStatus()
// ------------------------------------------------------------
METHOD UpdateStatus() CLASS TTicTacToe
   SetProperty( ::cWindowName, 'LblStatus', 'Value', 'Turn: ' + ::cTurn )
RETURN Nil

// ============================================================
// PROCEDURE: Main()
// Purpose:   Creates the MiniGUI window, all buttons and the status label,
//            instantiates the TTicTacToe game object AFTER all controls are defined,
//            and starts the event loop.
// ============================================================
Function Main()
   LOCAL oGame

   DEFINE WINDOW Win_TicTac ;
      AT 0,0 ;
      WIDTH 320 HEIGHT 400 ;
      TITLE 'Tic Tac Toe - MiniGUI' ;
      MAIN ;
      NOSIZE NOMAXIMIZE

      // Row 1
      @ 20 , 20  BUTTON Btn1 CAPTION '' ACTION oGame:Play(1) WIDTH 80 HEIGHT 80 FONT 'Arial' SIZE 24
      @ 20 , 110 BUTTON Btn2 CAPTION '' ACTION oGame:Play(2) WIDTH 80 HEIGHT 80 FONT 'Arial' SIZE 24
      @ 20 , 200 BUTTON Btn3 CAPTION '' ACTION oGame:Play(3) WIDTH 80 HEIGHT 80 FONT 'Arial' SIZE 24
      // Row 2
      @ 110, 20  BUTTON Btn4 CAPTION '' ACTION oGame:Play(4) WIDTH 80 HEIGHT 80 FONT 'Arial' SIZE 24
      @ 110, 110 BUTTON Btn5 CAPTION '' ACTION oGame:Play(5) WIDTH 80 HEIGHT 80 FONT 'Arial' SIZE 24
      @ 110, 200 BUTTON Btn6 CAPTION '' ACTION oGame:Play(6) WIDTH 80 HEIGHT 80 FONT 'Arial' SIZE 24
      // Row 3
      @ 200, 20  BUTTON Btn7 CAPTION '' ACTION oGame:Play(7) WIDTH 80 HEIGHT 80 FONT 'Arial' SIZE 24
      @ 200, 110 BUTTON Btn8 CAPTION '' ACTION oGame:Play(8) WIDTH 80 HEIGHT 80 FONT 'Arial' SIZE 24
      @ 200, 200 BUTTON Btn9 CAPTION '' ACTION oGame:Play(9) WIDTH 80 HEIGHT 80 FONT 'Arial' SIZE 24

      @ 300, 20 LABEL LblStatus VALUE 'Turn: X' WIDTH 260 CENTERALIGN

      // Create the game object AFTER defining all controls
      oGame := TTicTacToe():New( 'Win_TicTac' )
      // Update the initial status (the label already says 'Turn: X', but we call it
      // to keep the object synchronized)
      oGame:UpdateStatus()

   END WINDOW

   CENTER WINDOW Win_TicTac
   ACTIVATE WINDOW Win_TicTac
RETURN Nil
