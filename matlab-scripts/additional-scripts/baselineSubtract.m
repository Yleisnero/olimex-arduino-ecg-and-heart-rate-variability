% not working for ecg signals
clc;    % Clear the command window.
close all;  % Close all figures (except those of imtool.)
clear;  % Erase all existing variables. Or clearvars if you want.
workspace;  % Make sure the workspace panel is showing.
format long g;
format compact;
fontSize = 24;
% Create some data
x = 900:1400;
period = 500;
y=100*cos(2*pi*(x-950)/period) + 1200;
% Add noise
y = y + 120 * rand(1, length(y));
% Put in big spikes at x=1050 and 1210
y(150) = 1600;
y(310) = 1600;

% Now plot it.
plot(x, y, 'b-');
ylim([-200,1800]);
grid on;
xlabel('X', 'FontSize', fontSize);
ylabel('Y', 'FontSize', fontSize);
% Put a thick black line along the x axis
line([x(1), x(end)], [0, 0], 'LineWidth', 3, 'Color', 'k');
% Enlarge figure to full screen.
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
% Give a name to the title bar.
set(gcf, 'Name', 'Demo by ImageAnalyst', 'NumberTitle', 'Off') 
% Now smooth with a Savitzky-Golay sliding polynomial filter
windowWidth = 101
polynomialOrder = 3
baselineY = sgolayfilt(y, polynomialOrder, windowWidth);
hold on;
plot(x, baselineY, 'r-', 'LineWidth', 2);
title('Signal Smoothed by Savitzky-Golay Filter', 'FontSize', fontSize);
% Now subtract the baseline from the original data
detrendedY = y - baselineY;
% Now plot it.
plot(x, detrendedY, 'b-');