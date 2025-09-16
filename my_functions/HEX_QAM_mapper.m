%16QAM_MAPPERx
function symbols = HEX_QAM_mapper(bits)
    % Проверяем, что длина входного вектора кратна 4
    if mod(length(bits), 4) ~= 0
        error('Длина входного вектора бит должна быть четной.');
    end
    [strings, Size] = (size(bits)); % Достаем размер массива
    % Создаем два массива нужного размера
    for_Q = zeros(1, Size/2);
    for_I = zeros(1, Size/2);
    
    for_I(1:2:end) = bits(1:4:end);
    for_I(2:2:end) = bits(2:4:end);
    
    for_Q(1:2:end) = bits(3:4:end);
    for_Q(2:2:end) = bits(4:4:end);
    
    
    I_1 = (for_I(1:2:end) .* 2) - 1;
    I_2 = (for_I(2:2:end) .* 2) + 1;
    
    I = I_1 .* I_2;
    
    
    Q_1 = ((for_Q(1:2:end) .* 2) - 1) .* (-1);
    Q_2 = (for_Q(2:2:end) .* 2) + 1;
    
    Q = Q_1 .* Q_2;
    
    symbols = I + (1j * (Q));
    
    n = 3.162277660168380;
    symbols = symbols/n;
end