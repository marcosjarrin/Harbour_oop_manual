/*
 BadaSystem
 Program       : snake_harbour
 Module        : food.prg
 Compiler      : Harbour Win32 Console
 Author        : Marcos Jarrín
 Email         : marvijarrin@gmail.com
 Website       : badasystem.com
 Date          : 26/09/2026
 Update        : 28/09/2026
 Rev           : 1.0
 SPDX-License-Identifier: MIT

 Description:
   TFood handles random food spawning, ensuring it never overlaps
   the snake body or the border.
*/

#include "hbclass.ch"

#ifndef DIR_UP
   #define DIR_UP       5
   #define DIR_DOWN     24
   #define DIR_LEFT     19
   #define DIR_RIGHT    4
#endif

/* ===================================================================== */
CLASS TFood

   DATA oPosition
   DATA nMaxRow
   DATA nMaxCol

   METHOD New( nMaxRow, nMaxCol ) CONSTRUCTOR
   METHOD Spawn( oSnake )
   METHOD GetPosition()

ENDCLASS

/* --------------------------------------------------------------------- */
METHOD New( nMaxRow, nMaxCol ) CLASS TFood

   IF nMaxRow == NIL
      nMaxRow := 24
   ENDIF
   IF nMaxCol == NIL
      nMaxCol := 78
   ENDIF

   ::nMaxRow   := nMaxRow
   ::nMaxCol   := nMaxCol
   ::oPosition := NIL

RETURN Self

/* ---------------------------------------------------------------------
   Method: TFood:Spawn
   Purpose: Places food at a random cell not occupied by the snake.
   --------------------------------------------------------------------- */
METHOD Spawn( oSnake ) CLASS TFood

   LOCAL nRow, nCol
   LOCAL oCandidate
   LOCAL nAttempts := 0
   LOCAL lValid    := .F.

   DO WHILE ! lValid .AND. nAttempts < 500
      nRow       := hb_RandomInt( 2, ::nMaxRow - 1 )
      nCol       := hb_RandomInt( 2, ::nMaxCol - 1 )
      oCandidate := TCoordinate():New( nRow, nCol )

      IF ! oSnake:CollidesWith( oCandidate )
         lValid := .T.
      ENDIF
      nAttempts++
   ENDDO

   IF lValid
      ::oPosition := oCandidate
   ENDIF

RETURN lValid

/* --------------------------------------------------------------------- */
METHOD GetPosition() CLASS TFood
RETURN ::oPosition