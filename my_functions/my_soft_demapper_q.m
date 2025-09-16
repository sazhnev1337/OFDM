function LLRs = my_soft_demapper_q(symbols, SNR) % SNR(dB)
    
    disp = 10.^(-SNR/10); 
    l_s = length(symbols);
    
    %Создаем массив для llr
    LLRs = zeros(2, l_s);

    %Для первого бита из двух
    %S_0_frst = [-1 + j1, -1 - j1];
    %S_1_frst = [+1 + j1, +1 - j1];
    
    
    for i = 1:l_s
        sum_num = exp(-(abs( symbols(i) - (-1 + 1j) ).^2/(disp))) + ...
            exp(-(abs( symbols(i) - (-1 - 1j) ).^2/(disp)));
        sum_denum = exp(-(abs( symbols(i) - (+1 + 1j) ).^2/(disp))) + ...
            exp(-(abs( symbols(i) - (+1 - 1j) ).^2/(disp)));
        
        LLRs(1, i) = log(sum_num/sum_denum);
    end

    %Для первого бита из двух
    %S_0_last = [-1 + j1, +1 + j1];
    %S_1_last = [-1 - j1, +1 - j1];

    for i = 1:l_s
        sum_num = exp(-( abs( symbols(i) - (-1 + 1j) ).^2 /(disp))) + ...
            exp(-( abs( symbols(i) - (+1 + 1j) ).^2/(disp) ));
        sum_denum = exp(-(abs( symbols(i) - (-1 - 1j) ).^2/(disp))) + ...
            exp(-(abs( symbols(i) - (+1 - 1j) ).^2/(disp)));
        
        LLRs(2,i) = log(sum_num/sum_denum);
    end
end