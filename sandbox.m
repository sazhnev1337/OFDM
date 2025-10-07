%% SETTINGS

clc;        % Очистить командное окно
clear all;  % Очистить все переменные
close all;  % Закрыть все окна с графиками

addpath('my_functions/');
addpath('my_functions_2/');

%% 16-QAM Модуляция и Демодуляция с Нормировкой Мощности

clc;
close all;
clear;

% --- 1. Настройки Системы ---
M = 16;             % Порядок модуляции (16-QAM)
k = log2(M);        % Количество бит на символ (4)
num_bits = 100000;  % Общее количество передаваемых бит
SNR_dB = 10;        % Отношение сигнал/шум в децибелах

% --- 2. Генерация Исходных Данных ---
% Генерируем случайные биты (0 или 1)
tx_bits = randi([0 1], num_bits, 1);

% Преобразование битов в символы (группировка по 4 бита)
tx_symbols_int = bi2de(reshape(tx_bits, num_bits/k, k));

% --- 3. Модуляция (TX) ---
% qammod выполняет модуляцию. Опция 'UnitAveragePower', true 
% гарантирует, что средняя мощность созвездия равна 1 Вт.
tx_qam_symbols = qammod(tx_symbols_int, M, 'InputType', 'integer', ...
    'UnitAveragePower', true);

% Проверка мощности (должна быть близка к 1.0 Вт)
average_power = mean(abs(tx_qam_symbols).^2);
disp(['Средняя мощность модулированных символов: ', num2str(average_power)]);

% --- 4. Добавление Шума AWGN ---
% awgn добавляет белый гауссовский шум.
% 'measured' - означает, что функция измерит мощность tx_qam_symbols 
% и добавит шум относительно этой мощности при заданном SNR.
rx_qam_symbols = awgn(tx_qam_symbols, SNR_dB, 'measured');

% --- 5. Демодуляция (RX) ---
% qamdemod выполняет демодуляцию, используя ту же нормировку.
rx_symbols_int = qamdemod(rx_qam_symbols, M, 'OutputType', 'integer', ...
    'UnitAveragePower', true);

% Преобразование символов обратно в биты
rx_bits = reshape(de2bi(rx_symbols_int, k), [], 1);


% --- 6. Анализ Ошибок (BER) ---
% Сравнение исходных и полученных битов
[num_errors, BER] = biterr(tx_bits, rx_bits);

disp('------------------------------------');
disp(['SNR = ', num2str(SNR_dB), ' dB']);
disp(['Общее количество ошибок: ', num2str(num_errors)]);
disp(['Частота битовых ошибок (BER): ', num2str(BER)]);

% --- 7. Визуализация созвездия ---
figure('Name', 'Созвездие 16-QAM после канала AWGN');
scatter(real(rx_qam_symbols), imag(rx_qam_symbols), 5, 'filled');

title(['Созвездие 16-QAM при SNR = ', num2str(SNR_dB), ' dB']);
xlabel('I (In-phase / Действительная часть)');
ylabel('Q (Quadrature / Мнимая часть)');
grid on;
axis equal; % Убедиться, что оси I и Q имеют одинаковый масштаб
