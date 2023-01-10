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
    WHEN 'EXIT' OR 'CANCLE'.
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
      PERFORM check_selindex.  "어떤 라인 선택했는지 확인
      CHECK gv_err IS INITIAL.
      PERFORM check_validation TABLES gt_rows.
      IF gv_err <> 'X'.
        PERFORM modify_table TABLES gt_rows.
        PERFORM refresh_grid.
      ELSE.
        PERFORM refresh_grid.
        MESSAGE e000 WITH TEXT-e20.
      ENDIF.

    WHEN 'ADD_ROW'.
      gs_email-mark = 'I'.
      CLEAR gv_okcode.
      PERFORM add_row.

    WHEN 'DEL_ROW'.
      gs_email-mark = 'D'.
      CLEAR gv_okcode.
      PERFORM del_row.
  ENDCASE.
  
ENDMODULE.