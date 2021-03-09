% Example for a 50Hz hum frequency
Fs = 1000;            % Sampling frequency                    
T = 1/Fs;             % Sampling period       
L = 1500;             % Length of signal
t = (0:L-1)*T;        % Time vector

S = 0.7*sin(2*pi*50*t) ;

X = S + 2*randn(size(t));

Y = fft(X);

P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);

f = Fs*(0:(L/2))/L;

fftFigure = figure();
plot(f,P1, 'LineWidth', 1.2);
axis([0 300 0 1]);
title('Amplitudenspektrum');
xlabel('f (Hz)');
ylabel('|X(f)|');
set(fftFigure,'units', 'centimeters', 'position', [10 10 15 7.5]);
set(gca,'LooseInset',get(gca,'TightInset'));
print(fftFigure, 'amplitudenspektrum.eps', '-depsc', '-r300');