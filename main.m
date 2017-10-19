% Run find_cells and disp_all

% Parameters for find_cells
plate_number = 8;
plot_all = 0;
low_pass = 0;
filt_size = 9;
fudgeFactor = 1.5;
edge_threshold = 0.1;
sensitivity = 0.98;
rad_range = [20, 30]; 
rows = 4;
cols = 10;
total_cols = 12;
first_row = 1;
first_col = 2;
num_fields = 9;

[with_cells, num_cells, well_ids, x, y, z, row_ids, col_ids, cell_no_within_well, construct] = find_cells(plot_all, ...
    low_pass, filt_size, fudgeFactor, ...
    edge_threshold, sensitivity, ...
    rad_range, rows, cols, total_cols, first_row, first_col, num_fields);

output_file = fopen('ONESHOT-CELLS.STG', 'wt');
fprintf(output_file, '"Stage Memory List", Version 5.0 \r\n 0, 0, 0, 0, 0, 0, 0, "um", "um" \r\n 0 \r\n');
fprintf(output_file, int2str(num_cells));

format_spec = strcat('"96Well%02d-%c%02d%c', construct, '%d, %d, %d, 0, 0, FALSE, -9999, TRUE, TRUE, 0, -1');
fprintf(formatspec, output_file, well_ids, row_ids, col_ids, cell_no_within_well, x, y, z);

fclose(output_file);

% Paramters for disp_all
num_im_per_fig = 100;
num_rows_per_fig = 5; 
num_cols_per_fig = 20;


disp_all(with_cells, num_im_per_fig, num_rows_per_fig, num_cols_per_fig)

