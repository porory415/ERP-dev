*&---------------------------------------------------------------------*
*& Include          ZSAMPLE4_C01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Class lcl_event_handler
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
CLASS lcl_event_handler DEFINITION FINAL.

    PUBLIC SECTION.
      CLASS-METHODS: handler_data_changed FOR EVENT data_changed OF cl_gui_alv_grid
        IMPORTING
          er_data_changed.
  
  ENDCLASS.
*&---------------------------------------------------------------------*
*& Class (Implementation) lcl_event_handler
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
  CLASS lcl_event_handler IMPLEMENTATION.
  
    METHOD handler_data_changed.
      PERFORM del_rows USING er_data_changed.
    ENDMETHOD.
  
  ENDCLASS.