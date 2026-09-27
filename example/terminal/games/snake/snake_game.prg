/*
 BadaSystem
 Program       : snake_harbour
 Module        : snake_game.prg
 Compiler      : Harbour Win32 Console
 Author        : Marcos Jarrín
 Email         : marvijarrin@gmail.com
 Website       : badasystem.com
 Date          : 26/09/2026
 Update        : 28/09/2026
 Rev           : 1.0
 SPDX-License-Identifier: MIT

 Description:
   TSnakeGame orchestrates the game loop.
   Uses Inkey() with timeout for reliable auto-movement.
   
*/

#include "hbclass.ch"

#ifndef DIR_UP
   #define DIR_UP       5
   #define DIR_DOWN     24
   #define DIR_LEFT     19
   #define DIR_RIGHT    4
#endif

#ifndef VK_ESCAPE
   #define VK_ESCAPE    27
#endif
#ifndef VK_UP
   #define VK_UP        32768 + 72
   #define VK_DOWN      32768 + 80
   #define VK_LEFT      32768 + 75
   #define VK_RIGHT     32768 + 77
#endif

/* ===================================================================== */
CLASS TSnakeGame

   DATA oSnake
   DATA oFood
   DATA oScreen
   DATA nScore
   DATA nHighScore
   DATA nSpeed
   DATA nInitialSpeed
   DATA nRows
   DATA nCols
   DATA lRunning
   DATA cStatus

   METHOD New() CONSTRUCTOR
   METHOD Run()
   METHOD InitRound()
   METHOD GameLoop()
   METHOD HandleInput( nKey )
   METHOD Update()
   METHOD Render()
   METHOD CheckCollisions()
   METHOD ShowMainMenu()
   METHOD ShowSpeedMenu()
   METHOD ShowGameOver()
   METHOD ShowCredits()

ENDCLASS

/* --------------------------------------------------------------------- */
METHOD New() CLASS TSnakeGame

   ::nRows         := 24
   ::nCols         := 78
   ::nScore        := 0
   ::nHighScore    := 0
   ::nInitialSpeed := 0.15
   ::nSpeed        := ::nInitialSpeed
   ::lRunning      := .F.
   ::cStatus       := "menu"
   ::oScreen       := TScreen():New( ::nRows, ::nCols )
   ::oSnake        := NIL
   ::oFood         := TFood():New( ::nRows, ::nCols )

RETURN Self

/* --------------------------------------------------------------------- */
METHOD Run() CLASS TSnakeGame

   LOCAL lExit
   LOCAL nOption

   lExit := .F.

   DO WHILE ! lExit
      nOption := ::ShowMainMenu()
      DO CASE
      CASE nOption == 1
         ::InitRound()
         ::GameLoop()
         ::ShowGameOver()
      CASE nOption == 2
         ::ShowSpeedMenu()
      CASE nOption == 3
         ::ShowCredits()
      CASE nOption == 4
         lExit := .T.
      ENDCASE
   ENDDO

RETURN NIL

/* --------------------------------------------------------------------- */
METHOD InitRound() CLASS TSnakeGame

   LOCAL oHead

   ::nScore  := 0
   ::nSpeed  := ::nInitialSpeed
   ::cStatus := "playing"

   oHead     := TCoordinate():New( Int( ::nRows / 2 ), Int( ::nCols / 2 ) )
   ::oSnake  := TSnake():New( oHead )
   ::oFood:Spawn( ::oSnake )

   ::oScreen:Clear()
   ::oScreen:HideCursor()
   ::oScreen:DrawBorder()
   ::Render()

RETURN NIL

/* --------------------------------------------------------------------- */
METHOD GameLoop() CLASS TSnakeGame

   LOCAL lAlive
   LOCAL nKey

   lAlive := .T.
   ::lRunning := .T.

   DO WHILE lAlive .AND. ::lRunning
      nKey := Inkey( ::nSpeed )
      
      IF nKey != 0
         ::HandleInput( nKey )
      ENDIF
      
      IF ::lRunning
         ::Update()
         lAlive := ::CheckCollisions()
         ::Render()
      ENDIF
   ENDDO

   ::oScreen:ShowCursor()

RETURN NIL

/* --------------------------------------------------------------------- */
METHOD HandleInput( nKey ) CLASS TSnakeGame

   DO CASE
   CASE nKey == VK_ESCAPE
      ::lRunning := .F.
   CASE nKey == VK_UP    .OR. nKey == 5
      ::oSnake:ChangeDirection( DIR_UP )
   CASE nKey == VK_DOWN  .OR. nKey == 24
      ::oSnake:ChangeDirection( DIR_DOWN )
   CASE nKey == VK_LEFT  .OR. nKey == 19
      ::oSnake:ChangeDirection( DIR_LEFT )
   CASE nKey == VK_RIGHT .OR. nKey == 4
      ::oSnake:ChangeDirection( DIR_RIGHT )
   ENDCASE

RETURN NIL

/* --------------------------------------------------------------------- */
METHOD Update() CLASS TSnakeGame

   LOCAL oHead

   ::oSnake:Move()
   oHead := ::oSnake:GetHead()

   IF HB_IsObject( ::oFood:GetPosition() ) .AND. ;
      oHead:nRow == ::oFood:GetPosition():nRow .AND. ;
      oHead:nCol == ::oFood:GetPosition():nCol
      ::oSnake:Grow()
      ::nScore += 100
      IF ::nScore > ::nHighScore
         ::nHighScore := ::nScore
      ENDIF
      ::oFood:Spawn( ::oSnake )
      IF ::nSpeed > 0.05
         ::nSpeed -= 0.005
      ENDIF
   ENDIF

RETURN NIL

/* --------------------------------------------------------------------- */
METHOD CheckCollisions() CLASS TSnakeGame

   LOCAL oHead

   oHead := ::oSnake:GetHead()

   IF ! oHead:IsValid( ::nRows, ::nCols )
      ::cStatus := "gameover"
      RETURN .F.
   ENDIF

   IF ::oSnake:CollidesWithSelf()
      ::cStatus := "gameover"
      RETURN .F.
   ENDIF

RETURN .T.

/* --------------------------------------------------------------------- */
METHOD Render() CLASS TSnakeGame

   ::oScreen:ClearPlayfield()
   ::oScreen:DrawSnake( ::oSnake )
   ::oScreen:DrawFood( ::oFood )
   ::oScreen:DrawHUD( ::nScore, ::nHighScore, ::oSnake:Length() )

RETURN NIL

/* --------------------------------------------------------------------- */
METHOD ShowMainMenu() CLASS TSnakeGame

   LOCAL nOption

   nOption := 0

   CLS
   @  1,  1 TO 24, 78 DOUBLE
   @  3, 28 SAY "S N A K E   H A R B O U R"
   @  5, 22 SAY "Terminal OOP Edition - BadaSystem 2026"
   @ 10, 30 PROMPT "  Play Game  " MESSAGE "Start a new game"
   @ 12, 30 PROMPT "  Speed      " MESSAGE "Configure initial speed"
   @ 14, 30 PROMPT "  Credits    " MESSAGE "About this game"
   @ 16, 30 PROMPT "  Exit       " MESSAGE "Quit the game"
   @ 22, 22 SAY "Use arrows to move | ESC to quit"

   MENU TO nOption

RETURN nOption

/* --------------------------------------------------------------------- */
METHOD ShowSpeedMenu() CLASS TSnakeGame

   LOCAL nOption

   nOption := 2

   CLS
   @  1,  1 TO 24, 78 DOUBLE
   @  3, 30 SAY "Select Speed"
   @  8, 28 PROMPT "  1 - Slow     " MESSAGE "Relaxed pace"
   @ 10, 28 PROMPT "  2 - Normal   " MESSAGE "Standard pace"
   @ 12, 28 PROMPT "  3 - Fast     " MESSAGE "Challenging"
   @ 14, 28 PROMPT "  4 - Insane   " MESSAGE "For experts"
   @ 20, 28 PROMPT "  Back         " MESSAGE "Return to main menu"

   MENU TO nOption

   DO CASE
   CASE nOption == 1
      ::nInitialSpeed := 0.25
   CASE nOption == 2
      ::nInitialSpeed := 0.15
   CASE nOption == 3
      ::nInitialSpeed := 0.08
   CASE nOption == 4
      ::nInitialSpeed := 0.04
   ENDCASE

RETURN NIL

/* --------------------------------------------------------------------- */
METHOD ShowGameOver() CLASS TSnakeGame

   CLS
   @  1,  1 TO 24, 78 DOUBLE
   @  8, 32 SAY "G A M E   O V E R"
   @ 11, 28 SAY "Final Score: " + Str( ::nScore, 7 )
   @ 12, 28 SAY "High Score : " + Str( ::nHighScore, 7 )
   @ 13, 28 SAY "Length     : " + Str( ::oSnake:Length(), 3 )
   @ 18, 28 SAY "Press any key to continue..."

   Inkey( 0 )

RETURN NIL

/* --------------------------------------------------------------------- */
METHOD ShowCredits() CLASS TSnakeGame

   CLS
   @  1,  1 TO 24, 78 DOUBLE
   @  4, 24 SAY "Snake Harbour - Terminal OOP Edition"
   @  7, 24 SAY "Original Clipper version : Andre Martins"
   @  9, 24 SAY "Harbour OOP              : Marcos Jarrin"
   @ 11, 24 SAY "Website                  : badasystem.com"
   @ 13, 24 SAY "Build                    : Harbour 3.2 + BCC32"
   @ 15, 24 SAY "Date                     : September 2026"
   @ 20, 28 SAY "Press any key to return..."

   Inkey( 0 )

RETURN NIL