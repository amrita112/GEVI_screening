% Find cells in tif images of well FoVs taken during auto-focus at the beginning of the protocol. This code should 
% pick up files as they appear in the relevant folder, classify them as
% with or without cells and output the coordinates of fields with cells in
% a text file with the format used for screening. 

folder = 'Autofocus_100517';
file_pattern = fullfile(folder, '*.tif'); 
files = dir(file_pattern);

k = 1; % Counter to iterate over files
with_cells = zeros(length(files), 1); % 1 if file has cell

for k = 1 : length(files)
    %figure
    if (mod(k, 100) == 0)
        % Sporadically inform user which file is being processed
        k 
    end
    % Get full filename
    base_file_name = files(k).name;
    filename = fullfile(folder, base_file_name);
    I = imread(filename); % Array with pixel values
    %I = I*5;
    %subplot(3, 3, 1)
    %factor = 65536/max(max(I));
    %imshow(I*factor)

    % Low pass filter
    %filt = ones(25)/25;
    %I_low_pass = uint16(filter2(filt, I));
    %factor = 65536/max(max(I_low_pass));
    %subplot(3, 3, 2)
    %imshow(I_low_pass*factor)
    %title('low pass filtered image')
    
    % Binary gradient mask - could be that this emphasises processes?
    [~, threshold] = edge(I, 'sobel');
    fudgeFactor = 1.5;
    BWs = edge(I,'sobel', threshold * fudgeFactor);
    %[~, threshold] = edge(I, 'sobel');
    %BWs = edge(I_low_pass,'sobel', threshold * fudgeFactor);
    %subplot(3, 3, 3), imshow(BWs), title('binary gradient mask');

    % Dilating the gradient mask
    se90 = strel('line', 3, 90);
    se0 = strel('line', 3, 0);
    BWsdil = imdilate(BWs, [se90 se0]);
    %subplot(3, 3, 4), imshow(BWsdil), title('dilated gradient mask');

    % Fill inerior gaps
    BWdfill = imfill(BWsdil, 'holes');
    %factor = 65536/max(max(BWsdil));
    %subplot(3, 3, 5), imshow(BWdfill*factor);
    %title('Filled holes');

    % Remove connected objects on border 
    BWnobord = imclearborder(BWdfill, 4);
    %subplot(3, 3, 6), imshow(BWnobord), title('cleared border image');

%     Smoothen the object - maybe this will make it more circular
      seD = strel('diamond',1);
      BWfinal = imerode(BWnobord,seD);
      BWfinal = imerode(BWfinal,seD);
%     subplot(3, 3, 7)
%     imshow(BWfinal), title('segmented image');

    % Find circles using specified parameters
    edge_threshold = 0.1;
    sensitivity = 0.98;
    rad_range = [20, 30]; 
    [centers, radii] = imfindcircles(BWfinal, rad_range, 'ObjectPolarity', 'bright', 'EdgeThreshold', ...
        edge_threshold, 'Sensitivity', sensitivity);
    %subplot(3, 3, 8)
    %viscircles(centers, radii); % Visualize identified circles
    %pause
    if (~isempty(radii))
        with_cells(k) = 1;
    end
end
save('analysis3.mat', 'with_cells', 'edge_threshold', 'sensitivity', 'rad_range')

l = 'WITH CELLS'
% Look at classified FoVs
ind_with_cells = find(with_cells); % Change to indices of files with cells
for fig = 1:2
    figure
    for k = ((fig - 1)*119 + 1):(fig*119)
        if (k <= length(ind_with_cells))
            if(mod(k, 100) == 0)
                k
            end
            base_file_name = files(ind_with_cells(k)).name;
            filename = fullfile(folder, base_file_name);
            I = imread(filename); % Array with pixel values
            factor = 65536/max(max(I));
            %figure
            subplot(5, 24, k - (fig - 1)*119)
            imshow(I*factor)
            %pause
        end
    end
end
% load('analysis.mat')
l = 'without cells'
ind_without_cells = find(with_cells == 0);

for fig = 1:5
    figure
    for k = ((fig - 1)*100 + 1):(fig*100)
        if (k <= length(ind_without_cells))
            if(mod(k, 100) == 0)
                k
            end
            base_file_name = files(ind_without_cells(k)).name;
            filename = fullfile(folder, base_file_name);
            I = imread(filename); % Array with pixel values
    %         figure
            factor = 65536/max(max(I));
            subplot(5, 20, k - (fig - 1)*100)
            imshow(I*factor)
%         pause
        end
    end
end