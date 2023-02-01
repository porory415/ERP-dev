*&---------------------------------------------------------------------*
*& Include          ZSAMPLE4_I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_0100 INPUT.

  CASE gv_okcode.
    WHEN 'BACK' OR 'EXIT' OR 'CANCEL'.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CASE gv_okcode.

    WHEN 'REFRESH'.
      CLEAR:  gv_okcode.
      PERFORM refresh_grid.
    WHEN 'SAVE'.
      CLEAR:  gv_okcode.
      PERFORM save_mode.
    WHEN 'MOD'.
      CLEAR: gv_okcode.
      PERFORM change_mode.
    WHEN 'ADD_ROW'.
      gs_data-mark = 'I'.
      CLEAR: gv_okcode.
      PERFORM add_row.
    WHEN 'DEL_ROW'.
      CLEAR: gv_okcode.
      PERFORM del_row.

  ENDCASE.

ENDMODULE.