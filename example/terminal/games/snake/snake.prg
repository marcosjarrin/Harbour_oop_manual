/*
 BadaSystem
 Program       : snake_harbour
 Module        : snake.prg
 Compiler      : Harbour Win32 Console
 Author        : Marcos Jarrín
 Email         : marvijarrin@gmail.com
 Website       : badasystem.com
 Date          : 26/09/2026
 Update        : 28/09/2026
 Rev           : 1.0
 SPDX-License-Identifier: MIT

 Description:
   TSnake models the snake body as an array of TCoordinate objects.
   Handles movement, growth, self-collision and direction changes.

*/

#include "hbclass.ch"

/* Direction constants (shared across modules) */
#ifndef DIR_UP
   #define DIR_UP       5
   #define DIR_DOWN     24
   #define DIR_LEFT     19
   #define DIR_RIGHT    4
#endif

/* =====================================================================
   Class: TSnake
   ===================================================================== */
CLASS TSnake

   DATA aBody            // Array of TCoordinate (head = index 1)
   DATA nDirection       // Current heading (DIR_UP/DOWN/LEFT/RIGHT)
   DATA nPendingGrowth   // Segments to add on next move

   METHOD New( oHeadCoord ) CONSTRUCTOR
   METHOD GetHead()
   METHOD GetTail()
   METHOD GetSegment( nIndex )
   METHOD Move()
   METHOD Grow()
   METHOD ChangeDirection( nNewDir )
   METHOD CollidesWithSelf()
   METHOD CollidesWith( oCoord )
   METHOD Length()

ENDCLASS

/* --------------------------------------------------------------------- */
METHOD New( oHeadCoord ) CLASS TSnake

   LOCAL nI
   LOCAL oSeg

   ::aBody          := {}
   ::nDirection     := DIR_RIGHT
   ::nPendingGrowth := 0

   // Build initial body of 5 segments extending left from head
   FOR nI := 1 TO 5
      oSeg := TCoordinate():New( oHeadCoord:nRow, oHeadCoord:nCol - ( nI - 1 ) )
      AAdd( ::aBody, oSeg )
   NEXT

RETURN Self

/* --------------------------------------------------------------------- */
METHOD GetHead()  CLASS TSnake
RETURN ::aBody[ 1 ]

/* --------------------------------------------------------------------- */
METHOD GetTail()  CLASS TSnake
RETURN ::aBody[ Len( ::aBody ) ]

/* ---------------------------------------------------------------------
   Method: TSnake:GetSegment
   Purpose: Returns a specific body segment by index (Encapsulation).
   --------------------------------------------------------------------- */
METHOD GetSegment( nIndex ) CLASS TSnake

   IF nIndex >= 1 .AND. nIndex <= Len( ::aBody )
      RETURN ::aBody[ nIndex ]
   ENDIF

RETURN NIL

/* ---------------------------------------------------------------------
   Method: TSnake:Length
   Purpose: Returns the number of body segments.
   --------------------------------------------------------------------- */
METHOD Length()   CLASS TSnake
RETURN Len( ::aBody )

/* ---------------------------------------------------------------------
   Method: TSnake:Move
   Purpose: Advances the snake one cell in the current direction.
            Uses clean array reconstruction to prevent NIL holes.
   --------------------------------------------------------------------- */
METHOD Move() CLASS TSnake

   LOCAL oNewHead
   LOCAL aNewBody := {}
   LOCAL nI
   LOCAL nLen

   // Compute new head position
   DO CASE
   CASE ::nDirection == DIR_UP
      oNewHead := ::GetHead():MoveUp()
   CASE ::nDirection == DIR_DOWN
      oNewHead := ::GetHead():MoveDown()
   CASE ::nDirection == DIR_LEFT
      oNewHead := ::GetHead():MoveLeft()
   CASE ::nDirection == DIR_RIGHT
      oNewHead := ::GetHead():MoveRight()
   ENDCASE

   // Build new body array: new head + all existing segments
   AAdd( aNewBody, oNewHead )
   nLen := Len( ::aBody )
   FOR nI := 1 TO nLen
      AAdd( aNewBody, ::aBody[ nI ] )
   NEXT

   // If not growing, remove the last segment (tail)
   IF ::nPendingGrowth > 0
      ::nPendingGrowth--
   ELSE
      // Remove last element cleanly
      ASize( aNewBody, Len( aNewBody ) - 1 )
   ENDIF

   // Replace body with new array
   ::aBody := aNewBody

RETURN NIL

/* --------------------------------------------------------------------- */
METHOD Grow() CLASS TSnake
   ::nPendingGrowth++
RETURN NIL

/* ---------------------------------------------------------------------
   Method: TSnake:ChangeDirection
   Purpose: Changes heading, forbidding 180° reversals.
   --------------------------------------------------------------------- */
METHOD ChangeDirection( nNewDir ) CLASS TSnake

   LOCAL lOpposite := .F.

   DO CASE
   CASE nNewDir == DIR_UP    .AND. ::nDirection == DIR_DOWN
      lOpposite := .T.
   CASE nNewDir == DIR_DOWN  .AND. ::nDirection == DIR_UP
      lOpposite := .T.
   CASE nNewDir == DIR_LEFT  .AND. ::nDirection == DIR_RIGHT
      lOpposite := .T.
   CASE nNewDir == DIR_RIGHT .AND. ::nDirection == DIR_LEFT
      lOpposite := .T.
   ENDCASE

   IF ! lOpposite
      ::nDirection := nNewDir
   ENDIF

RETURN NIL

/* ---------------------------------------------------------------------
   Method: TSnake:CollidesWithSelf
   Purpose: Returns .T. if head overlaps any body segment.
   --------------------------------------------------------------------- */
METHOD CollidesWithSelf() CLASS TSnake

   LOCAL nI
   LOCAL oHead := ::GetHead()

   FOR nI := 2 TO Len( ::aBody )
      IF HB_IsObject( ::aBody[ nI ] ) .AND. oHead:Equals( ::aBody[ nI ] )
         RETURN .T.
      ENDIF
   NEXT

RETURN .F.

/* ---------------------------------------------------------------------
   Method: TSnake:CollidesWith
   Purpose: Returns .T. if any body segment matches oCoord.
            Includes defensive check to prevent BASE/1004.
   --------------------------------------------------------------------- */
METHOD CollidesWith( oCoord ) CLASS TSnake

   LOCAL nI

   IF ! HB_IsObject( oCoord )
      RETURN .F.
   ENDIF

   FOR nI := 1 TO Len( ::aBody )
      IF HB_IsObject( ::aBody[ nI ] ) .AND. ::aBody[ nI ]:Equals( oCoord )
         RETURN .T.
      ENDIF
   NEXT

RETURN .F.