INCLUDE zc2mmr2003_top                          .  " Global Data

INCLUDE zc2mmr2003_c01                          .
INCLUDE zc2mmr2003_o01                          .  " PBO-Modules
INCLUDE zc2mmr2003_i01                          .  " PAI-Modules
INCLUDE zc2mmr2003_f01                          .  " FORM-Routines

LOAD-OF-PROGRAM.

  PERFORM set_info.
  PERFORM set_data.

 CALL SCREEN '0100'.