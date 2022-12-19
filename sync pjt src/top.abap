*&---------------------------------------------------------------------*
*& Include ZC2MMR2003_TOP                           - Report ZC2MMR2003
*&---------------------------------------------------------------------*
REPORT zc2mmr2003 MESSAGE-ID zc202.

TABLES : ztc2mm2007, ztc2mm2004, ztc2mm2005, ztc2md2006.

CLASS : lcl_event_handler DEFINITION DEFERRED.

DATA: gv_plant  TYPE c LENGTH 4,
      gv_ddzid  TYPE sy-uname,
      gv_vendcd TYPE ztc2mm2007-vendorc,
      gv_purcym TYPE ztc2mm2007-purcym.


* Header ALV 왼쪽에 보이는....
DATA : gcl_container TYPE REF TO cl_gui_custom_container,
       gcl_grid      TYPE REF TO cl_gui_alv_grid,
       gcl_handler   TYPE REF TO lcl_event_handler,
       gs_fcat       TYPE lvc_s_fcat,
       gt_fcat       TYPE lvc_t_fcat,
       gs_layout     TYPE lvc_s_layo,
       gs_variant    TYPE disvariant,
       gs_stable     TYPE lvc_s_stbl,
       gs_sort       TYPE lvc_s_sort,
       gt_sort       TYPE lvc_t_sort.

* Item ALV 오른쪽에 보이는....
DATA : gcl_container2 TYPE REF TO cl_gui_custom_container,
       gcl_grid2      TYPE REF TO cl_gui_alv_grid,
       gcl_handler2   TYPE REF TO lcl_event_handler,
       gs_layout2     TYPE lvc_s_layo,
       gs_fcat2       TYPE lvc_s_fcat,
       gt_fcat2       TYPE lvc_t_fcat,
       gs_variant2    TYPE disvariant,
       gs_stable2     TYPE lvc_s_stbl.

*POPUP
DATA : gcl_container3 TYPE REF TO cl_gui_custom_container,
       gcl_grid3      TYPE REF TO cl_gui_alv_grid,
       gcl_handler3   TYPE REF TO lcl_event_handler,
       gs_layout3     TYPE lvc_s_layo,
       gs_fcat3       TYPE lvc_s_fcat,
       gt_fcat3       TYPE lvc_t_fcat,
       gs_variant3    TYPE disvariant,
       gs_stable3     TYPE lvc_s_stbl.

* header - 마감테이블   왼쪽에 보여지는...
DATA : BEGIN OF gs_data.
         INCLUDE STRUCTURE ztc2mm2007.
DATA :   status TYPE c LENGTH 4,
         color  TYPE lvc_t_scol,
       END OF gs_data,
       gt_Data LIKE TABLE OF gs_data.


* ITEM - 구매오더헤더   오른쯕에 보여지는...
DATA : BEGIN OF gs_data2.
         INCLUDE STRUCTURE ztc2mm2004.
DATA :  status TYPE c LENGTH 4,
         color  TYPE lvc_t_scol,
       END OF gs_data2,
       gt_data2 LIKE TABLE OF gs_data2.

* POPUP - 구매오더 아이템   팝업으로 주문내용 상세표시...
*  DATA : gs_data3 LIKE ztc2mm2005,
*         gt_data3 LIKE TABLE OF gs_data3.
DATA : BEGIN OF gs_data3.
         INCLUDE STRUCTURE ztc2mm2005.
DATA :   matrnm TYPE ztc2md2006-matrnm,
       END OF gs_data3,
       gt_data3 LIKE TABLE OF gs_data3.

DATA : gv_okcode TYPE sy-ucomm.

DATA : gs_row  TYPE lvc_s_row,
       gt_rows TYPE lvc_t_row.

DATA : gv_input TYPE ztc2md2005-vendorn.