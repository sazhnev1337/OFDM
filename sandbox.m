%% SETTINGS

clc;        % Очистить командное окно
clear all;  % Очистить все переменные
close all;  % Закрыть все окна с графиками

addpath('my_functions/');
addpath('my_functions_2/');

% [Bits, rows, cols] =  ImageToBits("test_picture.jpg",...
%                                   "gray", ...
%                                   "on", ...
%                                   "on");


% Image = BitsToImage(Bits,  ...
%                     rows, ...
%                     cols, ...
%                     "gray", ...
%                     "on", ...
%                     "on");

source_bits = logical([1, 0, 1, 1, 0, 1, 1, 1, 0, 0, 1, 0, 1, 0].');
disp("source bits:")
disp(source_bits.')

init_reg = logical([1, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0].');
[scrambled_bits, final_reg_scrambler] = scrambler(source_bits, init_reg);

disp("scrambled_bits:");
disp(scrambled_bits.');
disp("final_reg_scrambler:")
disp(final_reg_scrambler.');

[bits, final_reg_descrambler] = descrambler(scrambled_bits, init_reg);

disp("bits:");
disp(bits.');

disp("final_reg_descrambler:")
disp(final_reg_descrambler.')




if (isequal(source_bits, bits))
    disp("BITS ARE EQUAL")
else
    disp("ERROR: BITS ARE NOT EQUAL")
end

if (isequal(final_reg_scrambler, final_reg_descrambler));
    disp("FINAL STATATES OF REGISTERS ARE EQUAL")
else
    disp("ERROR: FINAL STATATES OF REGISTERS ARE NOT EQUAL")
end


X = zeros(13)
Y = PAPR(X)