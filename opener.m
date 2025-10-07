clc;        % Clear command window
close all;  % Close all figures
clipping_with_scrambling_en = 1;

% BER-SNR

figure;
hold on;
grid on;
set(gca,'Yscale','log');


    
data_file_to_load = 'figures/BER SNR with scrambling.mat'; 
load(data_file_to_load);
BER2         =  BER;
snr_array2   =  snr_array;
graph_name2  = graph_name;
BER2(BER2 == 0) = 1e-7;

semilogy(snr_array2, BER2, 'r-s', 'Linewidth', 1.5);
label2 = graph_name2;


data_file_to_load = 'figures/BER SNR.mat'; 
load(data_file_to_load);
BER3         =  BER;
snr_array3   =  snr_array;
graph_name3  = graph_name;
BER3(BER3 == 0) = 1e-7;

semilogy(snr_array3, BER3, 'k-^', 'Linewidth', 1.5);
label3 = graph_name3;

data_file_to_load = 'figures/BER SNR with clippingCR=2 with scrambling.mat'; 
load(data_file_to_load);
BER1         =  BER;
snr_array1   =  snr_array;
graph_name  = [graph_name];
BER1(BER1 == 0) = 1e-7;
semilogy(snr_array1, BER1, 'b', 'Linewidth', 1);
label20 = graph_name;


% CR variation
if clipping_with_scrambling_en == 1
    data_file_to_load = 'figures/BER SNR with clippingCR=1.5 with scrambling.mat'; 
    load(data_file_to_load);
    BER1         =  BER;
    snr_array1   =  snr_array;
    graph_name  = [graph_name, ' CR=', num2str(CR)];
    BER1(BER1 == 0) = 1e-7;
    semilogy(snr_array1, BER1, 'Color',[0 0 0.1], 'Linewidth', 1);
    label15 = graph_name;

    data_file_to_load = 'figures/BER SNR with clippingCR=2.5 with scrambling.mat'; 
    load(data_file_to_load);
    BER1         =  BER;
    snr_array1   =  snr_array;
    graph_name  = [graph_name, ' CR=', num2str(CR)];
    BER1(BER1 == 0) = 1e-7;
    semilogy(snr_array1, BER1, 'Color',[0 0 0.2], 'Linewidth', 1);
    label25 = graph_name;

    data_file_to_load = 'figures/BER SNR with clippingCR=3 with scrambling.mat'; 
    load(data_file_to_load);
    BER1         =  BER;
    snr_array1   =  snr_array;
    graph_name  = [graph_name, ' CR=', num2str(CR)];
    BER1(BER1 == 0) = 1e-7;
    semilogy(snr_array1, BER1, 'Color',[0 0 0.4], 'Linewidth', 1);
    label30 = graph_name;

    data_file_to_load = 'figures/BER SNR with clippingCR=3.5 with scrambling.mat'; 
    load(data_file_to_load);
    BER1         =  BER;
    snr_array1   =  snr_array;
    graph_name = [graph_name, ' CR=', num2str(CR)];
    BER1(BER1 == 0) = 1e-7;
    semilogy(snr_array1, BER1, 'Color',[0 0 0.6], 'Linewidth', 1);
    label35 = graph_name;

    data_file_to_load = 'figures/BER SNR with clippingCR=4 with scrambling.mat'; 
    load(data_file_to_load);
    BER1         =  BER;
    snr_array1   =  snr_array;
    graph_name = [graph_name, ' CR=', num2str(CR)];
    BER1(BER1 == 0) = 1e-7;
    semilogy(snr_array1, BER1, 'Color',[0 0 0.8], 'Linewidth', 1);
    label40 = graph_name;
end

xlabel('SNR (dB)');
ylabel('Bit Error Rate (BER)');
title('BER-SNR');

legend(label2, label3, label20, label15, label25, label30, label35, label40, 'Location', 'southwest');




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


%% Power comparation

data_file_to_load = 'figures/BER SNR with clippingCR=4 with scrambling.mat'; 
load(data_file_to_load)
power1 = power;
label1 = graph_name;
    
data_file_to_load = 'figures/BER SNR with scrambling.mat'; 
load(data_file_to_load)
power2 = power;
label2 = graph_name;


data_file_to_load = 'figures/BER SNR.mat'; 
load(data_file_to_load)
power3 = power;
label3 = graph_name;

% --- 1. Входные данные (Мощность в dBm) ---

% Определяем три значения мощности
P1_dBm = 10 * log10(power1/0.001);  % Мощность передатчика (Tx)
P2_dBm = 10 * log10(power2/0.001);  % Мощность на входе приемника (Rx)
P3_dBm = 10 * log10(power3/0.001);  % Мощность шума (Noise Floor)

% Объединяем их в вектор.
power_values = [P1_dBm, P2_dBm, P3_dBm];

% Создаем текстовые метки для каждого столбца
labels = {label1, label2, label3};


% --- 2. Построение столбчатой диаграммы (Bar Chart) ---

figure('Name', 'Сравнение мощностей');

% Строим столбцы. bar(Y) использует целые числа (1, 2, 3) для оси X.
h = bar(power_values, 'FaceColor', 'flat'); 
grid on;

% --- 3. Настройка графика для наглядности ---

title('Сравнение мощностей');
ylabel('Мощность (dBm)');

% Установка меток на оси X:
% Вместо 1, 2, 3 отображаем наши текстовые метки
set(gca, 'XTickLabel', labels); 

ylim([0, 30])

% Получаем координаты центра каждого столбца для размещения текста
x_centers = h.XEndPoints;
y_heights = h.YData;

% Размещаем текст с точными значениями над каждым столбцом
for i = 1:length(power_values)
    text(x_centers(i), y_heights(i), [num2str(power_values(i), '%.1f'), ' dBm'], ...
         'HorizontalAlignment', 'center', ...
         'VerticalAlignment', 'bottom', ...
         'FontSize', 10, ...
         'FontWeight', 'bold');
end
