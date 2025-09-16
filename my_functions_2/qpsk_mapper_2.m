function symbols = qpsk_mapper_2(bits)
    
    % Check that the length of the vector is a multiple of two
    if mod(length(bits), 2) ~= 0
        bits = bits(1:end-1);
        warning('The length is not multiple of two. Last bit is truncated');
    end



    % Transform bits into decimal values: (0, 1, 2, 3)
    decimal_values = bits(1:2:end) * 2 + bits(2:2:end);

    % Mapping rule:
    % 00 -> 0 -> -1+1j
    % 01 -> 1 -> -1-1j
    % 10 -> 2 -> +1+1j
    % 11 -> 3 -> +1-1j
    
    % Making mapping
    symbols = zeros(size(decimal_values));
    for i = 1:length(decimal_values)
        switch decimal_values(i)
            case 0
                symbols(i) = -1 + 1j;
            case 1
                symbols(i) = -1 - 1j;
            case 2
                symbols(i) = 1 + 1j;
            case 3
                symbols(i) = 1 - 1j;
        end
    end

    % Normalization of average power (UnitAveragePower).
    symbols = symbols / sqrt(2);
end