%% PREPARING

clc;        % Clear command window
clear all;  % Clear all variables
close all;  % Close all figures

addpath('my_functions_2/');

%% SETTINGS

% General

Nc = 100;            % Number of subcarriers
Nfft = 256;         % Number of fft and ifft points

Mapping_type = 16;

clipping_enable   = 1;
CR = 2.5;             % Clipping ratio 

scrambling_enable = 1;

SNR = 15;           % Default value of SNR
clear_channel = 0;  % Mode when simulation goes without adding AWGN in channel

CCDF_calc_enable = 0;  % (Complement cumulative density function) enable calculation 



% Settings for cyclic prefix 

CP_mode = "simple"; % cyclic prefix mode: 
                           % "simple" - just cut of cp at the reciever 
                           % "off"    - whithout cyclic prefix
                           % "on"     - with cyclic prefix

CP_size = 20;       % Size cyclic prefix 
if CP_mode == "off"
    CP_size = 0;
end
start_fft_win_samp = 10; % Starting from which sample should the fft window be placed?


% Settings for SNR graph
BER_SNR_calc_en = 0; % Enable BER-SNR calculation

if BER_SNR_calc_en == 1
    snr_array = 1:0.5:10;
    BER = zeros(1, length(snr_array), "double"); % Create array for BER results 
else
    snr_array = SNR;
    BER = 0;
end

% Figures displaying settings
cliping_effect_sh = "on";  % Picture shows the effect of clipling
src_pic_sh = "on";         % Source picture
fin_pic_sh = "on";         % Final picture
other_pic_disp = 0;        % Any other picture
constellation_show_en = 1;

% Logging settings
debug_mod         = 1;
Equivalence_check = 0;

if debug_mod == 1
    src_pic_log="on";
    fin_pic_log="on";
else
    src_pic_log="off";
    fin_pic_log="off";
end

% Non linsear amplifier model and constellation diagramm settings 

amp_en = 1; % Amplifier enable/disable
gain = 10;

amplifier = comm.MemorylessNonlinearity(Method="Cubic polynomial", ...
    LinearGain=gain,AMPMConversion=0);

% plot(amplifier)

% ###########################################################################
% ############################## Main part ##################################
% ###########################################################################
%% PICTURE TO BITS

[binary_vector, rows, cols] =  ImageToBits("test_picture.jpg",...% soucre pic
                                           "gray",            ...% color_mod
                                           src_pic_sh,        ...% show_mod
                                           src_pic_log);         % log_mod

%% SCRAMBLER

if scrambling_enable == 1
    initial_register_state = logical([1, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0].');
    [scrambled_binary_vector, final_reg_scrambler] = scrambler(binary_vector, initial_register_state);
else
    scrambled_binary_vector = binary_vector;
end
 
%% MAPPER

if Mapping_type == 4
    % My QPSK
    vector_of_sym = qpsk_mapper_2(scrambled_binary_vector);

elseif Mapping_type == 16
    % Built-in 16-QAM, работаем напрямую с битами
    M = 16;
    
    % Просто передаем скремблированный вектор в модулятор
    vector_of_sym = qammod(int32(scrambled_binary_vector), M, 'InputType', 'bit', ...
        'UnitAveragePower', true);
end

if constellation_show_en == 1
    scatterplot(vector_of_sym);
end
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
if debug_mod == 1
    disp(['Matrix_of_sym size: ', num2str(size(Matrix_of_sym, 1)), ' x ', num2str(size(Matrix_of_sym, 2))]);
end

%% IFFT

x_matrix = ifft(Matrix_of_sym.', Nfft).';
% The row of the 'x_matrix' is the result 
% of the ifft conversion of the OFDM symbol

disp(size(x_matrix));
if debug_mod == 1
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
if debug_mod == 1
    disp(['x_matrix size with cyclic prefix: ', num2str(size(x_matrix, 1)), ' x ', num2str(size(x_matrix, 2))]);
end

%% CLIPPING

if clipping_enable == 1
    % Getting root mean square error (sigma) of x
    sigma = std(x_matrix);  
    A = CR * sigma;
    x_clip_matrix = min(x_matrix, A);

    x_no_clip_matrix = x_matrix;
    x_matrix = x_clip_matrix;
end

% Getting CCDF оf PAPR
if CCDF_calc_enable == 1
    % Result of PAPR function is a PAPR vector, where 
    % each element is a PAPR of appropriate OFDM symbol 
    PAPR_vector = PAPR(x_matrix.').';
    % Use Emperical cumulative density function
    [F, v] = ECDF(PAPR_vector);
    % Turn into Complimentary CDF
    CCDF = 1 - F;

    graph_name = 'CCDF of PAPR';
    if clipping_enable == 1
        graph_name = [graph_name, ' with clipping']; 
    end
    if scrambling_enable == 1
        graph_name = [graph_name, ' with scrambling'];
    end
    name_to_save_data = ['figures/', graph_name, '.mat'];
    save(name_to_save_data, 'CCDF', 'v', "graph_name", "CR"); 

    disp(['Data saved to: ', name_to_save_data]);

end


%% PARALLEL TO SERIAL

x = reshape(x_matrix.', [], 1).';
if clipping_enable == 1
    x_no_clip = reshape(x_no_clip_matrix.', [], 1).';
end

if debug_mod == 1
    disp(['size of x: ', num2str(size(x))]);
end


%% Amplifier 

% Scaling
target_power = 25; % dBm
    scaled_x = scaleSignalToPower(x, target_power);
if clipping_enable == 1
    scaled_x_no_clip = scaleSignalToPower(x_no_clip, target_power);
end

if cliping_effect_sh == "on" & clipping_enable == 1
    figure;
    grid on;
    hold on;
    t = 1:length(x); 
    power_signal_clipping = abs(scaled_x).^2;
    power_signal = abs(scaled_x_no_clip).^2;
    plot(t, 10*log10(power_signal/0.001), 'r-', 'Linewidth', 1)
    plot(t, 10*log10(power_signal_clipping/0.001),      'b-', 'Linewidth', 0.7); 
    ylabel("power, dBm")
    xlabel("t, c")
    ylim([0, 35]);
    label2 = "with clipping with CR = " +  num2str(CR);
    legend('without clipping',label2)
end


power = mean(abs(scaled_x).^2);
if amp_en == 1
    ampOut = amplifier(scaled_x);
else
    ampOut = scaled_x;
end

%% CHANNEL & NOISE

% Main cycle for different snr
for i = 1:length(snr_array) 
    if clear_channel == 1
        y = ampOut;
    else
        y = awgn(ampOut, snr_array(i), 'measured');
    end

    % Descaling. Generally speaking, it is optional, since the 
    % unit power normalization is used on the demodulator.
    y = scaleSignalToPower(y, 20); % 30 dBm 

    %% SERIAL TO PARALLEL

    y_matrix = reshape(y, Nfft+CP_size, []).';
    if debug_mod == 1
        disp(['size of y_matrix with cyclic prefix: ', num2str(size(y_matrix))])
    end

    %% FFT

    if     (CP_mode == "off")
        Matrix_of_rsym_zp = fft(y_matrix.', Nfft).';
    elseif (CP_mode == "on")
        Matrix_of_rsym_zp = fft((y_matrix( : ,start_fft_win_samp : start_fft_win_samp + (Nfft-1) )).', Nfft).';
    elseif (CP_mode == "simple")
        disp("SIMPLE MODE")
        Matrix_of_rsym_zp = fft((y_matrix(:,CP_size+1:end)).', Nfft).';
    else 
        disp("ERROR: CHOOSE CP_MODE");
    end
    % Rows of Matrix_of_rsym are result of FFT transform of each block
    % Truncation
    Matrix_of_rsym = Matrix_of_rsym_zp(:, 1:Nc);

    if debug_mod == 1
        disp(['size of Matrix_of_rsym_zp: ', num2str(size(Matrix_of_rsym_zp))]);
        disp(['size of Matrix_of_rsym: ', num2str(size(Matrix_of_rsym))]);
    end

    if Equivalence_check == 1
        if (all(abs(Matrix_of_rsym - Matrix_of_sym) < 1e-7))
            disp('SYMBOL MATRIX AT RX & TX ARE EQUAL!');
        else 
            disp('WARNING! SYMBOL MATRIX ARENT EQUAL!!!')
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

    if debug_mod == 1
        disp(['size of : vector_of_rsym_zp:', num2str(size(vector_of_rsym_zp))]);
    end
    
    % Truncation of zero padding tail
    vector_of_rsym = vector_of_rsym_zp(1:Lsym);
    if debug_mod == 1
        disp(['size of vector_of_rsym: ', num2str(size(vector_of_rsym))]);
    end

    %% DEMAPPER
    vector_of_rsym = scaleSignalToPower(vector_of_rsym, 30); % 30 dBm 
    if constellation_show_en == 1
        scatterplot(vector_of_rsym);
    end
    if Mapping_type == 4
        % My QPSK
        binary_rvector = int32(qpsk_demapper_2(vector_of_rsym)).';
    elseif Mapping_type == 16
        % Built-in 16-QAM, получаем на выходе биты
        M = 16;
        
        % Демодулятор сразу возвращает нужный нам битовый вектор
        binary_rvector = qamdemod(vector_of_rsym, M, 'OutputType', 'bit', ...
            'UnitAveragePower', true);
    end
    %% DESCRAMBLER    

    if scrambling_enable == 1
        [descrambled_binary_rvector, final_reg_descrambler] = descrambler(binary_rvector, initial_register_state);
    else
        descrambled_binary_rvector = binary_rvector;
    end

    % Counting number of errors for this SNR
    BER(i) = sum(descrambled_binary_rvector ~= binary_vector)/length(binary_vector);

    % Check for shift registers of scrambler and descrambler are equal afterall.
    if clear_channel == 1
        if debug_mod == 1 & scrambling_enable == 1
            if isequal(final_reg_descrambler, final_reg_scrambler)
                disp("FINAL REGISTER'S STATES ARE EQUAL") 
            else
                disp("ERROR! FINAL REGISTER'S STATES ARE EQUAL")
            end
        end
        if Equivalence_check == 1
            if (isequal(descrambled_binary_rvector, binary_vector))
                disp('BINARY VECTORS AT RX & TX ARE EQUAL!');
            else 
                disp('WARNING! VECTORS ARENT EQUAL!!!')
            end
        end
    end

end

%% BER-SNR GRAPH
if BER_SNR_calc_en == 1

    graph_name = 'BER SNR';
    if clipping_enable == 1
        graph_name = [graph_name, ' with clipping', 'CR=', num2str(CR)]; 
    end
    if scrambling_enable == 1
        graph_name = [graph_name, ' with scrambling'];
    end

    name_to_save_data = ['figures/', graph_name, '.mat'];
    save(name_to_save_data, 'snr_array', 'BER', "graph_name", "CR", "power"); 

    disp(['Data saved to: ', name_to_save_data]);
end

%% BITS TO PICTURE

Image = BitsToImage(descrambled_binary_rvector,... 
                    rows,...
                    cols,...
                    "gray",...         % color_mod
                    fin_pic_sh,...     % show_mod
                    fin_pic_log);      % log_mod
