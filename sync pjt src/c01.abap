*&---------------------------------------------------------------------*
*& Include          ZC2MMR2003_C01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Class lcl_event_handler
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
CLASS lcl_event_handler DEFINITION FINAL.
    PUBLIC SECTION.
     METHODS:
       handle_hotspot for EVENT hotspot_click of cl_gui_alv_grid
         IMPORTING
           e_row_id
           e_column_id,
       handle_hotspot2 for event hotspot_click of cl_gui_alv_grid
          importing
            e_row_id
            e_column_id.
   
   ENDCLASS.
   *&---------------------------------------------------------------------*
   *& Class (Implementation) lcl_event_handler
   *&---------------------------------------------------------------------*
   *&
   *&---------------------------------------------------------------------*
   CLASS lcl_event_handler IMPLEMENTATION.
     METHOD handle_hotspot.
       perform handle_hotspot using e_row_id e_column_id.
     ENDMETHOD.
     method handle_hotspot2.
       PERFORM handle_hotspot2 USING e_row_id e_column_id.
     ENDMETHOD.
   ENDCLASS.