FUNCTION z_te_ifr0019.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  EXPORTING
*"     VALUE(EX_MTYPE) TYPE  BAPI_MTYPE
*"     VALUE(EX_MESSAGE) TYPE  BAPI_MSG
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
    MOVE it_tab-dsatadt TO lv_chfd.
    lv_chfd = it_tab-dsatadt.

*    "GI 상태면 처리 할 수 없다.         => GI상태 이후에 발생하는 로직이기 때문에 있으면 안됨
*    PERFORM check_is_gi USING lv_bokno
*                        CHANGING lv_err lv_message.
*
*    IF lv_err = 'E'.
*      ex_mtype = lv_err.
*      ex_message = lv_message.
*      EXIT.
*    ENDIF.

*  -------------------------------------------------
*    (4)B/L 변경
*  -------------------------------------------------
    "ZTETBLK 필드 변경이력도 남긴다.
    PERFORM chg_bl_info USING    lv_chfd it_tab-bokno lv_bookno    " 날짜, booking 관리번호, B/L 관리번호
                        CHANGING lv_err  lv_message.

    IF lv_err EQ 'E'.
      ex_mtype = lv_err.
      ex_message = lv_message.
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
*& Form CHG_BL_INFO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_CHFD
*&      --> IT_TAB_BOKNO
*&      <-- LV_ERR
*&      <-- LV_MESSAGE
*&---------------------------------------------------------------------*
FORM chg_bl_info  USING    pv_chfd TYPE zteardat
                           pv_bokno
                           lv_bookno
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
        END OF lt_bl.

  DATA lt_ztetblk LIKE ztetblk  OCCURS 0 WITH HEADER LINE.

  TABLES: *ztetblk, ztetblk.


  DATA: g_mode TYPE c,
        l_upd  TYPE c.


  CLEAR: ztetblk.

  l_upd = 'U'.

  " [원본]
*  SELECT BILNO
*    INTO TABLE LT_BL
*    FROM ZTETBLP
*   WHERE TRDNO IN (
*          SELECT TRDNO
*          FROM ZTETTDK
*          WHERE BOKNO = PV_BOKNO ).
*  SORT LT_BL BY BILNO.
*  DELETE ADJACENT DUPLICATES FROM LT_BL.

  " [UPDATE 전 체크 로직]
  SELECT *
    FROM ztetblk AS a
    INNER JOIN zteblp AS b
    ON a~bilno = b~bilno
    WHERE a~hblno = it_tab-blno
      AND b~bokno = it_tab-bokno.


    LOOP AT lt_bl.

      SELECT SINGLE *
        INTO CORRESPONDING FIELDS OF ztetblk
        FROM ztetblk
       WHERE bilno = lt_bl-bilno.

      CHECK sy-subrc = 0.

      *ztetblk = ztetblk.
      MOVE-CORRESPONDING pv_chfd TO ztetblk.

      CLEAR lt_ztetblk[].
      ztetblk-unam = sy-uname.        "그대로 살리기.
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