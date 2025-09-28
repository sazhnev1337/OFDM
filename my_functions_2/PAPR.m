function papr_dB = PAPR(x)
%   PAPR is calculated based on the maximum instantaneous power divided by 
%   the average power of the signal.

%   If x is a matrix, function will calculate PAPR of each column, and return STRING
    instantaneous_power = abs(x) .^ 2;
    
    peak_power = max(instantaneous_power);
    
    average_power = mean(instantaneous_power);
    
    PAPR_ratio = peak_power ./ average_power;
    
    papr_dB = 10 * log10(PAPR_ratio);
end