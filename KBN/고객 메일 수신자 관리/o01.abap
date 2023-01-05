*&---------------------------------------------------------------------*
*& Include          ZKEDU0005_O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
 SET PF-STATUS 'T0100'.
 SET TITLEBAR 'S0100'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module DISPLAY_ALV_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE display_alv_0100 OUTPUT.

  IF go_ccont IS INITIAL.
    PERFORM create_container.
    PERFORM create_instance.
    PERFORM set_grid_layout.
    PERFORM set_grid_exclude.
    PERFORM set_grid_fieldcat.
    PERFORM set_event_handle.
    PERFORM display_grid.
  ELSE.
    PERFORM refresh_grid.
  ENDIF.

ENDMODULE.