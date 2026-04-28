rsect OS_STRINGS

os_string_text> dc "This is a test text!\n", 0
os_string_greeting> dc "Welcome to ZachetOS!\n", 0

# NEW: help/ls include programs added from new branch
os_string_help> dc "Available commands: help, ls, prog1, prog2, input, calc\n", 0
os_string_ls> dc "prog1\nprog2\ninput\ncalc\n", 0

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

end
