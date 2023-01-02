*&---------------------------------------------------------------------*
*& Include          ZKEDU0005_C01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Class lcl_event_handler
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
CLASS lcl_event_handler DEFINITION FINAL.

    PUBLIC SECTION.
      METHODS handle_data_changed
        FOR EVENT data_changed OF cl_gui_alv_grid
        IMPORTING er_data_changed.
  
      METHODS handle_data_changed_finished
        FOR EVENT data_changed_finished OF cl_gui_alv_grid
        IMPORTING et_good_cells e_modified .
  
ENDCLASS.
*&---------------------------------------------------------------------*
*& Class (Implementation) lcl_event_handler
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
CLASS lcl_event_handler IMPLEMENTATION.

METHOD handle_data_changed.
    PERFORM handle_data_changed USING er_data_changed.

ENDMETHOD.

METHOD handle_data_changed_finished.
    PERFORM handle_data_changed_finished USING et_good_cells  e_modified.
ENDMETHOD.

ENDCLASS.