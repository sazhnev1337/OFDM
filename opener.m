clc;        % Clear command window
close all;  % Close all figures


% BER-SNR

figure;
hold on;
grid on;
set(gca,'Yscale','log');


data_file_to_load = 'figures/BER SNR with clipping with scrambling.mat'; 
load(data_file_to_load);
BER1         =  BER;
snr_array1   =  snr_array;
graph_name1  = [graph_name, ' CR=', num2str(CR)];
BER1(BER1 == 0) = 1e-2;

semilogy(snr_array1, BER1, 'b-o', 'Linewidth', 1.5);
label1 = graph_name1;

    
data_file_to_load = 'figures/BER SNR with scrambling.mat'; 
load(data_file_to_load);
BER2         =  BER;
snr_array2   =  snr_array;
graph_name2  = graph_name;
BER2(BER2 == 0) = 1e-2;

semilogy(snr_array2, BER2, 'r-s', 'Linewidth', 1.5);
label2 = graph_name2;


data_file_to_load = 'figures/BER SNR.mat'; 
load(data_file_to_load);
BER3         =  BER;
snr_array3   =  snr_array;
graph_name3  = graph_name;
BER3(BER3 == 0) = 1e-2;

semilogy(snr_array3, BER3, 'k-^', 'Linewidth', 1.5);
label3 = graph_name3;


xlabel('SNR (dB)');
ylabel('Bit Error Rate (BER)');
title('BER-SNR');

legend(label1, label2, label3, 'Location', 'southwest');




%% CCDF of PAPR 

figure;
hold on;
grid on;


data_file_to_load = 'figures/CCDF of PAPR.mat'; 
load(data_file_to_load);
CCDF1 = CCDF; v1 = v; CR1 = CR;
label1 = graph_name;

plot(v1, CCDF1, 'r-', 'Linewidth', 2.0);


data_file_to_load = 'figures/CCDF of PAPR with scrambling.mat'; 
load(data_file_to_load);
CCDF2 = CCDF; v2 = v; CR2 = CR;
label2 = graph_name;

plot(v2, CCDF2, 'b-', 'Linewidth', 2.0);


data_file_to_load = 'figures/CCDF of PAPR with clipping with scrambling.mat'; 
load(data_file_to_load);
CCDF3 = CCDF; v3 = v; CR3 = CR;
label3 = [graph_name, 'CR=', num2str(CR)];


plot(v3, CCDF3, 'g-', 'Linewidth', 1.0);


xlabel('value of PAPR');
ylabel('CCDF'); 
title('CCDF of PAPR');
legend(label1, label2, label3, 'Location', 'northeast');