%% SETTINGS

clc;        % Очистить командное окно
clear all;  % Очистить все переменные
close all;  % Закрыть все окна с графиками

addpath('my_functions/');
addpath('my_functions_2/');

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
figure;
subplot(1, 2, 1);
imshow(img);
title('Original picture');
subplot(1, 2, 2);
imshow(gray_img);
title('Gray picture');

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

Nc = 72; % Number of subcarriers
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

Nfft = 1024;
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

figure;
subplot(1, 2, 1);
stem(real(ifft_OFDM_sym_1));
title('Nfft={2^6}');
subplot(1, 2, 2);
stem(real(ifft_OFDM_sym_2));
title('Nfft={2^{11}}');



%% PARALLEL TO SERIAL

% x = reshape(x_matrix, [], 1);
x = reshape(x_matrix.', [], 1).';
disp(['size of x: ', num2str(size(x))]);

%% CHANNEL & NOISE

% Nothing happens
y = x;

%% SERIAL TO PARALLEL

% y_matrix = reshape(y, [], 1024);
y_matrix = reshape(y, 1024, []).';
disp(['size of y_matrix: ', num2str(size(y_matrix))])

%% FFT

Matrix_of_rsym_zp = fft(y_matrix.', Nfft).';
% Rows of Matrix_of_rsym are result of FFT transform of each block
disp(['size of Matrix_of_rsym_zp: ', num2str(size(Matrix_of_rsym_zp))]);
% Truncation
Matrix_of_rsym = Matrix_of_rsym_zp(:, 1:Nc);
disp(['size of Matrix_of_rsym: ', num2str(size(Matrix_of_rsym))]);

% Equivalence check 
if (all(abs(Matrix_of_rsym - Matrix_of_sym) < 1e-10))
    disp('SYMBOL MATRIX AT RX & TX ARE EQUAL!');
else 
    disp('AHTUNG! SYMBOL MATRIX ARENT EQUAL!!!')
end

% Visualise the result of FFT transform
ifft_OFDM_sym = y_matrix(1, :).';
OFDM_sym_zp = fft(ifft_OFDM_sym, Nfft);
figure;
subplot(1, 2, 1);
stem(real(OFDM_sym_zp));
title('FFT of 1st row of ifft\_OFDM\_sym before truncation (real part)');

OFDM_sym = OFDM_sym_zp(1:Nc);  % Truncation
subplot(1, 2, 2);
stem(real(OFDM_sym));
title('FFT of 1st row of ifft\_OFDM\_sym after truncation (real part)');


%% PARALLEL TO SERIAL

% vector_of_rsym_zp = reshape(Matrix_of_rsym, 1, []).';
vector_of_rsym_zp = reshape(Matrix_of_rsym.', 1, []).';

disp(['size of : vector_of_rsym_zp:', num2str(size(vector_of_rsym_zp))]);
% Truncation of zero padding tail
vector_of_rsym = vector_of_rsym_zp(1:Lsym);
disp(['size of vector_of_rsym: ', num2str(size(vector_of_rsym))]);

%% DEMAPPER

binary_rvector = int32(qpsk_demapper_2(vector_of_rsym)).';



if (isequal(binary_rvector, binary_vector))
    disp('BINARY VECTORS AT RX & TX ARE EQUAL!');
else 
    disp('AHTUNG! VECTORS ARENT EQUAL!!!')
end

%% BITS TO PICTURE


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

