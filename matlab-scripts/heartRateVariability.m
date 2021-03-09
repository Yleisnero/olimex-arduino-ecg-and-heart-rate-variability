function [hrv, hrvOld] = heartRateVariability(rPeakLocations)
    % Calculte HRV by using the locations of the r peaks

    % Remove first and last R-Peak from the calculation
    hrv = zeros(length(rPeakLocations) - 3,1);
    for i = 2:length(rPeakLocations) - 2
       hrvValue = rPeakLocations(i + 1) - rPeakLocations(i);
       hrv(i - 1) = hrvValue;
    end
    
    hrvOld = zeros(length(rPeakLocations) - 1,1);
    for i = 1:length(rPeakLocations) - 1
       hrvValue = rPeakLocations(i + 1) - rPeakLocations(i);
       hrvOld(i) = hrvValue;
    end
end

