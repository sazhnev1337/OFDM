function [scrambled_bits, afterall_register] = scrambler(bits, initial_register)
%  This is not a universal scrambler. 
%  This is an implementation of a specific framework. 
%  Somewhere in this project lies his scheme.
    if length(initial_register) ~=  15
        error("LENGTH OF initial_register MUST BE EQUALS TO 15");
    end

    N = length(bits);


    current_reg = logical(initial_register);
    scrambled_bits = zeros(N, 1, "logical");

    for i = 1:N
        % Refresh register's value
        newborn = xor(current_reg(end), current_reg(end-1));   
        % Work with arrays as a vectors                                     
        current_reg = [newborn, current_reg(1:14).'].';

        % Scramble each bit
        scrambled_bits(i) = xor(newborn, logical(bits(i)));

    end

    afterall_register = current_reg;
end
    