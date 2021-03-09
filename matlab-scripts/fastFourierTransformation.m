function fastFourierTransformation(inputData, samplingFrequency)
    % FFT Fast Fourier Transformation
    % Display frequencies using FFT
    
    Fs = samplingFrequency; % Sampling frequency
    T = 1/Fs;               % Sampling period
    L = length(inputData);  % Length of signal
    t = (0:L-1)*T;          % Time vector
    
    Y = fft(inputData);     % FFT
    P2 = abs(Y/L);          
    %P1 = P2(1:floor(L/2+1));
    P1 = P2(1:L/2+1);
    P1(2:end-1) = 2*P1(2:end-1);
    f = Fs*(0:(L/2))/L;
    fftFigure = figure();
    plot(f, P1);
    title('Amplitudenspektrum');
    xlabel('Frequenz f in Hz');
    ylabel('|X(f)|');
    axis([0 60 -0.0005 0.01])
    set(fftFigure,'units', 'centimeters', 'position', [10 10 15 7.5]);
    set(gca,'LooseInset',get(gca,'TightInset'));
    
    % Print to file
    %h = gcf;
    %set(h,'PaperOrientation','landscape');
    %print(fftFigure, 'amplitudenspektrum.pdf', '-dpdf', '-r300', '-bestfit');
    %print(fftFigure, 'amplitudenspektrum.png', '-dpng', '-r300');
end

