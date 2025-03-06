import random
import re

def generate_random_inputs(n, num_ones, num_toggles, seed):
    random.seed(seed)
    num_zeros = (10* n) - num_ones 
    vectors = [[] for _ in range(11)]

    if num_toggles == 0:
        line_ones = int(num_ones/10)
        bit = {}
        for i in range(0,line_ones): 
            bit[i] = ['1'] * 11
        for i in range(line_ones, n):  
            bit[i] = ['0'] * 11
        keys = list(bit.keys())
        values = list(bit.values())
        random.shuffle(values)
        shuffled_bit = {key: values[i] for i, key in enumerate(keys)}
        for bit_idx in shuffled_bit.keys(): 
            for i, value in enumerate(shuffled_bit[bit_idx]):
                vectors[i].append(value)
    else: 
        sequence = [random.choice(['0', '1'])]
        for _ in range(num_toggles):
            next_bit = '1' if sequence[-1] == '0' else '0'
            sequence.append(next_bit)
        current_num_ones = sequence.count('1')
        current_num_zeros = sequence.count('0')
        while len(sequence) < (num_ones + num_zeros):
            if current_num_ones < num_ones:
                one_indices = [i for i, value in enumerate(sequence) if value == '1']
                if one_indices: 
                    insert_index = random.choice(one_indices) 
                    sequence.insert(insert_index + 1, '1')  
                    current_num_ones += 1
            elif current_num_zeros < num_zeros:
                zero_indices = [i for i, value in enumerate(sequence) if value == '0']
                if zero_indices:  
                    insert_index = random.choice(zero_indices)  
                    sequence.insert(insert_index + 1, '0') 
                    current_num_zeros += 1
        toggle_error = 0
        for i in range(9, len(sequence) - 1, 10):
            if i + 1 < len(sequence) and (sequence[i], sequence[i + 1]) in [('0', '1'), ('1', '0')]:
                toggle_error += 1
        bit = {}
        for i in range(0, len(sequence), 10):
            bit_index = (i // 10)  
            bit[bit_index] = sequence[i:i + 10]
        keys = list(bit.keys())
        values = list(bit.values())
        #random.shuffle(values)
        #shuffled_bit = {key: values[i] for i, key in enumerate(keys)}
        for bit_idx in bit.keys(): 
            for i, value in enumerate(bit[bit_idx]):
                vectors[i+1].append(value) 
        vectors[0] = vectors[1][:]
        toggle_indices = random.sample(range(len(vectors[0])), toggle_error)
        for toggle_index in toggle_indices:
            if vectors[0][toggle_index] == '0':
                vectors[0][toggle_index] = '1'
            else:
                vectors[0][toggle_index] = '0'
    return vectors

def get_random_pd_values(n):
    pd_values = []
    p_ranges = [(i / 10, (i + 1) / 10) for i in range(0, 10)]
    d_ranges = [(i / 10, (i + 1) / 10) for i in range(0, 10)]
    count1 = 0
    count2 = 0
    for j in range(10* n + 1):
        i_range = range(0, 10 * n + 1, 10) if j == 0 else range(10 * n + 1)
        for i in i_range:
            P = i / (10 * n)
            D = j / (10 * n)
            if D <= 0.1 or (D > 0.1 and ((D*5/9) - (1/18)) <= P <= ((19/18)-(D*5/9))):
                count1 += 1
                for p_min, p_max in p_ranges:
                    if p_min <= P < p_max:
                        for d_min, d_max in d_ranges:
                            if d_min <= D < d_max:
                                pd_values.append((P, D, (p_min, p_max), (d_min, d_max),i,j))
                                count2 += 1
    return pd_values

def generate_vectors(module_name, k, n, seed):
    random.seed(seed)
    output_file = f'/'
    
    pd_values = get_random_pd_values(n)
    p_ranges = [(i / 10, (i + 1) / 10) for i in range(0, 10)]
    d_ranges = [(i / 10, (i + 1) / 10) for i in range(0, 10)]

    with open(output_file, 'w') as f:
        for p_range in p_ranges:
            for d_range in d_ranges:
                filtered_values = [pd for pd in pd_values if pd[2] == p_range and pd[3] == d_range]
                if filtered_values:
                    sampled = random.choices(filtered_values, k=k)
                    sampled_values = []
                    sampled_values += [(i, j) for _, _, _, _, i, j in sampled]
                    for i, j in sampled_values:
                        vectors = generate_random_inputs(n, i,j, seed)
                        #vectors = generate_random_inputs(n, i, j)
                        for vector in vectors:
                            f.write("".join(map(str, vector)) + "\n")

def get_input_bit_count(module_name):
    file_path = f'
    total_bits = 0
    
    try:
        with open(file_path, 'r') as f:
            for line in f:
                if 'input' in line:
                    match = re.search(r'input\s+(\[\d+:\d+\])?\s*(\w+)', line)
                    if match:
                        bit_range = match.group(1)
                        if bit_range: 
                            start_bit, end_bit = map(int, bit_range[1:-1].split(':'))
                            total_bits += (start_bit - end_bit + 1)
                        else:
                            total_bits += 1  
    except FileNotFoundError:
        print(f"Error: File {file_path} not found.")
        return 0
    #print(total_bits)
    return total_bits

if __name__ == "__main__":
    module_name = input("Enter the module name: ")
    k = int(input("Enter the number of samples (k): "))
    seed = 42

    n = get_input_bit_count(module_name)
    generate_vectors(module_name, k, n, seed)

