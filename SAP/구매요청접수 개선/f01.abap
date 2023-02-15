*&---------------------------------------------------------------------*
*  구매요청 계정지정
*----------------------------------------------------------------------*
FORM get_pr_data_ebkn_list TABLES pt_head STRUCTURE gt_head.
    DATA : lt_cepct   LIKE SORTED TABLE OF cepct WITH HEADER LINE              "추가
                      WITH NON-UNIQUE KEY prctr kokrs,
           lt_cskt    LIKE SORTED TABLE OF cskt  WITH HEADER LINE
                      WITH NON-UNIQUE KEY kostl kokrs,
           lt_fmfctrt LIKE SORTED TABLE OF fmfctrt WITH HEADER LINE
                               WITH NON-UNIQUE KEY fictr fikrs.
  
    TYPES : BEGIN OF ty_anla,
              anln1 LIKE anla-anln1,
              txt50 LIKE anla-txt50,
              bukrs LIKE anla-bukrs,
            END OF ty_anla.
  
    DATA : lt_anla    TYPE SORTED TABLE OF ty_anla WITH HEADER LINE
                      WITH NON-UNIQUE KEY anln1.
  
    TYPES : BEGIN OF ty_aufk,
              aufnr LIKE aufk-aufnr,
              ktext LIKE aufk-ktext,
            END OF ty_aufk.
  
    DATA : lt_aufk    TYPE SORTED TABLE OF ty_aufk WITH HEADER LINE
                      WITH UNIQUE KEY aufnr.
    DATA: ls_head LIKE gt_head.
  
    REFRESH gt_ebkn.
  
*&---------------------------------------------------------------------*
*   코스트센터, 손익센터, 자금관리센터 명 조회로직 개선
*----------------------------------------------------------------------*

DATA: BEGIN OF ls_ebkn.
INCLUDE STRUCTURE gt_ebkn.
DATA:   lfdat LIKE pt_head-lfdat,
END OF ls_ebkn.

DATA: lt_ebkn LIKE TABLE OF ls_ebkn WITH HEADER LINE.

SELECT  banfn
bnfpo
kokrs
sakto
prctr                         "손익센터
kostl                         "코스트센터
fistl
vbeln
vbelp
anln1
ps_psp_pnr AS pspnr
aufnr
INTO CORRESPONDING FIELDS OF TABLE lt_ebkn   "기존 GT_EBKN -> LT_EBKN으로 변경
FROM ebkn
 FOR ALL ENTRIES IN pt_head
WHERE banfn EQ pt_head-banfn
 AND bnfpo EQ pt_head-bnfpo
 AND vbeln IN s_vbeln
 AND vbelp IN s_vbelp.

LOOP AT lt_ebkn.
READ TABLE pt_head WITH KEY banfn = c_banfn
                      bnfpo = pt_head-bnfpo.

lt_ebkn-lfdat = pt_head-lfdat.

MODIFY lt_ebkn .
ENDLOOP.

IF lt_ebkn[] IS NOT INITIAL.

SELECT prctr ktext kokrs datbi    "손익센터, 일반이름, 관리회계영역, 효력종료일
INTO CORRESPONDING FIELDS OF TABLE lt_cepct[]
FROM cepct
FOR ALL ENTRIES IN lt_ebkn
WHERE spras = sy-langu
AND kokrs = lt_ebkn-kokrs
AND prctr = lt_ebkn-prctr
AND datbi >= lt_ebkn-lfdat.

SELECT kostl ktext kokrs datbi    "코스트센터, 일반이름, 관리회계영역, 효력종료일
INTO CORRESPONDING FIELDS OF TABLE lt_cskt[]
FROM cskt
FOR ALL ENTRIES IN lt_ebkn
WHERE spras = sy-langu
AND kokrs = lt_ebkn-kokrs
AND kostl = lt_ebkn-kostl
AND datbi >= lt_ebkn-lfdat.

SELECT fictr bezeich fikrs datab datbis    "자금관리센터, 이름, 재무관리영역, 효력시작일, 효력종료일
INTO CORRESPONDING FIELDS OF TABLE lt_fmfctrt[]
FROM fmfctrt
FOR ALL ENTRIES IN lt_ebkn
WHERE spras = sy-langu
AND fictr = lt_ebkn-fistl
AND datab <= lt_ebkn-lfdat    "효력 시작일
AND datbis >= lt_ebkn-lfdat.  "효력 종료일
ENDIF.

LOOP AT lt_ebkn.

"GL 계정
PERFORM get_sakto_text USING    lt_ebkn-sakto
                 CHANGING lt_ebkn-sakto_tx.
IF lt_ebkn-prctr IS NOT INITIAL AND                    "추가
lt_ebkn-kokrs IS NOT INITIAL.

READ TABLE lt_cepct WITH KEY prctr = lt_ebkn-prctr
                         kokrs = lt_ebkn-kokrs.


IF sy-subrc = 0.
lt_ebkn-prctr_tx = lt_cepct-ktext.
ELSE.

"손익센터
PERFORM get_prctr_text USING    lt_ebkn-prctr lt_ebkn-kokrs
                     CHANGING lt_ebkn-prctr_tx.
lt_cepct-prctr = lt_ebkn-prctr.
lt_cepct-kokrs = lt_ebkn-kokrs.
lt_cepct-ktext = lt_ebkn-prctr_tx.
INSERT TABLE lt_cepct.
ENDIF.

ENDIF.

"코스트센터
IF lt_ebkn-kostl IS NOT INITIAL AND                    "추가
lt_ebkn-kokrs IS NOT INITIAL.

READ TABLE lt_cskt WITH KEY kostl = lt_ebkn-kostl
                        kokrs = lt_ebkn-kokrs.
IF sy-subrc = 0.
lt_ebkn-kostl_tx = lt_cskt-ktext.
ELSE.

PERFORM get_kostl_text USING    lt_ebkn-kostl lt_ebkn-kokrs
                     CHANGING lt_ebkn-kostl_tx.
lt_cskt-kostl = lt_ebkn-kostl.
lt_cskt-kokrs = lt_ebkn-kokrs.
lt_cskt-ktext = lt_ebkn-kostl_tx.
INSERT TABLE lt_cskt.
ENDIF.

ENDIF.


"Fund Center
IF lt_ebkn-fistl IS NOT INITIAL AND                    "추가
lt_ebkn-kokrs IS NOT INITIAL.

READ TABLE lt_fmfctrt WITH KEY fictr = lt_ebkn-fistl
                           fikrs = lt_ebkn-kokrs.
IF sy-subrc = 0.
lt_ebkn-fistl_tx = lt_fmfctrt-bezeich.
ELSE.

PERFORM get_fistl_text USING    lt_ebkn-fistl lt_ebkn-kokrs
                     CHANGING lt_ebkn-fistl_tx.
lt_fmfctrt-fictr   = lt_ebkn-fistl.
lt_fmfctrt-fikrs   = lt_ebkn-kokrs.
lt_fmfctrt-bezeich = lt_ebkn-fistl_tx.
INSERT TABLE lt_fmfctrt.
ENDIF.

ENDIF.

"자산번호
IF lt_ebkn-anln1 IS NOT INITIAL AND                    "추가
lt_ebkn-kokrs IS NOT INITIAL.

READ TABLE lt_anla WITH KEY anln1 = lt_ebkn-anln1
                        bukrs = lt_ebkn-kokrs.
IF sy-subrc = 0.
gt_ebkn-anln1_tx = lt_anla-txt50.
ELSE.

PERFORM get_anln1_text USING    lt_ebkn-anln1 lt_ebkn-kokrs
                     CHANGING lt_ebkn-anln1_tx.
lt_anla-anln1 = lt_ebkn-anln1.
lt_anla-bukrs = lt_ebkn-kokrs.
lt_anla-txt50 = lt_ebkn-anln1_tx.
INSERT TABLE lt_anla.
ENDIF.

ENDIF.

"WBS 요소
IF lt_ebkn-pspnr <> '00000000'.                "추가
PERFORM get_pspnr_text CHANGING lt_ebkn-pspnr lt_ebkn-pspnr_tx.
ENDIF.

"Internal Order
IF lt_ebkn-aufnr IS NOT INITIAL.                  "추가

READ TABLE lt_aufk WITH KEY aufnr = lt_ebkn-aufnr.
IF sy-subrc = 0.
lt_ebkn-aufnr_tx = lt_aufk-ktext.
ELSE.
PERFORM get_aufnr_text USING    lt_ebkn-aufnr
                     CHANGING lt_ebkn-aufnr_tx.
lt_aufk-aufnr = lt_ebkn-aufnr.
lt_aufk-ktext = lt_ebkn-aufnr_tx.
INSERT TABLE lt_aufk.
ENDIF.

ENDIF.

APPEND lt_ebkn TO gt_ebkn.
CLEAR lt_ebkn.
ENDLOOP.

SORT gt_ebkn BY banfn bnfpo.

ENDFORM.