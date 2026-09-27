/*
 BadaSystem
 Program       : snake_harbour
 Module        : main.prg
 Compiler      : Harbour Win32 Console
 Author        : Marcos Jarrín
 Email         : marvijarrin@gmail.com
 Website       : badasystem.com
 Date          : 26/09/2026
 Update        : 27/09/2026
 Rev           : 1.0
 SPDX-License-Identifier: MIT

 Description:
   Entry point for the Snake Harbour terminal game.
   Initializes codepage and launches the TSnakeGame orchestrator.

*/

#include "hbclass.ch"

/* =====================================================================
   Procedure: Main
   Purpose: Mandatory entry point.
   ===================================================================== */
PROCEDURE Main()

   LOCAL oGame

   HB_SetCodePage( "UTF8" )
   SET CURSOR OFF
   SET ECHO OFF
   SET WRAP ON

   CLS

   oGame := TSnakeGame():New()
   oGame:Run()

   SET CURSOR ON
   CLS

   QOut( "Thanks for playing Snake Harbour! - BadaSystem 2026" )

RETURN