function essnr_dB=ssnr(speech, outfile,len)
% SSNR_DB compute segmental signal-to-noise ratio (in decibels) for an
%         utterance
% Input:
%   speech                'filename.wav'
%   modified_speech       'filename.wav'
%   len                   frame length
% Output:
%   ssnr_dB   segmental signal-to-noise ratio value
[tp, FS]=audioread(speech);
x = tp/sqrt(mean2( tp.^2));


[tp, FS]=audioread(outfile);
xh = tp/sqrt(mean2( tp.^2));
%x = speech;
%xh = outfile;
%y = noisy;

xf = enframe(x,len);
xhf = enframe(xh,len);
%yf = enframe(y,len);
esnr_dB = snr4ssnr(xf,xhf); % enhanced SNR
essnr_dB = mean(esnr_dB);
%ysnr_dB = ysnr(xf,xhf,yf); % noisy SNR
%yssnr_dB = mean(ysnr_dB);
%ssnr_dB=essnr_dB-yssnr_dB; % SSNRI
% ssnr_dB=10*log10(sum(x.^2)/sum((x-xh).^2)); % SNR
end
