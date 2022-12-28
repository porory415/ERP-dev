*&---------------------------------------------------------------------*
*& Report ZKEDU0005
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

INCLUDE zkedu0005_top                           .  " Global Data

INCLUDE zkedu0005_s01                           .  " Selection-screen
INCLUDE zkedu0005_c01                           .  " Local Class
INCLUDE zkedu0005_o01                           .  " PBO-Modules
INCLUDE zkedu0005_i01                           .  " PAI-Modules
INCLUDE zkedu0005_f01                           .  " FORM-Routines


*----------------------------------------------------------------------*
* AT SELECTION-SCREEN OUTPUT
*----------------------------------------------------------------------*
AT SELECTION-SCREEN.
  PERFORM check_input_validation.


START-OF-SELECTION.
  PERFORM get_contact_data.
  CALL SCREEN 0100.