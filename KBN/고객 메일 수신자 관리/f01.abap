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

  SELECT vkorg                "영업조직
          spart                "제품군
          vkgrp                "영업그룹
          a~kunag              "판매처
*         b~name1              "판매처명 (kna1)
          custmail             "판매처 메일주소1
          custmail_2           "판매처 메일주소2
          custmail_3           "판매처 메일주소3
          a~kunnr              "납품처
*         b~name2              "납품처명 (kna1)
          custmail2            "납품처 메일주소1
          custmail2_2          "납품처 메일주소2
          custmail2_3          "납품처 메일주소3
          salesman             "영업담당자명
          salesmail            "영업담당자 메일주소
          salesman2            "업무담당자명
          salesmail2           "업무담당자 메일주소
          salestel             "업무담당자 전화번호
          sendtype             "메일유형
          mailtype             "처리대상
          comnt                "비고
          a~aedat
          a~aezet
          a~ernam
          a~erdat
          a~aenam
          a~erzet
    INTO CORRESPONDING FIELDS OF TABLE gt_email
    FROM zsed0005t AS a
      LEFT OUTER JOIN kna1 AS b
        ON a~kunnr = b~kunnr
      WHERE vkorg = pa_vkorg
        AND spart = pa_spart
        AND vkgrp = pa_vkgrp
        AND a~kunag IN so_kunag  "판매처
        AND a~kunnr IN so_kunnr. "납품처


  SELECT kunnr name1
    INTO CORRESPONDING FIELDS OF TABLE lt_tab
    FROM kna1.


  LOOP AT gt_email.

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

  PERFORM edit_control.

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

  CALL METHOD go_grid->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.

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
*  gs_layo-cwidth_opt = 'X'.

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
        gs_fcat-just = c_c.    "정렬-가운데


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
        gs_fcat-outputlen = 20. "컬럼 사이즈
        gs_fcat-just = c_c.

      WHEN 'CUSTMAIL'.
        gs_fcat-col_pos = 6.
        gs_fcat-coltext = TEXT-m06.
        gs_fcat-outputlen = 30. "컬럼 사이즈
        gs_fcat-just = c_c.

      WHEN 'CUSTMAIL_2'.
        gs_fcat-col_pos = 7.
        gs_fcat-coltext = TEXT-m07.
        gs_fcat-outputlen = 30. "컬럼 사이즈
        gs_fcat-just = c_c.

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
        gs_fcat-col_pos = 10.
        gs_fcat-coltext = TEXT-m28.
        gs_fcat-outputlen = 20. "컬럼 사이즈
        gs_fcat-just = c_c.


      WHEN 'CUSTMAIL2'.
        gs_fcat-col_pos = 11.
        gs_fcat-coltext = TEXT-m10.
        gs_fcat-outputlen = 30. "컬럼 사이즈
        gs_fcat-just = c_c.

      WHEN 'CUSTMAIL2_2'.
        gs_fcat-col_pos = 12.
        gs_fcat-coltext = TEXT-m11.
        gs_fcat-outputlen = 30. "컬럼 사이즈
        gs_fcat-just = c_c.

      WHEN 'CUSTMAIL2_3'.
        gs_fcat-col_pos = 13.
        gs_fcat-coltext = TEXT-m12.
        gs_fcat-outputlen = 30. "컬럼 사이즈
        gs_fcat-just = c_c.

      WHEN 'SALESMAN'.
        gs_fcat-col_pos = 14.
        gs_fcat-coltext = TEXT-m13.
        gs_fcat-outputlen = 13. "컬럼 사이즈
        gs_fcat-just = c_c.

      WHEN 'SALESMAIL'.
        gs_fcat-col_pos = 15.
        gs_fcat-coltext = TEXT-m14.
        gs_fcat-outputlen = 30. "컬럼 사이즈
        gs_fcat-just = c_c.

      WHEN 'SALESMAN2'.
        gs_fcat-col_pos = 16.
        gs_fcat-coltext = TEXT-m15.
        gs_fcat-outputlen = 15. "컬럼 사이즈
        gs_fcat-just = c_c.

      WHEN 'SALESMAIL2'.
        gs_fcat-col_pos = 17.
        gs_fcat-coltext = TEXT-m16.
        gs_fcat-outputlen = 30. "컬럼 사이즈
        gs_fcat-just = c_c.

      WHEN 'SALESTEL'.
        gs_fcat-col_pos = 18.
        gs_fcat-coltext = TEXT-m17.
        gs_fcat-outputlen = 25. "컬럼 사이즈
        gs_fcat-just = c_c.

      WHEN 'SENDTYPE'.
        gs_fcat-col_pos = 19.
        gs_fcat-coltext = TEXT-m18.
        gs_fcat-outputlen = 11. "컬럼 사이즈
        gs_fcat-just = c_c.

      WHEN 'MAILTYPE'.
        gs_fcat-col_pos = 20.
        gs_fcat-coltext = TEXT-m19.
        gs_fcat-outputlen = 15. "컬럼 사이즈
        gs_fcat-just = c_c.

      WHEN 'COMNT'.
        gs_fcat-col_pos = 21.
        gs_fcat-coltext = TEXT-m20.
        gs_fcat-outputlen = 20. "컬럼 사이즈
        gs_fcat-just = c_c.

      WHEN 'ERDAT'.
        gs_fcat-col_pos = 22.
        gs_fcat-coltext = TEXT-m22.
        gs_fcat-outputlen = 10.
        gs_fcat-just = c_c.

      WHEN 'ERZET'.
        gs_fcat-col_pos = 23.
        gs_fcat-coltext = TEXT-m23.
        gs_fcat-outputlen = 10.
        gs_fcat-just = c_c.

      WHEN 'ERNAM'.
        gs_fcat-col_pos = 24.
        gs_fcat-coltext = TEXT-m24.
        gs_fcat-outputlen = 10.
        gs_fcat-just = c_c.

      WHEN 'AEDAT'.
        gs_fcat-col_pos = 25.
        gs_fcat-coltext = TEXT-m25.
        gs_fcat-outputlen = 10.
        gs_fcat-just = c_c.

      WHEN 'AEZET'.
        gs_fcat-col_pos = 26.
        gs_fcat-coltext = TEXT-m26.
        gs_fcat-outputlen = 10.
        gs_fcat-just = c_c.

      WHEN 'AENAM'.
        gs_fcat-col_pos = 27.
        gs_fcat-coltext = TEXT-m27.
        gs_fcat-outputlen = 10.
        gs_fcat-just = c_c.

      WHEN 'MARK'.
        gs_fcat-col_pos = 28.
        gs_fcat-coltext = 'MARK'.
        gs_fcat-outputlen = 10.
        gs_fcat-just = c_c.
        gs_fcat-no_out = c_x.   "보이지 않음

      WHEN 'DOMVALUE_L'.
        gs_fcat-col_pos = 29.
        gs_fcat-coltext = 'DOMVALUE_L'.
        gs_fcat-outputlen = 10.
        gs_fcat-just = c_c.
        gs_fcat-no_out = c_x.

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
      MESSAGE e000 WITH TEXT-e01.   "영업조직과 제품군이 유효하지 않습니다
    ENDIF.

  ENDIF.

  IF pa_spart IS NOT INITIAL.

    SELECT SINGLE spart
      FROM tvkos
      INTO gt_email-spart
      WHERE spart = pa_spart.

    IF sy-subrc <> 0.
      MESSAGE e000 WITH TEXT-e01.   "영업조직과 제품군이 유효하지 않습니다
    ENDIF.

  ENDIF.

  IF pa_vkgrp IS NOT INITIAL.

    SELECT SINGLE vkgrp
      FROM tvgrt
      INTO gt_email-vkgrp
      WHERE vkgrp = pa_vkgrp.
    IF sy-subrc <> 0.
      MESSAGE e000 WITH TEXT-e02.   "입력한 영업그룹이 유효하지 않습니다
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
  gs_exclude = cl_gui_alv_grid=>mc_fc_refresh.  "이거 추가함.
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

  gs_email-vkorg = pa_vkorg.
  gs_email-spart = pa_spart.
  gs_email-vkgrp = pa_vkgrp.


  PERFORM editable_fields USING: 'KUNAG', 'KUNNR', 'SALESMAN', 'SALESMAIL', 'SALESMAN2', 'SALESMAIL2',
                                  'CUSTMAIL', 'CUSTMAIL_2', 'CUSTMAIL_3',
                                  'CUSTMAIL2', 'CUSTMAIL2_2', 'CUSTMAIL2_3',
                                  'SALESTEL', 'SENDTYPE', 'MAILTYPE', 'COMNT'.

  PERFORM non_editable_fields USING: 'NAME1', 'NAME2', 'ERDAT', 'ERZET', 'ERNAM', 'AEDAT', 'AEZET', 'AENAM'.


  APPEND gs_email TO gt_email.

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
      MODIFY gt_email FROM gs_email INDEX v_tabix.
      CLEAR gv_err.
    ENDIF.

  ENDLOOP.

  CHECK gv_err IS INITIAL.

  "Validation Check
  LOOP AT pt_rows INTO ls_rows.

    CLEAR : gs_email.

    READ TABLE gt_email INDEX ls_rows-index INTO gs_email.
    PERFORM check_obligation.

    IF gs_email-kunag IS INITIAL.
      MESSAGE e029 DISPLAY LIKE 'E'.   "판매처는 필수값입니다.
    ELSE.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = gs_email-kunag
        IMPORTING
          output = gs_email-kunag.
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
          AND kunnr = gs_email-kunag  .

      IF ls_list-kunag IS INITIAL.
        MESSAGE e000 WITH '입력한 판매처가 해당 영업조직에 유효하지 않습니다'.
        CLEAR ls_list-kunag.
      ENDIF.
    ENDIF.


    " 납품처코드
    " KNVP-VKORG = 영업조직 AND
    " KNVP-SPART = 제품군 AND
    " KNVP-KUNNR = 판매처 AND KNVP-PARVW = 'WE' AND
    " KUNN2 = 납품처로 존재하는지 체크
*    SELECT SINGLE kunnr
*      FROM knvp
*      INTO ls_list-kunnr
*      WHERE vkorg = gs_email-vkorg
*        AND spart = gs_email-spart
*        AND kunnr = gs_email-kunag
*        AND kunnr = gs_email-kunnr
*          .
*    IF ls_list-kunnr IS INITIAL.
*      MESSAGE e032 DISPLAY LIKE 'E'.  "납품처는 필수입력값입니다.   "납품처는 공란이어도 ok이기 때문에 주석처리함.
*      CLEAR ls_list-kunnr.
*    ENDIF.

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
      MESSAGE e000 WITH '메일유형은 필수 입력값입니다. 메일유형을 입력하십시오.'.
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

    " - 메일유형이 1일 경우 판매처 메일주소, 영업담당자 메일주소, 업무담당자 메일주소에 값이 있어야 저장 되도록 한다.
    " (띄어쓰기로 공란만 입력된 것은 입력하지 않은것으로 보고 메세지 처리)
    "판매처 메일 주소 1~3 중 값이 있어야함

    IF gs_email-sendtype IS NOT INITIAL.
      CASE gs_email-sendtype.
        WHEN '1'.

          IF gs_email-custmail IS INITIAL AND gs_email-custmail_2 IS INITIAL AND gs_email-custmail_3 IS INITIAL.  "판매처 메일주소
            gv_err = c_x.
            MESSAGE e000 WITH '판매처 메일주소는 필수 입력값입니다.'.
          ENDIF.

          IF gs_email-salesmail IS INITIAL.  "영업담당자 메일주소
            MESSAGE e000 WITH '영업담당자 메일주소를 입력하세요.'.

          ENDIF.

          IF gs_email-salesmail2 IS INITIAL.  "업무담당자 메일주소
            MESSAGE e000 WITH '업무담당자 메일주소를 입력하세요.'.
          ENDIF.

        WHEN '2'.
          IF gs_email-custmail IS INITIAL AND gs_email-custmail_2 IS INITIAL AND gs_email-custmail_3 IS INITIAL.
            gv_err = c_x.
            MESSAGE e000 WITH '판매처 메일주소는 필수 입력값입니다'.
          ENDIF.
          IF gs_email-custmail2 IS INITIAL AND gs_email-custmail2_2 IS INITIAL AND gs_email-custmail2_3 IS INITIAL.
            gv_err = c_x.
            MESSAGE e000 WITH '납품처 메일주소는 필수 입력값입니다.'.
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

  DATA: ls_zsed0005 LIKE zsed0005t.
  DATA: lt_celltab TYPE lvc_t_styl,
        ls_celltab TYPE lvc_s_styl.

  CLEAR: gs_email-celltab, lt_celltab, ls_celltab.
  CLEAR: ls_celltab, lt_celltab, lt_celltab[].

* 행 저장 확인 팝업
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      text_question         = TEXT-i02   "선택한 행을 저장하시겠습니까?
      text_button_1         = 'Yes'
      text_button_2         = 'No'
      default_button        = '1'
      display_cancel_button = 'X'
    IMPORTING
      answer                = lv_answer
    EXCEPTIONS
      text_not_found        = 1
      OTHERS                = 2.

  IF lv_answer = '2' OR lv_answer = 'A'.
    EXIT.
*  ELSE.
*    MESSAGE s000 WITH '성공적으로 저장하였습니다.'.
  ENDIF.

  LOOP AT pt_rows INTO ls_rows.     "pt_rows's actual parameter == gt_rows

    CLEAR : gs_email.
    READ TABLE gt_email INDEX ls_rows-index INTO gs_email.
    CLEAR:ls_zsed0005.

    SELECT SINGLE *
      INTO CORRESPONDING FIELDS OF ls_zsed0005
      FROM zsed0005t
      WHERE vkorg = gs_email-vkorg   "영업 조직
      AND   spart = gs_email-spart   "제품군
      AND   vkgrp = gs_email-vkgrp   "영업 그룹
      AND   kunag = gs_email-kunag   "고객 번호(판매처)
      AND   kunnr = gs_email-kunnr.  "고객 번호(납품처)

    IF sy-subrc <> 0.   "데이터가 기존에 없음.
      CLEAR: ls_zsed0005.

      MOVE-CORRESPONDING gs_email TO ls_zsed0005.

      ls_zsed0005-erdat = sy-datlo.
      ls_zsed0005-erzet = sy-timlo.
      ls_zsed0005-ernam = sy-uname.

      INSERT zsed0005t FROM ls_zsed0005.

      gs_email-erdat = ls_zsed0005-erdat.
      gs_email-erzet = ls_zsed0005-erzet.
      gs_email-ernam = ls_zsed0005-ernam.


      MODIFY gt_email FROM gs_email INDEX ls_rows-index .

    ELSE.  "데이터가 기존에 있음.

      "수정일 경우 등록 일자 가지고 오기
*      SELECT SINGLE erdat erzet ernam
*        INTO CORRESPONDING FIELDS OF ls_zsed0005
*        FROM zsed0005t
*        WHERE vkorg = gs_email-vkorg   "영업 조직
*        AND   spart = gs_email-spart   "제품군
*        AND   vkgrp = gs_email-vkgrp   "영업 그룹
*        AND   kunag = gs_email-kunag   "고객 번호(판매처)
*        AND   kunnr = gs_email-kunnr.  "고객 번호(납품처)

      MOVE-CORRESPONDING gs_email TO ls_zsed0005.

      ls_zsed0005-aedat = sy-datlo. "변경일
      ls_zsed0005-aezet = sy-timlo. "변경시간
      ls_zsed0005-aenam = sy-uname. "변경자

      MODIFY zsed0005t FROM ls_zsed0005.   "O
      MOVE-CORRESPONDING ls_zsed0005 TO gs_email.
      MESSAGE s000 WITH '성공적으로 저장되었습니다.'.
      MODIFY gt_email FROM gs_email INDEX ls_rows-index.

    ENDIF.

*    PERFORM refresh_grid.
  ENDLOOP.

  PERFORM get_contact_data.  "단위테케 27번
  PERFORM refresh_grid.      "단위테케 27번

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

    PERFORM refresh_grid.

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

  DATA : lt_ins_cell TYPE lvc_t_moce,
          lt_mod_cell TYPE lvc_t_modi,
          lv_kunag    TYPE zsed0005t-kunag.

  DATA: BEGIN OF ls_list,
          name1 TYPE kna1-name1,
          kunnr TYPE kna1-kunnr,
        END OF ls_list.


  lt_ins_cell[] = pv_data_changed->mt_inserted_rows[].
  lt_mod_cell[] = pv_data_changed->mt_mod_cells[].

* & 새로 추가된 Row는 무시
  LOOP AT lt_ins_cell INTO ls_ins_cell.
    DELETE lt_mod_cell WHERE row_id = ls_ins_cell-row_id.
  ENDLOOP.

  CLEAR : gs_email.


*  LOOP AT lt_mod_cell INTO ls_mod_cell.
*
*    READ TABLE gt_email INTO gs_email INDEX ls_mod_cell-row_id.
*
*    IF sy-subrc <> 0.
*      CONTINUE.
*    ENDIF.
*
*
*  ENDLOOP.

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
*&---------------------------------------------------------------------*
*& Form set_event_handle
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_event_handle .

  CREATE OBJECT go_event_handler.
  SET HANDLER : go_event_handler->handle_data_changed          FOR go_grid,
                go_event_handler->handle_data_changed_finished FOR go_grid.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_data_changed_finished
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM handle_data_changed_finished USING et_good_cells TYPE lvc_t_modi
                                        e_modified    TYPE char01.

  DATA: es_good_cells  TYPE lvc_s_modi.

  DATA: lt_list  LIKE TABLE OF gt_email,
        ls_list  LIKE LINE  OF gt_email,
        ls_list2 LIKE LINE  OF gt_email,
        lv_kunag TYPE string.

  CLEAR : es_good_cells, lt_list, lt_list[], ls_list, ls_list2.

  IF e_modified <> abap_true.
    RETURN.
  ENDIF.

  LOOP AT et_good_cells INTO es_good_cells.

    CLEAR : ls_list, lt_list[].

    lt_list[] = gt_email[].

    READ TABLE gt_email INTO ls_list INDEX es_good_cells-row_id.

    "판매처 체크 및 판매처명 get
    IF es_good_cells-fieldname = 'KUNAG'.

      IF ls_list-kunag IS NOT INITIAL.

        SELECT SINGLE kunnr
          INTO ls_list2-kunag
          FROM kna1
          WHERE kunnr = ls_list-kunag.

        IF sy-subrc <> 0.
          ls_list-name1 = ''.
          MODIFY gt_email FROM ls_list INDEX es_good_cells-row_id TRANSPORTING name1.
          MESSAGE s000 WITH '입력한 판매처가 해당 영업조직에 유효하지 않습니다.' DISPLAY LIKE 'E'.
        ELSE.
          SELECT SINGLE name1
            INTO ls_list-name1
            FROM kna1
          WHERE kunnr = ls_list2-kunag.
          MODIFY gt_email FROM ls_list INDEX es_good_cells-row_id TRANSPORTING name1.
        ENDIF.


        lv_kunag = ls_list-kunag.
        DATA special_chr TYPE string.
        DATA msg TYPE string.

        CALL FUNCTION 'HR_GB_XML_PATTERN_CHECK'
          EXPORTING
            i_string  = lv_kunag
          IMPORTING
            e_invalid = special_chr
            e_errtxt  = msg.
        IF msg IS NOT INITIAL.
          MESSAGE e000 WITH '올바른 값을 입력하십시오'.
        ENDIF.

      ENDIF.


      "납품처 체크 및 납품처명 get
    ELSEIF es_good_cells-fieldname = 'KUNNR'.
      IF ls_list-kunnr IS NOT INITIAL.
        SELECT SINGLE kunnr
          INTO ls_list2-kunnr
          FROM kna1
          WHERE kunnr = ls_list-kunnr.
        IF sy-subrc <> 0.
          ls_list-name2 = ''.
          MODIFY gt_email FROM ls_list INDEX es_good_cells-row_id TRANSPORTING name2.
*          CLEAR: ls_list2-kunnr, ls_list-name2.
          MESSAGE s000 WITH TEXT-e14 DISPLAY LIKE 'E'.
        ELSE.
          SELECT SINGLE name1
            INTO ls_list-name2
            FROM kna1
            WHERE kunnr = ls_list-kunnr.
          MODIFY gt_email FROM ls_list INDEX es_good_cells-row_id TRANSPORTING name2.
        ENDIF.
        CLEAR: ls_list2-kunnr, ls_list-name2.
      ENDIF.
    ENDIF.
  ENDLOOP.

  PERFORM refresh_grid.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form edit_control
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM edit_control .

  DATA : lt_celltab TYPE lvc_t_styl,
          ls_celltab TYPE lvc_s_styl.

  CLEAR: gs_email, lt_celltab, ls_celltab.

  LOOP AT gt_email INTO gs_email.

    DATA(lv_tabix) = sy-tabix.
    CLEAR: gs_email-celltab, lt_celltab, ls_celltab.

    PERFORM editable_fields USING:    'SALESMAN', 'SALESMAIL', 'SALESMAN2', 'SALESMAIL2',
                                      'CUSTMAIL', 'CUSTMAIL_2', 'CUSTMAIL_3', 'CUSTMAIL2', 'CUSTMAIL2_2', 'CUSTMAIL2_3',
                                      'SALESTEL', 'SENDTYPE', 'MAILTYPE', 'COMNT'.

    PERFORM non_editable_fields USING: 'ERDAT', 'ERZET', 'ERNAM', 'AEDAT', 'AEZET', 'AENAM'.

    INSERT LINES OF lt_celltab INTO TABLE gs_email-celltab.   "추가
    MODIFY gt_email FROM gs_email INDEX lv_tabix.
*    CLEAR: gs_email.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form f4_p_vkgrp
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f4_pa_vkgrp .

  DATA : BEGIN OF ls_vkgrp,
            vkgrp TYPE vkgrp,   "영업그룹
            bezei TYPE bezei20, "내역
          END OF ls_vkgrp,

          lt_vkgrp LIKE TABLE OF ls_vkgrp.

  CLEAR : ls_vkgrp, lt_vkgrp.

  SELECT vkgrp bezei
    INTO CORRESPONDING FIELDS OF TABLE lt_vkgrp
    FROM tvgrt
    WHERE spras = sy-langu.

  SORT lt_vkgrp BY vkgrp.


  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'VKGRP'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      dynprofield     = 'P_VKGRP'
      window_title    = '영업그룹'
      value_org       = 'S'
    TABLES
      value_tab       = lt_vkgrp
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

ENDFORM.