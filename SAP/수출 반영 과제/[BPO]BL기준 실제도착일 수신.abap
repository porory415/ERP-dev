FUNCTION z_te_ifr0019.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  EXPORTING
*"     REFERENCE(EX_OUTPUT) TYPE  ZDT_GRPEXP0310_PRO_RESPONSE
*"  TABLES
*"      IT_TAB TYPE  ZDT_GRPEXP0310_PRO_IT_RESU_TAB OPTIONAL
*"----------------------------------------------------------------------

  DATA: lv_chfd    TYPE zteardat,      " ZTEARDAT : ardat의 데이터 엘레먼트
        lv_bookno  TYPE ztetblk-bilno, " B/L 관리번호
        lv_bokno   TYPE ztebokno,      " data element: Booking 관리번호
        lv_err     TYPE bapi_mtype,    " export param
        lv_message TYPE bapi_msg.      " export param

  LOOP AT it_tab.  "bpo로 넘어온 데이터가 it_tab에 담겨 있는 상태

    "변경할 필드 설정
    CLEAR lv_chfd.
    MOVE it_tab-dsatadt TO lv_chfd.   "실제 도착일을 도착예정일 필드에 넣어줌.

*  -------------------------------------------------
*    (4)B/L 변경
*  -------------------------------------------------
    "ZTETBLK 필드 변경이력도 남긴다.
    PERFORM chg_bl_info2  USING lv_chfd it_tab-bokno it_tab-blno
                          CHANGING lv_err lv_message.


    IF lv_err EQ 'E'.
      ex_output-header-z_result_cd   = lv_err.
      ex_output-header-z_result_msg  = lv_message.
      EXIT.
    ENDIF.

  ENDLOOP.

  IF lv_err = 'E'.
    ROLLBACK WORK.
  ELSE.
    COMMIT WORK.
  ENDIF.

ENDFUNCTION.


*&---------------------------------------------------------------------*
*& Form chg_bl_info2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_CHFD
*&      --> IT_TAB_BOKNO
*&      <-- LV_ERR
*&      <-- LV_MESSAGE
*&---------------------------------------------------------------------*
FORM chg_bl_info2  USING    pv_chfd
                            pv_bokno
                            pv_blno
                   CHANGING pv_err
                            pv_message.

  DATA : BEGIN OF xztetblp OCCURS 0.
           INCLUDE STRUCTURE vztetblp.
  DATA : END   OF xztetblp.

  DATA : BEGIN OF yztetblp OCCURS 0.
           INCLUDE STRUCTURE vztetblp.
  DATA : END   OF yztetblp.

  DATA : BEGIN OF xztetble OCCURS 0.
           INCLUDE STRUCTURE vztetble.
  DATA : END   OF xztetble.

  DATA : BEGIN OF yztetble OCCURS 0.
           INCLUDE STRUCTURE vztetble.
  DATA : END   OF yztetble.

  DATA: BEGIN OF lt_bl OCCURS 0,
          bilno LIKE ztetblp-bilno,
          bokno LIKE ztetblp-bokno,
        END OF lt_bl.

  DATA lt_ztetblk LIKE ztetblk  OCCURS 0 WITH HEADER LINE.

  DATA: g_mode TYPE c,
        l_upd  TYPE c.


  CLEAR: ztetblk.

  l_upd = 'U'.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE lt_bl
    FROM ztetblk AS a
    INNER JOIN ztetblp AS b
    ON a~bilno EQ b~bilno
    WHERE a~hblno EQ pv_blno
      AND b~bokno EQ pv_bokno.
  DELETE ADJACENT DUPLICATES FROM lt_bl.

  LOOP AT lt_bl.

    SELECT SINGLE *
      INTO CORRESPONDING FIELDS OF ztetblk
      FROM ztetblk
     WHERE bilno = lt_bl-bilno.

    CHECK sy-subrc = 0.

    *ztetblk = ztetblk.
    MOVE pv_chfd TO ztetblk-ardat.    "실제 도착일 값

    CLEAR lt_ztetblk[].
    ztetblk-unam = sy-uname.
    ztetblk-udat = sy-datum.
    ztetblk-utme = sy-uzeit.
    APPEND ztetblk TO lt_ztetblk.
    MODIFY ztetblk FROM TABLE lt_ztetblk.


*  -------------------------------------------------
*  > Change Document
*  -------------------------------------------------
    PERFORM p8120_change_document(saplz_te_main_for_bl) TABLES  xztetblp
                                          yztetblp
                                          xztetble
                                          yztetble
                                  USING   ztetblk
                                          *ztetblk
                                          g_mode
                                          sy-tcode
                                          l_upd.

  ENDLOOP.

ENDFORM.