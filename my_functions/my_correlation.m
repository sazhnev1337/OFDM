%##################
%Функция корреляции
%##################
function  n = my_correlation(Y, X)
numerator = dot(Y, conj(X)); %Функция скалярного произведения

denominator = sqrt(dot(X,X) * dot(Y,Y));

n = numerator / denominator;
end