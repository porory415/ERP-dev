PROCESS BEFORE OUTPUT.
 MODULE STATUS_0100.

*Header ALV
 MODULE set_fcat_layout.
 MODULE display_screen.

*Item ALV
MODULE set_fcat_layout2.
MODULE display_screen2.

PROCESS AFTER INPUT.
 field : gv_vendcd MODULE set_vendorc on REQUEST.
 MODULE USER_COMMAND_0100.
 MODULE exit_0100 AT EXIT-COMMAND.

PROCESS ON VALUE-REQUEST.
 FIELD : gv_vendcd MODULE f4_vendorc.