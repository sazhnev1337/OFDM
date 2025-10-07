function x_scaled = scaleSignalToPower(x, target_power_dBm)
% SCALESIGNALTOPOWER scaled signal to the target power in dBm.
%
%   Inputs:
%       x - source complex or real signal.
%       target_power_dBm - Целевая средняя мощность в dBm.
%
%   Output:
%       x_scaled - scaled signal

    % 1. Convertation of target power from dBm to watts (linear scale)
    % P_watts = 10^((P_dBm - 30) / 10)
    target_power_watts = 10.^((target_power_dBm - 30) / 10);
    
    % 2. Calculation of current power
    current_power_watts = mean(abs(x) .^ 2);
    
    % Avoiding zero dividing
    if current_power_watts == 0
        warning('Source signals power equals to zero!');
        x_scaled = x;
        return;
    end
    
    % 3. Scaling coefficient 
    % Scale Factor = sqrt(Target Power / Current Power)
    scale_factor = sqrt(target_power_watts / current_power_watts);
    
    % 4. Scaling
    x_scaled = x * scale_factor;
end
