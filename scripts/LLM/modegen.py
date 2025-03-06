from itertools import product
import ast 

file_path = ""

with open(file_path, "r") as file:
    content = file.read()  

table_data = ast.literal_eval(content)

def expand_x(entry):
    expanded_entries = []
    binary_options_3 = ["{:03b}".format(i) for i in range(8)] 
    binary_options_7 = ["{:07b}".format(i) for i in range(128)]  

    op_w, f3_w, f7_w = entry

    if f3_w == "XXX":
        f3_replacements = binary_options_3
    else:
        f3_replacements = [f3_w]

    if f7_w == "XXXXXXX":
        f7_replacements = binary_options_7
    else:
        f7_replacements = [f7_w]

    for f3 in f3_replacements:
        for f7 in f7_replacements:
            expanded_entries.append(op_w + f3 + f7)

    print(f"Original: {entry} -> Expanded: {expanded_entries[:5]} ...")

    return expanded_entries

expanded_table = []

for row in table_data:
    expanded_table.extend(expand_x(row))
    
output_file_path = ""

header = "constrained_range = [[0,6],[12,14],[25,31]]\n"
mode_signal_content = "mode_signal = [\n" + ",\n".join(f"'{entry}'" for entry in expanded_table) + "\n]"

with open(output_file_path, "w") as file:
    file.write(header)
    file.write(mode_signal_content)

