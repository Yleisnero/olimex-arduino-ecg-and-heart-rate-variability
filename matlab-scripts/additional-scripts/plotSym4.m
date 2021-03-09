% Plot the sym4-wavelet
load mit200

qrsEx = ecgsig(4560:4810);
[mpdict,~,~,longs] = wmpdictionary(numel(qrsEx),'lstcpt',{{'sym4',3}});

sym4_fig = figure();
plot(2*circshift(mpdict(:,11),[-2 0]), 'LineWidth', 2)
title('Sym4 Wavelet')
axis([50 120 -0.15 0.9]);
%set(sym4_fig,'units','normalized', 'outerposition', [0 0 1 1]);
set(sym4_fig,'units', 'centimeters', 'position', [5 5 5 7.5]);

% Print to file
%set(gca,'LooseInset',get(gca,'TightInset'));
%print(sym4_fig, 'sym4-wavelet.pdf', '-dpdf', '-r300', '-bestfit');
%print(sym4_fig, 'sym4-wavelet.eps', '-depsc', '-r300');
%print(sym4_fig, 'sym4-wavelet.png', '-dpng', '-r300');