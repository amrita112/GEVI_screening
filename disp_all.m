% Look at classified FoVs

%function [] = disp_all(with_cells, num_im_per_fig, num_rows_per_fig, num_cols_per_fig, files, folder)
function [] = disp_all(with_cells, num_im_per_fig, num_rows_per_fig, num_cols_per_fig)

    n = num_im_per_fig; 
    r = num_rows_per_fig; 
    c = num_cols_per_fig;
    
    file_pattern = fullfile('AutoFocus*.tif'); 
    files = dir(file_pattern);
   
    l = 'WITH CELLS'
    ind_with_cells = find(with_cells); % Change to indices of files with cells
    for fig = 1:ceil(length(ind_with_cells)/n)
        figure('name', strcat('With_cells_', int2str(fig)))
        for k = ((fig - 1)*n + 1):(fig*n)
            if (k <= length(ind_with_cells))
                if(mod(k, n) == 0)
                    k
                end
                base_file_name = files(ind_with_cells(k)).name;
                filename = fullfile(base_file_name);
                I = imread(filename); % Array with pixel values
                factor = 65536/max(max(I));
                %figure
                subplot(r, c, k - (fig - 1)*n)
                imshow(I*factor)
                %pause
            end
        end
    end

    l = 'WITHOUT CELLS'
    ind_without_cells = find(with_cells == 0);

    for fig = 1:ceil(length(ind_without_cells)/n)
        figure('name', strcat('Without_cells_', int2str(fig)))
        for k = ((fig - 1)*n + 1):(fig*n)
            if (k <= length(ind_without_cells))
                if(mod(k, n) == 0)
                    k
                end
                base_file_name = files(ind_without_cells(k)).name;
                filename = fullfile(base_file_name);
                I = imread(filename); % Array with pixel values
        %         figure
                factor = 65536/max(max(I));
                subplot(r, c, k - (fig - 1)*n)
                imshow(I*factor)
    %         pause
            end
        end
    end
end