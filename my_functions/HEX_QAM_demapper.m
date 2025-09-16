%16QAM_DEMAPPER
function bits = HEX_QAM_demapper(symbols)
    
    %Обратная нормироква
    n = 3.162277660168380;
    symbols = symbols .* n; 

    %Распределение для жесткого демаппера
% Распределение точек для жесткого демаппера
    for i = 1:length(symbols)
        if real(symbols(i)) > 0
            if imag(symbols(i)) > 0    % 1 квадрант           
                    if imag(symbols(i)) > 2
                            if real(symbols(i)) > 2
                                symbols(i) = 3 + 1j * 3;
                            else
                                symbols(i) = 1 + 1j * 3;
                            end
                    else
                            if real(symbols(i)) > 2
                                symbols(i) = 3 + 1j * 1;
                            else
                                symbols(i) = 1 + 1j * 1;
                            end
                    end
                %4 квадрант
            else
                    if abs(imag(symbols(i))) > 2
                        if abs(real(symbols(i))) > 2
                            symbols(i) = 3 - 1j * 3;
                        else
                            symbols(i) = 1 - 1j * 3;
                        end
                    else
                        if abs(real(symbols(i))) > 2
                            symbols(i) = 3 - 1j * 1;
                        else
                            symbols(i) = 1 - 1j * 1;
                        end
                    end
            end
        else
            
            if imag(symbols(i)) > 0     %2 квадрант
                    if abs(imag(symbols(i))) > 2
                            if abs(real(symbols(i))) > 2
                                symbols(i) = -3 + 1j * 3;
                            else
                                symbols(i) = -1 + 1j * 3;
                            end
                    else
                            if abs(real(symbols(i))) > 2
                                symbols(i) = -3 + 1j * 1;
                            else
                                symbols(i) = -1 + 1j * 1;
                            end
                    end
            else                        %3 квадрант  
                    if abs(imag(symbols(i))) > 2
                            if abs(real(symbols(i))) > 2
                                symbols(i) = -3 - 1j * 3;
                            else
                                symbols(i) = -1 - 1j * 3;
                            end
                    else
                            if abs(real(symbols(i))) > 2
                                symbols(i) = -3 - 1j * 1;
                            else
                                symbols(i) = -1 - 1j * 1;
                            end
                    end
            end
        end
    end



    I = real(symbols);
    Q = imag(symbols);

    [strings, Size] = (size(symbols)); % Размер массива
       
    abs_I = abs(I);
    sign_I = sign(I);
    abs_Q = abs(Q);
    sign_Q = sign(Q);

    I = zeros(1, Size*2);
    Q = zeros(1, Size*2);


    Q(1:2:end) = (sign_Q*(-1) + 1)/2;
    Q(2:2:end) = ((abs_Q) - 1)/2;
    
    I(1:2:end) = (sign_I + 1)/2;
    I(2:2:end) = (abs_I - 1)/2;

    bits = zeros(1, Size*4);

    bits(1:4:end) = I(1:2:end);
    bits(2:4:end) = I(2:2:end);
    
    bits(3:4:end) = Q(1:2:end);
    bits(4:4:end) = Q(2:2:end);
end