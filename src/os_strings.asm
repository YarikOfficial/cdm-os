rsect OS_STRINGS

os_string_text> dc "This is a test text!\n", 0
os_string_greeting> dc "Welcome to ZachetOS!\n", 0

# help/ls include programs added from new branch
os_string_help> dc "Available commands: help, ls, count, adder, input, calc, countbg, adderbg, kill1, kill2, ps, tasks\n", 0
os_string_ls> dc "count\nadder\ninput\ncalc\ncountbg\nadderbg\nkill1\nkill2\nps\ntasks\n", 0

os_string_count> dc "Counter value: ", 0
os_string_adder> dc "Sum value: ", 0
os_string_error_invalid_command> dc "This command is INVALID!\n", 0
os_string_prompt_start> dc ">", 0

# strings for input program
os_string_input_ask> dc "Enter text: ", 0
os_string_input_ans> dc "You typed: ", 0

# strings for calculator program
os_string_calc_a> dc "a: ", 0
os_string_calc_b> dc "b: ", 0
os_string_calc_result> dc "result: ", 0
os_string_newline> dc "\n", 0

# scheduler / task manager strings
os_string_countbg_started> dc "count started in background\n", 0
os_string_adderbg_started> dc "adder started in background\n", 0
os_string_countbg_stopped> dc "count background stopped\n", 0
os_string_adderbg_stopped> dc "adder background stopped\n", 0
os_string_ps_header> dc "PID NAME  STATE TICKS\n", 0
os_string_ps_task1> dc "1   count ", 0
os_string_ps_task2> dc "2   adder ", 0
os_string_ps_run> dc "RUN   ", 0
os_string_ps_stop> dc "STOP  ", 0

end
