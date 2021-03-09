% Test R-Peak Detection
load mit200
figure
plot(tm,ecgsig)
hold on
plot(tm(ann),ecgsig(ann),'ro')
xlabel('Seconds')
ylabel('Amplitude')
title('Subject - MIT-BIH 200')

qrsEx = ecgsig(4560:4810);
[mpdict,~,~,longs] = wmpdictionary(numel(qrsEx),'lstcpt',{{'sym4',3}});
figure
plot(qrsEx)
hold on
plot(2*circshift(mpdict(:,11),[-2 0]),'r')
axis tight
legend('QRS Complex','Sym4 Wavelet')
title('Comparison of Sym4 Wavelet and QRS Complex')

wt = modwt(ecgsig,5);       % Maximal overlap discrete wavelet transform
wtrec = zeros(size(wt));    % Create array of all zeros
wtrec(4:5,:) = wt(4:5,:);   
y = imodwt(wtrec,'sym4');   % Inverse maximal overlap discrete wavelet transform

figure();
plot(tm,y);
title('inverse modwt');

y = abs(y).^2;
[qrspeaks,locs] = findpeaks(y,tm,'MinPeakHeight',0.1,...    % Find local maxima
    'MinPeakDistance',0.150);
figure
plot(tm,y)
title('R-Waves Localized by Wavelet Transform')
hold on
hwav = plot(locs,qrspeaks,'ro');
hexp = plot(tm(ann),y(ann),'k*');
xlabel('Seconds')
legend([hwav hexp],'Automatic','Expert','Location','NorthEast');