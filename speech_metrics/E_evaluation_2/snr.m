function esnr_dB = snr(speech,outfile)
% SNR_DB compute signal-to-noise ratio (in decibels) for an utterance
% Input:
%   x       clean speech (one per row)
%   xh      modified speech (one per row)
% Output:
%   snr_dB  signal-to-noise ratio value

% e=x(1:length(xh),:)-xh(1:length(xh),:);

[tp, FS]=audioread(speech);
x = tp/sqrt(mean2( tp.^2));
%x = tp

[tp, FS]=audioread(outfile);
xh = tp/sqrt(mean2( tp.^2));
%xh = tp

e=x(1:size(xh),:)-xh(1:size(xh),:);
% a=sum(x(1:length(xh),:).*x(1:length(xh),:),2);
a=sum(x(1:size(xh),:).*x(1:size(xh),:),2);
b=sum(e.*e,2);
for i=1:size(xh)    %i=1:length(xh)
    if b(i) == 0
        b(i) = eps;
    end
end
esnr = a./b;
for i=1:size(xh)  %i=1:length(xh)
    if esnr(i) == 0
        esnr(i) = eps;
    end
end
esnr_dB = mean(10*log10(esnr));
disp(esnr_dB)
