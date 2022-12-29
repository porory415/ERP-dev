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

*  CLEAR:   gs_email.
*  REFRESH: gt_email.
  
  DATA: BEGIN OF lt_tab OCCURS 0.
  DATA: kunnr TYPE kna1-kunnr,
        name1 TYPE kna1-name1.
  DATA: END OF lt_tab.

  SELECT a~vkorg a~spart a~vkgrp a~kunag b~name1 a~kunnr a~custmail a~custmail_2
        a~custmail_3 a~custmail2
        a~custmail2_2 a~custmail2_3 a~salesman a~salesmail a~salesman2
        a~salesmail2 a~salestel a~sendtype
        a~mailtype a~comnt
    INTO CORRESPONDING FIELDS OF TABLE gt_email
    FROM zsed0005t AS a
    LEFT OUTER JOIN kna1 AS b
      ON a~kunnr = b~kunnr
    WHERE a~vkorg = pa_vkorg
      AND a~spart = pa_spart
      AND a~vkgrp = pa_vkgrp
      AND a~kunag IN so_kunag
      AND a~kunnr IN so_kunnr .

  SELECT kunnr name1
    INTO CORRESPONDING FIELDS OF TABLE lt_tab
    FROM kna1.


  LOOP AT gt_email.

    PERFORM return_uppercase.

    READ TABLE lt_tab WITH KEY kunnr = gt_email-kunnr.
    IF sy-subrc = 0.
      gt_email-name2 = lt_tab-name1.
    ENDIF.

    READ TABLE lt_tab WITH KEY kunnr = gt_email-kunag.
    IF sy-subrc = 0.
      gt_email-name1 = lt_tab-name1.
    ENDIF.

    MODIFY gt_email.
    CLEAR lt_tab.

  ENDLOOP.


  DATA : lt_celltab TYPE lvc_t_styl,
          ls_celltab TYPE lvc_s_styl.

  CLEAR: gs_email, lt_celltab, ls_celltab.

  LOOP AT gt_email INTO gs_email.

    DATA(lv_tabix) = sy-tabix.
    CLEAR: gs_email-celltab, lt_celltab, ls_celltab.

    PERFORM editable_fields USING:   'SALESMAN', 'SALESMAIL', 'SALESMAN2', 'SALESMAIL2',
                                      'CUSTMAIL', 'CUSTMAIL_2', 'CUSTMAIL_3', 'CUSTMAIL2', 'CUSTMAIL2_2', 'CUSTMAIL2_3',
                                      'SALESTEL', 'SENDTYPE', 'MAILTYPE', 'COMNT'.

    PERFORM non_editable_fields USING: 'ERDAT', 'ERZET', 'ERNAM', 'AEDAT', 'AEZET', 'AENAM'.

    MODIFY gt_email FROM gs_email INDEX lv_tabix.
    CLEAR: gs_email.

  ENDLOOP.

*  LOOP AT gt_email INTO gs_email.
*    DATA(lv_tabix) = sy-tabix.
*    MODIFY gt_email FROM gs_email INDEX lv_tabix.
*  ENDLOOP.

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
        gs_fcat-outputlen = 6. "컬럼 사이즈
        gs_fcat-just = c_c.    "정렬-가운데

      WHEN 'SPART'.
        gs_fcat-col_pos = 2.
        gs_fcat-coltext = TEXT-m02.
        gs_fcat-outputlen = 6. "컬럼 사이즈

      WHEN 'VKGRP'.
        gs_fcat-col_pos = 3.
        gs_fcat-coltext = TEXT-m03.
        gs_fcat-outputlen = 8. "컬럼 사이즈
        gs_fcat-just = c_c.

      WHEN 'KUNAG'.
        gs_fcat-col_pos = 4.
        gs_fcat-coltext = TEXT-m04.
        gs_fcat-outputlen = 10. "컬럼 사이즈
        gs_fcat-just = c_c.

      WHEN 'NAME1'.
        gs_fcat-col_pos = 5.
        gs_fcat-coltext = TEXT-m05.
        gs_fcat-outputlen = 25. "컬럼 사이즈
        gs_fcat-just = c_l.

      WHEN 'CUSTMAIL'.
        gs_fcat-col_pos = 6.
        gs_fcat-coltext = TEXT-m06.
        gs_fcat-outputlen = 30. "컬럼 사이즈
        gs_fcat-just = c_c.

      WHEN 'CUSTMAIL_2'.
        gs_fcat-col_pos = 7.
        gs_fcat-coltext = TEXT-m07.
        gs_fcat-outputlen = 30. "컬럼 사이즈
        gs_fcat-just = c_l.

      WHEN 'CUSTMAIL_3'.
        gs_fcat-col_pos = 8.
        gs_fcat-coltext = TEXT-m08.
        gs_fcat-outputlen = 30. "컬럼 사이즈
        gs_fcat-just = c_c.

      WHEN 'KUNNR'.
        gs_fcat-col_pos = 9.
        gs_fcat-coltext = TEXT-m09.
        gs_fcat-outputlen = 13. "컬럼 사이즈
        gs_fcat-just = c_c.

      WHEN 'NAME2'.
        gs_fcat-col_pos = 11.
        gs_fcat-coltext = TEXT-m28.
        gs_fcat-outputlen = 20. "컬럼 사이즈
        gs_fcat-just = c_c.

      WHEN 'CUSTMAIL2'.
        gs_fcat-col_pos = 10.
        gs_fcat-coltext = TEXT-m10.
        gs_fcat-outputlen = 30. "컬럼 사이즈
        gs_fcat-just = c_l.

      WHEN 'CUSTMAIL2_2'.
        gs_fcat-col_pos = 11.
        gs_fcat-coltext = TEXT-m11.
        gs_fcat-outputlen = 8. "컬럼 사이즈
        gs_fcat-just = c_c.

      WHEN 'CUSTMAIL2_3'.
        gs_fcat-col_pos = 12.
        gs_fcat-coltext = TEXT-m12.
        gs_fcat-outputlen = 30. "컬럼 사이즈
        gs_fcat-just = c_c.

      WHEN 'SALESMAN'.
        gs_fcat-col_pos = 13.
        gs_fcat-coltext = TEXT-m13.
        gs_fcat-outputlen = 13. "컬럼 사이즈
        gs_fcat-just = c_c.

      WHEN 'SALESMAIL'.
        gs_fcat-col_pos = 14.
        gs_fcat-coltext = TEXT-m14.
        gs_fcat-outputlen = 30. "컬럼 사이즈
        gs_fcat-just = c_l.

      WHEN 'SALESMAN2'.
        gs_fcat-col_pos = 15.
        gs_fcat-coltext = TEXT-m15.
        gs_fcat-outputlen = 15. "컬럼 사이즈
        gs_fcat-just = c_c.

      WHEN 'SALESMAIL2'.
        gs_fcat-col_pos = 16.
        gs_fcat-coltext = TEXT-m16.
        gs_fcat-outputlen = 30. "컬럼 사이즈
        gs_fcat-just = c_c.

      WHEN 'SALESTEL'.
        gs_fcat-col_pos = 17.
        gs_fcat-coltext = TEXT-m17.
        gs_fcat-outputlen = 25. "컬럼 사이즈
        gs_fcat-just = c_c.

      WHEN 'SENDTYPE'.
        gs_fcat-col_pos = 18.
        gs_fcat-coltext = TEXT-m18.
*        gs_fcat-outputlen = 8. "컬럼 사이즈
        gs_fcat-just = c_c.

      WHEN 'MAILTYPE'.
        gs_fcat-col_pos = 19.
        gs_fcat-coltext = TEXT-m19.
*        gs_fcat-outputlen = 8. "컬럼 사이즈
        gs_fcat-just = c_c.

      WHEN 'COMNT'.
        gs_fcat-col_pos = 20.
        gs_fcat-coltext = TEXT-m20.
*        gs_fcat-outputlen = 8. "컬럼 사이즈
        gs_fcat-just = c_c.

      WHEN 'ERDAT'.
        gs_fcat-col_pos = 23.
        gs_fcat-coltext = TEXT-m22.
        gs_fcat-outputlen = 10.

      WHEN 'ERZET'.
        gs_fcat-col_pos = 24.
        gs_fcat-coltext = TEXT-m23.
        gs_fcat-outputlen = 10.

      WHEN 'ERNAM'.
        gs_fcat-col_pos = 25.
        gs_fcat-coltext = TEXT-m24.
        gs_fcat-outputlen = 10.

      WHEN 'AEDAT'.
        gs_fcat-col_pos = 26.
        gs_fcat-coltext = TEXT-m25.
        gs_fcat-outputlen = 10.

      WHEN 'AEZET'.
        gs_fcat-col_pos = 27.
        gs_fcat-coltext = TEXT-m26.
        gs_fcat-outputlen = 10.

      WHEN 'AENAM'.
        gs_fcat-col_pos = 28.
        gs_fcat-coltext = TEXT-m27.
        gs_fcat-outputlen = 10.

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

  IF pa_vkorg IS NOT INITIAL.

    SELECT SINGLE vkorg
      FROM tvkos
      INTO gt_email-vkorg
      WHERE vkorg = pa_vkorg.

    IF sy-subrc <> 0.
      MESSAGE e000 WITH TEXT-e01.
    ENDIF.

  ENDIF.

  IF pa_spart IS NOT INITIAL.

    SELECT SINGLE spart
      FROM tvkos
      INTO gt_email-spart
      WHERE spart = pa_spart.

    IF sy-subrc <> 0.
      MESSAGE e000 WITH TEXT-e01.
    ENDIF.

  ENDIF.

  IF pa_vkgrp IS NOT INITIAL.

    SELECT SINGLE vkgrp
      FROM tvgrt
      INTO gt_email-vkgrp
      WHERE vkgrp = pa_vkgrp.
    IF sy-subrc <> 0.
      MESSAGE e000 WITH TEXT-e02.
    ENDIF.
  ENDIF.


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
  gs_exclude = cl_gui_alv_grid=>mc_fc_detail.
  APPEND gs_exclude TO gt_exclude.
  gs_exclude = cl_gui_alv_grid=>mc_fc_check.
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
  gs_exclude = cl_gui_alv_grid=>mc_fc_info. "이거 추가함.
  APPEND gs_exclude TO gt_exclude.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form add_row
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM add_row .

  DATA : lt_celltab TYPE lvc_t_styl,   " sort 테이블
          ls_celltab TYPE lvc_s_styl.

  CLEAR: gs_email, lt_celltab, ls_celltab.



  PERFORM editable_fields USING: 'SALESMAN', 'SALESMAIL', 'SALESMAN2', 'SALESMAIL2',
                                  'CUSTMAIL', 'CUSTMAIL_2', 'CUSTMAIL_3',
                                  'CUSTMAIL2', 'CUSTMAIL2_2', 'CUSTMAIL2_3',
                                  'SALESTEL', 'SENDTYPE', 'MAILTYPE', 'COMNT'.

  PERFORM non_editable_fields USING: 'ERDAT', 'ERZET', 'ERNAM', 'AEDAT', 'AEZET', 'AENAM'.

  gs_email-vkorg = pa_vkorg.
  gs_email-spart = pa_spart.
  gs_email-vkgrp = pa_vkgrp.

  APPEND gs_email TO gt_email.
*  MODIFY gt_email FROM gs_email INDEX sy-tabix.
  CLEAR gs_email.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_selindex
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_selindex .

  DATA: lt_rows TYPE lvc_t_row.
  CLEAR: gv_err.

  CALL METHOD go_grid->get_selected_rows
    IMPORTING
      et_index_rows = lt_rows.

  IF lt_rows[] IS INITIAL.
    MESSAGE s000 WITH TEXT-e09 DISPLAY LIKE 'E'.
    gv_err = c_x.
  ENDIF.

  CLEAR : gt_rows[].

  gt_rows[] = lt_rows[].

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_validation
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_EMAIL
*&---------------------------------------------------------------------*
FORM check_validation  TABLES  pt_rows  TYPE lvc_t_row.

  DATA:  ls_rows TYPE lvc_s_row.
  DATA:  lt_list LIKE TABLE OF gt_email.
  DATA:  ls_list LIKE LINE OF gt_email.
  DATA:  v_tabix TYPE syst_tabix.
  DATA:  lv_len(5).

  CLEAR: gv_err, gs_email.
  CLEAR : gs_email.

  "중복데이터 체크
  LOOP AT gt_email INTO gs_email.
    CLEAR: lt_list[], ls_list.

    lt_list[] = gt_email[].

    DELETE lt_list INDEX sy-tabix.

    v_tabix = sy-tabix.

    "중복데이터 체크
    READ TABLE lt_list INTO ls_list
    WITH KEY vkorg = gs_email-vkorg
              spart = gs_email-spart
              vkgrp = gs_email-vkgrp
              kunag = gs_email-kunag
              kunnr = gs_email-kunnr.

    IF sy-subrc = 0.
      gv_err = c_x.
      MESSAGE e031 DISPLAY LIKE 'E'.
*      MODIFY gt_email FROM gs_email INDEX v_tabix.
    ENDIF.

  ENDLOOP.

  CHECK gv_err IS INITIAL.

  "Validation Check
  LOOP AT pt_rows INTO ls_rows.

    CLEAR : gs_email.

    READ TABLE gt_email INDEX ls_rows-index INTO gs_email.
    PERFORM check_obligation.

    " 판매처코드
    " KNVP-VKORG = 영업조직 AND
    " KNVP-SPART = 제품군 AND
    " KNVP-KUNNR = 판매처 AND KNVP-PARVW = 'AG'
    " 없을 경우 메세지 처리.
    SELECT SINGLE kunnr
      FROM knvp
      INTO ls_list-kunag
      WHERE vkorg = gs_email-vkorg
        AND spart = gs_email-spart
        AND kunnr = gs_email-kunag
          .
    IF ls_list-kunag IS INITIAL.
      MESSAGE e000 WITH '입력한 판매처가 해당 영업조직에 유효하지 않습니다'.
      CLEAR ls_list-kunag.
    ENDIF.

    " 납품처코드
    " KNVP-VKORG = 영업조직 AND
    " KNVP-SPART = 제품군 AND
    " KNVP-KUNNR = 판매처 AND KNVP-PARVW = 'WE' AND
    " KUNN2 = 납품처로 존재하는지 체크
    SELECT SINGLE kunnr
      FROM knvp
      INTO ls_list-kunnr
      WHERE vkorg = gs_email-vkorg
        AND spart = gs_email-spart
        AND kunnr = gs_email-kunag
        AND kunnr = gs_email-kunnr
          .
    IF ls_list-kunnr IS INITIAL.
      MESSAGE e000 WITH '입력한 납품처가 판매처에 유효하지 않습니다.'.
      CLEAR ls_list-kunnr.
    ENDIF.

    " 메일 수신유형
    IF gs_email-sendtype IS NOT INITIAL.

      SELECT SINGLE domvalue_l
        FROM dd07v
        INTO ls_list-domvalue_l
        WHERE domname = 'ZDSENDTYPE'
            AND domvalue_l = gs_email-sendtype
            AND ddlanguage = sy-langu.

      IF sy-subrc <> 0.
        gv_err = c_x.
        MESSAGE e000 WITH '유효하지 않은 메일유형입니다.'.
        CLEAR : ls_list-domvalue_l.
      ENDIF.
    ELSE.
      MESSAGE e000 WITH '메일유형을 입력하세요.'.
    ENDIF.

    "메일 송신대상
    IF gs_email-mailtype IS NOT INITIAL.

      SELECT SINGLE domvalue_l
        FROM dd07v
        INTO ls_list-domvalue_l
        WHERE domname = 'ZDMAILTYPE'
            AND domvalue_l = gs_email-mailtype
            AND ddlanguage = sy-langu
        .
      IF sy-subrc <> 0.

        gv_err = c_x.
        MESSAGE e000 WITH '메일 송신대상이 유효하지 않습니다.'.
        CLEAR ls_list-domvalue_l.
      ENDIF.
    ENDIF.

    " 메일유형이 1일 경우 판매처 메일주소, 영업담당자 메일주소, 업무담당자 메일주소에 값이 있어야 저장 되도록 한다.
    " (띄어쓰기로 공란만 입력된 것은 입력하지 않은것으로 보고 메세지 처리)
    "판매처 메일 주소 1~3 중 값이 있어야함

    IF gs_email-sendtype IS NOT INITIAL.
      CASE gs_email-sendtype.
        WHEN '1'.

          IF gs_email-custmail IS INITIAL AND gs_email-custmail_2 IS INITIAL AND gs_email-custmail_3 IS INITIAL.
            gv_err = c_x.
            MESSAGE e000 WITH '판매처 메일주소는 필수 입력값입니다. 판매처 메일주소를 입력하세요.'.

          ENDIF.

          IF gs_email-salesmail IS INITIAL.
            MESSAGE e000 WITH '영업담당자 메일주소를 입력하세요.'.

          ENDIF.

          IF gs_email-salesmail2 IS INITIAL.
            MESSAGE e000 WITH '업무담당자 메일주소를 입력하세요.'.
          ENDIF.
      ENDCASE.
    ENDIF.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_table
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_EMAIL
*&---------------------------------------------------------------------*
FORM modify_table  TABLES pt_rows TYPE lvc_t_row.

  DATA:  ls_rows TYPE lvc_s_row.
  DATA:  lv_answer(1).
  CLEAR: lv_answer.

  DATA:  ls_zsed0005 LIKE zsed0005t.
  DATA: lt_celltab TYPE lvc_t_styl,
        ls_celltab TYPE lvc_s_styl.

  CLEAR: gs_email-celltab, lt_celltab, ls_celltab.
  CLEAR: ls_celltab, lt_celltab, lt_celltab[].

* 행 저장 확인 팝업
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      text_question         = TEXT-i02
      text_button_1         = 'Yes'
      text_button_2         = 'No'
      default_button        = '1'
      display_cancel_button = 'X'
    IMPORTING
      answer                = lv_answer
    EXCEPTIONS
      text_not_found        = 1
      OTHERS                = 2.

  IF lv_answer = '2' OR lv_answer = '0'.
    EXIT.
  ENDIF.

  LOOP AT pt_rows INTO ls_rows.
    CLEAR: gs_email.
    READ TABLE gt_email INDEX ls_rows-index INTO gs_email.

    CLEAR: ls_zsed0005.

    SELECT SINGLE *
      INTO CORRESPONDING FIELDS OF ls_zsed0005
      FROM zsed0005t
      WHERE vkorg = gs_email-vkorg
        AND spart = gs_email-spart
        AND vkgrp = gs_email-vkgrp
        AND kunag = gs_email-kunag
        AND kunnr = gs_email-kunnr.

    IF sy-subrc <> 0.   "데이터가 기존에 없음.
      CLEAR: ls_zsed0005.

      ls_zsed0005-erdat = sy-datlo.
      ls_zsed0005-erzet = sy-timlo.
      ls_zsed0005-ernam = sy-uname.

      gs_email-erdat = ls_zsed0005-erdat.
      gs_email-erzet = ls_zsed0005-erzet.
      gs_email-ernam = ls_zsed0005-ernam.
      MOVE-CORRESPONDING gs_email TO ls_zsed0005.
      INSERT zsed0005t FROM ls_zsed0005.

*      MESSAGE s000 WITH '저장되었습니다.'.

      IF sy-subrc = 0.
        MESSAGE s024.
        "영업조직, 제품군, 영업그룹, 판매처명, 납품처명
        ls_celltab-fieldname = 'VKORG' ."수정 가능 / 불가능 필드 이름을 문자열로
        ls_celltab-fieldname = 'SPART' .
        ls_celltab-fieldname = 'VKGRP' .
        ls_celltab-fieldname = 'KUNAG' .
        ls_celltab-fieldname = 'KUNNR' .
        ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled. " 수정 불가능 상수값
        INSERT ls_celltab INTO TABLE lt_celltab. "sort 테이블이기 때문에 insert로 삽입. [원본]

        gs_email-celltab = lt_celltab.
        MODIFY gt_email FROM gs_email INDEX ls_rows-index TRANSPORTING erdat erzet ernam celltab.
      ELSE.
        MESSAGE s026.
        MODIFY gt_email FROM gs_email INDEX ls_rows-index TRANSPORTING erdat erzet ernam.
      ENDIF.

    ELSE.  "데이터가 기존에 있음.
      CLEAR : ls_zsed0005.

      ls_zsed0005-aedat = sy-datlo. "변경일
      ls_zsed0005-aezet = sy-timlo. "변경시간
      ls_zsed0005-aenam = sy-uname. "변경자

      "수정일 경우 등록 일자 가지고 오기(엑셀 업로드 후 재조회 에서 문제가 생겨 추가)
      SELECT SINGLE erdat erzet ernam
        INTO CORRESPONDING FIELDS OF ls_zsed0005
        FROM zsed0005t
        WHERE vkorg = pa_vkorg
          AND spart = pa_spart
          AND vkgrp = pa_vkgrp
          AND kunag IN so_kunag
          AND kunnr IN so_kunnr.

      MODIFY zsed0005t FROM ls_zsed0005.

      gs_email-erdat = ls_zsed0005-erdat.
      gs_email-erzet = ls_zsed0005-erzet.
      gs_email-ernam = ls_zsed0005-ernam.
      gs_email-aedat = ls_zsed0005-aedat.
      gs_email-aezet = ls_zsed0005-aezet.
      gs_email-aenam = ls_zsed0005-aenam.

      IF sy-subrc = 0.
        MESSAGE s030 DISPLAY LIKE 'S'.
*        gs_list-zmsg = TEXT-e15.
        MODIFY gt_email FROM gs_email INDEX ls_rows-index TRANSPORTING erdat erzet ernam aedat aezet aenam.
      ELSE.
        MESSAGE e027 DISPLAY LIKE 'E'.
        MODIFY gt_email FROM gs_email INDEX ls_rows-index TRANSPORTING erdat erzet ernam aedat aezet aenam.
      ENDIF.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form del_row
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM del_row .

  DATA : lv_answer(1).
  DATA : ls_rows TYPE lvc_s_row.


  PERFORM check_selindex.
  CHECK gv_err IS INITIAL.


  LOOP AT gt_rows INTO ls_rows.

    gs_email-mark = 'X'.
    MODIFY gt_email FROM gs_email INDEX ls_rows TRANSPORTING mark.
    CLEAR gs_email.

  ENDLOOP.

  " 선택한 행을 삭제하시겠습니까?
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      text_question         = TEXT-i01
      text_button_1         = 'Yes'
      text_button_2         = 'No'
      default_button        = '1'
      display_cancel_button = 'X'
    IMPORTING
      answer                = lv_answer
    EXCEPTIONS
      text_not_found        = 1
      OTHERS                = 2.

  IF lv_answer = '2' OR "NO
      lv_answer = 'A'.   "취소
    EXIT.
  ENDIF.

  LOOP AT gt_email INTO gs_email WHERE mark = 'X'.

    DELETE gt_email INDEX sy-tabix.

    IF sy-subrc = 0.
      MESSAGE s000 WITH TEXT-e10.
    ELSE.
      EXIT.
    ENDIF.

    DELETE FROM  zsed0005t WHERE vkorg = gs_email-vkorg
                              AND spart = gs_email-spart
                              AND vkgrp = gs_email-vkgrp
                              AND kunag = gs_email-kunag
                              AND kunnr = gs_email-kunnr.

    IF sy-subrc <> 0.
      CONTINUE.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form editable_fields
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM editable_fields  USING    VALUE(p_field).

  DATA: lt_celltab TYPE lvc_t_styl,
        ls_celltab TYPE lvc_s_styl.

*  CLEAR: gs_list, lt_celltab, ls_celltab.

  ls_celltab-fieldname = p_field.
  ls_celltab-style = cl_gui_alv_grid=>mc_style_enabled.
  INSERT ls_celltab INTO TABLE lt_celltab.

  INSERT LINES OF lt_celltab INTO TABLE gs_email-celltab.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form non_editable_fields
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM non_editable_fields  USING    VALUE(p_field).

  DATA: lt_celltab TYPE lvc_t_styl,
        ls_celltab TYPE lvc_s_styl.

  ls_celltab-fieldname = p_field.
  ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
  INSERT ls_celltab INTO TABLE lt_celltab.

  INSERT LINES OF lt_celltab INTO TABLE gs_email-celltab.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_data_changed
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ER_DATA_CHANGED
*&---------------------------------------------------------------------*
FORM handle_data_changed  USING pv_data_changed TYPE REF TO cl_alv_changed_data_protocol.

  DATA : ls_ins_cell TYPE lvc_s_moce,
          ls_mod_cell TYPE lvc_s_modi.

  DATA: lt_ins_cell TYPE lvc_t_moce,
        lt_mod_cell TYPE lvc_t_modi.


  lt_ins_cell[] = pv_data_changed->mt_inserted_rows[].
  lt_mod_cell[] = pv_data_changed->mt_mod_cells[].

* & 새로 추가된 Row는 무시
  LOOP AT lt_ins_cell INTO ls_ins_cell.
    DELETE lt_mod_cell WHERE row_id = ls_ins_cell-row_id.
  ENDLOOP.

  CLEAR : gs_email.

  LOOP AT lt_mod_cell INTO ls_mod_cell.

    READ TABLE gt_email INTO gs_email INDEX ls_mod_cell-row_id.

    IF sy-subrc <> 0.
      CONTINUE.
    ENDIF.

  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_obligation
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_obligation .

  IF gs_email-vkorg IS INITIAL.
    MESSAGE e000 WITH '영업조직은 필수 입력값입니다. 영업조직을 입력하십시오.'.
  ENDIF.

  IF gs_email-spart IS INITIAL.
    MESSAGE e000 WITH '제품군은 필수 입력값입니다. 제품군을 입력하십시오.'.
  ENDIF.

  IF gs_email-vkgrp IS INITIAL.
    MESSAGE e000 WITH '영업그룹은 필수 입력값입니다. 영업그룹을 입력하십시오.'.
  ENDIF.

  IF gs_email-kunag IS INITIAL.
    MESSAGE e000 WITH '판매처는 필수 입력값입니다. 판매처를 입력하십시오.'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form return_uppercase
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM return_uppercase .

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = gt_email-kunag
    IMPORTING
      output = gt_email-kunag.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = gt_email-kunnr
    IMPORTING
      output = gt_email-kunnr.

ENDFORM.