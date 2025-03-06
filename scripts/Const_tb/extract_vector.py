import re
import os

def extract_table_from_file(file_path):

    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    table_pattern = r"^\|.*\|$"
    table_lines = re.findall(table_pattern, content, re.MULTILINE)

    if not table_lines or len(table_lines) < 3:
        return []

    header = [col.strip() for col in table_lines[0].split("|")[1:-1]]

    input_vectors = []

    for line in table_lines[2:]:
        columns = [col.strip() for col in line.split("|")[1:-1]]
        vector = ''.join(columns)
        input_vectors.append(vector)

    return input_vectors

def process_single_file(file_path):
    if file_path.endswith('.txt'):
        print(f"Processing file: {file_path}")

        input_vectors = extract_table_from_file(file_path)

        if input_vectors:
            output_file_path = file_path.replace('.txt', '.list')
            with open(output_file_path, 'w', encoding='utf-8') as f_out:
                for vector in input_vectors:
                    f_out.write(vector + '\n')
            print(f"Saved input vectors to: {output_file_path}")
        else:
            print(f"No valid table found in: {file_path}")
    else:
        print("The provided file is not a .txt file.")

file_path = ""  
process_single_file(file_path)
