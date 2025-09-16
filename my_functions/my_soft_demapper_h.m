function LLRs = my_soft_demapper_h(symbols, SNR) % SNR(dB)
    %Эта функция выполняет приближенное вычисление LLR
    disp = 10.^(-SNR/10); 
    l_s = length(symbols);
    %Создаем массив для llr
    LLRs = zeros(4, l_s);

    %матрица созвездия
    constellation = [...
    -3.0000 + 3.0000i  -1.0000 + 3.0000i   1.0000 + 3.0000i   3.0000 + 3.0000i; ...
    -3.0000 + 1.0000i  -1.0000 + 1.0000i   1.0000 + 1.0000i   3.0000 + 1.0000i; ...
    -3.0000 - 1.0000i  -1.0000 - 1.0000i   1.0000 - 1.0000i   3.0000 - 1.0000i; ...
    -3.0000 - 3.0000i  -1.0000 - 3.0000i   1.0000 - 3.0000i   3.0000 - 3.0000i];

    %Создаем матрицу для S_0 и S_1 каждого бита
    S = zeros(4, 2, 8); %строка - номер бита % столбец - S_0 или S_1
    %глубина - соответствующие элементы созвездия
    %1 бит
    con = (constellation(:,1:2));
    S(1, 1, :) = con(:);
    con = (constellation(:,3:4));
    S(1, 2, :) = con(:);
    %2 бит
    con =  [constellation(:,1) constellation(:,4)] ;
    S(2, 1, :) = con(:);
    con = (constellation(:,2:3));
    S(2,2,:) = con(:);
    %3 бит
    con = constellation(1:2,:);
    S(3,1,:) = con(:);
    con = constellation(3:4,:);
    S(3,2,:) = con(:);
    %4 бит
    con = [constellation(1,:) constellation(4,:)];
    S(4,1,:) = con(:);
    con = constellation(2:3,:);
    S(4,2,:) = con(:); 


    %Для каждого символа
    for k = 1:1:l_s
        current_symb = symbols(k);
        %Для каждого бита символа
        for i = 1:1:4
        d_0 = min(abs(S(i,1,:) - current_symb)).^2 ;
        d_1 = min(abs(S(i,2,:) - current_symb)).^2 ;
        
        LLRs(i,k) = - (1/disp)*(d_0 - d_1);

        end
    end
end
