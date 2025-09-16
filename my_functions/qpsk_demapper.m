function bits = qpsk_demapper(symbols)
    symbols = symbols * sqrt(2);
    % Распределение точек для жесткого демаппера
    for i = 1:length(symbols)
        if real(symbols(i)) > 0
            if imag(symbols(i)) > 0
                symbols(i) = 1 +  1j * 1;
            else
                symbols(i) = 1 -  1j * 1;
            end
        else
            if imag(symbols(i)) > 0
                symbols(i) = -1 +  1j * 1;
            else
                symbols(i) = -1 -  1j * 1;
            end
        end
    end

    %Создаем массив для битов
    [~, Size] = (size(symbols));
    bits = zeros(1, (Size*2));
    bits(1:2:end) = (real(symbols) + 1)/2;
    bits(2:2:end) = -(imag(symbols) - 1)/2;
end