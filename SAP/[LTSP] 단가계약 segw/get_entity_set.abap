METHOD zbnt257testset_get_entityset.

    DATA: ls_entity      LIKE LINE OF et_entityset,
            lo_transaction TYPE REF TO zcl_zswxutil_transaction,
            iv_appid       TYPE zeswxappid,
            lt_where       TYPE TABLE OF zswx1011s.

    DATA:
        lo_filter      TYPE REF TO zcl_zswxutil_filter,
        lv_vkorg       TYPE vkorg,
        lv_kunnr       TYPE kunnr,
        lv_qtdat_fr    TYPE zeltspqtdat_fr,
        lv_qtdat_to    TYPE zeltspqtdat_to,
        lv_spart       TYPE spart,
        lv_zzkunnr_end TYPE zeotckunnrend,
        lv_slnum       TYPE zeltsslnum,
        lv_zqttyp      TYPE char20,
        lv_vkgrp       TYPE vkgrp,
        lv_slnum_dt    TYPE zeltsppernr_dt,
        lv_apstt_sa    TYPE zeltsapstt,
        lv_apstt_dt    TYPE zeltspapstt_dt,
        lv_qtdno_fr    TYPE zeltspqtdno,
        lv_qtdno_to    TYPE zeltspqtdno,
        lv_qttype      TYPE char1.


    TYPES: BEGIN OF ty_output,
                et_header TYPE STANDARD TABLE OF zswx1010s WITH EMPTY KEY,
                et_result TYPE STANDARD TABLE OF zltsp1020s WITH EMPTY KEY,
                es_return TYPE zswx1001s,
            END OF ty_output.
    DATA: ls_output TYPE ty_output.

    TYPES: BEGIN OF ty_output_detail,
                et_header TYPE STANDARD TABLE OF zswx1010s WITH EMPTY KEY,
                et_result TYPE STANDARD TABLE OF zswx2411s WITH EMPTY KEY,
                es_return TYPE zswx1001s,
            END OF ty_output_detail.

    DATA: ls_output_detail TYPE ty_output_detail,
            ls_login         TYPE zswx1000s,
            ls_login1        TYPE zlts1000s.

    DATA: lt_result TYPE TABLE OF zltsp1020s.


    "------------------------------------------------------------------------------

    CREATE OBJECT lo_filter
        EXPORTING
        i_input = it_filter_select_options.
    lo_filter->get_value( EXPORTING i_prpid = 'iv_vkorg'    IMPORTING e_value = lv_vkorg ).
    lo_filter->get_value( EXPORTING i_prpid = 'iv_kunnr'    IMPORTING e_value = lv_kunnr ).
    lo_filter->get_value( EXPORTING i_prpid = 'iv_qtdat_fr' IMPORTING e_value = lv_qtdat_fr ).
    lo_filter->get_value( EXPORTING i_prpid = 'iv_qtdat_to' IMPORTING e_value = lv_qtdat_to ).
    lo_filter->get_value( EXPORTING i_prpid = 'iv_spart'    IMPORTING e_value = lv_spart ).
    lo_filter->get_value( EXPORTING i_prpid = 'iv_zzkunnr_end'  IMPORTING e_value = lv_zzkunnr_end ).
    lo_filter->get_value( EXPORTING i_prpid = 'iv_slnum'        IMPORTING e_value = lv_slnum ).
    lo_filter->get_value( EXPORTING i_prpid = 'iv_zqttyp'   IMPORTING e_value = lv_zqttyp ).
    lo_filter->get_value( EXPORTING i_prpid = 'iv_vkgrp'    IMPORTING e_value = lv_vkgrp ).
    lo_filter->get_value( EXPORTING i_prpid = 'iv_slnum_dt' IMPORTING e_value = lv_slnum_dt ).
    lo_filter->get_value( EXPORTING i_prpid = 'iv_apstt_sa' IMPORTING e_value = lv_apstt_sa ).
    lo_filter->get_value( EXPORTING i_prpid = 'iv_apstt_dt' IMPORTING e_value = lv_apstt_dt ).

    zcl_zswxutil_filter=>get_filter_table(
        EXPORTING
        i_input = it_filter_select_options
        IMPORTING
        e_filter_table = lt_where
        e_login        = ls_login ).

    DATA: lt_request_header TYPE tihttpnvp.
    lt_request_header = me->mr_request_details->technical_request-request_header.

    LOOP AT lt_request_header ASSIGNING FIELD-SYMBOL(<fs_request_header>).
        IF <fs_request_header>-name = '~remote_addr'.
        ls_login-sysip = <fs_request_header>-value.
        ENDIF.
    ENDLOOP.

    MOVE-CORRESPONDING ls_login TO ls_login1.

    CALL FUNCTION 'Z_LTSP_IF0401'
        EXPORTING
        is_login       = ls_login1
        iv_vkorg       = lv_vkorg
        iv_kunnr       = lv_kunnr
        iv_qtdat_fr    = lv_qtdat_fr
        iv_qtdat_to    = lv_qtdat_to
        iv_spart       = lv_spart
        iv_zzkunnr_end = lv_zzkunnr_end
        iv_slnum       = lv_slnum
        iv_zqttyp      = lv_zqttyp
        iv_vkgrp       = lv_vkgrp
        iv_slnum_dt    = lv_slnum_dt
        iv_apstt_sa    = lv_apstt_sa
        iv_apstt_dt    = lv_apstt_dt
        IMPORTING
        es_return      = ls_output-es_return
        TABLES
        t_list         = lt_result.


    IF ls_output-es_return-mtype NE 'E'.
    ENDIF.

    LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<fs_result>).
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
            input  = <fs_result>-qtdpo
        IMPORTING
            output = <fs_result>-qtdpo.

*      CLEAR: <fs_result>-qtdpo.
    ENDLOOP.

    MOVE-CORRESPONDING lt_result TO ls_output-et_result.

    CREATE OBJECT lo_transaction.
    lo_transaction->set_data( i_frgid = 'table' i_data = ls_output ).
    ls_entity-output   = lo_transaction->stringify_output( ).

    APPEND ls_entity TO et_entityset.

ENDMETHOD.