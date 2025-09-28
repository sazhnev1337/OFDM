function [bits, afterall_register] = descrambler(scrambled_bits, initial_register)

    if length(initial_register) ~=  15
        error("LENGTH OF initial_register MUST BE EQUALS TO 15");
    end

    N = length(scrambled_bits);

    bits = zeros(N, 1, "logical");

    current_reg = logical(initial_register);

    for i = 1:N
        % Refresh register's value
        newborn = xor(current_reg(end), current_reg(end-1));   
        current_reg = [newborn, current_reg(1:14).'].';

        % Scramble each bit
        bits(i) = xor(newborn, logical(scrambled_bits(i)));
    end
    afterall_register = current_reg;
end