*&---------------------------------------------------------------------*
*& Include          ZKEDU0005_S01
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE TEXT-t01.

  PARAMETERS: pa_vkorg TYPE zsed0005t-vkorg OBLIGATORY,
              pa_spart TYPE zsed0005t-spart OBLIGATORY,
              pa_vkgrp TYPE zsed0005t-vkgrp OBLIGATORY.

  SELECT-OPTIONS: so_kunag FOR zsed0005t-kunag,
                  so_kunnr FOR zsed0005t-kunnr.

SELECTION-SCREEN END OF BLOCK bl1.