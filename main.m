%% SETTINGS

clc;        % Очистить командное окно
clear all;  % Очистить все переменные
close all;  % Закрыть все окна с графиками

addpath('my_functions/');
addpath('my_functions_2/');

%% SETTINGS

Nc = 72;            % Number of subcarriers
Nfft = 1024;        % Number of fft and ifft points
CP_mode = "simple"; % cyclic prefix mode: 
                           % "simple" - just cut of cp at the reciever 
                           % "off"    - whithout cyclic prefix
                           % "on"     - with cyclic prefix
CP_size = 20;       % cyclic prefix size
if CP_mode == "off"
    CP_size = 0;
end
start_fft_win_samp = 10; % Starting from which character sample should the fft window be placed?
% НАДО ПЕРЕДЕЛАТЬ!!! ОКНО ДОЛЖНО ОТСЧИТЫВАТЬСЯ ОТ НАЧАЛА СИМВОЛА А НЕ ОТ КОНЦА

% Settings for snr graph
snr_array = 1:1:10;
BER = zeros(1, length(snr_array), "double"); % Create array for BER results 
clear_channel = 0;

% НАДО ДОДУМАТЬ
if clear_channel == 1
   N = 1;   
end

% Figures displaying settings
final_pic_disp = 0;

other_pic_disp = 0;

%% PICTURE TO BITS

% Step 1: loading picture
img = imread('test_picture.jpg');

% Step 2: transrofmation into gray picture
if size(img, 3) == 3
    gray_img = rgb2gray(img);
else
    gray_img = img;
end
% Demonstration of original picture and gray picture
if other_pic_disp == 1
    figure;
    subplot(1, 2, 1);
    imshow(img);
    title('Original picture');
    subplot(1, 2, 2);
    imshow(gray_img);
    title('Gray picture');
end

% Step 3: transformation each pixel into 8-bit string with '0'/'1' symbols 
binary_strings = dec2bin(gray_img);
disp(['size(binary_strings): ', num2str(size(binary_strings))]);

% Step 4: concatenating strings
binary_char_vector = reshape(binary_strings.', 1, [])'; 
% binary_char_vector - long single string
disp(['size(binary_char_vector): ', num2str(size(binary_char_vector))])
% Checking dimensions
pic_rows = size(gray_img, 1);
pic_cols = size(gray_img, 2);

fprintf('The size of the original image: %d x %d pixels\n', size(gray_img, 1), size(gray_img, 2));
fprintf('The size of binary vector: %d bits\n', length(binary_char_vector));
fprintf('The first 100 bits: %s\n', binary_char_vector(1:100));

% Step 5: convertation symbols '1' and '0' to digits
disp(['class(binary_char_vector(1)):', class(binary_char_vector(1))])
binary_vector = int32(binary_char_vector - '0');
disp(['class(binary_vector(1)):', class(binary_vector(1))])

% Correct data format for comparing
% binary_vector = randi([0 1], 100, 1);
% disp('binary_vector:')
% disp(binary_vector(1:10))
% disp('size of binary_vector:')
% disp(size(binary_vector))

%% Mapper

% Original matlab mapper for comparing
% vector_of_sym = qammod(binary_vector, 4, 'UnitAveragePower', true); %, 'InputType', 'bit', 'PlotConstellation', false);
% disp('The first 10 symbols(qammod):')
% disp(right_qpsk_symbols(1:10));


vector_of_sym = qpsk_mapper_2(binary_vector);
disp('The first 10 symbols(mine):')
disp(vector_of_sym(1:10));

%% SERIAL TO PARALLEL

Lsym = length(vector_of_sym);

% We divide the sequence into blocks of Nc characters each
% Implementation in the form of a matrix

% Zero padding
num_of_zeros = ceil(Lsym/Nc) * Nc - Lsym;
padding_vector = zeros(num_of_zeros, 1, "double");
symbol_vector_zp = cat(1, vector_of_sym, padding_vector);
Lsym_zp = length(symbol_vector_zp);

% Matrix_of_sym = reshape(symbol_vector_zp, Lsym_zp/Nc, Nc); % That is not correct!
Matrix_of_sym = reshape(symbol_vector_zp, Nc, Lsym_zp/Nc).'; 
% The row of the 'Matrix_of_sym' is a single OFDM character
disp(['Matrix_of_sym size: ', num2str(size(Matrix_of_sym, 1)), ' x ', num2str(size(Matrix_of_sym, 2))]);

%% IFFT

x_matrix = ifft(Matrix_of_sym.', Nfft).';
% The row of the 'x' is the result 
% of the ifft conversion of the OFDM symbol

disp(size(x_matrix));
disp(['size of x_matrix: ', num2str(size(x_matrix,1)), ' x ', num2str(size(x_matrix,2))]);

% Visualize result of ifft with different Nfft
OFDM_sym = Matrix_of_sym(1, :)';
% disp(['size of OFDM_sym: ', num2str(size(OFDM_sym,1)), ' x ', num2str(size(OFDM_sym,2))]);
ifft_OFDM_sym_1 = ifft(OFDM_sym, 2^6);
ifft_OFDM_sym_2 = ifft(OFDM_sym, 2^11);

if other_pic_disp == 1
    figure;
    subplot(1, 2, 1);
    stem(real(ifft_OFDM_sym_1));
    title('Nfft={2^6}');
    subplot(1, 2, 2);
    stem(real(ifft_OFDM_sym_2));
    title('Nfft={2^{11}}');
end

%% Cyclic prefix

if (CP_mode=="on" | CP_mode=="simple")
    x_matrix = [ x_matrix(:, end-(CP_size-1): end), x_matrix];
end
disp(['x_matrix size with cyclic prefix: ', num2str(size(x_matrix, 1)), ' x ', num2str(size(x_matrix, 2))]);

%% PARALLEL TO SERIAL

x = reshape(x_matrix.', [], 1).';
disp(['size of x: ', num2str(size(x))]);

%% CHANNEL & NOISE

% main cycle for different snr
for i = 1:length(snr_array) 
    y = awgn(x, snr_array(i), 'measured');

    %% SERIAL TO PARALLEL

    y_matrix = reshape(y, Nfft+CP_size, []).';
    disp(['size of y_matrix with cyclic prefix: ', num2str(size(y_matrix))])

    %% FFT

    if     (CP_mode == "off")
        Matrix_of_rsym_zp = fft(y_matrix.', Nfft).';
    elseif (CP_mode == "on")
        Matrix_of_rsym_zp = fft((y_matrix(:,end-start_fft_win_samp-(Nfft-1):end-start_fft_win_samp)).', Nfft).';
    elseif (CP_mode == "simple")
        disp("SIMPLE MODE")
        Matrix_of_rsym_zp = fft((y_matrix(:,CP_size+1:end)).', Nfft).';
    else 
        disp("ERROR: CHOOSE CP_MODE");
    end
    % Rows of Matrix_of_rsym are result of FFT transform of each block
    disp(['size of Matrix_of_rsym_zp: ', num2str(size(Matrix_of_rsym_zp))]);
    % Truncation
    Matrix_of_rsym = Matrix_of_rsym_zp(:, 1:Nc);
    disp(['size of Matrix_of_rsym: ', num2str(size(Matrix_of_rsym))]);

    % % Equivalence check 
    % if (all(abs(Matrix_of_rsym - Matrix_of_sym) < 1e-10))
    %     disp('SYMBOL MATRIX AT RX & TX ARE EQUAL!');
    % else 
    %     disp('AHTUNG! SYMBOL MATRIX ARENT EQUAL!!!')
    % end

    % Visualise the result of FFT transform
    ifft_OFDM_sym = y_matrix(1, :).';
    OFDM_sym_zp = fft(ifft_OFDM_sym, Nfft);
    if other_pic_disp ==1
        figure;
        subplot(1, 2, 1);
        stem(real(OFDM_sym_zp));
        title('FFT of 1st row of ifft\_OFDM\_sym before truncation (real part)');

        OFDM_sym = OFDM_sym_zp(1:Nc);  % Truncation
        subplot(1, 2, 2);
        stem(real(OFDM_sym));
        title('FFT of 1st row of ifft\_OFDM\_sym after truncation (real part)');
    end

    %% PARALLEL TO SERIAL

    % vector_of_rsym_zp = reshape(Matrix_of_rsym, 1, []).';
    vector_of_rsym_zp = reshape(Matrix_of_rsym.', 1, []).';

    disp(['size of : vector_of_rsym_zp:', num2str(size(vector_of_rsym_zp))]);
    % Truncation of zero padding tail
    vector_of_rsym = vector_of_rsym_zp(1:Lsym);
    disp(['size of vector_of_rsym: ', num2str(size(vector_of_rsym))]);

    %% DEMAPPER

    binary_rvector = int32(qpsk_demapper_2(vector_of_rsym)).';



    % if (isequal(binary_rvector, binary_vector))
    %     disp('BINARY VECTORS AT RX & TX ARE EQUAL!');
    % else 
    %     disp('AHTUNG! VECTORS ARENT EQUAL!!!')
    % end
    
    BER(i) = sum(binary_rvector ~= binary_vector);

    
end


%% BER-SNR GRAPH
figure;
scatter(snr_array, BER);
title('BER-SNR');


%% BITS TO PICTURE

if final_pic_disp == 1
    % Step 1: Reshape the binary vector into a single string
    binary_char_vector_reshaped = char(binary_rvector' + '0');
    disp(['size(binary_char_vector_reshaped): ', num2str(size(binary_char_vector_reshaped))])

    % Step 2: Reshape the long single string into 8-bit strings
    num_pixels = length(binary_char_vector_reshaped) / 8;
    num_rows_reshape = pic_rows * pic_cols; % This should be equal to num_pixels
    binary_strings_reshaped = reshape(binary_char_vector_reshaped, 8, num_rows_reshape)';

    % Step 3: Convert the 8-bit strings back to decimal pixel values
    gray_img_reconstructed = bin2dec(binary_strings_reshaped);

    % Step 4: Reshape the vector of pixel values back into a 2D grayscale image
    gray_img_reconstructed = reshape(gray_img_reconstructed, pic_rows, pic_cols);
    disp(['size(gray_img_reconstructed): ', num2str(size(gray_img_reconstructed))])

    % Step 5: Convert the data type back to uint8 
    reconstructed_img = uint8(gray_img_reconstructed);
    disp(['class(reconstructed_img):', class(reconstructed_img)])

    figure;
    imshow(reconstructed_img);
    title('Reconstructed Grayscale Picture');
end
