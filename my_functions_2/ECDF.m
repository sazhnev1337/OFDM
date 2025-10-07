function [F, x] = ECDF(data)
    
    % Calculation of Emperical cumulativr density function

    % Remove 'NaN' data
    data = data(~isnan(data)); 
    
    
    sorted_data = sort(data);
    n = length(sorted_data);     
    [unique_x, ~, ic] = unique(sorted_data, 'stable'); % 'stable' maintain sequence
    % unique_x - is a list of unique values from sorted_data. Ex.: [1, 9, 9, 13] -> [1, 9, 13]
    % ic - indexes of elements from sorted_data. Ex.: [1, 2, 2, 3]

    counts = accumarray(ic, 1);
    % Ex.: [1, 2, 1]
    
    cumulative_counts = cumsum(counts);
    % Ex.: [1, 3, 4]
    
    F_unique = cumulative_counts / n;

    
    x = [unique_x(1); unique_x];
    F = [0; F_unique];

end
