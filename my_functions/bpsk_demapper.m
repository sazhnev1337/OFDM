%BPSK_DEMAPPER
function bits = bpsk_demapper(symbols)
    % Векторизованная реализация (без цикла)
    bits = (real(symbols) >= 0);  % 1 для Re>=0, 0 для Re<0
    bits = bits(:)';  % Возвращаем строку 
end