*&---------------------------------------------------------------------*
*& Include          ZC2MMR2003_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form set_fcat_layout
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_fcat_layout .

    gs_layout-zebra       = 'X'.
    gs_layout-sel_mode    = 'D'.
    gs_layout-cwidth_opt  = 'X'.
    gs_layout-no_toolbar  = 'X'.
    gs_layout-ctab_fname = 'COLOR'.
  
    PERFORM set_fcat USING :
          ' '   'STATUS'     '상태'     'ZTC2MM2007'   'STATUS'   ' '  7  'C',
          ' '   'PURCYM'      ' '      'ZTC2MM2007'   'PURCYM'   ' '  7  'C',
          ' '   'VENDORC'     ' '      'ZTC2MM2007'   'VENDORC'  ' '  7  'C',
          ' '   'PURCTP'      ' '      'ZTC2MM2007'   'PURCTP'   'X' 12  'R',
          ' '   'CURRENCY'    ' '      'ZTC2MM2007'   'CURRENCY' ' '  5  'C',
          ' '   'RESPRID'     ' '      'ZTC2MM2007'   'RESPRID'  ' '  7  'C',
          ' '   'PURCFDT'     ' '      'ZTC2MM2007'   'PURCFDT'  ' '  9  'C'.
  
    PERFORM set_fcat_sort USING:
          '1' 'PURCYM' 'X' 'X'.
  
  
  ENDFORM.
  *&---------------------------------------------------------------------*
  *& Form set_fcat
  *&---------------------------------------------------------------------*
  *& text
  *&---------------------------------------------------------------------*
  *&      --> P_
  *&      --> P_
  *&      --> P_
  *&      --> P_
  *&      --> P_
  *&---------------------------------------------------------------------*
  FORM set_fcat  USING  pv_key pv_field pv_text pv_ref_table pv_ref_feild pv_sum pv_length pv_just.
  
    gs_fcat-key       = pv_key.
    gs_fcat-fieldname = pv_field.
    gs_fcat-coltext   = pv_text.
    gs_fcat-ref_table = pv_ref_table.
    gs_fcat-ref_field = pv_ref_feild.
    gs_fcat-do_sum    = pv_sum.
    gs_fcat-outputlen = pv_length.
    gs_fcat-just      = pv_just.
  
    CASE pv_field.
      WHEN 'PURCTP'.
        gs_fcat-cfieldname = 'CURRENCY'.
        gs_fcat-hotspot = 'X'.
      WHEN OTHERS.
        gs_fcat-hotspot = ''.
    ENDCASE.
  
    APPEND gs_fcat TO gt_fcat.
  
  ENDFORM.
  *&---------------------------------------------------------------------*
  *& Form display_screen
  *&---------------------------------------------------------------------*
  *& text
  *&---------------------------------------------------------------------*
  *& -->  p1        text
  *& <--  p2        text
  *&---------------------------------------------------------------------*
  FORM display_screen .
  
    IF gcl_container IS NOT BOUND.
  
      CREATE OBJECT gcl_container
        EXPORTING
          container_name = 'GCL_CONTAINER'.
  
      CREATE OBJECT gcl_grid
        EXPORTING
          i_parent = gcl_container.
  
      gs_variant-report = sy-repid.
  
      IF gcl_handler IS NOT BOUND.
        CREATE OBJECT gcl_handler.
      ENDIF.
  
      CLEAR gs_layout-cwidth_opt.
  
      SET HANDLER : gcl_handler->handle_hotspot FOR gcl_grid.
  
      CALL METHOD gcl_grid->set_table_for_first_display
        EXPORTING
          is_variant      = gs_variant
          i_save          = 'A'
          i_default       = 'X'
          is_layout       = gs_layout
        CHANGING
          it_outtab       = gt_data
          it_fieldcatalog = gt_fcat
          it_sort         = gt_sort.
  
    ENDIF.
  
  
  ENDFORM.
  *&---------------------------------------------------------------------*
  *& Form SET_INFO
  *&---------------------------------------------------------------------*
  *& text
  *&---------------------------------------------------------------------*
  *& -->  p1        text
  *& <--  p2        text
  *&---------------------------------------------------------------------*
  FORM set_info .
  
    gv_plant = '1000'.
    gv_ddzid = sy-uname.
  
  ENDFORM.
  *&---------------------------------------------------------------------*
  *& Form get_data
  *&---------------------------------------------------------------------*
  *& text
  *&---------------------------------------------------------------------*
  *& -->  p1        text
  *& <--  p2        text
  *&---------------------------------------------------------------------*
  FORM get_data .
  
    DATA : lv_tabix TYPE sy-tabix,
           ls_color TYPE lvc_s_scol.
  
    CLEAR   : gs_data.
    REFRESH : gt_data.
  
    IF gv_vendcd IS INITIAL.
  *    SELECT *
      SELECT statflag cmpnc plant purcym vendorc purctp currency purcfdt resprid
      INTO CORRESPONDING FIELDS OF TABLE gt_data
      FROM ztc2mm2007
      WHERE purcym = gv_purcym
        AND ( statflag = '14' OR statflag = '17').
  
    ELSEIF gv_purcym IS INITIAL.
  *    SELECT *
      SELECT statflag cmpnc plant purcym vendorc purctp currency purcfdt resprid
      INTO CORRESPONDING FIELDS OF TABLE gt_data
      FROM ztc2mm2007
      WHERE vendorc = gv_vendcd
        AND ( statflag = '14' OR statflag = '17').
  
    ELSE.
  *    SELECT *
      SELECT statflag cmpnc plant purcym vendorc purctp currency purcfdt resprid
      INTO CORRESPONDING FIELDS OF TABLE gt_data
      FROM ztc2mm2007
      WHERE vendorc = gv_vendcd
       AND  purcym = gv_purcym
       AND  ( statflag = '14' OR statflag = '17').
    ENDIF.
  
    LOOP AT gt_data INTO gs_data.
      lv_tabix = sy-tabix.
  
      CASE gs_data-statflag.
        WHEN '13'.
          gs_data-status       = '입고대기'.
          ls_color-fname       = 'STATUS'.
          ls_color-color-col   = '3'.
          ls_color-color-int   = '0'.
          ls_color-color-inv   = '0'.
  
          APPEND ls_color TO gs_data-color.
  
        WHEN '14'.
          gs_data-status       = '입고완료'.
          ls_color-fname       = 'STATUS'.
          ls_color-color-col   = '7'.
          ls_color-color-int   = '0'.
          ls_color-color-inv   = '0'.
  
          APPEND ls_color TO gs_data-color.
  
        WHEN '15'.
          gs_data-status       = '입고지연'.
          ls_color-fname       = 'STATUS'.
          ls_color-color-col   = '5'.
          ls_color-color-int   = '0'.
          ls_color-color-inv   = '0'.
  
          APPEND ls_color TO gs_data-color.
  
        WHEN '17'.
          gs_data-status       = '매입확정'.
          ls_color-fname       = 'STATUS'.
          ls_color-color-col   = '5'.
          ls_color-color-int   = '0'.
          ls_color-color-inv   = '0'.
  
          APPEND ls_color TO gs_data-color.
  
      ENDCASE.
  
      MODIFY gt_data FROM gs_data INDEX lv_tabix
      TRANSPORTING status color.
  
    ENDLOOP.
  
  ENDFORM.
  *&---------------------------------------------------------------------*
  *& Form set_fcat_layout2
  *&---------------------------------------------------------------------*
  *& text
  *&---------------------------------------------------------------------*
  *& -->  p1        text
  *& <--  p2        text
  *&---------------------------------------------------------------------*
  FORM set_fcat_layout2 .
  
    gs_layout2-zebra       = 'X'.
    gs_layout2-sel_mode    = 'D'.
    gs_layout2-cwidth_opt  = 'X'.
    gs_layout2-no_toolbar  = 'X'.
    gs_layout2-ctab_fname = 'COLOR'.
  
    PERFORM set_fcat2 USING :
  
          'X'   'STATUS'     '상태'   ''             ''          ' '  7  'C',
          'X'   'PURCORNB'    ' '   'ZTC2MM2004'   'PURCORNB'   ' ' 10  'C',
          ' '   'VENDORC'     ' '   'ZTC2MM2004'   'VENDORC'    ' '  7  'C',
          ' '   'ORPDDT'      ' '   'ZTC2MM2004'   'INSTRDT'    ' '  8  'C',
          ' '   'INSTRDD'     ' '   'ZTC2MM2004'   'INSTRDD'    ' '  8  'C',
          ' '   'PURCTP'      ' '   'ZTC2MM2004'   'PURCTP'     'X'  10 'R',
          ' '   'CURRENCY'    ' '   'ZTC2MM2004'   'CURRENCY'   ' '  5  'L'.
  
  ENDFORM.
  *&---------------------------------------------------------------------*
  *& Form display_screen2
  *&---------------------------------------------------------------------*
  *& text
  *&---------------------------------------------------------------------*
  *& -->  p1        text
  *& <--  p2        text
  *&---------------------------------------------------------------------*
  FORM display_screen2 .
  
    IF gcl_container2 IS NOT BOUND.
  
      CREATE OBJECT gcl_container2
        EXPORTING
          container_name = 'GCL_CONTAINER2'.
  
      CREATE OBJECT gcl_grid2
        EXPORTING
          i_parent = gcl_container2.
  
      gs_variant-report = sy-repid.
  
      IF gcl_handler IS NOT BOUND.
        CREATE OBJECT gcl_handler.
      ENDIF.
  
      SET HANDLER : gcl_handler->handle_hotspot2 FOR gcl_grid2.
  
      CLEAR gs_layout2-cwidth_opt.
  
      CALL METHOD gcl_grid2->set_table_for_first_display
        EXPORTING
          is_variant      = gs_variant2
          i_save          = 'A'
          i_default       = 'X'
          is_layout       = gs_layout2
        CHANGING
          it_outtab       = gt_data2
          it_fieldcatalog = gt_fcat2.
  
    ENDIF.
  
  ENDFORM.
  *&---------------------------------------------------------------------*
  *& Form set_fcat2
  *&---------------------------------------------------------------------*
  *& text
  *&---------------------------------------------------------------------*
  *&      --> P_
  *&      --> P_
  *&      --> P_
  *&      --> P_
  *&      --> P_
  *&---------------------------------------------------------------------*
  FORM set_fcat2  USING  pv_key pv_field pv_text pv_ref_table pv_ref_field pv_sum pv_length pv_just.
  
    gs_fcat2-key       = pv_key.
    gs_fcat2-fieldname = pv_field.
    gs_fcat2-coltext   = pv_text.
    gs_fcat2-ref_table = pv_ref_table.
    gs_fcat2-ref_field = pv_ref_field.
    gs_fcat2-do_sum    = pv_sum.
    gs_fcat2-outputlen = pv_length.
    gs_fcat2-just      = pv_just.
  
    CASE pv_field.
      WHEN 'PURCTP'.
        gs_fcat2-cfieldname = 'CURRENCY'.
      WHEN 'PURCORNB'.
        gs_fcat2-hotspot = 'X'.
    ENDCASE.
  
    APPEND gs_fcat2 TO gt_fcat2.
    CLEAR  gs_fcat2.
  
  ENDFORM.
  
  FORM set_fcat_sort USING sv_spos sv_field sv_up sv_subtot.
  
    gs_sort-spos      = sv_spos.
    gs_sort-fieldname = sv_field.
    gs_sort-up        = sv_up.
    gs_sort-subtot    = sv_subtot.
  
    APPEND gs_sort TO gt_sort.
  ENDFORM.
  
  FORM refresh_grid .
    gs_stable-row = 'X'.
    gs_stable-col = 'X'.
  
    CALL METHOD gcl_grid->refresh_table_display
      EXPORTING
        is_stable      = gs_stable
        i_soft_refresh = space.
  
  ENDFORM.
  
  FORM refresh_grid2 .
    gs_stable2-row = 'X'.
    gs_stable2-col = 'X'.
  
    CALL METHOD gcl_grid2->refresh_table_display
      EXPORTING
        is_stable      = gs_stable2
        i_soft_refresh = space.
  ENDFORM.
  
  FORM set_data .
  
    DATA : lv_tabix TYPE sy-tabix,
           ls_color TYPE lvc_s_scol.
  
    CLEAR   : gs_data.
    REFRESH : gt_data.
  
    SELECT *
      INTO CORRESPONDING FIELDS OF TABLE gt_data
      FROM ztc2mm2007 AS a
       WHERE ( a~statflag = '14' OR a~statflag = '17' )
         AND purctp <> '0'.
  
    LOOP AT gt_data INTO gs_data.
      lv_tabix = sy-tabix.
  
      CASE gs_data-statflag.
  
        WHEN '14'.
          gs_data-status       = '입고완료'.
          ls_color-fname       = 'STATUS'.
          ls_color-color-col   = '7'.
          ls_color-color-int   = '0'.
          ls_color-color-inv   = '0'.
  
          APPEND ls_color TO gs_data-color.
  
        WHEN '17'.
          gs_data-status       = '매입확정'.
          ls_color-fname       = 'STATUS'.
          ls_color-color-col   = '5'.
          ls_color-color-int   = '0'.
          ls_color-color-inv   = '0'.
  
          APPEND ls_color TO gs_data-color.
  
      ENDCASE.
  
      MODIFY gt_data FROM gs_data INDEX lv_tabix
      TRANSPORTING status color.
  
    ENDLOOP.
  
    SORT gt_data BY vendorc ASCENDING.
  
  ENDFORM.
  *&---------------------------------------------------------------------*
  *& Form handle_hotspot
  *&---------------------------------------------------------------------*
  *& text
  *&---------------------------------------------------------------------*
  *&      --> E_ROW_ID
  *&      --> E_COLUMN_ID
  *&---------------------------------------------------------------------*
  FORM handle_hotspot  USING    ps_row_id     TYPE lvc_s_row
                                ps_column_id  TYPE lvc_s_col.
  
    READ TABLE gt_data INTO gs_data INDEX ps_row_id-index.
  
    IF sy-subrc <> 0.
      EXIT.
    ENDIF.
  
  
    PERFORM get_data2 USING gs_data-purcym gs_data-vendorc.
  ENDFORM.
  *&---------------------------------------------------------------------*
  *& Form get_data2
  *&---------------------------------------------------------------------*
  *& text
  *&---------------------------------------------------------------------*
  *&      --> GS_DATA_PURCYM
  *&      --> GS_DATA_VENDCD
  *&---------------------------------------------------------------------*
  FORM get_data2  USING    pv_purcym
                           pv_vendorc.
  
    DATA : lv_tabix TYPE sy-tabix,
           ls_color TYPE lvc_s_scol.
  
    CLEAR   : gs_data2.
    REFRESH : gt_data2.
  
      SELECT *
      FROM ztc2mm2004
      INTO CORRESPONDING FIELDS OF TABLE gt_data2
      WHERE purcym  = pv_purcym
        AND vendorc = pv_vendorc
        AND delflag <> 'X'
        AND ( statflag = '14' OR statflag = '17' ). "OR statflag = '18').
  
    LOOP AT gt_data2 INTO gs_data2.
      lv_tabix = sy-tabix.
  
      CASE gs_data2-statflag.
  
        WHEN '14'.
          gs_data2-status       = '입고완료'.
          ls_color-fname       = 'STATUS'.
          ls_color-color-col   = '7'.
          ls_color-color-int   = '0'.
          ls_color-color-inv   = '0'.
  
          APPEND ls_color TO gs_data2-color.
  
        WHEN '17'.
          gs_data2-status      = '매입확정'.
          ls_color-fname       = 'STATUS'.
          ls_color-color-col   = '5'.
          ls_color-color-int   = '0'.
          ls_color-color-inv   = '0'.
  
          APPEND ls_color TO gs_data2-color.
  
      ENDCASE.
  
      MODIFY gt_data2 FROM gs_data2 INDEX lv_tabix
      TRANSPORTING status color.
  
    ENDLOOP.
  
    PERFORM refresh_grid2.
  
  ENDFORM.
  *&---------------------------------------------------------------------*
  *& Form handle_hotspot2
  *&---------------------------------------------------------------------*
  *& text
  *&---------------------------------------------------------------------*
  *&      --> E_ROW_ID
  *&      --> E_COLUMN_ID
  *&---------------------------------------------------------------------*
  FORM handle_hotspot2  USING    ps_row_id2     TYPE lvc_s_row
                                 ps_column_id2  TYPE lvc_s_col.
  
    READ TABLE gt_data2 INTO gs_data2 INDEX ps_row_id2-index.
  
    IF sy-subrc <> 0.
      EXIT.
    ENDIF.
  
  
    PERFORM get_data3 USING gs_data2-purcornb.
    CALL SCREEN '0101' STARTING AT 10 3.
  
  ENDFORM.
  *&---------------------------------------------------------------------*
  *& Form get_data3
  *&---------------------------------------------------------------------*
  *& text
  *&---------------------------------------------------------------------*
  *&      --> GS_DATA2_PURCYM
  *&      --> GS_DATA2_VENDCD
  *&---------------------------------------------------------------------*
  FORM get_data3  USING    pv_data2_purcornb.
  
    CLEAR : gs_data3.
    REFRESH : gt_data3.
  
    SELECT purcornb a~matrc b~matrnm a~vendorc purcym purcp a~unit instq falutyq
      INTO CORRESPONDING FIELDS OF TABLE gt_data3
      FROM ztc2mm2005 AS a
      INNER JOIN ztc2md2006 AS b
      ON a~matrc = b~matrc
      WHERE purcornb = pv_data2_purcornb.
  
  ENDFORM.
  *&---------------------------------------------------------------------*
  *&      Module  USER_COMMAND_0101  INPUT
  *&---------------------------------------------------------------------*
  *       text
  *----------------------------------------------------------------------*
  MODULE user_command_0101 INPUT.
  
    CASE gv_okcode.
      WHEN 'CLOSE'.
        CLEAR gv_okcode.
        LEAVE TO SCREEN 0.
    ENDCASE.
  
  ENDMODULE.
  *&---------------------------------------------------------------------*
  *& Form set_fcat_layout3
  *&---------------------------------------------------------------------*
  *& text
  *&---------------------------------------------------------------------*
  *& -->  p1        text
  *& <--  p2        text
  *&---------------------------------------------------------------------*
  FORM set_fcat_layout3 .
  
    gs_layout3-zebra       = 'X'.
    gs_layout3-sel_mode    = 'D'.
    gs_layout3-cwidth_opt  = 'X'.
    gs_layout3-no_toolbar  = 'X'.
  
    PERFORM set_fcat3 USING :
  
          'X'   'PURCORNB'    ' '   'ZTC2MM2005'   'PURCORNB'  12  'C',
          ' '   'VENDORC'     ' '   'ZTC2MM2005'   'VENDORC'    7  'C',
          ' '   'MATRC'       ' '   'ZTC2MM2005'   'MATRC'      8  'C',
          ' '   'MATRNM'      ' '   'ZTC2MD2006'   'MATRNM'    12  'C',
          ' '   'PURCYM'      ' '   'ZTC2MM2005'   'PURCYM'     8  'C',
          ' '   'PURCP'       ' '   'ZTC2MM2005'   'PURCP'      6  'C',
          ' '   'UNIT'        ' '   'ZTC2MM2005'   'UNIT'       6  'C',
          ' '   'INSTQ'       ' '   'ZTC2MM2005'   'INSTQ'      6  'C',
          ' '   'FALUTYQ'     ' '   'ZTC2MM2005'   'FALUTYQ'    6  'C'.
  
  ENDFORM.
  *&---------------------------------------------------------------------*
  *& Module DISPLAY_SCREEN3 OUTPUT
  *&---------------------------------------------------------------------*
  *&
  *&---------------------------------------------------------------------*
  MODULE display_screen3 OUTPUT.
  
    IF gcl_container3 IS NOT BOUND.
  
      CREATE OBJECT gcl_container3
        EXPORTING
          container_name = 'GCL_CONTAINER3'.
  
      CREATE OBJECT gcl_grid3
        EXPORTING
          i_parent = gcl_container3.
  
      gs_variant-report = sy-repid.
  
      CLEAR gs_layout3-cwidth_opt.
  
      CALL METHOD gcl_grid3->set_table_for_first_display
        EXPORTING
          is_variant      = gs_variant3
          i_save          = 'A'
          i_default       = 'X'
          is_layout       = gs_layout3
        CHANGING
          it_outtab       = gt_data3
          it_fieldcatalog = gt_fcat3.
  
    ENDIF.
  
    PERFORM refresh_grid3.
  
  ENDMODULE.
  *&---------------------------------------------------------------------*
  *& Form set_fcat3
  *&---------------------------------------------------------------------*
  *& text
  *&---------------------------------------------------------------------*
  *&      --> P_
  *&      --> P_
  *&      --> P_
  *&      --> P_
  *&      --> P_
  *&---------------------------------------------------------------------*
  FORM set_fcat3  USING  pv_key pv_field pv_text pv_ref_table pv_ref_field pv_length pv_just.
  
    gs_fcat3-key       = pv_key.
    gs_fcat3-fieldname = pv_field.
    gs_fcat3-coltext   = pv_text.
    gs_fcat3-ref_table = pv_ref_table.
    gs_fcat3-ref_field = pv_ref_field.
    gs_fcat3-outputlen = pv_length.
    gs_fcat3-just      = pv_just.
  
    APPEND gs_fcat3 TO gt_fcat3.
    CLEAR  gs_fcat3.
  
  ENDFORM.
  *&---------------------------------------------------------------------*
  *& Form refresh_grid3
  *&---------------------------------------------------------------------*
  *& text
  *&---------------------------------------------------------------------*
  *& -->  p1        text
  *& <--  p2        text
  *&---------------------------------------------------------------------*
  FORM refresh_grid3 .
  
    gs_stable3-row = 'X'.
    gs_stable3-col = 'X'.
  
    CALL METHOD gcl_grid3->refresh_table_display
      EXPORTING
        is_stable      = gs_stable3
        i_soft_refresh = space.
  
  ENDFORM.
  *&---------------------------------------------------------------------*
  *& Form confirm_data
  *&---------------------------------------------------------------------*
  *& text
  *&---------------------------------------------------------------------*
  *& -->  p1        text
  *& <--  p2        text
  *&---------------------------------------------------------------------*
  FORM confirm_data .
  
    DATA : lv_tabix TYPE sy-tabix,
           ls_color TYPE lvc_s_scol.
  
    DATA : ls_data  TYPE ztc2mm2007,
           lt_data  LIKE TABLE OF ls_data,
           ls_data2 TYPE ztc2mm2004,
           lt_data2 LIKE TABLE OF ls_data2.
  
    DATA : lv_answer TYPE c LENGTH 1,
           lv_purcym TYPE ztc2mm2004-purcym.
  
  
    CLEAR   : gs_row, ls_color, ls_data.
    REFRESH : gt_rows, lt_data.
  
    CALL METHOD gcl_grid->get_selected_rows
      IMPORTING
        et_index_rows = gt_rows.
  
  
    IF gs_data2 IS INITIAL.
      MESSAGE s005 WITH TEXT-m05 DISPLAY LIKE 'E'.
      ROLLBACK WORK.
    ELSE.
  
  
      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          titlebar              = '매입확정'
          text_question         = '매입을 확정하시겠습니까?'
          text_button_1         = 'YES'
          icon_button_1         = 'ICON_SYSTEM_OKAY'
          text_button_2         = 'NO'
          icon_button_2         = 'ICON_SYSTEM_CANCEL'
          display_cancel_button = ''
        IMPORTING
          answer                = lv_answer
        EXCEPTIONS
          text_not_found        = 1
          OTHERS                = 2.
      .
      IF lv_answer = 1.
        SELECT *
          INTO CORRESPONDING FIELDS OF TABLE lt_data
          FROM ztc2mm2007.
  
        IF gt_rows IS INITIAL.
          MESSAGE s005 WITH TEXT-m01 DISPLAY LIKE 'E'.
          EXIT.
        ENDIF.
  
        LOOP AT gt_rows INTO gs_row.
          READ TABLE gt_data INTO gs_data INDEX gs_row-index.
  
          lv_tabix = sy-tabix.
          lv_purcym = gs_data-purcym.
  
          CASE gs_data-statflag.
            WHEN '14'."입고완료
              gs_data-statflag     = '17'. "매입확정
              gs_data-status       = '매입확정'.
              ls_color-fname       = 'STATUS'.
              ls_color-color-col   = '5'.
              ls_color-color-int   = '0'.
              ls_color-color-inv   = '0'.
              modify table gs_data-color from ls_color.
  
             gs_data-resprid = sy-uname.
          ENDCASE.
  
          MOVE-CORRESPONDING gs_data TO ls_data.
          APPEND ls_data TO lt_data.
  
          MODIFY gt_data FROM gs_data INDEX lv_tabix TRANSPORTING statflag status resprid color color.
  
        ENDLOOP.
  
  
  
  *********************************************************************************
                                                              "mm2004 테이블
  
        SELECT *
          FROM ztc2mm2004
          INTO CORRESPONDING FIELDS OF TABLE lt_data2.
  
        LOOP AT gt_data2 INTO gs_data2.
  
          lv_tabix = sy-tabix.
  
          CASE gs_data2-statflag.
            WHEN '14'.
              gs_data2-statflag     = '17'. "매입확정
              gs_data2-status       = '매입확정'.
              gs_data2-resprid      = sy-uname.
              ls_color-fname       = 'STATUS'.
              ls_color-color-col   = '5'.
              ls_color-color-int   = '0'.
              ls_color-color-inv   = '0'.
              modify table gs_data2-color from  ls_color.
  
  
              gs_data2-resprid = sy-uname.
              gs_data2-purcym  = lv_purcym.
  
          ENDCASE.
          MOVE-CORRESPONDING gs_data2 TO ls_data2.
          APPEND ls_data2 TO lt_data2.
  
          MODIFY gt_data2 FROM gs_data2 INDEX lv_tabix TRANSPORTING statflag status resprid color ormfdt purcym color.
  
  
        ENDLOOP.
  
  
  ************************************************************************************
  
        LOOP AT lt_data INTO ls_data.
          READ TABLE gt_data INTO gs_data
             WITH KEY  vendorc  = ls_data-vendorc
                       purcym  = ls_data-purcym.
  
          IF sy-subrc = 0.
            IF gs_data-statflag = '17'.
  
  
              ls_data-statflag = '17'.
              ls_data-resprid  = sy-uname.
              ls_data-purcfdt  = sy-datum.
              ls_data-purcym = gs_data-purcym.
              ls_data-resprid = gs_data-resprid.
  
  
           MOVE-CORRESPONDING ls_data TO gs_data.
  
            ENDIF.
  
           MODIFY table gt_data FROM gs_data.
  
          ENDIF.
        ENDLOOP.
  
        APPEND ls_data TO lt_data.
  
  
        CALL METHOD gcl_grid->check_changed_data.
  
        MODIFY ztc2mm2007 FROM TABLE lt_data.
  
        MODIFY ztc2mm2004 FROM TABLE lt_data2.
  
        PERFORM get_data.
        PERFORM set_data.
  
  *************************************************************
        PERFORM refresh_grid2.
        PERFORM refresh_grid.
  
  
        IF sy-dbcnt > 0.
          COMMIT WORK AND WAIT.
          MESSAGE s005 WITH TEXT-m02.
        ELSE.
          ROLLBACK WORK.
          MESSAGE s005 WITH TEXT-m03 DISPLAY LIKE 'E'.
        ENDIF.
  
  
      ELSEIF lv_answer = 2.
        MESSAGE s005 WITH TEXT-m04 DISPLAY LIKE 'W'.
  
  
      ENDIF.
    ENDIF.
  ENDFORM.
  *&---------------------------------------------------------------------*
  *& Form f4_vendorc
  *&---------------------------------------------------------------------*
  *& text
  *&---------------------------------------------------------------------*
  *& -->  p1        text
  *& <--  p2        text
  *&---------------------------------------------------------------------*
  FORM f4_vendorc .
  
    DATA : BEGIN OF ls_value,
             vendorc TYPE ztc2md2005-vendorc,
             vendorn TYPE ztc2md2005-vendorn,
           END OF ls_value,
  
           lt_value LIKE TABLE OF ls_value.
  
    REFRESH lt_value.
  
    SELECT vendorc vendorn
      INTO CORRESPONDING FIELDS OF TABLE lt_value
      FROM ztc2md2005
     WHERE vendorc BETWEEN '001' AND '007'.
  
  
    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        retfield     = 'VENDORC'
        dynpprog     = sy-repid
        dynpnr       = sy-dynnr
        dynprofield  = 'GV_VENDORC'
        window_title = '거래처 정보'
        value_org    = 'S'
      TABLES
        value_tab    = lt_value.
  
  ENDFORM.