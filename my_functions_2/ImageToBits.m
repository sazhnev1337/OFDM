%% PICTURE TO BITS

function [binary_vector, pic_rows, pic_cols] = ImageToBits(picture_name, color_mod, show_mod, log_mod)

    % Step 1: loading picture
    img = imread(picture_name);

    if (color_mod == "gray")
    % Step 2: transrofmation into gray picture
        if size(img, 3) == 3
            img = rgb2gray(img);
        end
        % Demonstration of gray picture
        if show_mod=="on"
            figure;
            imshow(img);
            title('Source picture');
        end
    end

    % Step 3: transformation each pixel into 8-bit string with '0'/'1' symbols 
    binary_strings = dec2bin(img);
    if log_mod=="on"
        disp(['size(binary_strings): ', num2str(size(binary_strings))]);
    end

    % Step 4: concatenating strings
    binary_char_vector = reshape(binary_strings.', 1, [])'; 
    % binary_char_vector - long single string
    if log_mod=="on"
        disp(['size(binary_char_vector): ', num2str(size(binary_char_vector))])
    end

    % Checking dimensions
    pic_rows = size(img, 1);
    pic_cols = size(img, 2);
    if log_mod=="on"
        fprintf('The size of the original image: %d x %d pixels\n', size(img, 1), size(img, 2));
        fprintf('The size of binary vector: %d bits\n', length(binary_char_vector));
        % fprintf('The first 100 bits: %s\n', binary_char_vector(1:100));
    end

    % Step 5: convertation symbols '1' and '0' to digits
    binary_vector = int32(binary_char_vector - '0');
    if log_mod=="on"
        disp(['class(binary_char_vector(1)):', class(binary_char_vector(1))])
        disp(['class(binary_vector(1)):', class(binary_vector(1))])
    end


end