*&---------------------------------------------------------------------*
*& Include          ZSAMPLE4_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form del_rows
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ER_DATA_CHANGED
*&---------------------------------------------------------------------*
FORM del_rows  USING pcl_data_changed TYPE REF TO cl_alv_changed_data_protocol.

DATA(lt_delitem) = pcl_data_changed->mt_deleted_rows.


"alv => itab을 위해 check change data
SORT lt_delitem BY row_id DESCENDING.

LOOP AT lt_delitem INTO DATA(ls_delitem).
    READ TABLE gt_data INTO gs_data INDEX ls_delitem-row_id.

    IF sy-subrc = 0.
    APPEND gs_data TO gt_data2.
    ENDIF.

    DELETE gt_data INDEX ls_delitem-row_id.

ENDLOOP.

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

SELECT *
    FROM zsample_jh
    INTO CORRESPONDING FIELDS OF TABLE gt_data.

IF sy-subrc <> 0.
    MESSAGE '데이터를 불러올 수 없습니다.' TYPE 'E'.
ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_toolbar
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_toolbar .

REFRESH gt_exclude.
CLEAR   gt_exclude.

APPEND cl_gui_alv_grid=>mc_fc_views      TO gt_exclude.
APPEND cl_gui_alv_grid=>mc_fc_print      TO gt_exclude.
APPEND cl_gui_alv_grid=>mc_fc_view_excel TO gt_exclude.
APPEND cl_gui_alv_grid=>mc_mb_export    TO gt_exclude.
APPEND cl_gui_alv_grid=>mc_fc_check     TO gt_exclude.
APPEND cl_gui_alv_grid=>mc_mb_view      TO gt_exclude.
APPEND cl_gui_alv_grid=>mc_fc_info      TO gt_exclude.
APPEND cl_gui_alv_grid=>mc_fc_find      TO gt_exclude.
APPEND cl_gui_alv_grid=>mc_fc_detail    TO gt_exclude.
APPEND cl_gui_alv_grid=>mc_fc_filter    TO gt_exclude.

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

CREATE OBJECT go_container
    EXPORTING
    container_name = 'MASTER_ALV'.

CREATE OBJECT go_grid
    EXPORTING
    i_parent = go_container.


*  CALL METHOD go_grid->register_edit_event
*    EXPORTING
*      i_event_id = cl_gui_alv_grid=>mc_evt_modified.

SET HANDLER: lcl_event_handler=>handler_data_changed FOR go_grid.

CALL METHOD go_grid->register_edit_event
    EXPORTING
    i_event_id = cl_gui_alv_grid=>mc_evt_modified.

gs_variant-report = sy-repid.
CALL METHOD go_grid->set_table_for_first_display
    EXPORTING
    is_variant           = gs_variant
    i_save               = 'A'
    i_default            = 'X'
    is_layout            = gs_layout
    it_toolbar_excluding = gt_exclude
    CHANGING
    it_outtab            = gt_data
    it_fieldcatalog      = gt_fcat.

CALL METHOD go_grid->set_ready_for_input
    EXPORTING
    i_ready_for_input = 0.

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

gs_stable-row = 'X'.
gs_stable-col = 'X'.

CALL METHOD go_grid->refresh_table_display
    EXPORTING
    is_stable      = gs_stable
    i_soft_refresh = space.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_mode
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_mode .

DATA: ls_data TYPE zsample_jh,
        lt_data LIKE TABLE OF ls_data,
        lv_mode.

LOOP AT gt_data INTO gs_data.

    READ TABLE gt_data INTO gs_data INDEX sy-tabix.

    MOVE-CORRESPONDING gs_data TO ls_data.
    APPEND ls_data TO lt_data.

*    MODIFY lt_data FROM ls_data INDEX sy-tabix.
    CLEAR ls_data.

ENDLOOP.

*  IF gt_data2 IS NOT INITIAL.
*    DELETE zsample_jh FROM TABLE gt_data2.
*
*    IF sy-dbcnt > 0.
*      lv_mode = 'X'.
*    ENDIF.
*
*  ENDIF.

MODIFY zsample_jh FROM TABLE lt_data.

IF sy-dbcnt > 0.
    lv_mode = 'X'.
ENDIF.

IF lv_mode IS NOT INITIAL.
    COMMIT WORK AND WAIT.
    MESSAGE '성공적으로 저장되었습니다' TYPE 'S'.
ELSE.
    ROLLBACK WORK.
    MESSAGE '저장에 실패하였습니다.' TYPE 'E'.
ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_fcat_layout
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_fcat_layout .

gs_layout-zebra      = 'X'.
gs_layout-sel_mode   = 'D'.
gs_layout-cwidth_opt = 'X'.

IF gt_fcat IS INITIAL.
    PERFORM set_fcat USING:
            'X'    'STGCD'   '창고코드'          'ZSAMPLE_JH'    'STGCD'    ' ',
            ''     'STGNM'   '창고명'            'ZSAMPLE_JH'    'STGNM'    'X',
            ''     'SREGD'   '인허가일자'        'ZSAMPLE_JH'    'SREGD'    ' ',
            ''     'PLTCD'   '플랜트코드'        'ZSAMPLE_JH'    'PLTCD'    ' ',
            ''     'TELNO'   '전화번호'          'ZSAMPLE_JH'    'TELNO'    'X',
            ''     'STGTY'   '창고용도'          'ZSAMPLE_JH'    'STGTY'    'X',
            ''     'USPLT'   '한계용량'          'ZSAMPLE_JH'    'USPLT'    ' ',
            ''     'SAREA'   '부지면적'          'ZSAMPLE_JH'    'SAREA'    'X',
            ''     'FBILD'   '냉동창고통수'      'ZSAMPLE_JH'    'FBILD'    'X',
            ''     'FAREA'   '냉동창고면적'      'ZSAMPLE_JH'    'FAREA'    'X',
            ''     'EMPNO'   '사원번호'          'ZSAMPLE_JH'    'EMPNO'    ' ',
            ''     'STGSD'   '창고운영개시일'    'ZSAMPLE_JH'    'STGSD'    'X',
            ''     'STGED'   '창고운영종료일'    'ZSAMPLE_JH'    'STGED'    'X'.

ENDIF.

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
*&      --> P_
*&---------------------------------------------------------------------*
FORM set_fcat  USING  pv_key pv_field pv_text pv_ref_table pv_ref_field pv_edit.

gs_fcat = VALUE #( key       = pv_key
                    fieldname = pv_field
                    coltext   = pv_text
                    ref_table = pv_ref_table
                    ref_field = pv_ref_field
                    edit      = pv_edit ).

APPEND gs_fcat TO gt_fcat.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form change_mode
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM change_mode .

CASE 'X'.
    WHEN pa_rd1.
    CALL METHOD go_grid->set_ready_for_input
        EXPORTING
        i_ready_for_input = 0.

    WHEN pa_rd2.
    CALL METHOD go_grid->set_ready_for_input
        EXPORTING
        i_ready_for_input = 1.

ENDCASE.

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

CLEAR: gs_data, lt_celltab, ls_celltab.


PERFORM editable_fields USING: 'STGNM', 'TELNO', 'STGTY', 'SAREA', 'FBILD' ,'FAREA', 'STGSD', 'STGED'.



PERFORM non_editable_fields USING: 'STGCD' ,'SREGD' ,'PLTCD' ,' USPLT' ,'EMPNO'.


APPEND gs_data TO gt_data.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form editable_fields
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
FORM editable_fields  USING  VALUE(p_field).

DATA: lt_celltab TYPE lvc_t_styl,
        ls_celltab TYPE lvc_s_styl.


ls_celltab-fieldname = p_field.
ls_celltab-style = cl_gui_alv_grid=>mc_style_enabled.
INSERT ls_celltab INTO TABLE lt_celltab.

INSERT LINES OF lt_celltab INTO TABLE gs_data-celltab.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form non_editable_fields
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM non_editable_fields  USING   VALUE(p_field).

DATA: lt_celltab TYPE lvc_t_styl,
        ls_celltab TYPE lvc_s_styl.

ls_celltab-fieldname = p_field.
ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
INSERT ls_celltab INTO TABLE lt_celltab.

INSERT LINES OF lt_celltab INTO TABLE gs_data-celltab.

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

    gs_data-mark = 'X'.
    MODIFY gt_data FROM gs_data INDEX ls_rows TRANSPORTING mark.
    CLEAR gs_data.

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

LOOP AT gt_data INTO gs_data WHERE mark = 'X'.

    DELETE gt_data INDEX sy-tabix.

    IF sy-subrc = 0.
    MESSAGE '정상적으로 삭제되었습니다. ' TYPE 'S'.
    ELSE.
    EXIT.
    ENDIF.

    DELETE FROM  zsample_jh  WHERE stgcd = gs_data-stgcd.

    IF sy-subrc <> 0.
    CONTINUE.
    ENDIF.

    PERFORM refresh_grid.

ENDLOOP.

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
    MESSAGE '선택된 데이터가 없습니다. ' TYPE 'E'.
    gv_err ='X'.
ENDIF.

CLEAR : gt_rows[].

gt_rows[] = lt_rows[].

ENDFORM.