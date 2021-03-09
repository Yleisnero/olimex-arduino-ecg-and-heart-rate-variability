import readData.m.*
import fastFourierTransformation.m.*
import iirNotchFilter.m.*
import heartRateVariability.m.*

% Close all figures
close all;

% Read data from text files
filename1 = 'subject0_einthoven1';
filename2 = 'subject0_einthoven2';
filename3 = 'subject0_einthoven3';
extension = '.txt';
data = readData(strcat(filename1, extension));
data2 = readData(strcat(filename2, extension));
data3 = readData(strcat(filename3, extension));

% Select time-values and ecg-values seperately
time = data(:,1);
ecgValues = data(:,2);
time2 = data2(:,1);
ecgValues2 = data2(:,2);
time3 = data3(:,1);
ecgValues3 = data3(:,2);

% FFT
%fastFourierTransformation(ecgValues, 256);

% Remove 50Hz & 100Hz noise
%filteredData = cascadeIIRNotchFilter(50, 100, 45, 35, 256, ecgValues);
%fastFourierTransformation(filteredData, 256);

% IIR Notch Filter for filtering 50Hz
filteredData = iirNotchFilter(50, 256, 35, ecgValues);
filteredData2 = iirNotchFilter(50, 256, 35, ecgValues2);
filteredData3 = iirNotchFilter(50, 256, 35, ecgValues3);
%fastFourierTransformation(filteredData, 256);

% Wavelet-Transformation with sym4-wavelet
wt = modwt(filteredData,5);    % Maximal overlap discrete wavelet transform

% Plot all different modwt signals
%trans_wt = wt';
%plotModwt(trans_wt, time);

% Wavelet-sythesis with a inverse maximal overlap discrete wavelet transform
wtrec = zeros(size(wt));    % Create array of all zeros
wtrec(4:5,:) = wt(4:5,:);   % Use level 4 & level 5
inversemow = imodwt(wtrec,'sym4');

% Plot ecg signal with only scales 4 & 5 (5.625hZ - 22.5Hz)
%plotImodwt(time, inversemow);

% Squared absolute values
inversemow = inversemow.^2;

% Find local maxima
% !!! SOMETIMES the MinPeakHeight NEEDS TO BE ADJUSTED !!!
% For example if the 50 & 100Hz cascade filter is used
[qrspeaks,locs] = findpeaks(inversemow,time,'MinPeakHeight', 0.001, ...
    'MinPeakDistance', 0.4);

% Plot detected R-Peaks
%plotRPeaks(time, inversemow, locs, qrspeaks);

% R-Peaks to File
%rPeaksToFile(locs);

% Heart Rate Variability
% Also returns the hrv values based on all detected r-peaks (hrvOld)
% hrv does not include the first and the last r-peak
[hrv, hrvOld] = heartRateVariability(locs);

% Round to 2 decimal digits
hrvRound = round(hrv*100) / 100;

% SDNN HRV (standard deviation)
%SDNN(hrv);
%SDNN(hrvRound);

% RMSSD HRV
%RMSSD(hrv);
%RMSSD(hrvRound);

% STRESS INDEX HRV
%stressIndex(hrvRound);

% BAR HRV
barPlot(hrv);
%TwoBarPlot(hrv, hrvOld);

% HISTOGRAM HRV
%histogramPlot(hrv);
%TwoHistogramPlot(hrv, hrvOld);

% SCATTER HRV
%scatterPlot(hrv);

% HISTOGRAM + SCATTER
%multipleHrvPlots(hrv);

% Raw ECG vs filtered ECG signal
%plotEcgFiltUnfilt(time, ecgValues, filteredData);

% ECG
plotEcg(time, filteredData, 'ECG');
%plotEcg(time2, filteredData2, '');
%plotEcg(time3, filteredData3, 'Einthoven III');
%plotMultEcgs(filteredData, filteredData2, filteredData3, time, time2, time3);

%plotEcgAndRPeaks(filteredData, time, inversemow, locs, qrspeaks);

function plotRPeaks(time, imodwtrec, locs, qrspeaks)
    rpeak_fig = figure();
    plot(time,imodwtrec, 'LineWidth', 1.2)
    hold on
    plot(locs,qrspeaks,'ro', 'LineWidth', 1.2)
    xlabel('Zeit in Sekunden')
    title('Automatisch detektierte R-Zacken')
    axis([58.5 60.5 0 0.03])
    set(rpeak_fig,'units', 'centimeters', 'position', [10 10 15 7.5]);
    
    % Specify a custom update function to your data cursor object
    % To get more decimal places
    dcm = datacursormode(gcf);
    set(dcm, 'UpdateFcn', @customDataCursorUpdateFcn, 'Enable', 'Off'); 
    % Here's the function that specifies 6 decimal places 
    function txt = customDataCursorUpdateFcn(~, event)
        pos = event.Position;
        txt = {sprintf('X: %.6f', pos(1)), sprintf('Y: %.6f', pos(2))};
    end

    % Print to file
    %set(gca,'LooseInset',get(gca,'TightInset'));
    %print(rpeak_fig, 'rpeaks-at-end.eps', '-depsc', '-r300');
end

function rPeaksToFile(locs)
    fileID = fopen('r-peaks.txt','w');
    formatSpec = '%f\n';
    fprintf(fileID, formatSpec, locs);
    fclose(fileID);
end

function SDNN (hrvValues)    
    sdnn = std(hrvValues);
    disp('SDNN');
    sdnn = sdnn * 1000;
    disp(strcat(string(sdnn),' ms'));
end

function RMSSD(hrvValues)
    sum_hrv = 0;
    for i = 1:length(hrvValues) - 1
        sum_hrv = sum_hrv + ((hrvValues(i+1) - hrvValues(i))^2);
    end
    rmssd = sqrt((1/(length(hrvValues)-1)) * sum_hrv);
    rmssd = rmssd * 1000;
    disp('RMSSD:');
    disp(strcat(string(rmssd),' ms'));
end

function stressIndex (hrvValues)
    % Stress Index
    min_hrv = min(hrvValues);
    max_hrv = max(hrvValues);
    [M, F] = mode(hrvValues);
    SI = ((F/length(hrvValues)) * 100) / (2 * M * (max_hrv - min_hrv));
    disp('SI');
    disp(string(SI));
end

function plotModwt(mod_wt, time)
    modwt_fig = figure();
    for i = 1:5
        subplot(5,1,i);
        plot(time, mod_wt(:,i), 'LineWidth', 1.2);
        title(sprintf('Level %d', i));
        if i == 1
            axis([30 36 -0.025 0.025])
            xlabel('Zeit in Sekunden')
        elseif i == 2
            axis([30 36 -0.08 0.08])
            xlabel('Zeit in Sekunden')
        elseif i == 3
            axis([30 36 -0.18 0.12])
            xlabel('Zeit in Sekunden')
        elseif i == 4
            axis([30 36 -0.18 0.15])
            xlabel('Zeit in Sekunden')
        elseif i == 5
            axis([30 36 -0.18 0.15])
            xlabel('Zeit in Sekunden')
        end
    end
    
    set(modwt_fig,'units', 'centimeters', 'position', [0 0 32  18]);
    %set(modwt_fig,'units', 'normalized', 'outerposition', [0 0 1 1]);
    
    % Print to file
    %set(gca,'LooseInset',get(gca,'TightInset'));
    %print(modwt_fig, 'modwt.png', '-dpng', '-r300');
    
    % Print to PDF
    %h = gcf;
    %set(h,'PaperOrientation','landscape');
    %print(modwt_fig, 'modwt.pdf', '-dpdf', '-r300', '-bestfit');
end

function plotImodwt(time, inversemodwt)
    imodwt_fig = figure();  
    plot(time,inversemodwt, 'LineWidth', 1.2);
    axis([30 36 -0.2 0.3])
    xlabel('Zeit in Sekunden')
    set(imodwt_fig,'units', 'centimeters', 'position', [10 10 18 5]);
    
    % Print to file
    %set(gca,'LooseInset',get(gca,'TightInset'));
    %print(imodwt_fig, 'imodwt.eps', '-depsc', '-r300');
    %print(imodwt_fig, 'imodwt.png', '-dpng', '-r300');
end

function barPlot(hrvValues)
    hrv_fig = figure();
    bar(hrvValues);
    axis([0 90 0 1.2]);
    title('heart rate variability');
    ylabel('RR-Intervalle in Sekunden');
    set(hrv_fig,'units','centimeters', 'position', [10 10 15 5]);
    
    % Print to file
    %set(gca,'LooseInset',get(gca,'TightInset'));
    %print(hrv_fig, 'barplot_p1.png', '-dpng', '-r300');
    %print(hrv_fig, 'hrv_balken_proband3.eps', '-depsc', '-r300');
end

function TwoBarPlot(hrvValues, hrvValues2)
    hrv_fig = figure();
    subplot(1,2,1);
    bar(hrvValues);
    axis([0 52 0 1.5]);
    title('heart rate variability');
    ylabel('RR-Intervalle in Sekunden');
    
    subplot(1,2,2);
    bar(hrvValues2);
    axis([0 54 0 1.5]);
    title('heart rate variability');
    ylabel('RR-Intervalle in Sekunden');
    
    set(hrv_fig,'units','centimeters', 'position', [10 10 20 5]);
    
    % Print to file
    %set(gca,'LooseInset',get(gca,'TightInset'));
    %print(hrv_fig, 'two-hrv-bars.eps', '-depsc', '-r300');
end

function histogramPlot(hrvValues)
    hist_fig = figure();
    histogram(hrvValues,'Normalization','probability','BinWidth',0.05)
    ylabel('Häufigkeit');
    xlabel('Zeitdifferenz in Sekunden');
    set(hist_fig,'units','centimeters', 'position', [10 10 15 7.5]);
    
    % Print to file
    %set(gca,'LooseInset',get(gca,'TightInset'));
    %print(hist_fig, 'hrv_histogramm.eps', '-depsc', '-r300');
end

function TwoHistogramPlot(hrvValues, hrvValues2)
    hist_fig = figure();
    subplot(1,2,1);
    histogram(hrvValues,'Normalization','probability','BinWidth',0.05)
    ylabel('Häufigkeit');
    xlabel('Zeitdifferenz in Sekunden');
    
    subplot(1,2,2);
    histogram(hrvValues2,'Normalization','probability','BinWidth',0.05)
    ylabel('Häufigkeit');
    xlabel('Zeitdifferenz in Sekunden');
    
    set(hist_fig,'units','centimeters', 'position', [10 10 15 7.5]);
    
    % Print to file
    %set(gca,'LooseInset',get(gca,'TightInset'));
    %print(hist_fig, 'hrv_histogramm.eps', '-depsc', '-r300');
end

function scatterPlot(hrvValues)
    scatter_x = zeros(int8(length(hrvValues) / 2) + 1,1);
    scatter_y = zeros(int8(length(hrvValues) / 2) + 1,1);
    pos = 1;
    for i = 1:(length(hrvValues)/2)-1 
        scatter_x(i) = hrvValues(pos);
        scatter_y(i) = hrvValues(pos + 1);
        pos = pos + 2;
    end
    scatter_fig = figure();
    scatter(scatter_x, scatter_y);
    axis([0.8 1.4 0.6 1.6]);
    ylabel('Zeitdifferenz 2 in Sekunden');
    xlabel('Zeitdifferenz 1 in Sekunden');
    set(scatter_fig,'units','centimeters', 'position', [10 10 15 7.5]);
    
    % Print to file
    %set(gca,'LooseInset',get(gca,'TightInset'));
    %print(scatter_fig, 'hrv_streudiagramm.eps', '-depsc', '-r300');
end

function multipleHrvPlots(hrvValues)
    hrv_fig = figure();
    %subplot(2,2,1)
    %bar(hrvValues);
    %axis([0 65 0 1.3]);
    %title('Balkendiagramm');
    %ylabel('RR-Intervalle in Sekunden');
    
    subplot(1,2,1)
    histogram(hrvValues,'Normalization','probability','BinWidth',0.05)
    axis([0.8 1.3 0 0.8]);
    title('Histogramm');
    
    scatter_x = zeros(int8(length(hrvValues) / 2) + 1,1);
    scatter_y = zeros(int8(length(hrvValues) / 2) + 1,1);
    pos = 1;
    for i = 1:(length(hrvValues)/2)-1 
        scatter_x(i) = hrvValues(pos);
        scatter_y(i) = hrvValues(pos + 1);
        pos = pos + 2;
    end

    subplot(1,2,2)
    scatter(scatter_x, scatter_y);
    axis([0.8 1.3 0.6 1.6]);
    title('Streudiagramm');
    
    set(hrv_fig,'units','centimeters', 'position', [10 10 18 7.5]);
    
    % Print to file
    %set(gca,'LooseInset',get(gca,'TightInset'));
    %print(hrv_fig, 'two_hrv_plots.png', '-dpng', '-r300');
    %print(hrv_fig, 'multiple_hrv_plots_proband4.eps', '-depsc', '-r300');
end

function plotEcgFiltUnfilt(time, ecgValues, filteredValues)
    ecg_fig = figure();
    plot(time,ecgValues, 'LineWidth', 1.2);
    hold on
    plot(time,filteredValues,'LineWidth', 1.2);
    axis([32.5 34.5 0.45 1.15])
    title('Noisy ECG vs Filtered ECG');
    xlabel('Zeit in Sekunden');
    ylabel('Spannung in Millivolt');
    legend('ungefiltert','gefiltert');
    
    set(ecg_fig,'units','centimeters', 'position', [10 10 18 7.5]);
    
    % Print to file
    %set(gca,'LooseInset',get(gca,'TightInset'));
    %print(ecg_fig, 'filtered-vs-unfiltered.png', '-dpng', '-r300');
end

function plotEcg(time, ecgValues, tit)
    ecg_fig = figure();
    plot(time, ecgValues, 'LineWidth', 1.2);
    axis([18 24 0.4 1])
    title(tit);
    xlabel('Zeit in Sekunden');
    ylabel('Spannung in Millivolt');
    set(ecg_fig,'units','centimeters', 'position', [10 10 18 5]);
    set(gca,'LooseInset',get(gca,'TightInset'));
    
    % Specify a custom update function to your data cursor object
    % To get more decimal places
    dcm = datacursormode(gcf); 
    set(dcm, 'UpdateFcn', @customDataCursorUpdateFcn, 'Enable', 'Off'); 
    % Here's the function that specifies 6 decimal places 
    function txt = customDataCursorUpdateFcn(~, event)
        pos = event.Position;
        txt = {sprintf('X: %.6f', pos(1)), sprintf('Y: %.6f', pos(2))};
    end
    
    h = gcf;
    set(h,'PaperOrientation','landscape');
    %print(ecg_fig, 'einthovenIII.pdf', '-dpdf', '-r300', '-bestfit');
    %print(ecg_fig, 'gehen_proband0.png', '-dpng', '-r300');
    %print(ecg_fig, 'proband0_einthoven1.eps', '-depsc', '-r300');
end

function plotMultEcgs(filteredData, filteredData2, filteredData3, time, time2, time3)
    mult_ecg_fig = figure();
    subplot(3,1,1);
        plot(time, filteredData, 'LineWidth', 1.2);
        axis([30 36 0.2 1])
        title('Einthoven I');
        xlabel('Zeit in Sekunden');
        ylabel('Spannung in Millivolt');
    subplot(3,1,2);
        plot(time2, filteredData2, 'LineWidth', 1.2);
        axis([30 36 0.4 1.1])
        title('Einthoven II');
        xlabel('Zeit in Sekunden');
        ylabel('Spannung in Millivolt');
    subplot(3,1,3);
        plot(time3, filteredData3, 'LineWidth', 1.2);
        axis([30 36 0.4 1.2])
        title('Einthoven III');
        xlabel('Zeit in Sekunden');
        ylabel('Spannung in Millivolt');

    set(mult_ecg_fig,'units','centimeters', 'position', [5 0 30 16.875]);
    
    % Print to file
    set(gca,'LooseInset',get(gca,'TightInset'));
    %print(mult_ecg_fig, 'proband4_mult_ecg.eps', '-depsc', '-r300');
    %print(mult_ecg_fig, 'mult_ecg.png', '-dpng', '-r300'); 
    
    % Print to pdf
    %h = gcf;
    %set(h,'PaperOrientation','landscape');
    %print(mult_ecg_fig, 'proband0_I-III.pdf', '-dpdf', '-r300', '-bestfit');
end

function plotEcgAndRPeaks(ecgValues, time, imodwtrec, locs, qrspeaks)
    ecg_r_fig = figure();
    subplot(2,1,1);
    plot(time, ecgValues, 'LineWidth', 1.2);
    axis([21 24 0.4 1])
    xlabel('Zeit in Sekunden');
    ylabel('Spannung in Millivolt');
    
    subplot(2,1,2);
    plot(time,imodwtrec, 'LineWidth', 1.2)
    hold on
    plot(locs,qrspeaks,'ro', 'LineWidth', 1.2)
    xlabel('Zeit in Sekunden')
    axis([21 24 0 0.035])
    
    % Specify a custom update function to your data cursor object
    % To get more decimal places
    dcm = datacursormode(gcf); 
    set(dcm, 'UpdateFcn', @customDataCursorUpdateFcn, 'Enable', 'Off'); 
    % Here's the function that specifies 6 decimal places 
    function txt = customDataCursorUpdateFcn(~, event)
        pos = event.Position;
        txt = {sprintf('X: %.6f', pos(1)), sprintf('Y: %.6f', pos(2))};
    end
    
    set(ecg_r_fig,'units', 'centimeters', 'position', [10 10 18 10]);
    
    % Print to pdf
    %set(gca,'LooseInset',get(gca,'TightInset'));
    %print(ecg_r_fig, 'ecg-r-peak.eps', '-depsc', '-r300'); 
end