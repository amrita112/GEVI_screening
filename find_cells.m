% Find cells in tif images of well FoVs taken during auto-focus at the beginning of the protocol. This code should 
% pick up files as they appear in the relevant folder, classify them as
% with or without cells and output the coordinates of fields with cells in
% a text file with the format used for screening. 

%function [with_cells] = find_cells(folder, plot_all, low_pass, filt_size, fudgeFactor, edge_threshold, sensitivity, ...
%    rad_range, output_file, rows, cols, first_row, first_col, num_fields)

function [with_cells] = find_cells(plot_all, low_pass, filt_size, fudgeFactor, edge_threshold, sensitivity, ...
    rad_range, output_file, rows, cols, total_cols, first_row, first_col, num_fields)
    
    % rows = number of filled rows in the plate 
    % cols = number of filled wells per row in the plate
    % total_cols = total number (filled and unfilled) of wells per row in the plate
    % first_row = first filled row in plate (number, not letter)
    % first_col = first filled well in each plate 
    % num_fields = number of fields per well
    
    with_cells = zeros(rows*cols*num_fields, 1); % 1 if file has cell
    img = 0; % Image counter
    
    format_spec = '"96Well%s-%s%c_%s", %d, %d, %d, %d, %d, %s, %d, %s \n';
    
    for row = first_row:first_row + rows - 1
        row
        for col = first_col:first_col + cols - 1
            col
            flag = 0; % Reports whether all files for that well are found
            while (flag == 0)
                if (col < 10)
                    well_str = strcat(char(64 + row), num2str(0), num2str(col));
                else
                    well_str = strcat(char(64 + row), num2str(col));
                end
                file_pattern = fullfile(strcat('AutoFocus*', well_str, '*.tif')); 
                files = dir(file_pattern);
                if(length(files) == num_fields)
                    flag = 1; % all files for that well found
                end
            end

            for k = 1 : length(files)
                img = img + 1; % Update image counter
                % Get full filename
                base_file_name = files(k).name;
                filename = fullfile(base_file_name);
                I = imread(filename); % Array with pixel values

                radii = find_cells_single_file(I, low_pass, filt_size, fudgeFactor, edge_threshold, sensitivity, ...
                rad_range, plot_all);

                % If cells are found, add to with_cells
                if (~isempty(radii))
                    with_cells(img) = 1;
                end                      
                well_no = row*total_cols + col;
                if well_no < 10
                    well_no = strcat('0', int2str(well_no));
                else
                    well_no = int2str(well_no);
                end
                fprintf(output_file, format_spec, [well_no, well_str, char(96 + k), '375dot1', ...
                    -17560, -1800, -1800, -1800, -1800, 'FALSE', -1800, 'TRUE, TRUE, 0, -1']);
            end
            %save(output_file, 'with_cells', 'edge_threshold', 'sensitivity', 'rad_range')

        end
    end
end