*&---------------------------------------------------------------------*
*& Include          ZKEDU0005_I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_0100 INPUT.

  gv_saveok = gv_okcode.
  CLEAR gv_okcode.

  CASE gv_saveok.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN 'CANC'.
      LEAVE PROGRAM.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  gv_saveok = gv_okcode.
  CLEAR gv_okcode.

  CASE gv_saveok.
    WHEN 'SAVE'.
*      PERFORM check_validation TABLES gt_rows.  "validation은 중요한 기능.
*      PERFORM refresh_grid. "GRID 재조회
*      IF gv_err <> 'X'.
*        PERFORM modify_data TABLES gt_rows.
*      ELSE.
*        PERFORM refresh_grid. "GRID 재조회
*        MESSAGE e000 WITH TEXT-e17.
*        EXIT.
*      ENDIF.
  ENDCASE.


ENDMODULE.