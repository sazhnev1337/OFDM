function LLR_s = my_soft_demapper(symbols, SNR, bits_in_symbol)  
    if bits_in_symbol == 1
        LLR_s = my_soft_demapper_b(symbols, SNR);
    elseif bits_in_symbol == 2
        LLR_s = my_soft_demapper_q(symbols, SNR);
    elseif bits_in_symbol == 4
        LLR_s = my_soft_demapper_h(symbols, SNR);
    end
end

