import re

def extract_commands_from_file(filename):
    with open(filename, 'r', encoding='utf-8') as file:
        content = file.read()
    
    # Find all commands in markdown table rows
    pattern = r'^\| \\([a-zA-Z]+)'
    commands = re.findall(pattern, content, re.MULTILINE)
    
    return commands

# Example usage:
commands = extract_commands_from_file('Commands.md')
print('["' + '", "'.join(commands) + '"]')
