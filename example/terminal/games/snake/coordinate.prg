/*
 BadaSystem
 Program       : snake_harbour
 Module        : coordinate.prg
 Compiler      : Harbour Win32 Console
 Author        : Marcos Jarrín
 Email         : marvijarrin@gmail.com
 Website       : badasystem.com
 Date          : 26/09/2026
 Update        : 28/09/2026
 Rev           : 1.0
 SPDX-License-Identifier: MIT

 Description:
   Value object representing a 2D coordinate (row, col) on the
   terminal screen. Immutable-style: operations return new instances.

*/

#include "hbclass.ch"

/* =====================================================================
   Class: TCoordinate
   Purpose: Value object for (row, col) positions.
   ===================================================================== */
CLASS TCoordinate

   DATA nRow
   DATA nCol

   METHOD New( nRow, nCol ) CONSTRUCTOR
   METHOD Clone()
   METHOD Equals( oOther )
   METHOD MoveUp()
   METHOD MoveDown()
   METHOD MoveLeft()
   METHOD MoveRight()
   METHOD IsValid( nMaxRow, nMaxCol )

ENDCLASS

/* ---------------------------------------------------------------------
   Method: TCoordinate:New
   Purpose: Constructor.
   --------------------------------------------------------------------- */
METHOD New( nRow, nCol ) CLASS TCoordinate

   IF nRow == NIL
      nRow := 1
   ENDIF
   IF nCol == NIL
      nCol := 1
   ENDIF

   ::nRow := Int( nRow )
   ::nCol := Int( nCol )

RETURN Self

/* ---------------------------------------------------------------------
   Method: TCoordinate:Clone
   Purpose: Returns a new TCoordinate with same values.
   --------------------------------------------------------------------- */
METHOD Clone() CLASS TCoordinate
RETURN TCoordinate():New( ::nRow, ::nCol )

/* ---------------------------------------------------------------------
   Method: TCoordinate:Equals
   Purpose: Compares with another coordinate. Prevents BASE/1004.
   --------------------------------------------------------------------- */
METHOD Equals( oOther ) CLASS TCoordinate

   IF oOther == NIL .OR. ! HB_IsObject( oOther )
      RETURN .F.
   ENDIF

RETURN ( ::nRow == oOther:nRow .AND. ::nCol == oOther:nCol )

/* ---------------------------------------------------------------------
   Method: TCoordinate:MoveUp / Down / Left / Right
   Purpose: Returns a NEW coordinate shifted by one cell.
   --------------------------------------------------------------------- */
METHOD MoveUp()    CLASS TCoordinate
RETURN TCoordinate():New( ::nRow - 1, ::nCol )

METHOD MoveDown()  CLASS TCoordinate
RETURN TCoordinate():New( ::nRow + 1, ::nCol )

METHOD MoveLeft()  CLASS TCoordinate
RETURN TCoordinate():New( ::nRow, ::nCol - 1 )

METHOD MoveRight() CLASS TCoordinate
RETURN TCoordinate():New( ::nRow, ::nCol + 1 )

/* ---------------------------------------------------------------------
   Method: TCoordinate:IsValid
   Purpose: Returns .T. if inside the playable area (excludes border).
   --------------------------------------------------------------------- */
METHOD IsValid( nMaxRow, nMaxCol ) CLASS TCoordinate

   IF nMaxRow == NIL
      nMaxRow := 24
   ENDIF
   IF nMaxCol == NIL
      nMaxCol := 78
   ENDIF

RETURN ( ::nRow > 1 .AND. ::nRow < nMaxRow .AND. ;
         ::nCol > 1 .AND. ::nCol < nMaxCol )