function symbols = qpsk_mapper(bits)
    bits = bits(:);
    % Проверяем, что длина входного вектора кратна 2.
    % Иначе обрезаем последний бит. 
    if mod(length(bits), 2) ~= 0
        bits = bits(1:end-1);
    end

    % Преобразуем биты в символы QPSK
    symbols = (-1 + 2*bits(1:2:end)) + 1j * (1 - 2*bits(2:2:end));

    % Нормировка для единичной мощности.
    symbols = symbols / sqrt(2);
    % Простой вид из-за того, что у созвездия лишь одна окружность.
 end