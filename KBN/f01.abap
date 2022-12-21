*&---------------------------------------------------------------------*
*& Include          ZKEDU0005_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form get_contact_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_contact_data .

    CLEAR: gs_email.
    REFRESH: gt_email.
  
    DATA: lv_tabix TYPE sy-tabix.
*&---------------------------------------------------------------------*
*& 원본 쿼리
*& 덤프 원인 찾는 중
*&---------------------------------------------------------------------*
  
    SELECT a~vkorg a~spart a~vkgrp a~kunag b~name1 a~custmail a~custmail_2 a~custmail_3 a~kunnr a~custmail2
         a~custmail2_2 a~custmail2_3 a~salesman a~salesmail a~salesman2 a~salesmail2 a~salestel a~sendtype
         a~mailtype a~comnt
      INTO CORRESPONDING FIELDS OF TABLE gt_email
      FROM zsed0005t AS a
      INNER JOIN kna1 AS b
        ON a~kunnr = b~kunnr
      WHERE a~vkorg = pa_vkorg
        AND a~spart = pa_spart
        AND a~vkgrp = pa_vkgrp
        AND a~kunag IN so_kunag
        AND a~kunnr IN so_kunnr
         .
  
*&---------------------------------------------------------------------*
*& 임시 쿼리
*& alv 확인용
*&---------------------------------------------------------------------*
  *  SELECT *
  *    FROM zsed0005t
  *    INTO CORRESPONDING FIELDS OF TABLE gt_email
  *     WHERE vkorg = pa_vkorg
  *       OR spart = pa_spart
  *       OR vkgrp = pa_vkgrp
  *       AND kunag IN so_kunag
  *       AND kunnr IN so_kunnr.
  
  
    LOOP AT gt_email INTO gs_email.
      lv_tabix = sy-tabix.
      MODIFY gt_email FROM gs_email INDEX lv_tabix.
    ENDLOOP.
  
  ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_container
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
  FORM create_container .
  
    CREATE OBJECT go_ccont
      EXPORTING
        container_name = gv_cont_name.
  
  ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_instance
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
  FORM create_instance .
  
    CREATE OBJECT go_grid
      EXPORTING
        i_parent = go_ccont.
  
    CALL METHOD go_grid->set_ready_for_input " alv 수정 모드로 변경 (CELL Tab 쓰려면 꼭 있어야함.)
      EXPORTING
        i_ready_for_input = 1.
  
  ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_grid_layout
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
  FORM set_grid_layout .
  
    CLEAR: gs_layo.
    gs_layo-sel_mode = c_a.
    gs_layo-zebra = c_x.
    gs_layo-stylefname = 'CELLTAB'. " lvc_t_style 테이블로 선언한 변수명을 파라미터로
    gs_layo-cwidth_opt = 'X'.
  
  ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_grid_fieldcat
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
  FORM set_grid_fieldcat .
  
    PERFORM fcat_merge.
    PERFORM fcat_modify.
  
  ENDFORM.
*&---------------------------------------------------------------------*
*& Form fcat_merge
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
  FORM fcat_merge .
  
    DATA : lt_fieldcat TYPE  slis_t_fieldcat_alv,
           lt_alv_cat  TYPE TABLE OF lvc_s_fcat.
    DATA : lv_memory_id_clear TYPE string,
           lv_memory_id_hash  TYPE hash160.
  
  * CLEAR BUFFER
    CONCATENATE sy-repid 'GT_EMAIL' INTO lv_memory_id_clear.
  
    CALL FUNCTION 'CALCULATE_HASH_FOR_CHAR'
      EXPORTING
        data = lv_memory_id_clear
      IMPORTING
        hash = lv_memory_id_hash.
  
    FREE MEMORY ID lv_memory_id_hash.
  
    CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
      EXPORTING
        i_program_name     = sy-repid
        i_internal_tabname = 'GT_EMAIL'
        i_inclname         = sy-repid
      CHANGING
        ct_fieldcat        = lt_fieldcat[].
  
    CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
      EXPORTING
        it_fieldcat_alv = lt_fieldcat
      IMPORTING
        et_fieldcat_lvc = lt_alv_cat
      TABLES
        it_data         = gt_email.
  
    CALL FUNCTION 'LVC_FIELDCAT_COMPLETE'
      CHANGING
        ct_fieldcat = lt_alv_cat.
  
    REFRESH gt_fcat .
    gt_fcat[] = lt_alv_cat[].
  
  ENDFORM.
*&---------------------------------------------------------------------*
*& Form fcat_modify
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
  FORM fcat_modify .
  
    LOOP AT gt_fcat INTO gs_fcat.
  
      CASE gs_fcat-fieldname.
  
        WHEN 'VKORG'.
          gs_fcat-col_pos = 1.
          gs_fcat-coltext = TEXT-m01.
          gs_fcat-just = c_c.
  
        WHEN 'SPART'.
          gs_fcat-col_pos = 2.
          gs_fcat-coltext = TEXT-m02.
  
        WHEN 'VKGRP'.
          gs_fcat-col_pos = 3.
          gs_fcat-coltext = TEXT-m03.
          gs_fcat-just = c_c.
  
        WHEN 'KUNAG'.
          gs_fcat-col_pos = 4.
          gs_fcat-coltext = TEXT-m04.
          gs_fcat-just = c_c.
  
        WHEN 'NAME1'.
          gs_fcat-col_pos = 5.
          gs_fcat-coltext = TEXT-m05.
          gs_fcat-just = c_l.
  
        WHEN 'CUSTMAIL'.
          gs_fcat-col_pos = 6.
          gs_fcat-coltext = TEXT-m06.
          gs_fcat-just = c_c.
  
        WHEN 'CUSTMAIL_2'.
          gs_fcat-col_pos = 7.
          gs_fcat-coltext = TEXT-m07.
          gs_fcat-just = c_l.
  
        WHEN 'CUSTMAIL_3'.
          gs_fcat-col_pos = 8.
          gs_fcat-coltext = TEXT-m08.
          gs_fcat-just = c_c.
  
        WHEN 'KUNNR'.
          gs_fcat-col_pos = 9.
          gs_fcat-coltext = TEXT-m09.
          gs_fcat-just = c_c.
  
        WHEN 'CUSTMAIL2'.
          gs_fcat-col_pos = 10.
          gs_fcat-coltext = TEXT-m10.
          gs_fcat-just = c_l.
  
        WHEN 'CUSTMAIL2_2'.
          gs_fcat-col_pos = 11.
          gs_fcat-coltext = TEXT-m11.
          gs_fcat-just = c_c.
  
        WHEN 'CUSTMAIL2_3'.
          gs_fcat-col_pos = 12.
          gs_fcat-coltext = TEXT-m12.
          gs_fcat-just = c_c.
  
        WHEN 'SALESMAN'.
          gs_fcat-col_pos = 13.
          gs_fcat-coltext = TEXT-m13.
          gs_fcat-just = c_c.
  
        WHEN 'SALESMAIL'.
          gs_fcat-col_pos = 14.
          gs_fcat-coltext = TEXT-m14.
          gs_fcat-just = c_l.
  
        WHEN 'SALESMAN2'.
          gs_fcat-col_pos = 15.
          gs_fcat-coltext = TEXT-m15.
          gs_fcat-just = c_c.
  
        WHEN 'SALESMAIL2'.
          gs_fcat-col_pos = 16.
          gs_fcat-coltext = TEXT-m16.
          gs_fcat-just = c_c.
  
        WHEN 'SALESTEL'.
          gs_fcat-col_pos = 17.
          gs_fcat-coltext = TEXT-m17.
          gs_fcat-just = c_c.
  
        WHEN 'SENDTYPE'.
          gs_fcat-col_pos = 18.
          gs_fcat-coltext = TEXT-m18.
          gs_fcat-just = c_c.
  
        WHEN 'MAILTYPE'.
          gs_fcat-col_pos = 19.
          gs_fcat-coltext = TEXT-m19.
          gs_fcat-just = c_c.
  
        WHEN 'COMNT'.
          gs_fcat-col_pos = 20.
          gs_fcat-coltext = TEXT-m20.
          gs_fcat-just = c_c.
  
  
      ENDCASE.
  
      MODIFY gt_fcat FROM gs_fcat.
  
    ENDLOOP.
  
  
  ENDFORM.
*&---------------------------------------------------------------------*
*& Form display_grid
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
  FORM display_grid .
  
    gs_variant = sy-cprog.
    CALL METHOD go_grid->set_table_for_first_display
      EXPORTING
        i_default                     = c_x
        i_structure_name              = 'GT_EMAIL'
        is_layout                     = gs_layo
        is_variant                    = gs_variant
        i_save                        = c_a
       it_toolbar_excluding          = gt_exclude
      CHANGING
        it_fieldcatalog               = gt_fcat
        it_outtab                     = gt_email[]
      EXCEPTIONS
        invalid_parameter_combination = 1
        program_error                 = 2
        too_many_lines                = 3
        OTHERS                        = 4.
  
    CALL METHOD cl_gui_control=>set_focus
      EXPORTING
        control = go_grid.
  
  
  ENDFORM.

*&---------------------------------------------------------------------*
*& Form refresh_grid
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
  FORM refresh_grid .
  
    gs_stbl-row = c_x.
    gs_stbl-col = c_x.
  
    CALL METHOD go_grid->refresh_table_display
      EXPORTING
        is_stable      = gs_stbl
        i_soft_refresh = space.
  
  ENDFORM.

*&---------------------------------------------------------------------*
*& Form check_input_validation
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
  FORM check_input_validation .
  
  *  IF pa_vkorg IS NOT INITIAL.
  *
  *  ENDIF.
  *
  *  IF pa_spart IS NOT INITIAL.
  *
  *  ENDIF.
  *
  *  IF pa_vkgrp IS NOT INITIAL.
  *
  *  ENDIF.
  
  ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_grid_exclude
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
  FORM set_grid_exclude .
    gs_exclude = cl_gui_alv_grid=>mc_fc_loc_append_row.
    APPEND gs_exclude TO gt_exclude.
    gs_exclude = cl_gui_alv_grid=>mc_fc_loc_copy.
    APPEND gs_exclude TO gt_exclude.
    gs_exclude = cl_gui_alv_grid=>mc_fc_loc_copy_row.
    APPEND gs_exclude TO gt_exclude.
    gs_exclude = cl_gui_alv_grid=>mc_fc_loc_cut.
    APPEND gs_exclude TO gt_exclude.
    gs_exclude = cl_gui_alv_grid=>mc_fc_loc_delete_row.
    APPEND gs_exclude TO gt_exclude.
    gs_exclude = cl_gui_alv_grid=>mc_fc_loc_insert_row.
    APPEND gs_exclude TO gt_exclude.
    gs_exclude = cl_gui_alv_grid=>mc_fc_loc_move_row.
    APPEND gs_exclude TO gt_exclude.
    gs_exclude = cl_gui_alv_grid=>mc_fc_loc_paste.
    APPEND gs_exclude TO gt_exclude.
    gs_exclude = cl_gui_alv_grid=>mc_fc_loc_paste_new_row.
    APPEND gs_exclude TO gt_exclude.
    gs_exclude = cl_gui_alv_grid=>mc_fc_loc_undo.
    APPEND gs_exclude TO gt_exclude.
    gs_exclude = cl_gui_alv_grid=>mc_fc_info.  "이거 추가함.
    APPEND gs_exclude TO gt_exclude.
  
  ENDFORM.