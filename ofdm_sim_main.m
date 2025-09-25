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
snr_array = 1:0.5:10;
BER = zeros(1, length(snr_array), "double"); % Create array for BER results 
clear_channel = 0;

% НАДО ДОДУМАТЬ
if clear_channel == 1
   N = 1;   
end

% Figures displaying settings
src_pic_sh = "off";
fin_pic_sh = "off";
other_pic_disp = 0;

% Display settings
debug_mod = False;
Equivalence_check = False;
if debug_mod
    src_pic_log="off";
    fin_pic_log="off";
end

%% PICTURE TO BITS

[binary_vector, rows, cols] =  ImageToBits("test_picture.jpg",...% soucre pic
                                           "gray",            ...% color_mod
                                           src_pic_sh,        ...% show_mod
                                           src_pic_log);         % log_mod

%% Mapper

vector_of_sym = qpsk_mapper_2(binary_vector);


%% SERIAL TO PARALLEL

Lsym = length(vector_of_sym);

% We divide the sequence into blocks of Nc characters each
% Implementation in the form of a matrix

% Zero padding
num_of_zeros = ceil(Lsym/Nc) * Nc - Lsym;
padding_vector = zeros(num_of_zeros, 1, "double");
symbol_vector_zp = cat(1, vector_of_sym, padding_vector);
Lsym_zp = length(symbol_vector_zp);


Matrix_of_sym = reshape(symbol_vector_zp, Nc, Lsym_zp/Nc).'; 
% The row of the 'Matrix_of_sym' is a single OFDM character
if debug_mode
    disp(['Matrix_of_sym size: ', num2str(size(Matrix_of_sym, 1)), ' x ', num2str(size(Matrix_of_sym, 2))]);
end
%% IFFT

x_matrix = ifft(Matrix_of_sym.', Nfft).';
% The row of the 'x_matrix' is the result 
% of the ifft conversion of the OFDM symbol

disp(size(x_matrix));
if debug_mod
    disp(['size of x_matrix: ', num2str(size(x_matrix,1)), ' x ', num2str(size(x_matrix,2))]);
end

% % Visualize result of ifft with different Nfft
% OFDM_sym = Matrix_of_sym(1, :)';
% % disp(['size of OFDM_sym: ', num2str(size(OFDM_sym,1)), ' x ', num2str(size(OFDM_sym,2))]);
% ifft_OFDM_sym_1 = ifft(OFDM_sym, 2^6);
% ifft_OFDM_sym_2 = ifft(OFDM_sym, 2^11);

% if other_pic_disp == 1
%     figure;
%     subplot(1, 2, 1);
%     stem(real(ifft_OFDM_sym_1));
%     title('Nfft={2^6}');
%     subplot(1, 2, 2);
%     stem(real(ifft_OFDM_sym_2));
%     title('Nfft={2^{11}}');
% end

%% Cyclic prefix

if (CP_mode=="on" | CP_mode=="simple")
    x_matrix = [ x_matrix(:, end-(CP_size-1): end), x_matrix];
end
if debug_mod
    disp(['x_matrix size with cyclic prefix: ', num2str(size(x_matrix, 1)), ' x ', num2str(size(x_matrix, 2))]);
end

%% PARALLEL TO SERIAL

x = reshape(x_matrix.', [], 1).';
if debug_mod
    disp(['size of x: ', num2str(size(x))]);
end

%% CHANNEL & NOISE

% main cycle for different snr
for i = 1:length(snr_array) 
    y = awgn(x, snr_array(i), 'measured');

    %% SERIAL TO PARALLEL

    y_matrix = reshape(y, Nfft+CP_size, []).';
    if debug_mod
        disp(['size of y_matrix with cyclic prefix: ', num2str(size(y_matrix))])
    end

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
    % Truncation
    Matrix_of_rsym = Matrix_of_rsym_zp(:, 1:Nc);

    if debug_mod
        disp(['size of Matrix_of_rsym_zp: ', num2str(size(Matrix_of_rsym_zp))]);
        disp(['size of Matrix_of_rsym: ', num2str(size(Matrix_of_rsym))]);
    end

    if Equivalence_check
        if (all(abs(Matrix_of_rsym - Matrix_of_sym) < 1e-10))
            disp('SYMBOL MATRIX AT RX & TX ARE EQUAL!');
        else 
            disp('AHTUNG! SYMBOL MATRIX ARENT EQUAL!!!')
        end
    end

    ifft_OFDM_sym = y_matrix(1, :).';
    OFDM_sym_zp = fft(ifft_OFDM_sym, Nfft);

    % Visualise the result of FFT transform
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

    vector_of_rsym_zp = reshape(Matrix_of_rsym.', 1, []).';

    if debug_mod
        disp(['size of : vector_of_rsym_zp:', num2str(size(vector_of_rsym_zp))]);
    end
    
    % Truncation of zero padding tail
    vector_of_rsym = vector_of_rsym_zp(1:Lsym);
    if debug_mod
        disp(['size of vector_of_rsym: ', num2str(size(vector_of_rsym))]);
    end

    %% DEMAPPER

    binary_rvector = int32(qpsk_demapper_2(vector_of_rsym)).';

    if Equivalence_check
        if (isequal(binary_rvector, binary_vector))
            disp('BINARY VECTORS AT RX & TX ARE EQUAL!');
        else 
            disp('AHTUNG! VECTORS ARENT EQUAL!!!')
        end
    end
    
    % Counting number of errors for this SNR
    BER(i) = sum(binary_rvector ~= binary_vector);

    
end

%% BER-SNR GRAPH
figure;
scatter(snr_array, BER);
title('BER-SNR');


%% BITS TO PICTURE

Image = BitsToImage(binary_rvector,... 
                    rows,...
                    cols,...
                    "gray",...         % color_mod
                    fin_pic_sh,...     % show_mod
                    fin_pic_log);      % log_mod
