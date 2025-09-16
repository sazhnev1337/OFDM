%BPSK_MAPPER
function symbols = bpsk_mapper(bits)

    % Преобразуем биты в символы BPSK
    symbols = (-1 + 2*bits);
end