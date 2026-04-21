rsect os_strings

os_string_text> dc "This is a test text!\n", 0
os_string_greeting> dc "Welcome to ZachetOS!\n", 0
os_string_help> dc "Available commands: help, ls, prog1, prog2\n", 0
os_string_ls> dc "prog1\nprog2\n", 0
os_string_prog1> dc "Program 1 started!\n", 0
os_string_prog2> dc "Program 2 started!\n", 0
os_string_error_invalid_command> dc "This command is INVALID!\n", 0
os_string_prompt_start> dc ">", 0
    
end