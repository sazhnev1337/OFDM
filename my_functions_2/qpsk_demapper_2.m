function bits = qpsk_demapper_2(symbols)
    
    % Demapping rule
    % 00 -> -1+1j
    % 01 -> -1-1j
    % 10 -> +1+1j
    % 11 -> +1-1j

    real_part = real(symbols);
    imag_part = imag(symbols);

    % Creating empty array for output bits
    bits = zeros(1, 2 * length(symbols));
    
    for k = 1:length(symbols)
        % Определяем квадрант
        if real_part(k) > 0 && imag_part(k) > 0 
            % It's code: 10 (according to map)
            bits(2*k-1:2*k) = [1 0];
        elseif real_part(k) < 0 && imag_part(k) > 0 
            % Code: 00
            bits(2*k-1:2*k) = [0 0];
        elseif real_part(k) < 0 && imag_part(k) < 0 
            % Code: 01
            bits(2*k-1:2*k) = [0 1];
        elseif real_part(k) > 0 && imag_part(k) < 0 
            % Code: 11
            bits(2*k-1:2*k) = [1 1];
        else
            % If symbol on the axis, it might be an error
            bits(2*k-1:2*k) = [0 0];
        end
    end
end