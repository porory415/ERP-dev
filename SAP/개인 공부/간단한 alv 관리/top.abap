*&---------------------------------------------------------------------*
*& Include ZSAMPLE4_TOP                             - 모듈풀              ZSAMPLE4
*&---------------------------------------------------------------------*
PROGRAM zsample4.

TABLES: zsample_jh.


DATA: BEGIN OF gs_data.
        INCLUDE STRUCTURE zsample_jh.
DATA:   celltab TYPE lvc_t_styl,
        mark(1),
      END OF gs_data,
      gt_data LIKE TABLE OF gs_data.

DATA: gt_data2 LIKE TABLE OF gs_data.

DATA: go_container TYPE REF TO cl_gui_custom_container,
      go_grid      TYPE REF TO cl_gui_alv_grid,
      gt_fcat      TYPE lvc_t_fcat,
      gs_fcat      TYPE lvc_s_fcat,
      gs_layout    TYPE lvc_s_layo,
      gs_variant   TYPE disvariant,
      gs_stable    TYPE lvc_s_stbl.


DATA : gv_okcode  TYPE sy-ucomm,
       gv_date    TYPE sy-datum,
       gv_time    TYPE sy-timlo,
       gv_id      TYPE sy-uname,
       gt_exclude TYPE ui_functions,
       gv_answer  TYPE c,
       pa_rd1     VALUE 'X',  "처음엔 무조건 어느하나에 선택모드를 줘야함
       pa_rd2.

DATA: gv_err, "X: Error
      gt_rows TYPE lvc_t_row.