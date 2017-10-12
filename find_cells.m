% Find cells in tif images of well FoVs taken during auto-focus at the beginning of the protocol. This code should 
% pick up files as they appear in the relevant folder, classify them as
% with or without cells and output the coordinates of fields with cells in
% a text file with the format used for screening. 

function [] = find_cells(folder, plot_all, low_pass, filt_size, fudgeFactor, edge_threshold, sensitivity, ...
    rad_range, output_file)

    file_pattern = fullfile(folder, '*.tif'); 
    files = dir(file_pattern);

    with_cells = zeros(length(files), 1); % 1 if file has cell

    for k = 1 : length(files)
        
        % Sporadically inform user which file is being processed
        if (mod(k, 100) == 0)
            k 
        end
        
        % Get full filename
        base_file_name = files(k).name;
        filename = fullfile(folder, base_file_name);
        I = imread(filename); % Array with pixel values

        % Low pass filter
        if(low_pass == 1)
            filt = ones(filt_size)/filt_size;
            I_low_pass = uint16(filter2(filt, I));
        end

        % Binary gradient mask - could be that this emphasises processes?
        if (low_pass == 1)
            [~, threshold] = edge(I_low_pass, 'sobel');
            BWs = edge(I_low_pass,'sobel', threshold * fudgeFactor);
        else
            [~, threshold] = edge(I, 'sobel');
            BWs = edge(I,'sobel', threshold * fudgeFactor);
        end

        % Dilating the gradient mask
        se90 = strel('line', 3, 90);
        se0 = strel('line', 3, 0);
        BWsdil = imdilate(BWs, [se90 se0]);

        % Fill inerior gaps
        BWdfill = imfill(BWsdil, 'holes');

        % Remove connected objects on border 
        BWnobord = imclearborder(BWdfill, 4);

        % Smoothen the object - maybe this will make it more circular
        seD = strel('diamond',1);
        BWfinal = imerode(BWnobord,seD);
        BWfinal = imerode(BWfinal,seD);
   
        % Find circles using specified parameters
        [centers, radii] = imfindcircles(BWfinal, rad_range, 'ObjectPolarity', 'bright', 'EdgeThreshold', ...
            edge_threshold, 'Sensitivity', sensitivity);
        
        % If cells are found, add to with_cells
        if (~isempty(radii))
            with_cells(k) = 1;
        end
        
        % Plot all steps for each image
        if (plot_all == 1)
            figure
            factor = 65536/max(max(I)); 
            subplot(3, 3, 1), imshow(I*factor), title('original image');  
            if (low_pass == 1)                
                factor = 65536/max(max(I_low_pass));
                subplot(3, 3, 2), imshow(I_low_pass*factor), title('low pass filtered image');
            end
            subplot(3, 3, 3), imshow(BWs), title('binary gradient mask');
            subplot(3, 3, 4), imshow(BWsdil), title('dilated gradient mask');
            subplot(3, 3, 5), imshow(BWdfill); ('Filled holes');
            subplot(3, 3, 6), imshow(BWnobord), title('cleared border image');
            subplot(3, 3, 7), imshow(BWfinal), title('segmented image');
            subplot(3, 3, 8), viscircles(centers, radii); % Visualize identified circles
            pause
        end
        
    end
    save(output_file, 'with_cells', 'edge_threshold', 'sensitivity', 'rad_range')

end