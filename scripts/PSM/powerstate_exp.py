import matplotlib.pyplot as plt
from collections import Counter
from mpl_toolkits.mplot3d import Axes3D 
import numpy as np
import random
import json
import os

module_name = input("Enter module name: ")

in_info_file_path = f""
out_info_file_path =  f""

def read_file_and_remove_newlines(file_path):
    with open(file_path, 'r') as file:
        cleaned_data = [line.strip() for line in file]
    return cleaned_data

data_in = read_file_and_remove_newlines(in_info_file_path)
data_out = read_file_and_remove_newlines(out_info_file_path)

def split_bits(input_array):
    return [list(binary) for binary in input_array]

in_splited_array = split_bits(data_in)
out_splited_array = split_bits(data_out)

def compute_pin(arr):
    Pin = []
    for i in range(0, len(arr)-1, 11):
        combined = arr[i+1] + arr[i+2]+ arr[i+3]+ arr[i+4]+ arr[i+5]+ arr[i+6]+ arr[i+7]+ arr[i+8]+ arr[i+9]+ arr[i+10]
        ones_count = sum(1 for bit in combined if bit == '1')
        pin_value = ones_count / len(combined)
        Pin.append(pin_value)
    return Pin

def compute_din(arr):
    Din = []
    for i in range(0, len(arr)-1, 11):
        value = 0
        for k in range(10): 
            diff = [1 if arr[i+k][j] != arr[i+k+1][j] else 0 for j in range(len(arr[i]))]
            value += sum(diff)
        value = value / (10*len(arr[0]))
        Din.append(value) 
    return Din

Pin = compute_pin(in_splited_array)
Din = compute_din(in_splited_array)
Dout = compute_din(out_splited_array)

points = list(zip(Pin, Din, Dout))  

fig = plt.figure(figsize=(10, 10))
ax = fig.add_subplot(111, projection='3d')  

bins = np.arange(0, 1.1, 0.1)

red_cube_count = 0
blue_cube_count = 0
for x in bins[:-1]:
    for y in bins[:-1]:
        for z in bins[:-1]:
            x_mask = (Pin >= x) & (Pin < x + 0.1)
            y_mask = (Din >= y) & (Din < y + 0.1)
            z_mask = (Dout >= z) & (Dout < z + 0.1)
            
            if np.any(x_mask & y_mask & z_mask):
                ax.bar3d(x, y, z, 0.1, 0.1, 0.1, color='blue', alpha=0.4)  
            if np.any(x_mask & y_mask):
                ax.bar3d(x, y, z, 0.1, 0.1, 0.1, color='r', alpha=0.05)  
                red_cube_count += 1 

ax.set_title('(Pin, Din, Dout) Distribution') 
ax.set_xlabel('Pin') 
ax.set_ylabel('Din')  
ax.set_zlabel('Dout')  

ax.set_xlim(0, 1)
ax.set_ylim(0, 1)
ax.set_zlim(0, 1)

ax.grid(True, linestyle='--', linewidth=0.5)
ax.text2D(
    0.05, 0.95, 
    f'Red cubes count: {red_cube_count}\nBlue cubes count: {blue_cube_count}', 
    transform=ax.transAxes, 
    fontsize=12, 
    color='black' 
)



base_name = '' + module_name

plotpath = base_name + '_plot.png'
plt.savefig(plotpath, dpi=300)

fig_xy = plt.figure(figsize=(10, 10))
ax_xy = fig_xy.add_subplot(111)
for x in bins[:-1]:
    for y in bins[:-1]:
        x_mask = (Pin >= x) & (Pin < x + 0.1)
        y_mask = (Din >= y) & (Din < y + 0.1)
        dout_values = [Dout[i] for i in range(len(Pin)) if x_mask[i] and y_mask[i]]
        if dout_values:
            unique_dout_values = list(set(dout_values))
            rounded_dout_values = [min(int(d * 10 + 1) / 10, 1) for d in unique_dout_values]
            rounded_dout_values = list(set(rounded_dout_values))
            dout_text = "\n".join([f'{rounded_dout_values[i]:.1f}, {rounded_dout_values[i+1]:.1f}' if i + 1 < len(rounded_dout_values) else f'{rounded_dout_values[i]:.1f}' for i in range(0, len(rounded_dout_values), 2)])
            ax_xy.add_patch(plt.Rectangle((x, y), 0.1, 0.1, color='lightblue', alpha=0.5))
            ax_xy.text(x + 0.05, y + 0.05, dout_text, color='black', fontsize=9, ha='center')
ax_xy.set_xlabel('Pin')
ax_xy.set_ylabel('Din')
ax_xy.set_title('XY Plane View (Pin vs Din with Dout Values)')
ax_xy.set_xticks(bins)
ax_xy.set_yticks(bins)
ax_xy.grid(True, linestyle='--', linewidth=0.5)
plotpath_xy = base_name + '_plot_xy.png'
plt.savefig(plotpath_xy, dpi=300)





fill_color = 'blue'
fig_xy_zback = plt.figure(figsize=(10, 10))
ax_xy_zback = fig_xy_zback.add_subplot(111)

for x in bins[:-1]:
    for y in bins[:-1]:
        x_mask = (Pin >= x) & (Pin < x + 0.1)
        y_mask = (Din >= y) & (Din < y + 0.1)
        dout_values = [Dout[i] for i in range(len(Pin)) if x_mask[i] and y_mask[i]]
        
        dout_bins = np.arange(0, 1.1, 0.1)
        dout_bin_counts = [0] * len(dout_bins)
        
        for dout in dout_values:
            dout_bin_idx = int(dout * 10)  
            dout_bin_counts[dout_bin_idx] += 1

        if dout_values:
            ax_xy_zback.add_patch(plt.Rectangle((x, y), 0.1, 0.1, color='lightblue', alpha=0.5)) 
        

        for i in range(10): 
            if dout_bin_counts[i] > 0:  

                ax_xy_zback.add_patch(plt.Rectangle((x, y + i * 0.01), 0.1, 0.01, color=fill_color, alpha=0.7))  
                
        for i in range(1, 10):
            ax_xy_zback.plot([x, x + 0.1], [y + i * 0.01, y + i * 0.01], color='lightgray', linestyle='-', linewidth=0.75)  
            

ax_xy_zback.set_xlim(0.0, 1.0)  
ax_xy_zback.set_ylim(0.0, 1.0) 

ax_xy_zback.set_xlabel('Pin')
ax_xy_zback.set_ylabel('Din')
ax_xy_zback.set_title('XY Plane View (Pin vs Din with Dout Values)')
ax_xy_zback.set_xticks(bins)
ax_xy_zback.set_yticks(bins)
ax_xy_zback.grid(True, linestyle='-', linewidth=1.5, color='black')
plotpath_xy_zback = base_name + '_plot_xy_zback.png'
plt.savefig(plotpath_xy_zback, dpi=300)

