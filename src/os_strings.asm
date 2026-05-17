rsect OS_STRINGS

os_string_text> dc "This is a test text!\n", 0
os_string_greeting> dc "Welcome to ZachetOS!\n", 0

# NEW: help/ls include programs added from new branch
os_string_help> dc "Available commands: help, ls, prog1, prog2, input, calc, prog1bg, prog2bg, kill1, kill2, ps, tasks\n", 0
os_string_ls> dc "prog1\nprog2\ninput\ncalc\nprog1bg\nprog2bg\nkill1\nkill2\nps\ntasks\n", 0

os_string_prog1> dc "Program 1 started!\n", 0
os_string_prog2> dc "Program 2 started!\n", 0
os_string_error_invalid_command> dc "This command is INVALID!\n", 0
os_string_prompt_start> dc ">", 0

# NEW: strings for input program
os_string_input_ask> dc "Enter text: ", 0
os_string_input_ans> dc "You typed: ", 0

# NEW: strings for calculator program
os_string_calc_a> dc "a: ", 0
os_string_calc_b> dc "b: ", 0
os_string_calc_result> dc "result: ", 0
os_string_newline> dc "\n", 0

# NEW: scheduler / task manager strings
os_string_prog1bg_started> dc "prog1 started in background\n", 0
os_string_prog2bg_started> dc "prog2 started in background\n", 0
os_string_prog1bg_stopped> dc "prog1 background stopped\n", 0
os_string_prog2bg_stopped> dc "prog2 background stopped\n", 0
os_string_ps_header> dc "PID NAME  STATE TICKS\n", 0
os_string_ps_task1> dc "1   prog1 ", 0
os_string_ps_task2> dc "2   prog2 ", 0
os_string_ps_run> dc "RUN   ", 0
os_string_ps_stop> dc "STOP  ", 0

end
