function filteredData = iirNotchFilter(filterFrequency,samplingFrequency, qFactor, data)
    % Design IIR Notch Filter to remove humming from a signal
    wo = filterFrequency/(samplingFrequency/2);
    bw = wo/qFactor;
    [b,a] = iirnotch(wo, bw, qFactor);
    
    % Print to file
    %[h,w] = freqz(b,a,'whole',2001);
    %iirnotch_fig = figure();
    %plot(128* (w/pi),20*log10(abs(h)), 'LineWidth', 1.5)
    %axis([0 100 -70 5])
    %xlabel('Frequenz (Hz)')
    %ylabel('Verstärkung (dB)')
    %set(iirnotch_fig,'units', 'centimeters', 'position', [10 10 15 10]);
    %set(gca,'LooseInset',get(gca,'TightInset'));
    %print(iirnotch_fig, 'iir-notch-filter.eps', '-depsc', '-r300');
    
    filteredData = filter(b, a, data);
end

