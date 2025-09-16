%####################################################
%Функция корреляции по дифференциальным коэффициентам
%####################################################
function  n = my_dc_correlation(X, Y)

X_diff = X .* conj(circshift(X, -1));
Y_diff = Y .* conj(circshift(Y, -1));

 X_diff(end) = X(end);
 Y_diff(end) = Y(end);
numerator = dot(X_diff, conj(Y_diff)); %Функция скалярного произведения

denominator = sqrt(dot(X_diff,X_diff) * dot(Y_diff,Y_diff));

n = numerator / denominator;
end
