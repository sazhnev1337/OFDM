%% SETTINGS

clc;        % Очистить командное окно
clear all;  % Очистить все переменные
close all;  % Закрыть все окна с графиками

addpath('my_functions/');
addpath('my_functions_2/');

% figure;

% subplot(1, 4, 1);
% x = [1+3i, 4-2i , -6+1i, -2-6i, 15+5i];
% lenx = length(x);
% Nfft = 64;
% stem(x);
% title('Source sequence')



% X = fft(x, Nfft);
% subplot(1, 4, 2);
% stem(X);
% title('FFT result: X = F[x]')

% x_with_zero_padding = ifft(X, Nfft);
% subplot(1, 4, 3);
% stem(x_with_zero_padding);
% title('IFFT result: F^-1[X]')

% final_x = x_with_zero_padding(1: lenx);
% subplot(1, 4, 4);
% stem(final_x);
% title('final x (after truncation)')

% if isequal(final_x, x)
%     disp('All correct')
% else
%     disp('Something wrong')
% end



% test = [ 0.7071 + 0.7071i, -0.7071 + 0.7071i, 0.7071 - 0.7071i, -0.7071 + 0.7071i]


% correct = qamdemod(test, 4, 'UnitAveragePower', true, 'OutputType', 'bit' )


% my_result = qpsk_demapper_2(test)

matrix = [1, 2 ; 3, 4; 5, 6]
disp(matrix(1, 2));
vector = reshape(matrix, 1 , []).'



string = [1, 2, 3, 4, 5, 6]

maatrix1 = reshape(string, 3, 2).'
maatrix2 = reshape(string, 2, 3)


A = [1,2,3; 4,5,6; 7,8,9]

A = A(:,1:end-1)


snr_array = [1:0.2:3]




BERSNR_array = zeros(3, 10, "double")
