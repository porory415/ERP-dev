*&---------------------------------------------------------------------*
*& Include          ZSAMPLE4_O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'S0100'.
  SET TITLEBAR 'T0100'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module GET_DATA OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE get_data OUTPUT.

  gv_date = sy-datum.
  gv_time = sy-timlo.
  gv_id   = sy-uname.

  PERFORM get_data.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module SET_TOOLBAR OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE set_toolbar OUTPUT.
  PERFORM set_toolbar.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module DISPLAY_SCREEN OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE display_screen OUTPUT.

  IF go_container IS NOT BOUND.
    PERFORM display_screen.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module SET_FCAT_LAYOUT OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE set_fcat_layout OUTPUT.
  IF gt_fcat IS INITIAL.
    PERFORM set_fcat_layout.
  ENDIF.

ENDMODULE.