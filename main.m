% Run find_cells and disp_all

% Parameters for find_cells
%folder = 'Autofocus_100517';
plate_number = 8;
plot_all = 0;
low_pass = 0;
filt_size = 9;
fudgeFactor = 1.5;
edge_threshold = 0.1;
sensitivity = 0.98;
rad_range = [20, 30]; 
output_file = fopen(strcat('720_', int2str(plate_number), '_new.txt'), 'wt');
rows = 4;
cols = 10;
total_cols = 12;
first_row = 1;
first_col = 2;
num_fields = 9;

fprintf(output_file, '"Stage Memory List", Version 5.0 \n 0, 0, 0, 0, 0, 0, 0, "um", "um" \n 0 \n');

with_cells = find_cells(plot_all, low_pass, filt_size, fudgeFactor, edge_threshold, sensitivity, ...
    rad_range, output_file, rows, cols, total_cols, first_row, first_col, num_fields);

% This needs to be written to a specific line:
fprintf(output_file, num2str(sum(with_cells)));

% Paramters for disp_all
num_im_per_fig = 100;
num_rows_per_fig = 5; 
num_cols_per_fig = 20;


disp_all(with_cells, num_im_per_fig, num_rows_per_fig, num_cols_per_fig)

% AutoFocusRef2   _96Well02-A02_375dot1_g_8654.24_um_XY-Position_-17650_-6877_Analog-GFP-0.15
%                 "96Well02-A02a_375dot1", -17534, -6993, 8577.79, 0, 8577.79, FALSE, -9999, TRUE, TRUE, 0, -1