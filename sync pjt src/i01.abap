*&---------------------------------------------------------------------*
*& Include          ZC2MMR2003_I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CASE gv_okcode.
    WHEN 'SEARCH'.
      CLEAR gv_okcode.
      PERFORM get_data.
      PERFORM refresh_grid.

    WHEN 'CONFIRM'.
      CLEAR gv_okcode.
      PERFORM confirm_data.
      PERFORM refresh_grid.
      PERFORM refresh_grid2.

    WHEN 'REFRESH'.
      CLEAR gv_okcode.
      PERFORM set_data.
      PERFORM refresh_grid.
      PERFORM refresh_grid2.
  ENDCASE.
ENDMODULE.

MODULE exit_0100 INPUT.
  LEAVE TO SCREEN 0.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  EXIT_0101  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_0101 INPUT.
  LEAVE TO SCREEN 0.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  F4_VENDORC  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE f4_vendorc INPUT.

  PERFORM f4_vendorc.

ENDMODULE.

MODULE set_vendorc INPUT.
  SELECT SINGLE vendorn
    INTO gv_input
    FROM ztc2md2005
   WHERE vendorc = gv_vendcd.
ENDMODULE.