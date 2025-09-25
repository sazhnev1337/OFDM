%% BITS TO PICTURE


function reconstructed_img = BitsToImage(binary_vector, pic_rows, pic_cols, ...
                                          color_mod, show_mod, log_mod)

    % Step 1: Reshape the binary vector into a single string
    binary_char_vector_reshaped = char(binary_vector' + '0');
    if log_mod=="on"
        disp(['size(binary_char_vector_reshaped): ', num2str(size(binary_char_vector_reshaped))])
    end

    % Step 2: Reshape the long single string into 8-bit strings

    num_rows_reshape = pic_rows * pic_cols; % This should be equal to num_pixels
    binary_strings_reshaped = reshape(binary_char_vector_reshaped, 8, num_rows_reshape)';

    % Step 3: Convert the 8-bit strings back to decimal pixel values
    img_reconstructed = bin2dec(binary_strings_reshaped);

    % Step 4: Reshape the vector of pixel values back into an image
    if color_mod=="gray"
        img_reconstructed = reshape(img_reconstructed, pic_rows, pic_cols);
    end
    if log_mod=="on"
        disp(['size(gray_img_reconstructed): ', num2str(size(img_reconstructed))])
    end

    % Step 5: Convert the data type back to uint8 
    reconstructed_img = uint8(img_reconstructed);
    if log_mod=="on"
        disp(['class(reconstructed_img):', class(reconstructed_img)])
    end

    if show_mod=="on"
        figure;
        imshow(reconstructed_img);
        title('Reconstructed Picture');
    end

end
