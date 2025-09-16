function LLRs = my_soft_demapper_b(symbols, SNR) % SNR(dB)
     
    %Начнем с BPSK. Затем напишем для остальных и объединим в одну
    
    %Переведем SNR в среднеквадратичное отклонение
    % Среднаквадратичное отклонение = корень из дисперсии
    %Полагаем, что мощность сигнала равна единице

    disp = 10.^(-SNR/10); 
    l_s = length(symbols);
    
    LLRs = zeros(1, l_s);
    for i = 1:l_s
    
    LLRs(i) = -(4 * symbols(i))/disp; %смотри документацию mtlab!
    
    end
end