/*
 BadaSystem
 Program       : snake_harbour
 Module        : screen.prg
 Compiler      : Harbour Win32 Console
 Author        : Marcos Jarrín
 Email         : marvijarrin@gmail.com
 Website       : badasystem.com
 Date          : 26/09/2026
 Update        : 28/09/2026
 Rev           : 1.0
 SPDX-License-Identifier: MIT

 Description:
   TScreen wraps terminal/console drawing primitives.
   Uses selective clearing to prevent flickering.
   
*/

#include "hbclass.ch"

/* ===================================================================== */
CLASS TScreen

   DATA nRows
   DATA nCols

   METHOD New( nRows, nCols ) CONSTRUCTOR
   METHOD Clear()
   METHOD ClearPlayfield()
   METHOD DrawBorder()
   METHOD DrawSnake( oSnake )
   METHOD DrawFood( oFood )
   METHOD DrawHUD( nScore, nHighScore, nLength )
   METHOD DrawAt( nRow, nCol, cChar )
   METHOD HideCursor()
   METHOD ShowCursor()

ENDCLASS

/* --------------------------------------------------------------------- */
METHOD New( nRows, nCols ) CLASS TScreen

   LOCAL nRDef
   LOCAL nCDef

   IF nRows == NIL
      nRDef := 24
   ELSE
      nRDef := nRows
   ENDIF

   IF nCols == NIL
      nCDef := 78
   ELSE
      nCDef := nCols
   ENDIF

   ::nRows := nRDef
   ::nCols := nCDef

RETURN Self

/* --------------------------------------------------------------------- */
METHOD Clear() CLASS TScreen
   CLS
RETURN NIL

/* ---------------------------------------------------------------------
   Method: TScreen:ClearPlayfield
   Purpose: Clears ONLY the interior to prevent flickering.
   --------------------------------------------------------------------- */
METHOD ClearPlayfield() CLASS TScreen

   LOCAL nR

   FOR nR := 2 TO ::nRows - 1
      @ nR, 2 SAY Space( ::nCols - 2 )
   NEXT

RETURN NIL

/* --------------------------------------------------------------------- */
METHOD HideCursor() CLASS TScreen
   SET CURSOR OFF
RETURN NIL

/* --------------------------------------------------------------------- */
METHOD ShowCursor() CLASS TScreen
   SET CURSOR ON
RETURN NIL

/* --------------------------------------------------------------------- */
METHOD DrawBorder() CLASS TScreen
   @  1,  1 TO ::nRows, ::nCols DOUBLE
RETURN NIL

/* --------------------------------------------------------------------- */
METHOD DrawAt( nRow, nCol, cChar ) CLASS TScreen
   @ nRow, nCol SAY cChar
RETURN NIL

/* --------------------------------------------------------------------- */
METHOD DrawSnake( oSnake ) CLASS TScreen

   LOCAL nI
   LOCAL oSeg
   LOCAL cChar

   FOR nI := 1 TO oSnake:Length()
      oSeg := oSnake:GetSegment( nI )
      IF HB_IsObject( oSeg )
         IF nI == 1
            cChar := "@"
         ELSE
            cChar := "*"
         ENDIF
         @ oSeg:nRow, oSeg:nCol SAY cChar
      ENDIF
   NEXT

RETURN NIL

/* --------------------------------------------------------------------- */
METHOD DrawFood( oFood ) CLASS TScreen

   LOCAL oPos

   oPos := oFood:GetPosition()
   IF HB_IsObject( oPos )
      @ oPos:nRow, oPos:nCol SAY "#"
   ENDIF

RETURN NIL

/* --------------------------------------------------------------------- */
METHOD DrawHUD( nScore, nHighScore, nLength ) CLASS TScreen

   LOCAL cLine
   LOCAL nMaxWidth

   nMaxWidth := ::nCols - 4
   cLine := " Score: " + Str( nScore, 7 ) + ;
            "  |  Length: " + Str( nLength, 3 ) + ;
            "  |  High: " + Str( nHighScore, 7 )

   cLine := PadR( cLine, nMaxWidth )
   @ ::nRows - 1, 2 SAY cLine

RETURN NIL