*&---------------------------------------------------------------------*
*& Include ZKEDU0005_TOP                            - Report ZKEDU0005
*&---------------------------------------------------------------------*
REPORT zkedu0005 NO STANDARD PAGE HEADING MESSAGE-ID zmsd.

TABLES: zsed0005t.

*--------------------------------------------------------------------*
* SCREEN
*--------------------------------------------------------------------*
DATA : gv_okcode   LIKE sy-ucomm,
       gv_saveok   LIKE sy-ucomm.

* SELECTED ROWS
DATA : gt_rows TYPE lvc_t_row.


*--------------------------------------------------------------------*
* Variables
*--------------------------------------------------------------------*
DATA : gv_err.  "X:Error

************************************************************************
* The Declaration of Variables
************************************************************************
DATA: BEGIN OF gt_email occurs 0.
      include STRUCTURE zsed0005t.
*        vkorg       TYPE         zsed0005t-vkorg,
*        spart       TYPE         zsed0005t-spart,
*        vkgrp       TYPE         zsed0005t-vkgrp,
*        kunag       TYPE         zsed0005t-kunag,
*        name1       TYPE         kna1-name1,
*        custmail    TYPE         zsed0005t-custmail,
*        custmail2   TYPE         zsed0005t-custmail2,
*        custmail_3  TYPE         zsed0005t-custmail_3,
*        kunnr       TYPE         zsed0005t-kunnr,
*        custmail2_2 TYPE         zsed0005t-custmail2_2,
*        custmail2_3 TYPE         zsed0005t-custmail2_3,
*        salesman    TYPE         zsed0005t-salesman,
*        salesmail   TYPE         zsed0005t-salesmail,
*        salesman2   TYPE         zsed0005t-salesman2,
*        salesmail2  TYPE         zsed0005t-salesmail2,
*        salestel    TYPE         zsed0005t-salestel,
*        sendtype    TYPE         zsed0005t-sendtype,
*        mailtype    TYPE         zsed0005t-mailtype,
*        comnt       TYPE         zsed0005t-comnt,
     DATA : name1 TYPE c LENGTH 35.
     DATA : name2 TYPE c LENGTH 35,
*     DATA : NAME1 TYPE KNA1-NAME1.
*     DATA : NAME2 TYPE KNA1-NAME1,
           domvalue_l like dd07v-domvalue_l,
           mark(1),
           celltab TYPE lvc_t_styl.
     data: END OF gt_email.
     data: gs_email like line of gt_email.
*      data: gt_email LIKE TABLE OF gs_email.



*&---------------------------------------------------------------------*
*& ALV varaibles
*&---------------------------------------------------------------------*
DATA: gv_cont_name TYPE scrfname VALUE 'CCONT',
      go_ccont     TYPE REF TO cl_gui_custom_container,
      go_grid      TYPE REF TO cl_gui_alv_grid,
      gs_layo      TYPE        lvc_s_layo,
      gs_fcat      TYPE        lvc_s_fcat,
      gt_fcat      TYPE        lvc_t_fcat,
      gs_stbl      TYPE        lvc_s_stbl,
      gs_variant   TYPE        disvariant,
      gs_exclude   TYPE        ui_func,
      gt_exclude   TYPE        ui_functions.

*--------------------------------------------------------------------*
* CONSTANTS
*--------------------------------------------------------------------*
CONSTANTS : c_a       TYPE char01 VALUE 'A',
            c_b       TYPE char01 VALUE 'B',
            c_c       TYPE char01 VALUE 'C',
            c_d       TYPE char01 VALUE 'D',
            c_e       TYPE char01 VALUE 'E',
            c_f       TYPE char01 VALUE 'F',
            c_g       TYPE char01 VALUE 'G',
            c_h       TYPE char01 VALUE 'H',
            c_h_small TYPE char01 VALUE 'h',
            c_i       TYPE char01 VALUE 'I',
            c_j       TYPE char01 VALUE 'J',
            c_k       TYPE char01 VALUE 'K',
            c_l       TYPE char01 VALUE 'L',
            c_m       TYPE char01 VALUE 'M',
            c_n       TYPE char01 VALUE 'N',
            c_o       TYPE char01 VALUE 'O',
            c_p       TYPE char01 VALUE 'P',
            c_q       TYPE char01 VALUE 'Q',
            c_r       TYPE char01 VALUE 'R',
            c_s       TYPE char01 VALUE 'S',
            c_t       TYPE char01 VALUE 'T',
            c_u       TYPE char01 VALUE 'U',
            c_v       TYPE char01 VALUE 'V',
            c_w       TYPE char01 VALUE 'W',
            c_x       TYPE char01 VALUE 'X',
            c_y       TYPE char01 VALUE 'Y',
            c_z       TYPE char01 VALUE 'Z',
            c_0       TYPE char01 VALUE '0',
            c_1       TYPE char01 VALUE '1',
            c_2       TYPE char01 VALUE '2',
            c_3       TYPE char01 VALUE '3',
            c_4       TYPE char01 VALUE '4',
            c_5       TYPE char01 VALUE '5',
            c_6       TYPE char01 VALUE '6',
            c_7       TYPE char01 VALUE '7',
            c_8       TYPE char01 VALUE '8',
            c_9       TYPE char01 VALUE '9',
            c_10      TYPE char02 VALUE '10',
            c_11      TYPE char02 VALUE '11',
            c_12      TYPE char02 VALUE '12',
            c_13      TYPE char02 VALUE '13',
            c_14      TYPE char02 VALUE '14',
            c_15      TYPE char02 VALUE '15',
            c_16      TYPE char02 VALUE '16',
            c_17      TYPE char02 VALUE '17',
            c_18      TYPE char02 VALUE '18',
            c_19      TYPE char02 VALUE '19',
            c_21      TYPE char02 VALUE '21',
            c_22      TYPE char02 VALUE '22',
            c_23      TYPE char02 VALUE '23',
            c_24      TYPE char02 VALUE '24',
            c_25      TYPE char02 VALUE '25',
            c_26      TYPE char2  VALUE '26',
            c_27      TYPE char2  VALUE '27',
            c_28      TYPE char2  VALUE '28',
            c_29      TYPE char2  VALUE '29',
            c_31      TYPE char2  VALUE '31',
            c_32      TYPE char2  VALUE '32',
            c_33      TYPE char2  VALUE '33',
            c_34      TYPE char2  VALUE '34',
            c_35      TYPE char2  VALUE '35',
            c_36      TYPE char2  VALUE '36',
            c_37      TYPE char2  VALUE '37',
            c_38      TYPE char2  VALUE '38',
            c_39      TYPE char2  VALUE '39',
            c_41      TYPE char2  VALUE '41',
            c_42      TYPE char2  VALUE '42',
            c_43      TYPE char2  VALUE '43',
            c_44      TYPE char2  VALUE '44',
            c_45      TYPE char2  VALUE '45',
            c_46      TYPE char2  VALUE '46',
            c_47      TYPE char2  VALUE '47',
            c_48      TYPE char2  VALUE '48',
            c_49      TYPE char2  VALUE '49'.