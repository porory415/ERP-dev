FUNCTION Z_TE_IFR0012.
*"----------------------------------------------------------------------
*"* "Local interface:
*"  EXPORTING
*"     VALUE(EX_MTYPE) TYPE  BAPI_MTYPE
*"     VALUE(EX_MESSAGE) TYPE  BAPI_MSG
*"  TABLES
*"      IT_TAB TYPE  ZDT_GRPEXP0170_PRO_ZTESEB_TAB1 OPTIONAL
*"----------------------------------------------------------------------

*    PTDSN  2   경유항 (Port of Discharge) 국가코드  POD국가
*    PTDSC  3   경유항 (Port of Discharge) 코드      POD포트
*    ALPTN  2   도착항 (Place of Delivery) 국가 Code PDL국가
*    ALPTC  3   도착항 (Place of Delivery)  Code     PDL포트
*    ETDDT  19  출항예정일 (ETD)       ETD
*    ETADT  19  도착예정일 (ETA)       ETA
*    CARTX  200 선기명 (Vessel Name)   VSN
*    VOYNO  200 항차 (Voyage No.)      VOY
*    PODDT  19  Discharge Date         POD

  DATA: LV_CHFD     TYPE ZTDSCHBK,
        LV_BOKNO    TYPE ZTEBOKNO,
        LV_ERR      TYPE BAPI_MTYPE,
        LV_MESSAGE  TYPE BAPI_MSG.


  LOOP AT IT_TAB.

    "변경할 필드 설정"
    MOVE-CORRESPONDING IT_TAB TO LV_CHFD.
    LV_BOKNO = IT_TAB-BOKNO.

    "GI상태면 처리할 수 없다.
    PERFORM CHECK_IS_GI USING LV_BOKNO
                             CHANGING LV_ERR
                                      LV_MESSAGE.

    IF LV_ERR EQ 'E'.
      EX_MTYPE = LV_ERR.
      EX_MESSAGE = LV_MESSAGE.
      EXIT.
    ENDIF.
*  -------------------------------------------------
*    (1) Bokking 정보 변경
*  -------------------------------------------------
    PERFORM CHG_BOKKING_INFO USING LV_CHFD LV_BOKNO
                             CHANGING LV_ERR
                                      LV_MESSAGE.
    IF LV_ERR EQ 'E'.
      EX_MTYPE = LV_ERR.
      EX_MESSAGE = LV_MESSAGE.
      EXIT.
    ENDIF.
    CHECK LV_ERR IS INITIAL."W인 경우 Pass"

*  -------------------------------------------------
*    (2)선적서류 변경(S/D)
*  -------------------------------------------------
    PERFORM CHG_SD_INFO USING LV_CHFD LV_BOKNO
                             CHANGING LV_ERR
                                      LV_MESSAGE.
    IF LV_ERR EQ 'E'.
      EX_MTYPE = LV_ERR.
      EX_MESSAGE = LV_MESSAGE.
      EXIT.
    ENDIF.
    CHECK LV_ERR IS INITIAL."W인 경우 Pass"

*  -------------------------------------------------
*    (3)S/R 변경
*  -------------------------------------------------
    PERFORM CHG_SR_INFO USING LV_CHFD IT_TAB-BUKRS LV_BOKNO
                             CHANGING LV_ERR
                                      LV_MESSAGE.
    IF LV_ERR EQ 'E'.
      EX_MTYPE = LV_ERR.
      EX_MESSAGE = LV_MESSAGE.
      EXIT.
    ENDIF.
    CHECK LV_ERR IS INITIAL."W인 경우 Pass"

*  -------------------------------------------------
*    (4)B/L 변경
*  -------------------------------------------------
    PERFORM CHG_BL_INFO USING LV_CHFD IT_TAB-BOKNO
                             CHANGING LV_ERR
                                      LV_MESSAGE.
    IF LV_ERR EQ 'E'.
      EX_MTYPE = LV_ERR.
      EX_MESSAGE = LV_MESSAGE.
      EXIT.
    ENDIF.

  ENDLOOP.

  IF LV_ERR EQ 'E'.
    ROLLBACK WORK.
  ELSE.
    COMMIT WORK.
  ENDIF.


ENDFUNCTION.