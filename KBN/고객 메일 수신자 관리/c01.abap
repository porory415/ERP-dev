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
        
    ENDCLASS.
*&---------------------------------------------------------------------*
*& Class (Implementation) lcl_event_handler
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
    CLASS lcl_event_handler IMPLEMENTATION.
    
        METHOD handle_data_changed.
        PERFORM handle_data_changed using er_data_changed.
        ENDMETHOD.
    
    ENDCLASS.