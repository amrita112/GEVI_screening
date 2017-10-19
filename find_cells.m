% Find cells in tif images of well FoVs taken during auto-focus at the beginning of the protocol. This code should 
% pick up files as they appear in the relevant folder, classify them as
% with or without cells and output the coordinates of fields with cells in
% a text file with the format used for screening. 

%function [with_cells] = find_cells(folder, plot_all, low_pass, filt_size, fudgeFactor, edge_threshold, sensitivity, ...
%    rad_range, output_file, rows, cols, first_row, first_col, num_fields)

function [with_cells, num_cells, well_ids, x, y, z, row_ids, col_ids, cell_no_within_well, construct] = find_cells(plot_all, ...
    low_pass, filt_size, ...
    fudgeFactor, edge_threshold, sensitivity, ...
    rad_range, rows, cols, total_cols, first_row, first_col, num_fields)
    
    % rows: number of filled rows in the plate 
    % cols: number of filled wells per row in the plate
    % total_cols: total number (filled and unfilled) of wells per row in the plate
    % first_row: first filled row in plate (number, not letter)
    % first_col: first filled well in each plate 
    % num_fields: number of fields per well
    
    with_cells = zeros(rows*cols*num_fields, 1); % 1 if file has cell
    img = 0; % Image counter
    cell = 0; % Cell counter
    
    well_ids = zeros(rows*cols*num_fields, 1); % Well numbers for position list file
    x = zeros(rows*cols*num_fields, 1); % X position of cells
    y = zeros(rows*cols*num_fields, 1); % Y position of cells
    z = zeros(rows*cols*num_fields, 1); % Z position of cells
    row_ids = zeros(rows*cols*num_fields, 1); % Row of cells
    col_ids = zeros(rows*cols*num_fields, 1); % Col of cells
    cell_no_within_well = zeros(rows*cols*num_fields, 1); % 'a', 'b', 'c' etc in stage position list file

    for row = first_row:first_row + rows - 1
        row
        for col = first_col:first_col + cols - 1
            trial = 0;
            flag = 0; % Reports whether all files for that well are found
            while (flag == 0)
                if (col < 10)
                    well_str = strcat(char(64 + row), num2str(0), num2str(col));
                else
                    well_str = strcat(char(64 + row), num2str(col));
                end
                file_pattern = fullfile(strcat('..\AutoFocus*', well_str, '*.tif')); 
                files = dir(file_pattern);
                if(length(files) == num_fields)
                    flag = 1; % all files for that well found
                end
            end

            cell_within_well = 0; % Cell counter for a single well

            for k = 1 : length(files)
                img = img + 1; % Update image counter
                % Get full filename
                base_file_name = files(k).name;
                filename = fullfile(base_file_name);
                I = imread(filename); % Array with pixel values
                
                if(row == first_row && col == first_col && k == 1)
                    ind_construct = strfind(filename, '_');
                    construct = filename(ind_construct(2):(ind_construct(3) - 1));
                    construct = strcat(construct, '", ');
                   
                end
                
                radii = find_cells_single_file(I, low_pass, filt_size, fudgeFactor, edge_threshold, sensitivity, ...
                rad_range, plot_all);

                % If cells are found, add to with_cells
                if (~isempty(radii))
                    with_cells(img) = 1;
                    
                    cell = cell + 1;
                    well_no = row*total_cols + col;
                    well_ids(cell) = well_no;

                    % Store coordinates
                    dot_idx = strfind(filename, 'dot');
                    filename = filename(dot_idx:end);
                    z_idx = strfind(filename, '_');
                    z(cell) = str2double(filename((z_idx(2) + 1):(z_idx(3) - 1)));
                    xypos_idx = strfind(filename, 'XY-Position');
                    filename = filename(xypos_idx:end);
                    xy_idx = strfind(filename, '_');
                    x(cell) = str2double(filename((xy_idx(1) + 1):(xy_idx(2) - 1)));
                    y(cell) = str2double(filename((xy_idx(2) + 1):(xy_idx(3) - 1)));
                    
                    row_ids(cell) = row + 64;
                    col_ids(cell) = col;
                    
                    cell_within_well = cell_within_well + 1;
                    cell_no_within_well(cell) = cell_within_well + 96;

                end                      
                
            end
        end
    end
    
    num_cells = sum(sum(with_cells));
    % Truncate well_ids, x, y, z
    well_ids = well_ids(1:num_cells);
    x = x(1:num_cells);
    y = y(1:num_cells);
    z = z(1:num_cells);
    row_ids = row_ids(1:num_cells);
    col_ids = col_ids(1:num_cells);
end