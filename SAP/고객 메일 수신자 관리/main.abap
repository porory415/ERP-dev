*&---------------------------------------------------------------------*
*& PROGRAM ID : zkedu0005
*& Title : [OTC] 고객 출고 메일 수신자 관리
*& Created By : BNT257
*& Created On : 2022.12.19
*& Description : 영업조직에 따른 거래처 메일 수신자를 관리한다.
*&---------------------------------------------------------------------*
*MODIFICATION LOG
*&---------------------------------------------------------------------*
*& Date. Author. Description.
*&---------------------------------------------------------------------*
*& 2022.12. 19 BNT257 신규 개발
*&
*&---------------------------------------------------------------------*

INCLUDE zkedu0005_top                           .  " Global Data

INCLUDE zkedu0005_s01                           .  " Selection-screen
INCLUDE zkedu0005_c01                           .  " Local Class
INCLUDE zkedu0005_o01                           .  " PBO-Modules
INCLUDE zkedu0005_i01                           .  " PAI-Modules
INCLUDE zkedu0005_f01                           .  " FORM-Routines


*----------------------------------------------------------------------*
* AT SELECTION-SCREEN ON VALUE-REQUEST FOR
*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_vkgrp.
  PERFORM f4_pa_vkgrp.


*======================================================================*
* S T A R T - O F - S E L E C T I O N
*======================================================================*
START-OF-SELECTION.
  PERFORM check_input_validation.
  PERFORM get_contact_data.
  CALL SCREEN 0100.